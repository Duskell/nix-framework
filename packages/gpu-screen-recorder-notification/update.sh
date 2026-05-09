#!/usr/bin/env bash
set -euo pipefail
packages_dir=$(realpath "$(dirname -- "$(realpath -- "$0")")/..")
bash "${packages_dir}/gpu-screen-recorder/update.sh" \
	gpu-screen-recorder-notification