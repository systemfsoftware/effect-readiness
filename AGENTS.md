# effect-readiness

Private workspace for `@systemfsoftware/effect-readiness` (`packages/effect-readiness/`), extracted with its history
from `systemfsoftware/systemfsoftware` at `2ad94574b4f257f7376a9793fd550258f6ccd176`. Private tools that gate it live
in `tooling/<name>/`.

## Boundaries

| Surface            | Examples                                                                    | Limit                                                      |
| ------------------ | --------------------------------------------------------------------------- | ---------------------------------------------------------- |
| **Evaluator**      | `commitlint.config.ts`, `.github/`, `.mergify.yml`, `turbo.json`            | Edit only in a pull request whose subject is the evaluator |
| **Doctrine**       | `.compound-engineering/config.yaml`, this file                              | Edit only on deliberate direction                          |
| **Dependencies**   | `@systemfsoftware/*` packages in `node_modules/`                            | Read-only (see No local mutation)                          |
| **Human approval** | Releases, publishing, credentials, repository visibility, ruleset changes   | User-confirmed only                                        |
| **Editable**       | `packages/effect-readiness/`, `tooling/*`, tests, documentation, changesets | Edit freely                                                |

## Published versions

Every `@systemfsoftware/*` dependency is a published version, pinned in `pnpm-lock.yaml`. Never a `workspace:` link
into a core checkout, a `link:` or `file:` path, or a `.sfs-deps/` tarball. A change this package needs from a
dependency lands in the dependency's own repository, is published there, and arrives here as a version bump.

## Layer per dependency

Layers are core's package layer map (`package-layers.json`, SYS-648). This package is in `extracted`, a layer core's
edge check forbids no runtime or peer edge from; a new edge is weighed in review by the layer of its target.

| Dependency                                                                           | Kind    | Layer                    |
| ------------------------------------------------------------------------------------ | ------- | ------------------------ |
| `@systemfsoftware/effect-cell-types`                                                 | runtime | core                     |
| `effect`, `@effect/platform-node`                                                    | runtime | upstream (Effect)        |
| `@systemfsoftware/tsconfig`, `tsdown-config`, `vitest-config`, `stryker-config`      | dev     | core                     |
| `@systemfsoftware/oxlint-config-recommended`                                         | dev     | core                     |
| `@systemfsoftware/effect-schema-law`, `effect-schema-vite`                           | dev     | core                     |
| `@systemfsoftware/vitest`, `conformance-spec`, `effect-gherkin-spec`                 | dev     | harness                  |
| `@systemfsoftware/stryker-*`, `@systemfsoftware/arethetypeswrong-cli`                | dev     | outside core's layer map |
| `typescript`, `vitest`, `tsdown`, `oxlint`, `@microsoft/api-extractor`, `fast-check` | dev     | upstream                 |

A new `@systemfsoftware/*` dependency names its layer in this table in the same pull request.

## Runners

Every job runs on the organisation's self-hosted pool: `["self-hosted","systemfsoftware-runner","amd64"]`, passed as
`runs-on` and `test-runs-on` to the shared workflows. A job that needs arm64 names `arm64` in place of `amd64`. Never
`ubuntu-latest`. The pool provides Nix; `.github/actions/dev-shell` installs it only on a GitHub-hosted runner.

## Tooling

A tool is a private Bun package under `tooling/<name>/`: Effect with `@systemfsoftware/effect-cell-types`, inputs
decoded with Effect Schema, sources in `src/` and the entry point in `bin/`, linted by oxlint against
`oxlint.shared.ts`, typechecked with `tsc -b` against `tsconfig.base.json`, and covered by vitest property tests. No new
Deno code. Workflow and action YAML only invokes tools, one line per call: parsing, hashing, keying and decision logic
belong in a tool, and review blocks them in YAML.

## Gate

`pnpm check:local` runs the whole gate on a workstation: `pnpm check:static` (dprint, oxlint, typecheck, API report,
attw) and `pnpm test`. CI runs the same tasks through `.github/workflows/ci.yml`, whose `checks / gate` job is the
required check; a pull request is done when `pnpm check:local` passes and `checks / gate` is green.

## Version bumps

- This package's version moves only through changesets. A pull request that changes the package's turbo `build` hash
  ships an intent: `pnpm change --bump <none|patch|minor|major> --summary "<entry>" @systemfsoftware/effect-readiness`.
  The release pull request (`chore(release): version packages`) applies it; never edit `version` by hand.
- A dependency moves by changing its range in `pnpm-workspace.yaml`'s catalog (or the manifest that names it), running
  `pnpm install` to rewrite `pnpm-lock.yaml`, adding a `patch` intent for this package (its packed manifest changes),
  and passing `pnpm check:local`. One dependency move per pull request.

## No local mutation

Nothing in `node_modules/` is edited, patched with `pnpm patch`, or overlaid by a link for an `@systemfsoftware/*`
package. Nothing publishes, tags, releases or changes repository settings from a workstation: release and publish run
only in CI on `main`, and rulesets change through `.github/rulesets/` with human approval.

## Commits

Conventional commits (`<type>(<scope>): <subject>`), no AI trailers; `commitlint.config.ts` and the Husky hooks enforce
both. One pull request per unit, based on `main`. Never force-push.
