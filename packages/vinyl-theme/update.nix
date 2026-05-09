#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

nix-update --quiet --flake \
	--write-commit-message "${UPDATE_MESSAGE_FILE:-/dev/null}" \
	vinyl-theme