# homebrew-hawkop (DEPRECATED)

> **This tap is deprecated and no longer receives updates.**
> The HawkOp Homebrew formula has moved to the consolidated StackHawk CLI tap
> at [`stackhawk/homebrew-cli`](https://github.com/stackhawk/homebrew-cli) —
> the same tap that already serves `hawk` (HawkScan).
>
> The last version published from this tap was `hawkop` v0.6.1.

## Migrate to the new tap

```sh
brew untap stackhawk/hawkop
brew tap stackhawk/cli
brew install hawkop          # or: brew upgrade hawkop, if already installed
```

That's it — Homebrew will pick up the latest `hawkop` from the new tap on
your next `brew update`.

## Why the move?

`hawk` (HawkScan) and `hawkop` (the StackHawk Platform CLI) are now both
published from a single tap, `stackhawk/cli`, so users only need one
`brew tap` to get either tool. Going forward, all formula updates,
release automation, and platform support land in the new repo.

## Resources

- New tap: https://github.com/stackhawk/homebrew-cli
- HawkOp source: https://github.com/stackhawk/hawkop
- HawkOp docs: https://docs.stackhawk.com/hawkop/
- HawkOp downloads (direct): https://download.stackhawk.com/hawkop/
