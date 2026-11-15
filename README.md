# effect-readiness

Effect-native readiness waits for a service exposed through a port mapping. Poll a TCP port, an HTTP path or a log for a pattern until it is satisfied or a deadline passes, and get back a typed verdict.

## Install

```sh
pnpm add @systemfsoftware/effect-readiness effect
```

Its peer dependencies, `effect@^4.1.2` and `typescript@>=7.0.0`, come from your project: this package declares them but does not install them, so one copy is shared with the rest of your project.

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
