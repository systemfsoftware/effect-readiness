# Contributing

## Prerequisites

Install [Nix](https://nixos.org/download/) with flakes enabled. The development shell provides Node.js, pnpm and dprint.

## Setup

From the repository root, enter `nix develop`, then install the workspace:

```bash
nix develop
pnpm install
```

`@systemfsoftware` packages come from npm like any other dependency: package manifests and catalogs name caret ranges and `pnpm-lock.yaml` holds the exact versions. Take newer ones with `pnpm update '@systemfsoftware/*'`. `flake.nix` pins core at a full commit (input `core`) only for its dprint build and its nixpkgs.

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
