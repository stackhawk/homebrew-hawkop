#!/usr/bin/env bats

setup() {
  export SCRIPT="$BATS_TEST_DIRNAME/update-formula.sh"
  export TMPDIR_TEST="$(mktemp -d)"
  cd "$TMPDIR_TEST"
  cp "$BATS_TEST_DIRNAME/formula-template.rb" .
  mkdir -p scripts
  cp "$BATS_TEST_DIRNAME/formula-template.rb" scripts/
}

teardown() {
  rm -rf "$TMPDIR_TEST"
}

@test "rejects missing --version" {
  run "$SCRIPT"
  [ "$status" -ne 0 ]
  [[ "$output" == *"--version is required"* ]]
}

@test "rejects invalid version format" {
  run "$SCRIPT" --version "not-a-version"
  [ "$status" -ne 0 ]
  [[ "$output" == *"invalid version"* ]]
}

@test "accepts semver" {
  # Dry-run and offline mode so we don't hit the network
  run "$SCRIPT" --version "1.2.3" --dry-run --offline
  [ "$status" -eq 0 ]
}

@test "accepts semver with prerelease suffix" {
  run "$SCRIPT" --version "1.2.3-rc.1" --dry-run --offline
  [ "$status" -eq 0 ]
}

@test "extracts 64-char hex from sha256 sidecar" {
  run bash -c "echo 'abc123$(printf "%.0s0" {1..58})  hawkop-v0.0.0-x86_64-apple-darwin.tar.gz' | '$SCRIPT' --parse-sha-stdin"
  [ "$status" -eq 0 ]
  [[ "$output" == abc123* ]]
  [ ${#output} -eq 64 ]
}

@test "rejects sidecar without 64-char hex" {
  run bash -c "echo 'not-a-hash' | '$SCRIPT' --parse-sha-stdin"
  [ "$status" -ne 0 ]
  [[ "$output" == *"expected 64-char hex"* ]]
}

@test "dry-run offline prints rendered formula to stdout" {
  run "$SCRIPT" --version 1.2.3 --dry-run --offline
  [ "$status" -eq 0 ]
  [[ "$output" == *'class Hawkop < Formula'* ]]
  [[ "$output" == *'version "1.2.3"'* ]]
  [[ "$output" == *'hawkop-v1.2.3-x86_64-apple-darwin.tar.gz'* ]]
  # No unsubstituted placeholders remain
  [[ "$output" != *'${version}'* ]]
  [[ "$output" != *'${mac_x64_sha256}'* ]]
}

@test "writes Formula/hawkop.rb when not dry-run" {
  run "$SCRIPT" --version 1.2.3 --offline
  [ "$status" -eq 0 ]
  [ -f "Formula/hawkop.rb" ]
  run cat Formula/hawkop.rb
  [[ "$output" == *'class Hawkop < Formula'* ]]
}

@test "is idempotent — second run produces the same file" {
  "$SCRIPT" --version 1.2.3 --offline
  sum1=$(shasum -a 256 Formula/hawkop.rb | awk '{print $1}')
  "$SCRIPT" --version 1.2.3 --offline
  sum2=$(shasum -a 256 Formula/hawkop.rb | awk '{print $1}')
  [ "$sum1" = "$sum2" ]
}
