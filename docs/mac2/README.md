# Phase 2 review — Mac 2 main Nginx edge

Mac 2 terminates HTTPS and proxies application requests to Backend A or B. Phase 2 adds a shared upstream zone, passive failure detection, bounded retries, and response headers for the edge identity and upstream attempts.

- [Redacted Phase 1 backup reference](../../configs/mac2/nginx-phase1.conf)
- [Redacted Phase 2 configuration reference](../../configs/mac2/nginx-phase2.conf)
- [Nginx syntax check](../../evidence/mac2/nginx-config-test.txt)
- [TLS setup and verification](tls-setup.md)

The configuration references use example deployment values. The evidence summarizes actual observations and omits internal addresses, hostnames, local paths, and exact event times.

## Resilience and HA failover — A, B and D (15 team marks)

For A and B, the team needs client-side results showing the answer from backup DNS when the primary is down, the remaining TTL, and what the client receives after cache expiry. Mac 2 can verify the application path from a client using the backup resolver.

For D, [observed retry events](../../evidence/mac2/D-backend-failover/nginx-retry-errors.txt) show Nginx trying alternate upstreams. The controlled three-stage demonstration is pending. Run [the capture script](../../scripts/mac2/capture-requests.sh) once for each stage with the main HTTPS hostname and port.

1. With both backends healthy, record HTTP 200 from A and B.
2. Have Mac 3 stop Backend A while leaving backup DNS running. Record HTTP 200 from B only.
3. Have Mac 3 restart Backend A. Wait for the configured failure interval and record HTTP 200 from A and B.

Use the `X-Backend`, `X-Upstream-Addr`, and `X-Upstream-Status` response headers to distinguish successful requests, retries, and recovery.

## Service isolation and edge migration — C and E (10 team marks)

For C, [both direct probes failed to connect](../../evidence/mac2/C-service-isolation/mac2-backend-access.txt). Repeat once both services are listening. Capture HTTP 200 and the matching backend identity for each on Mac 2. Pair that evidence with the backend owners' firewall rule and disallowed-client captures.

For E, the [main edge snapshot](../../evidence/mac2/E-edge-migration/nginx-before-migration.txt) records the pre-migration observation. The team still needs both DNS answers pointing to Mac 4, the effect of cache expiry, the Mac 2 stop time, a Mac 1 HTTP 200 with `X-Edge: mac4`, and the Mac 2 restart and restored HTTPS response. Verify the restored main edge before switching DNS back.

## Troubleshooting challenge — F (10 team marks)

The syntax check passed and an HTTPS request reached Mac 2. The response showed HTTP 502 and two failed upstream attempts, and direct requests to both backends failed to connect. These observations locate the failure on the upstream connection path. The backend process state and firewall decision remain unverified.

To narrow the cause during the challenge, check the backend listener on each owner machine, then its firewall rules and counters. Repeat the direct requests from Mac 2 before retesting through Nginx. Check DNS separately against each resolver when the client receives the wrong edge address. The live challenge result is pending.

## Final report (5 team marks)

Include the configuration changes and TLS results above. Attach the team captures for each demonstration and label any failed or pending result. The Mac 2 run shows why an HTTP 502 alone cannot distinguish a stopped backend from a firewall or reachability problem. The per-upstream headers and direct probes narrow the investigation.

## Individual viva (10 marks per student)

Be ready to trace a request through DNS and its cache, TLS certificate validation at the selected edge, upstream selection, and the backend response. Explain when the cache picks up a DNS cutover, why a shared upstream zone matters, how Nginx retries within its configured budget, and which checks distinguish DNS, TLS, and backend connection failures.
