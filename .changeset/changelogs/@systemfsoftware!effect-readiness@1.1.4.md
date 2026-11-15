# @systemfsoftware/effect-readiness@1.1.4

Depends on published @systemfsoftware packages by caret range, so the package installs from npm.

`Wait.forHttp` sends the host and port it dials as the request's `Host` header, instead of a fixed `ref`, so a server that enforces its domain (Grafana with `enforce_domain`) answers the probe instead of redirecting it.
