#!/bin/sh
# Render scripts/formula-template.rb to Formula/hawkop.rb for a given hawkop version.
# Fetches SHA256 sidecars from download.stackhawk.com.
#
# Usage:
#   scripts/update-formula.sh --version 0.6.2
#   scripts/update-formula.sh --version 0.6.2 --dry-run
#   scripts/update-formula.sh --version 0.6.2 --offline   # skip network, use zeros
set -eu

VERSION=""
DRY_RUN=0
OFFLINE=0

while [ $# -gt 0 ]; do
  case "$1" in
    --version)
      VERSION="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --offline)
      OFFLINE=1
      shift
      ;;
    -h|--help)
      sed -n '2,8p' "$0"
      exit 0
      ;;
    *)
      echo "unknown arg: $1" >&2
      exit 2
      ;;
  esac
done

if [ -z "$VERSION" ]; then
  echo "error: --version is required" >&2
  exit 2
fi

# Strict semver with optional prerelease suffix
if ! printf '%s' "$VERSION" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+(-[A-Za-z0-9.-]+)?$'; then
  echo "error: invalid version '$VERSION' — expected semver like 1.2.3 or 1.2.3-rc.1" >&2
  exit 2
fi

# Placeholder — rest of implementation lands in later tasks
echo "version=$VERSION dry_run=$DRY_RUN offline=$OFFLINE"
