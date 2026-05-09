#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

system=$(nix eval --expr 'builtins.currentSystem' --impure --raw)
package="${1:-gpu-screen-recorder}"
package_repo=$(nix eval "path:.#packages.${system}.${package}.src.url" --impure --raw)

# Find the latest version.
latest_version=$(
	git ls-remote "$package_repo" 'refs/tags/*' \
		| awk '{ print $2 }' \
		| sed 's#^refs/tags/##' \
		| sort -V \
		| tail -n1
)

nix-update --quiet --flake \
	--write-commit-message "${UPDATE_MESSAGE_FILE:-/dev/null}" \
	--version "$latest_version" \
	"$package"