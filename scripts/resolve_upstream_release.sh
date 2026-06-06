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

releases_json="$(curl -fsSL "$api_url")"

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
