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
    --version)
      if [ -z "${2:-}" ]; then
        echo "error: --version requires an argument" >&2
        exit 2
      fi
      VERSION="$2"; shift 2
      ;;
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
  curl -sSf "${BASE_URL}/${archive}.sha256" | "$0" --parse-sha-stdin
}

MAC_X64_SHA=$(fetch_sha "x86_64-apple-darwin")
MAC_ARM64_SHA=$(fetch_sha "aarch64-apple-darwin")
LINUX_X64_SHA=$(fetch_sha "x86_64-unknown-linux-gnu")
LINUX_ARM64_SHA=$(fetch_sha "aarch64-unknown-linux-gnu")

# --- Render template ---
# Resolve template path relative to this script.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE="${SCRIPT_DIR}/formula-template.rb"
if [ ! -f "$TEMPLATE" ]; then
  echo "error: template not found at $TEMPLATE" >&2
  exit 1
fi

render() {
  sed \
    -e "s|\${version}|${VERSION}|g" \
    -e "s|\${mac_x64_sha256}|${MAC_X64_SHA}|g" \
    -e "s|\${mac_arm64_sha256}|${MAC_ARM64_SHA}|g" \
    -e "s|\${linux_x64_sha256}|${LINUX_X64_SHA}|g" \
    -e "s|\${linux_arm64_sha256}|${LINUX_ARM64_SHA}|g" \
    "$TEMPLATE"
}

if [ "$DRY_RUN" -eq 1 ]; then
  render
else
  mkdir -p Formula
  render > Formula/hawkop.rb
  echo "wrote Formula/hawkop.rb (version $VERSION)" >&2
fi

# --- Optional local audit ---
# If brew is on PATH and we actually wrote a file, run audit. Skip in dry-run
# or offline mode (offline produces zeroed SHAs that would fail audit).
if [ "$DRY_RUN" -eq 0 ] && [ "$OFFLINE" -eq 0 ] && command -v brew >/dev/null 2>&1; then
  echo "running: brew audit --strict --online Formula/hawkop.rb" >&2
  brew audit --strict --online Formula/hawkop.rb
fi
