# Network segmentation

- Network segmentation to keep critical services isolated through VLANs.

- Isolation and rules in OPNsense are in active hardening, moving rule by rule from an ANY-ANY fallback to explicit deny-by-default.

## Terminology (important)

- **VLAN**: logical separation at Layer 2 (broadcast domain). A VLAN allows traffic to be segmented on the switch and broadcast domains to be controlled.

- **Subnet**: segmentation at Layer 3 (range of IP addresses). A subnet can be assigned to a VLAN, but they are not the same.

- In this project, I use VLANs to isolate services at Layer 2 and assign IP subnets per VLAN. OPNsense policies (routing/firewall) operate at Layer 3 and can apply NAT or rules between subnets/VLANs as needed.

## Current status

- Creation of VLANs to isolate critical services and avoid lateral movement at the network level in case of compromise.

- The selected services for migration are infrastructure services, not end-user services.

- Migration of services to VLAN:

  - Vaultwarden

  - Keycloak

  - K3s

  - NPM

  - Nextcloud

  - Immich

- Pi-hole was not migrated because it acts as the DHCP server for the flat network and must keep scope over all clients.

- OPNsense was also not migrated because it is the communication point between the VLAN and the flat network.

- Rule-by-rule hardening completed for: wg-easy, Portainer, NPM, Semaphore, admin SSH. ANY-ANY fallback rules on LAN and VLAN have been removed.

- NPM Access Lists applied on top of firewall rules: 18 of 19 Proxy Hosts restricted to `192.168.X.X/X` + `192.168.X.X/X` (reachable only via LAN or either wg-easy tunnel). Nextcloud is the sole exception, kept Publicly Accessible by design (see Decisions).

- OPNsense webUI Listen Interfaces corrected from "All" to explicit LAN + VLAN (see Issues encountered).

## Topology (current)

### OPNsense Network Rules by Service

This document lists all current OPNsense firewall rules, organized by service rather than by direction. Traffic origin and destination are described by service name and logical network (LAN, WAN, VLAN1, VLAN2) rather than by raw IP address, consistent with the anonymization already used across this repository. VLAN1 corresponds to the infrastructure VLAN (Portainer, Semaphore, Homarr, wg-easy VLAN instance, Pi-hole reverse-proxy access). VLAN2 corresponds to the Nextcloud/Immich VLAN.

---

#### NPM (Nginx Proxy Manager)

| Direction | Origin | Destination:Port | Protocol | Description |
|---|---|---|---|---|
| LAN → VLAN1 | Any | NPM:80 | TCP | HTTP access to the reverse proxy from the flat network |
| LAN → VLAN1 | Any | NPM:443 | TCP | HTTPS access to the reverse proxy from the flat network |
| WAN → VLAN1 | Any | NPM:80 | TCP | HTTP access to the reverse proxy from the public internet (Nextcloud and Immich are the only backends actually reachable from WAN) |
| WAN → VLAN1 | Any | NPM:443 | TCP | HTTPS access to the reverse proxy from the public internet |
| VLAN1 → LAN | NPM | Any:Any | TCP | Outbound connection from NPM to backend services on the flat network |
| VLAN1 → LAN | NPM | Any:Any | UDP | Outbound connection from NPM to backend services on the flat network (UDP) |
| VLAN1 → This Firewall | NPM | This Firewall:8443 | TCP | NPM proxying the OPNsense admin domain to the firewall's webUI |
| LAN → VLAN1 | Fixed admin IP | NPM:2226 | TCP | SSH administrative access to the NPM host |

NPM Access Lists provide an additional layer on top of these firewall rules: 18 of 19 Proxy Hosts are restricted to LAN + VLAN source IPs at the application layer, regardless of what the firewall allows through. Nextcloud is the sole exception and remains fully public by design.

---

#### Pi-hole

