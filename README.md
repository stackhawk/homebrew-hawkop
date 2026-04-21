# homebrew-hawkop

Homebrew tap for [HawkOp](https://github.com/stackhawk/hawkop) — a CLI companion for the StackHawk AppSec Intelligence Platform.

## Install

```sh
brew tap stackhawk/hawkop
brew install hawkop
```

## Upgrade

```sh
brew update
brew upgrade hawkop
```

## Uninstall

```sh
brew uninstall hawkop
brew untap stackhawk/hawkop
```

## Releasing a new version

The formula is auto-generated. Do **not** edit `Formula/hawkop.rb` by hand.

### Manual release

```sh
gh workflow run update-formula.yml \
  -R stackhawk/homebrew-hawkop \
  -f version=X.Y.Z
```

This triggers the `update-formula` workflow, which renders
`scripts/formula-template.rb` using SHA256 sidecars from
`download.stackhawk.com/hawkop/cli/` and commits the result to `main`.

### Automated release

Upstream `stackhawk/hawkop` can send a `repository_dispatch` event of type
`hawkop-release` with payload `{"version": "X.Y.Z"}` to this repo to trigger
the same workflow.

## Troubleshooting

**`brew install` fails with a checksum mismatch.**
The tarball was re-uploaded with different content than the formula recorded.
Re-run the update workflow for the affected version.

**`brew install` fails with HTTP 404.**
The formula is pinned to a version whose tarballs have not been published,
or the download bucket was rolled back. Check
`https://download.stackhawk.com/hawkop/cli/hawkop-v<VERSION>-<target>.tar.gz`
with `curl -I` and coordinate with the `stackhawk/hawkop` release owner.

**Shell renderer fails locally.**
Run `bats scripts/test-update-formula.bats` and
`shellcheck scripts/update-formula.sh` from the repo root.
