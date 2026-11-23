# Mac 4 — Backend B, Standby Edge and Test Client

## 1. Role
- Backend B
- Standby nginx edge server
- Test client

## 2. Network Details

| Detail | Value |
|---|---|
| Team | team1 |
| Mac | Mac 4 |
| Latest IP | 10.7.26.54 |
| IP checked | 24 November 2026, 04:17 IST |
| Main edge IP | 10.7.3.111 |
| Backend A | 10.7.25.239:3001 |
| Backend B | 10.7.26.54:3002 |
| Standby HTTP | 8080 |
| Standby HTTPS | 8443 |

IP addresses may change when reconnecting to Wi-Fi.

## 3. Dependencies
- macOS
- Python 3
- nginx 1.31.9
- OpenSSL
- PF firewall
- Git

Check versions:
- python3 --version
- nginx -v
- openssl version

## 4. Backend B

Existing shared source: backend/backend.py

The source was compared with ~/cn-backend/server.py using diff. No differences were reported.

Start Backend B from the repository root:

    python3 backend/backend.py B 3002

Health check:

    curl --noproxy '*' -i http://127.0.0.1:3002/api/status

Verified result: HTTP 200, backend B, status ok.

Stop: Press Ctrl+C in the Terminal running the backend.

If port 3002 is already occupied, inspect it:

    lsof -nP -iTCP:3002 -sTCP:LISTEN

Do not start another copy if the existing backend is running.

## 5. Standby nginx

Configuration: config/standby-nginx.conf

Upstream backends:
- Backend A: 10.7.25.239:3001
- Backend B: 127.0.0.1:3002

Listeners:
- HTTP: 8080
- HTTPS: 8443

Hostnames:
- app.team1.test
- api.team1.test

Installed nginx version: 1.31.9

Runtime directory: ~/cn-phase2/standby/

The private key must be provisioned locally at:
~/cn-phase2/standby/certs/standby.key

Start nginx:

    nginx -p "$HOME/cn-phase2/standby/" -c "$HOME/cn-phase2/standby/nginx.conf"

Check nginx:

    pgrep -fl nginx
    sudo lsof -nP -iTCP:8080 -iTCP:8443 -sTCP:LISTEN

Graceful stop:

    nginx -p "$HOME/cn-phase2/standby/" -c "$HOME/cn-phase2/standby/nginx.conf" -s quit

The nginx configuration passed nginx -t after its shared-memory zone was increased to 128k. nginx was also started successfully and listeners on ports 8080 and 8443 were observed. A graceful shutdown command was subsequently issued.

## 6. PF Firewall

Project anchor: com.apple/cn-phase2-team1

Configuration:
- config/backend-strict.pf
- config/root-filter-hooks.pf

Policy:
- Allow localhost TCP access to ports 3001 and 3002.
- Allow main edge IP 10.7.3.111 to access those ports.
- Block other incoming TCP connections to those ports.

PF was confirmed enabled. The project rules and cn_edges table were inspected.

Original snapshots and active rules are stored in evidence/pf/.

Do not use pfctl -F all or disable PF globally with pfctl -d.

Follow the approved project rollback procedure when cleanup is authorized.

## 7. TLS Certificate

Public certificate files:
- config/certs/standby.crt
- config/certs/team-CA.pem

Certificate details:
- Common Name: app.team1.test
- Issuer: team1 Local Root CA
- SAN: app.team1.test
- SAN: api.team1.test
- Validity: 23 November 2026 to 21 February 2027

Certificate chain verification returned OK.

Evidence is stored in evidence/tls/.

The private key is intentionally excluded.

## 8. Evidence Inventory

evidence/pf/
- Original PF configuration and status snapshots
- Apple child-anchor snapshots
- Root rules after repair
- Active backend rules
- Allowed edge IP table
- PF enable output

evidence/dns/
- Backup DNS packet capture
- Previous DNS snapshot

evidence/tls/
- Certificate SAN and validity verification
- Certificate chain verification

evidence/system/
- macOS version
- nginx configuration test output

## 9. Verified Results

- Backend B listened on port 3002.
- Backend B API returned HTTP 200 and status ok.
- PF was enabled.
- Strict firewall rules were loaded.
- cn_edges contained 10.7.3.111.
- Apple child anchors remained present after root-hook repair.
- Standby certificate SAN entries were verified.
- Certificate chain verification returned OK.
- nginx configuration syntax test passed.
- nginx successfully started and listened on ports 8080 and 8443 during testing.

A backup DNS packet capture is included.

Primary-down DNS/HTTPS, trusted standby HTTPS serving both backends, fresh-DNS cutover, main-edge outage and restoration must only be marked PASS when their corresponding test evidence is included.

## 10. Security

Never commit:
- standby.key
- cn-team.env
- Private keys
- Passwords or tokens
- Machine-specific secrets

Only public certificates, configurations and sanitized evidence belong in this repository.
