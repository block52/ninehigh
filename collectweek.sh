#!/usr/bin/env bash
#
# Collects merged PRs, commits and release tags across the three Block 52 repos
# for the previous Monday-to-Sunday week (Australia/Brisbane), and writes a
# JSON digest to week-data.json.
#
# Requires: gh (authenticated via GH_TOKEN), jq.
# Sets GitHub Actions outputs: window_start, window_end, window_label,
# article_date, pr_total, should_write.

set -euo pipefail

TZ_LOCAL="Australia/Brisbane"
REPOS=("block52/ui" "block52/pvm" "block52/pokerchain")
# Display names used in the article — keep in step with REPOS above.
declare -A REPO_LABEL=(
  ["block52/ui"]="UI"
  ["block52/pvm"]="PVM"
  ["block52/pokerchain"]="Chain"
)
declare -A REPO_BLURB=(
  ["block52/ui"]="the client"
  ["block52/pvm"]="the Poker Virtual Machine"
  ["block52/pokerchain"]="the settlement chain"
)

# Minimum merged PRs across all three repos before an article is worth writing.
THRESHOLD="${PR_THRESHOLD:-5}"

# ---------------------------------------------------------------------------
# 1. Work out the window: previous Mon 00:00 -> Mon 00:00 (exclusive), Brisbane
# ---------------------------------------------------------------------------
today=$(TZ="$TZ_LOCAL" date +%Y-%m-%d)
dow=$(TZ="$TZ_LOCAL" date +%u)                       # 1 = Monday
start_date=$(TZ="$TZ_LOCAL" date -d "$today -$((dow - 1)) days -7 days" +%Y-%m-%d)
end_date=$(TZ="$TZ_LOCAL" date -d "$start_date +7 days" +%Y-%m-%d)
last_day=$(TZ="$TZ_LOCAL" date -d "$end_date -1 day" +%Y-%m-%d)

START="${start_date}T00:00:00+10:00"
END="${end_date}T00:00:00+10:00"
LABEL="$(TZ="$TZ_LOCAL" date -d "$start_date" '+%-d %B') to $(TZ="$TZ_LOCAL" date -d "$last_day" '+%-d %B %Y')"
ARTICLE_DATE="$today"

echo "Window: $START -> $END  ($LABEL)"

# ---------------------------------------------------------------------------
# 2. Pull the data
# ---------------------------------------------------------------------------
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

for repo in "${REPOS[@]}"; do
  safe="${repo//\//_}"
  echo "--- $repo"

  # Merged PRs, with line counts.
  if ! gh pr list --repo "$repo" \
        --state merged --limit 300 \
        --search "merged:${START}..${END}" \
        --json number,title,url,mergedAt,additions,deletions,changedFiles,author,labels \
        > "$tmp/${safe}.prs.json" 2>"$tmp/${safe}.prs.err"; then
    echo "::error::Could not read pull requests from $repo. $(cat "$tmp/${safe}.prs.err")"
    echo "::error::Check that BLOCK52_TOKEN has read access to $repo."
    exit 1
  fi

  # Commits on the default branch. The messages are where the story lives.
  gh api "repos/${repo}/commits" \
      -X GET -f "since=${START}" -f "until=${END}" --paginate \
      --jq '[.[] | {sha: .sha[0:7], message: .commit.message, author: .commit.author.name, date: .commit.author.date}]' \
      > "$tmp/${safe}.commits.json" 2>/dev/null \
    || echo '[]' > "$tmp/${safe}.commits.json"
  # --paginate emits one array per page; flatten them.
  jq -s 'add // []' "$tmp/${safe}.commits.json" > "$tmp/${safe}.commits.flat.json"

  # Releases cut during the window (tolerated if the repo publishes none).
  gh release list --repo "$repo" --limit 30 --json tagName,publishedAt \
      --jq "[.[] | select(.publishedAt >= \"$START\" and .publishedAt < \"$END\")]" \
      > "$tmp/${safe}.releases.json" 2>/dev/null \
    || echo '[]' > "$tmp/${safe}.releases.json"

  echo "    merged PRs: $(jq 'length' "$tmp/${safe}.prs.json")"
  echo "    commits:    $(jq 'length' "$tmp/${safe}.commits.flat.json")"
done

# ---------------------------------------------------------------------------
# 3. Assemble one digest
# ---------------------------------------------------------------------------
{
  echo '{'
  printf '  "window": {"start": "%s", "end": "%s", "label": "%s", "article_date": "%s"},\n' \
    "$START" "$END" "$LABEL" "$ARTICLE_DATE"
  echo '  "repos": ['
  first=1
  for repo in "${REPOS[@]}"; do
    safe="${repo//\//_}"
    [ $first -eq 1 ] || echo ','
    first=0
    jq -n \
      --arg repo "$repo" \
      --arg label "${REPO_LABEL[$repo]}" \
      --arg blurb "${REPO_BLURB[$repo]}" \
      --slurpfile prs "$tmp/${safe}.prs.json" \
      --slurpfile commits "$tmp/${safe}.commits.flat.json" \
      --slurpfile releases "$tmp/${safe}.releases.json" \
      '{
         repo: $repo,
         label: $label,
         blurb: $blurb,
         merged_prs: ($prs[0] | length),
         additions: ($prs[0] | map(.additions) | add // 0),
         deletions: ($prs[0] | map(.deletions) | add // 0),
         files_changed: ($prs[0] | map(.changedFiles) | add // 0),
         commit_count: ($commits[0] | length),
         pull_requests: $prs[0],
         commits: ($commits[0] | map(.message |= ((. // "") | split("\n")[0]))),
         releases: $releases[0]
       }'
  done
  echo '  ]'
  echo '}'
} | jq '.' > week-data.json

TOTAL=$(jq '[.repos[].merged_prs] | add // 0' week-data.json)
ADDED=$(jq '[.repos[].additions] | add // 0' week-data.json)
REMOVED=$(jq '[.repos[].deletions] | add // 0' week-data.json)

echo "=== Total merged PRs: $TOTAL  (+$ADDED / -$REMOVED lines)"

SHOULD_WRITE=true
[ "$TOTAL" -lt "$THRESHOLD" ] && SHOULD_WRITE=false

{
  echo "window_start=$START"
  echo "window_end=$END"
  echo "window_label=$LABEL"
  echo "article_date=$ARTICLE_DATE"
  echo "pr_total=$TOTAL"
  echo "lines_added=$ADDED"
  echo "lines_removed=$REMOVED"
  echo "should_write=$SHOULD_WRITE"
} >> "${GITHUB_OUTPUT:-/dev/stdout}"

{
  echo "## Block 52 week: $LABEL"
  echo
  echo "| Repository | Merged PRs | Lines added | Lines removed |"
  echo "|---|---:|---:|---:|"
  jq -r '.repos[] | "| **\(.label)** | \(.merged_prs) | \(.additions) | \(.deletions) |"' week-data.json
  echo "| **Total** | **$TOTAL** | **$ADDED** | **$REMOVED** |"
  echo
  if [ "$SHOULD_WRITE" = "false" ]; then
    echo "_Below the threshold of $THRESHOLD merged PRs — no article this week._"
  fi
} >> "${GITHUB_STEP_SUMMARY:-/dev/stdout}"