| Direction | Origin | Destination:Port | Protocol | Description |
|---|---|---|---|---|
| VLAN1/VLAN2 → LAN | VLAN1 network, VLAN2 network | Pi-hole:Any | Any | Reverse-proxy path toward Pi-hole for internal domain resolution (floating rule) |
| VLAN1 → LAN | Semaphore | Pi-hole:2235 | TCP | Semaphore management access to Pi-hole |
| VLAN1 → LAN | Semaphore | Pi-hole:2225 | TCP | Ansible SSH access to Pi-hole |
| VLAN1 → LAN | Portainer | Pi-hole:9001 | TCP | Portainer agent connection |
| VLAN1 → LAN | Homarr | Pi-hole:53 | UDP | DNS query from Homarr |
| VLAN2 → LAN | Immich | Pi-hole:53 | UDP | DNS query from Immich |
| VLAN2 → LAN | Nextcloud | Pi-hole:53 | UDP | DNS query from Nextcloud |
| WAN → LAN | Any | Pi-hole:51823 | UDP | WG-LAN tunnel entry point |
| WAN → * | Pi-hole | Any:Any | UDP | WG-LAN tunnel outbound |

**Known limitation:** WGLAN clients can reach the flat network but cannot reach VLAN1 or VLAN2. The root cause lives inside the Pi-hole/wg-easy VM, not in any OPNsense rule or NAT setting (see the wg-easy service documentation for the full technical breakdown). WGLAN's scope is therefore permanently limited to the flat network; any access to VLAN1, including internal DNS resolution through Pi-hole while tunneled, requires WGVLAN instead, VLAN2 is kept isolated on purpose, without a direct access per wgvlan, the access is still possible, as the ssh connection is permitted for k3s to VLAN2.

---

#### Nextcloud

| Direction | Origin | Destination:Port | Protocol | Description |
|---|---|---|---|---|
| VLAN2 → * | Nextcloud | Any:443 | TCP | Outbound GitHub access |
| VLAN1 → VLAN2 | Semaphore | Nextcloud:2235 | TCP | Semaphore management access |
| VLAN1 → VLAN2 | Portainer | Nextcloud:9001 | TCP | Portainer agent connection |
| VLAN1 → VLAN2 | Homarr | Nextcloud:Any | TCP | Homarr integration |
| LAN → VLAN2 | Any | Nextcloud:2235 | TCP | Direct administrative SSH access |
| VLAN2 → VLAN1 | Nextcloud | Keycloak:Any | Any | OAuth login flow through Keycloak |

---

#### Immich

| Direction | Origin | Destination:Port | Protocol | Description |
|---|---|---|---|---|
| VLAN2 → * | Immich | Any:443 | TCP | Outbound GitHub access |
| VLAN1 → VLAN2 | Homarr | Immich:Any | TCP | Homarr integration |
| VLAN1 → VLAN2 | Portainer | Immich:9001 | TCP | Portainer agent connection |
| LAN → VLAN2 | Any | Immich:22 | TCP | Direct administrative SSH access |

---

#### Wazuh

| Direction | Origin | Destination:Port | Protocol | Description |
|---|---|---|---|---|
| LAN/VLAN1 → LAN | LAN network, VLAN1 network | Wazuh:443 | TCP | Dashboard access |
| LAN/VLAN1/VLAN2 → LAN | LAN network, VLAN1 network, VLAN2 network | Wazuh:Any | TCP | Agent connections (full port range required by the Wazuh agent protocol) |
| VLAN1 → LAN | Semaphore | Wazuh:22 | TCP | Semaphore management access |

---

#### Semaphore / Ansible — infrastructure management matrix

All entries below originate from Semaphore (VLAN1), destined to TCP port 22, unless noted otherwise.

| Destination | Description |
|---|---|
| Panel node | Semaphore-Panel |
| Api-panel node | Semaphore-Apipanel |
| Datacenter node | Semaphore-Datacenter |
| Nextcloud-prim node | Semaphore-NextcloudPrim |
| Nextcloud-sec node | Semaphore-NextcloudSec |
| i5 node | Semaphore-I5 |
| PBS node | Semaphore-PBS |
| Wazuh VM | Semaphore-Wazuh |
| pterodactyl VM | Semaphore-pterodactyl |

GitHub egress for automation is consolidated into a single rule regardless of which pod initiates it (Terraform, Ansible, or any other automation pod), since all k3s pods share the same node source IP after SNAT and are therefore indistinguishable to OPNsense: `VLAN1 → Any:443 TCP`. Per-pod differentiation, where needed, is enforced at the k3s NetworkPolicy layer instead.

---

#### Firewall administrative access

