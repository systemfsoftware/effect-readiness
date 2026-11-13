# effect-readiness

Effect-native readiness waits for a service exposed through a port mapping. Poll a TCP port, an HTTP path or a log for a pattern until it is satisfied or a deadline passes, and get back a typed verdict.

## Install

`@systemfsoftware` packages are distributed as Nix tarballs from `nix.systemfsoftware.com`, not from npm, so do not run `npm install` or `pnpm add` for them. Take them through a flake. Third-party peers such as `effect` install from npm as usual.

Add the producer as a flake input in your project's `flake.nix`. Pin it to a full commit SHA or a release tag:

```nix
{
  nixConfig = {
    extra-substituters = "https://nix.systemfsoftware.com";
    extra-trusted-public-keys = "nix-cache-1:wXA8I4DayNW9q6enUyQA/P/nT38pGSTLt374t3gsn7M=";
  };

  inputs = {
    nixpkgs.follows = "effect-readiness/nixpkgs";
    effect-readiness.url = "github:systemfsoftware/effect-readiness/<rev>";
    pnpm-release-management.url = "github:systemfsoftware/pnpm-release-management";
  };

  outputs = { self, nixpkgs, effect-readiness, pnpm-release-management }: {
    packages = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in rec {
        producer-tarballs = pnpm-release-management.lib.mkProducerTarballs {
          inherit pkgs;
          producers = { inherit effect-readiness; };
        };
        pnpm-store = pnpm-release-management.lib.mkPnpmConsumerStore {
          inherit pkgs;
          src = self;
          files.".deps" = producer-tarballs;
        };
      });

    devShells = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in {
        default = pkgs.mkShell {
          packages = [ pkgs.nodejs_24 pkgs.pnpm_12 ];
          shellHook = self.packages.${system}.producer-tarballs.shellHook;
        };
      });
  };
}
```

Then, inside `nix develop`:

```sh
nix eval --raw .#producer-tarballs.overrides   # paste the output into pnpm-workspace.yaml
pnpm add effect
```

Declare the package in `package.json` as a tarball in `.deps/`:

```json
"@systemfsoftware/effect-readiness": "file:.deps/effect-readiness.tgz"
```

Add `.deps/` to `.gitignore`.

## Usage

This example supplies log entries through a `LogSource` and waits for the word `ready`. Save it as `example.mjs`:

```js
import { Readiness } from '@systemfsoftware/effect-readiness'
import { Effect, Layer } from 'effect'

const target = Readiness.target([], { timeoutMs: 1000, pollMs: 50 })
const program = target.awaitCondition(Readiness.Wait.forLog('ready')).pipe(
  Effect.provide(
    Layer.merge(
      Readiness.NodeHostProber.layer,
      Layer.succeed(Readiness.LogSource, { entries: Effect.succeed(['server ready']) }),
    ),
  ),
)

const verdict = await Effect.runPromise(program)
console.log(verdict._tag)
```

```text
Satisfied
```

Replace the example `LogSource` with one that reads your service's logs.

## Conditions

| Condition                            | What is observed                             |
| ------------------------------------ | -------------------------------------------- |
| `Readiness.Wait.forTcp(port)`        | A connection to the mapped host socket.      |
| `Readiness.Wait.forHttp(path, port)` | An HTTP response with a successful status.   |
| `Readiness.Wait.forLog(pattern)`     | A log entry matching the regular expression. |

TCP and HTTP conditions take the guest port and find its binding among the port bindings passed to `Readiness.target`. Each binding has `guest`, `host` and `hostPort`. `HostProber` and `LogSource` are Effect services. `Readiness.NodeHostProber.layer` implements host socket access on Node.js; supply your own `HostProber` or `LogSource` to change what is observed.

## Timeouts and verdicts

`timeoutMs` (default 30000) sets the deadline and `pollMs` (default 250) sets the polling interval. A wait returns `Satisfied` or `TimedOut`. A log source that fails and an invalid input are typed errors (`LogSourceError`, `ProbeInputInvalid`), not verdicts.

## Contributing

Development setup and checks are in [CONTRIBUTING.md](CONTRIBUTING.md).

## Support

Report problems in the [issue tracker](https://github.com/systemfsoftware/effect-readiness/issues).

## License

[Apache-2.0](LICENSE).
