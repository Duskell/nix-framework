#!/usr/bin/env bash
# my-dotfiles | Copyright (C) 2025 eth-p
# Repository: https://github.com/eth-p/my-dotfiles
# ==============================================================================
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

# ------------------------------------------------------------------------------

status() {
	printf "\x1B[1;34m==> \x1B[0;34m%s\x1B[m\n" "$1" 1>&2
}

hash_url() {
	nix-hash --type sha256 --base32 --sri --flat <(
		curl "$1" -fsL
	)
}

hash_github() {
	extract_dir=$(mktemp -d)
	(
		trap 'rm -rf "$extract_dir"' EXIT
		curl "https://github.com/$1/$2/archive/$3.tar.gz" -fsL -o- \
			| tar -C "$extract_dir" --strip-components=1 -xz 1>&2
		nix-hash --type sha256 --base32 --sri "$extract_dir"
	)
}

version="${1?Required}"

status "Fetching binary blob hashes (x86_64)..."
sha256_64bit=$(hash_url "https://us.download.nvidia.com/XFree86/Linux-x86_64/${version}/NVIDIA-Linux-x86_64-${version}.run")

status "Fetching binary blob hashes (aarch64)..."
sha256_aarch64=$(hash_url "https://us.download.nvidia.com/XFree86/Linux-aarch64/${version}/NVIDIA-Linux-aarch64-${version}.run")

status "Fetching open GPU kernel module hashes..."
openSha256=$(hash_github "NVIDIA" "open-gpu-kernel-modules" "$version")

status "Fetching nvidia-settings hashes..."
settingsSha256=$(hash_github "NVIDIA" "nvidia-settings" "$version")

status "Fetching nvidia-persistenced hashes..."
persistencedSha256=$(hash_github "NVIDIA" "nvidia-persistenced" "$version")

status "mkDriver attributes for ${version}:"
cat <<EOF
  version = "${version}";
  sha256_64bit = "${sha256_64bit}";
  sha256_aarch64 = "${sha256_aarch64}";
  openSha256 = "${openSha256}";
  settingsSha256 = "${settingsSha256}";
  persistencedSha256 = "${persistencedSha256}";
EOF