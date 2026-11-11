# Contributing

## Prerequisites

Install [Nix](https://nixos.org/download/) with flakes enabled. The development shell provides Node.js, pnpm and dprint.

## Setup

From the repository root, enter `nix develop`, which lays the pinned core tarballs under `.deps/`, then install the workspace:

```bash
nix develop
pnpm install
```

https://nix.systemfsoftware.com is the package registry for `@systemfsoftware` packages: a producer pushes its package tarballs there from `main`, a consumer substitutes them through its flake inputs, and nothing is published to npm. To update core, advance the `core` input in `flake.nix`, regenerate the override block with `nix eval --raw .#producer-tarballs.overrides` into `pnpm-workspace.yaml`, and run `pnpm update '@systemfsoftware/*'`.

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
