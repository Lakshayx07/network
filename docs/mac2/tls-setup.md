# Mac 2 TLS setup

The main edge redirects HTTP to HTTPS and enables HTTP/2 with TLS 1.2 and 1.3. The application and API names are both present in the certificate SANs.

Mac 4 generated a standby key and certificate signing request. Mac 2 signed the request with the team's local CA. Clients trust the public CA certificate. Each edge keeps its private key on its own machine.

[Certificate verification](../../evidence/mac2/TLS/certificate-verification.txt) records the results for both names and both certificates.
