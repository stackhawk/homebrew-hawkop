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
