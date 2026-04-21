#!/bin/sh
# Render scripts/formula-template.rb to Formula/hawkop.rb for a given hawkop version.
# Fetches SHA256 sidecars from download.stackhawk.com.
#
# Usage:
#   scripts/update-formula.sh --version 0.6.2
#   scripts/update-formula.sh --version 0.6.2 --dry-run
#   scripts/update-formula.sh --version 0.6.2 --offline   # skip network, use zeros
set -eu

parse_sha_from_stdin() {
  sha=$(tr -d '\r' | grep -Eo '[0-9a-fA-F]{64}' | head -n1)
  if [ -z "$sha" ]; then
    echo "error: expected 64-char hex in sha256 sidecar" >&2
    return 1
  fi
  printf '%s' "$sha"
}

if [ "${1:-}" = "--parse-sha-stdin" ]; then
  parse_sha_from_stdin
  exit $?
fi

VERSION=""
DRY_RUN=0
OFFLINE=0

while [ $# -gt 0 ]; do
  case "$1" in
    --version)   VERSION="$2"; shift 2 ;;
    --dry-run)   DRY_RUN=1; shift ;;
    --offline)   OFFLINE=1; shift ;;
    -h|--help)   sed -n '2,8p' "$0"; exit 0 ;;
    *)           echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

if [ -z "$VERSION" ]; then
  echo "error: --version is required" >&2
  exit 2
fi

if ! printf '%s' "$VERSION" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+(-[A-Za-z0-9.-]+)?$'; then
  echo "error: invalid version '$VERSION' — expected semver like 1.2.3 or 1.2.3-rc.1" >&2
  exit 2
fi

BASE_URL="https://download.stackhawk.com/hawkop/cli"

fetch_sha() {
  target="$1"
  if [ "$OFFLINE" -eq 1 ]; then
    printf '%064d' 0
    return 0
  fi
  archive="hawkop-v${VERSION}-${target}.tar.gz"
  archive_status=$(curl -sSIo /dev/null -w '%{http_code}' "${BASE_URL}/${archive}")
  if [ "$archive_status" != "200" ]; then
    echo "error: archive ${archive} returned HTTP ${archive_status}" >&2
    exit 1
  fi
  curl -sSf "${BASE_URL}/${archive}.sha256" | parse_sha_from_stdin
}

MAC_X64_SHA=$(fetch_sha "x86_64-apple-darwin")
MAC_ARM64_SHA=$(fetch_sha "aarch64-apple-darwin")
LINUX_X64_SHA=$(fetch_sha "x86_64-unknown-linux-gnu")
LINUX_ARM64_SHA=$(fetch_sha "aarch64-unknown-linux-gnu")

echo "version=$VERSION"
echo "mac_x64=$MAC_X64_SHA"
echo "mac_arm64=$MAC_ARM64_SHA"
echo "linux_x64=$LINUX_X64_SHA"
echo "linux_arm64=$LINUX_ARM64_SHA"
