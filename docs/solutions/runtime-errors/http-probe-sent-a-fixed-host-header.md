---
title: The HTTP readiness probe sent a fixed Host header, so domain-enforcing servers never looked ready
date: 2026-11-15
category: runtime-errors
module: effect-readiness
problem_type: runtime_error
component: readiness_probe
severity: medium
symptoms:
  - "`Wait.forHttp` times out against a server that answers the same path with 200 to curl"
  - "The probe's request, replayed by hand, gets `301 Moved Permanently` to the server's own address"
root_cause: logic_error
tags: [readiness, http, host-header, grafana]
---

# The HTTP readiness probe sent a fixed Host header

## Problem

`Wait.forHttp(path, port)` wrote `GET <path> HTTP/1.0` with the header `Host: ref` on every probe. A server that checks the request's host against its own domain, such as Grafana with `enforce_domain`, answers such a request with a 301 redirect to its own address. The probe counts only a 2xx status as ready, so it waited until its timeout against a server that was up. Probing Tempo through Grafana's datasource proxy hit exactly this.

## Root cause

The `Host` header named no real authority. HTTP defines `Host` as the authority the client is addressing (RFC 9112 §3.2), and the probe knows it: the host and port it dials.

## Fix

`NodeHostProber` sends `Host: <host>:<port>` for the binding it dials, with an IPv6 literal bracketed and the default port 80 left out (RFC 3986 §3.2.2). Measured against Grafana's datasource proxy: the old request got `HTTP/1.0 301 Moved Permanently`, the new one gets `HTTP/1.0 200 OK`.

A redirect is still not readiness. The probe does not follow it, because a redirect to a login page would answer 200 for a backend that is not routed.

## Prevention

A hand-written protocol request carries the values the protocol defines for that request, never a placeholder, even when the common servers ignore that field.
