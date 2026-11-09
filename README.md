# effect-readiness

Effect-native readiness waits for services exposed through port mappings. Poll TCP connections, HTTP responses, or log entries until a condition is satisfied or a deadline expires.

## Install

The latest published package is **1.0.0**. The examples below describe that release; this repository's main branch is at 1.1.2, which is not published to npm.

In an existing npm project:

```bash
npm install @systemfsoftware/effect-readiness@1.0.0
```

## Usage

This example supplies log entries through a `LogSource` and waits for the word `ready`. Save it as `example.mjs` and run it with Node.js:

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

```bash
node example.mjs
```

The output is `Satisfied`. Replace the example `LogSource` with one that reads your service's logs.

## Conditions

| Condition                            | What is observed                             |
| ------------------------------------ | -------------------------------------------- |
| `Readiness.Wait.forTcp(port)`        | A connection to the mapped host socket.      |
| `Readiness.Wait.forHttp(path, port)` | An HTTP response with a successful status.   |
| `Readiness.Wait.forLog(pattern)`     | A log entry matching the regular expression. |

TCP and HTTP conditions use the guest port to select a binding supplied to `Readiness.target`, whose entries contain `guest`, `host`, and `hostPort`. The Node host prober implements socket access; `HostProber` and `LogSource` are Effect services that can be supplied by the caller.

## Timeouts and errors

Set `timeoutMs` and `pollMs` in the target options to control the deadline and polling interval. A completed wait returns a `Satisfied` or `TimedOut` verdict; log-source and invalid-input failures are represented as typed errors.

## Version status

The 1.0.0 example above uses the published package, not the unpublished source on main. Consult the source when working on the unreleased version.

## Contributing

Development setup and checks: [CONTRIBUTING.md](CONTRIBUTING.md).

## Support

Report problems in the [issue tracker](https://github.com/systemfsoftware/effect-readiness/issues).

## License

[Apache-2.0](LICENSE).