| Direction | Origin | Destination:Port | Protocol | Description |
|---|---|---|---|---|
| LAN → This Firewall | Any | This Firewall:8443 | TCP | Direct OPNsense webUI access from the flat network |
| VLAN1 → This Firewall | NPM | This Firewall:8443 | TCP | OPNsense admin domain proxied through NPM |

---

#### Direct administrative access (not routed through Semaphore)

| Direction | Origin | Destination:Port | Protocol | Description |
|---|---|---|---|---|
| LAN → VLAN1 | Any | k3s:22 | TCP | Direct SSH access to the k3s VM, independent of Semaphore |

---

#### Meteo API

| Direction | Origin | Destination:Port | Protocol | Description |
|---|---|---|---|---|
| VLAN1 → Meteo_API alias | Homarr (via VLAN1 node) | Meteo_API:Any | Any | External weather API consumed by the Homarr widget |

**Decision:** this is the only egress rule in the infrastructure with no fixed destination IP, since the alias resolves an external FQDN rather than a static host. This was decided, because the IP of the domain changes constantly, The rule is kept as-is: OPNsense's FQDN alias narrows the actual reachable destination to the resolved IP of the weather API, and the pattern is consistent with the already-accepted GitHub egress rule.

---

#### SMTP (VLAN2)

| Direction | Origin | Destination:Port | Protocol | Description |
|---|---|---|---|---|
| VLAN2 → * | VLAN2 network | Any:587 | TCP | Outbound SMTP for Nextcloud email notifications |

---

#### Maintenance (floating rule)

| Direction | Origin | Destination:Port | Protocol | Description |
|---|---|---|---|---|
| LAN/VLAN1/VLAN2 → * | LAN, VLAN1, VLAN2 | Any:80 | TCP | apt/package repository access ("Ubuntu" rule) |
| LAN/VLAN1/VLAN2 → * | LAN, VLAN1, VLAN2 | Any:443 | TCP | apt/package repository access ("Ubuntu" rule) |

---

#### WireGuard tunnels

| Direction | Origin | Destination:Port | Protocol | Description |
|---|---|---|---|---|
| WAN → VLAN1 | Any | k3s (WGVLAN):51821 | UDP | WGVLAN tunnel entry point |
| WAN → * | k3s (WGVLAN) | Any:Any | UDP | WGVLAN tunnel outbound |
| WAN → LAN | Any | Pi-hole (WGLAN):51823 | UDP | WGLAN tunnel entry point |
| WAN → * | Pi-hole (WGLAN) | Any:Any | UDP | WGLAN tunnel outbound |

WGVLAN grants access to VLAN1, including internal DNS resolution through Pi-hole. WGLAN grants access to the flat network only.

---

#### Outbound NAT

Outbound NAT mode is set to Hybrid. In addition to the automatic per-interface rules, one manual exception rule is defined:

| Interface | Source | Destination | Do not NAT |
|---|---|---|---|
| LAN | VLAN1 network | LAN network | Yes |

This rule preserves the real source IP for VLAN1-to-LAN traffic instead of translating it to OPNsense's own LAN address, consistent with the same automatic-outbound-NAT problem previously fixed for VLAN-to-flat traffic (see Decisions in the main document). It did not resolve the WGLAN-to-VLAN limitation described above.

## Decisions

- Network segmentation started with a single VLAN (VLAN1, infrastructure services). A second VLAN (VLAN2) was later added to isolate Nextcloud and Immich specifically — user-facing storage services with a large blast radius (many containers, direct internet exposure for Nextcloud) — away from infrastructure-critical services like Vaultwarden and Keycloak.

- I decided to place the reverse proxy inside the VLAN; internal DNS queries pass through Pi-hole and are forwarded to NPM, while OPNsense acts as the bridge to return the resolution to the client.

- Internal services that do not have access to the external network were placed in the VLAN, leaving only end-user services in the flat network to avoid lateral movement.

- Initial risk acceptance due to the absence of any explicit network-flow rules, taking an approach of making it more restrictive over time instead of closing everything at the outset and then opening it up later.

- I decided to use the local DNS records in Pi-hole rather than conditional forwarding, since I keep that list updated. When the VLAN was created, it was enough to point the existing records to the new NPM IP so domain resolution continued to work without needing to configure conditional forwarding.

