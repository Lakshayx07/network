# Phase 2 submission · Mac 2

These redacted excerpts come from the Mac 2 terminal. The healthy load-balancing capture preserves the request order and relative timing.

- **Nginx.** The live syntax check passed. [Phase 1 config reference](../../../configs/mac2/nginx-phase1.conf) · [Phase 2 config reference](../../../configs/mac2/nginx-phase2.conf)
- **DNS and TTL.** Both resolvers returned the current Mac 2 address with a 30-second TTL. The OS lookup returned the same address. [Resolver output](DNS-resolver-answers.txt)
- **C · Direct backend access.** Mac 2 received HTTP 200 from Backend A and Backend B with matching `X-Backend` headers. [Direct responses](C-direct-backend-access.txt)
- **D · Healthy baseline.** Eight HTTPS requests returned HTTP 200 and alternated between B and A through Mac 2. [Healthy A/B capture](D1-healthy-A-B.txt)
- **E · Standby TLS preparation.** The standby certificate verified against the team CA and included SANs for both the application and API names. [Certificate verification](TLS-standby-certificate.txt)
