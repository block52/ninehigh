#!/usr/bin/env bash
#
# Posts a link to a Facebook Page feed via the Graph API.
#
# Usage: post-facebook.sh "the message text" "https://the/link"
#
# Requires:
#   FB_PAGE_ID             numeric id of the Page to post to
#   FB_PAGE_ACCESS_TOKEN   a long-lived Page access token with
#                          pages_manage_posts (and pages_read_engagement)
#
# Facebook renders its own link preview from the URL's Open Graph tags, so the
# message is the commentary and the link carries the card (title, description,
# og:image). We pass both; we do not upload an image.

set -euo pipefail

MESSAGE="${1:?usage: post-facebook.sh \"message\" \"link\"}"
LINK="${2:?usage: post-facebook.sh \"message\" \"link\"}"

: "${FB_PAGE_ID:?FB_PAGE_ID is not set}"
: "${FB_PAGE_ACCESS_TOKEN:?FB_PAGE_ACCESS_TOKEN is not set}"

GRAPH_VERSION="v21.0"
URL="https://graph.facebook.com/${GRAPH_VERSION}/${FB_PAGE_ID}/feed"

HTTP_CODE=$(curl -sS -o /tmp/fb_response.json -w '%{http_code}' \
  -X POST "$URL" \
  --data-urlencode "message=${MESSAGE}" \
  --data-urlencode "link=${LINK}" \
  --data-urlencode "access_token=${FB_PAGE_ACCESS_TOKEN}")

echo "Graph API responded $HTTP_CODE"
cat /tmp/fb_response.json

if [ "$HTTP_CODE" != "200" ]; then
  echo "::error::Facebook post failed (HTTP $HTTP_CODE). If this is an auth"
  echo "::error::error the Page token may have expired — regenerate a"
  echo "::error::long-lived token and update the FB_PAGE_ACCESS_TOKEN secret."
  exit 1
fi

POST_ID=$(jq -r '.id // empty' /tmp/fb_response.json)
if [ -n "$POST_ID" ]; then
  echo "Posted to Facebook: https://www.facebook.com/$POST_ID" >> "${GITHUB_STEP_SUMMARY:-/dev/stdout}"
fi
