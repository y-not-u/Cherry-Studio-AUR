#!/bin/bash

set -euo pipefail

repo="${1:-cherryHQ/cherry-studio}"
api_url="https://api.github.com/repos/${repo}/releases?per_page=30"

if ! command -v curl >/dev/null 2>&1; then
  echo "Error: curl is required" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required" >&2
  exit 1
fi

curl_args=(
  -fsSL
  --retry 3
  --retry-delay 2
  -A "cherry-studio-aur-update"
  -H "Accept: application/vnd.github+json"
)

# GitHub Actions exposes a repository token through github.token. Using it
# avoids the very small unauthenticated API rate limit on scheduled runners.
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  curl_args+=( -H "Authorization: Bearer ${GITHUB_TOKEN}" )
fi

if ! releases_json="$(curl "${curl_args[@]}" "$api_url")"; then
  echo "Error: failed to query GitHub releases API: $api_url" >&2
  echo "Hint: set GITHUB_TOKEN when running this script outside GitHub Actions." >&2
  exit 1
fi

version="$(
  jq -r '
    first(
      .[]
      | select(.draft == false and .prerelease == false)
      | .tag_name as $tag
      | ($tag | sub("^v"; "")) as $version
      | select(any(.assets[]?; .name == ("Cherry-Studio-" + $version + "-x86_64.AppImage")))
      | select(any(.assets[]?; .name == ("Cherry-Studio-" + $version + "-arm64.AppImage")))
      | $version
    ) // empty
  ' <<< "$releases_json"
)"

if [[ -z "$version" ]]; then
  echo "Error: no stable upstream release with both x86_64 and arm64 AppImage assets was found" >&2
  exit 1
fi

echo "$version"
