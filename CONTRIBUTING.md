# Contributing

## Prerequisites

Install [Nix](https://nixos.org/download/) with flakes enabled. The development shell provides Node.js, pnpm and dprint.

## Setup

From the repository root, enter `nix develop`, then build the pinned core packages and install the workspace:

```bash
mkdir -p .sfs-deps && cp -L --no-preserve=mode "$(nix build --no-link --print-out-paths .#sfs-deps)"/*.tgz .sfs-deps/
pnpm install
```

Core packages are supplied as local tarballs, not downloaded from a registry. To update them, advance the `core` input in `flake.nix`, update the override versions in `pnpm-workspace.yaml`, rebuild the tarballs and run `pnpm install`.

## Checks

Run these from the root in `nix develop`:

```bash
pnpm format:check
pnpm lint
pnpm typecheck
pnpm test
```

`pnpm check:local` also runs the static, packaging and local conformance checks. Mutation runs in CI only. Use `pnpm --filter @systemfsoftware/effect-readiness <command>` for package-specific commands.

## Pull requests

Use conventional commit messages, such as `fix(readiness): describe the change`. Changes to the published package output require at least a patch version increase.
