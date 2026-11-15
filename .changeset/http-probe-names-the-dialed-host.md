---
"@systemfsoftware/effect-readiness": patch
---

`Wait.forHttp` sends the host and port it dials as the request's `Host` header, instead of a fixed `ref`, so a server that enforces its domain (Grafana with `enforce_domain`) answers the probe instead of redirecting it.