- Hardening pattern: ALLOW rule on the correct interface → temporary DENY test → validate → remove ANY-ANY once every critical service has its own rule. wg-easy was the reference implementation.

- NPM source rule kept broad (`NPM → LAN network, any port`) instead of one rule per backend. NPM already has high blast radius by design; restricting by host doesn't reduce that, only adds maintenance for a homelab-scale project.

- Admin SSH (NPM, k3s) allowed from flat network, restricted to fixed admin IP, same pattern as Portainer. Vaultwarden stays fully behind VPN at the application layer — reachable only from LAN/VLAN via NPM Access List, not from WAN under any source. Nextcloud is the only genuinely public-facing service (external family access), so it's the only one with WAN-facing rules and no NPM Access List restriction.

- Found and removed 5 SSH port-forwards on the router (unrelated to OPNsense, ~3 weeks old). Rule going forward: no administrative port ever exposed directly to the internet, only genuinely public-facing services.

- NPM Access Lists reconsidered and implemented for all Proxy Hosts except Nextcloud (previously discarded as "not worth it for this project" — reversed after confirming the actual exposure, see Issues encountered). Rule of thumb going forward: any new Proxy Host defaults to an `internal-only` Access List (LAN + VLAN); Publicly Accessible is an explicit, deliberate exception, not a default.

- Nextcloud, Immich and NPM are the only services that can be accessed from public network, NPM per firewall and Nextcloud and Immich per reverse proxy.

### Issues encountered

- Rules are evaluated by the interface where the packet *enters* OPNsense, not the logical direction. Traffic leaving VLAN toward the internet enters through the VLAN interface, not WAN. Mistake made: put the GitHub outbound rule on WAN instead of VLAN.

- Anti-lockout rule only covers direct access from flat network to the firewall's own IP. Traffic that reaches it indirectly (client → NPM → OPNsense, admin domain proxied through NPM) isn't covered and needs its own rule.

- Automatic outbound NAT was rewriting VLAN→flat traffic with OPNsense's own IP, breaking source-IP filtering on flat-network services (found via Zabbix agent, before Zabbix was decommissioned). Fixed with Hybrid NAT + "Do not NAT" rule. Caution: badly ordered, this rule can take down all internal access at once. Rollback path: console access to the OPNsense VM via Proxmox, `pfctl -d`.

- VLAN isolation at network level isn't isolation at application level. NPM forwards by Host header/SNI, not by whether a public DNS record exists — confirmed with `curl --resolve` against the public IP: services with no public DNS record (Vaultwarden, Keycloak, OPNsense webUI, NPM admin) were still fully reachable from WAN by anyone who knew the exact subdomain. Reversed the earlier "NPM Access Lists discarded" decision — rolled out to every Proxy Host except Nextcloud.

- OPNsense webUI Listen Interfaces was set to "All", so the webUI itself listened on WAN even though no firewall rule allowed reaching it — port 80 leaked an identifiable `Server: OPNsense` banner to a plain port scan. Fixed by restricting to LAN + VLAN. Caution: wrong interface choice can lock out the webUI; rollback via OPNsense VM console through Proxmox. Brief self-resolving interruption observed right after applying (service restart).

- WGLAN clients cannot reach VLAN services. ICMP from inside the Pi-hole/wg-easy VM never reaches OPNsense at all (100% packet loss before the firewall), ruling out an OPNsense rule as the cause. MTU and systemd-resolved ruled out as differentiators from the working WGVLAN tunnel. Root cause not yet resolved — investigation points to something inside the Pi-hole/wg-easy VM itself, not OPNsense. Not blocking in practice: VLAN access is intentionally treated as the higher-trust tunnel (WGVLAN), while WGLAN is scoped to the flat network only.

- ICMP being blocked is not the same as a service being down. During VLAN2 hardening (Nextcloud), `ping` to the VLAN gateway failed while the actual service (HTTPS via NPM) worked fine — OPNsense only had an explicit ALLOW for the service's real port, not for ICMP, since it follows the rule-by-rule hardening pattern (no ANY-ANY fallback). Lesson: when troubleshooting connectivity during hardening, test the actual service port/protocol directly (curl, telnet) instead of relying on ping — a failed ping does not confirm a broken firewall rule for the traffic that actually matters.