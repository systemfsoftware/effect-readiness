# Changesets

This directory holds change-intent files consumed by the shared release tooling
([`pnpm-release-management`](https://github.com/systemfsoftware/pnpm-release-management)),
configured in [`release.jsonc`](../release.jsonc). One file per change, authored
with:

```
pnpm change --bump <none|patch|minor|major> --summary "<changelog entry>" [<pkg>...]
```

- An intent's frontmatter names each package and its bump,
  `"<pkg>": <none|patch|minor|major>`. Its body is the changelog entry, published
  verbatim in the release notes.
- A PR that changes a publishable package's turbo `build` hash MUST ship with an
  intent here. The Changeset Check workflow runs `changeset-management check`
  against the PR's base and blocks the PR when a changed hash is not named
  (`release.jsonc` `gate`).
- `--bump none` records a change that needs no release. It is correct only when
  the packed tarball stays byte-identical; a `none` on a behavior-visible change
  is the silent non-release the gate exists to catch.
- A catalog value flip in `pnpm-workspace.yaml` changes no package hash, so the
  gate never sees it, but it changes the packed manifest of every package that
  names the entry: release each one with `pnpm change --bump patch <pkg>...`.
- This README is NOT a changeset: the gate requires a file whose frontmatter
  parses as `"<pkg>": <none|patch|minor|major>`.

## Versioning

`release.jsonc` uses `changesets` versioning: every package versions on its own,
from the intents that name it. Private packages (`tooling/*`) are versioned but
never tagged or released.

## History

`ledger.yaml` and `changelogs/` carry @systemfsoftware/effect-readiness's
release record from `systemfsoftware/systemfsoftware`, where the package was
versioned up to 1.1.0. `changelogs/` must stay tracked: the release phase reads
`changelogs/<pkg>@<version>.md` as the GitHub Release body.
