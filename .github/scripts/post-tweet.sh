#!/usr/bin/env bash
#
# Posts a single tweet via the X (Twitter) API v2 using OAuth 1.0a
# user-context signing. No external gems/packages — just bash, openssl and
# curl, all present on ubuntu-latest.
#
# Usage: post-tweet.sh "the tweet text"
#
# Requires these env vars (set them as repo secrets on the workflow):
#   X_API_KEY              consumer (app) key
#   X_API_SECRET           consumer (app) secret
#   X_ACCESS_TOKEN         access token for the posting account
#   X_ACCESS_TOKEN_SECRET  access token secret for the posting account
#
# The X app must have Read AND Write permissions, and the access token must
# have been generated AFTER write was enabled.

set -euo pipefail

TEXT="${1:?usage: post-tweet.sh \"tweet text\"}"

: "${X_API_KEY:?X_API_KEY is not set}"
: "${X_API_SECRET:?X_API_SECRET is not set}"
: "${X_ACCESS_TOKEN:?X_ACCESS_TOKEN is not set}"
: "${X_ACCESS_TOKEN_SECRET:?X_ACCESS_TOKEN_SECRET is not set}"

URL="https://api.twitter.com/2/tweets"
METHOD="POST"

# RFC 3986 percent-encoding — everything but the unreserved set is escaped.
rawurlencode() {
  local s="$1" out="" c i
  for (( i=0; i<${#s}; i++ )); do
    c="${s:i:1}"
    case "$c" in
      [a-zA-Z0-9.~_-]) out+="$c" ;;
      *) out+=$(printf '%%%02X' "'$c") ;;
    esac
  done
  printf '%s' "$out"
}

# A nonce and timestamp are required per request. Date.now equivalents are fine
# here — this runs live on the runner, not in a resumable workflow script.
NONCE=$(openssl rand -hex 16)
TIMESTAMP=$(date +%s)

# OAuth parameters (the request body is JSON, so it is NOT part of the
# signature base string for v2 — only the oauth_* params are).
declare -A OAUTH=(
  [oauth_consumer_key]="$X_API_KEY"
  [oauth_nonce]="$NONCE"
  [oauth_signature_method]="HMAC-SHA1"
  [oauth_timestamp]="$TIMESTAMP"
  [oauth_token]="$X_ACCESS_TOKEN"
  [oauth_version]="1.0"
)

# Build the parameter string: sorted by key, each key/value percent-encoded,
# joined with &.
PARAM_STRING=""
for key in $(printf '%s\n' "${!OAUTH[@]}" | sort); do
  ekey=$(rawurlencode "$key")
  eval_val="${OAUTH[$key]}"
  eval="$ekey=$(rawurlencode "$eval_val")"
  PARAM_STRING+="${PARAM_STRING:+&}$eval"
done

# Signature base string = METHOD & encoded(URL) & encoded(param string)
BASE_STRING="${METHOD}&$(rawurlencode "$URL")&$(rawurlencode "$PARAM_STRING")"

# Signing key = encoded(consumer secret) & encoded(token secret)
SIGNING_KEY="$(rawurlencode "$X_API_SECRET")&$(rawurlencode "$X_ACCESS_TOKEN_SECRET")"

SIGNATURE=$(printf '%s' "$BASE_STRING" \
  | openssl dgst -sha1 -hmac "$SIGNING_KEY" -binary \
  | openssl base64)

OAUTH[oauth_signature]="$SIGNATURE"

# Assemble the Authorization header.
HEADER="OAuth "
first=1
for key in $(printf '%s\n' "${!OAUTH[@]}" | sort); do
  [ $first -eq 1 ] || HEADER+=", "
  first=0
  HEADER+="$(rawurlencode "$key")=\"$(rawurlencode "${OAUTH[$key]}")\""
done

# JSON-encode the tweet body safely (handles quotes, newlines, unicode).
BODY=$(jq -n --arg text "$TEXT" '{text: $text}')

HTTP_CODE=$(curl -sS -o /tmp/x_response.json -w '%{http_code}' \
  -X POST "$URL" \
  -H "Authorization: $HEADER" \
  -H "Content-Type: application/json" \
  --data "$BODY")

echo "X API responded $HTTP_CODE"
cat /tmp/x_response.json

if [ "$HTTP_CODE" != "201" ] && [ "$HTTP_CODE" != "200" ]; then
  echo "::error::Tweet failed (HTTP $HTTP_CODE). See response above."
  exit 1
fi

TWEET_ID=$(jq -r '.data.id // empty' /tmp/x_response.json)
if [ -n "$TWEET_ID" ]; then
  echo "Posted: https://x.com/i/web/status/$TWEET_ID" >> "${GITHUB_STEP_SUMMARY:-/dev/stdout}"
fi
