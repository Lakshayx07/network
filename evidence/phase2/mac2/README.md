# Phase 2 submission · Mac 2

These excerpts come from two Mac 2 terminal transcripts. Internal addresses, hostnames, operating-system paths and absolute timestamps were removed. The healthy load-balancing capture preserves the original request order and relative timing.

## Submission evidence

- **Nginx and TLS.** The live Nginx syntax check passed. See the [Phase 1 backup reference](../../../configs/mac2/nginx-phase1.conf), the [Phase 2 config reference](../../../configs/mac2/nginx-phase2.conf), and [standby certificate signing and verification](E-standby-TLS-and-edge-checks.txt).
- **A · Backup DNS.** The primary query timed out and an explicit backup query answered. The backup answer pointed to the old edge address, and the HTTPS request timed out. After both records were corrected, normal HTTPS returned 200. [Resolver capture](AB-resolver-observations.txt)
- **B · TTL.** Resolver answers show the configured 30-second TTL, and the OS lookup returned the corrected address after a manual flush. A cache countdown and natural expiration still need captures. [TTL and OS lookup output](AB-resolver-observations.txt)
- **C · Isolation.** Direct requests from Mac 2 returned HTTP 200 with `X-Backend: A` and `X-Backend: B`. The terminal does not establish that strict PF rules were active. Include the backend owners' active policy and blocked-client evidence for the full check. [Direct HTTP responses](C-direct-backend-access.txt)
- **D · Backend failover.** Eight healthy HTTPS requests returned HTTP 200 and alternated B/A through Mac 2. Earlier logs show Nginx trying both upstreams when connections were refused. The controlled B-only run with A stopped and the A/B run after A restarts still need captures. [Healthy baseline](D1-healthy-A-B.txt) · [Retry and error output](D-nginx-retry-errors.txt)
- **E · Edge migration.** The standby certificate verified against the team CA, with SANs for both application names. The earlier Homebrew restart was part of troubleshooting. The planned Mac 2 stop, Mac 1 HTTP 200 with `X-Edge: mac4`, and Mac 2 restoration still need captures. [Certificate and service output](E-standby-TLS-and-edge-checks.txt)
- **F · Troubleshooting.** Pinning HTTPS to the local edge returned 200 while the name-based request failed against the old address. In a separate incident, both backend hosts responded to ping while their application TCP ports refused connections. These are practice observations. The formal injected-fault challenge still needs its own result. [Troubleshooting capture](F-troubleshooting-observations.txt)
