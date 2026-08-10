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

- Migration of services to the VLAN:

  - Vaultwarden

  - Keycloak

  - K3s

  - NPM

  - Nextcloud (proxied only, see Decisions)

- Pi-hole was not migrated because it acts as the DHCP server for the flat network and must keep scope over all clients.

- OPNsense was also not migrated because it is the communication point between the VLAN and the flat network.

- Rule-by-rule hardening completed for: wg-easy, Portainer, NPM, Semaphore, admin SSH. ANY-ANY fallback rules on LAN and VLAN have been removed.

- NPM Access Lists applied on top of firewall rules: 18 of 19 Proxy Hosts restricted to `192.168.X.X/X` + `192.168.X.X/X` (reachable only via LAN or either wg-easy tunnel). Nextcloud is the sole exception, kept Publicly Accessible by design (see Decisions).

- OPNsense webUI Listen Interfaces corrected from "All" to explicit LAN + VLAN (see Issues encountered).

## Topology (current)

**WAN → VLAN:**

- UDP 51821 → wg-easy WGVLAN (192.168.X.X)

- TCP 80/443 → NPM (192.168.X.X)

**WAN → LAN:**

- UDP 51823 → wg-easy WGLAN (192.168.X.X)

**VLAN → WAN:**

- TCP 443 → NPM only, any destination (Let's Encrypt renewal, general HTTPS)

- TCP 443 → k3s (192.168.30.X) only, any destination (GitHub, needs matching k3s NetworkPolicy egress)

**LAN → VLAN:**

- TCP 80/443 → NPM, any LAN source

- TCP 2226 → NPM, source restricted to admin IP

- TCP 22 → k3s, source restricted to admin IP

- TCP 8443 → This Firewall, source LAN network (OPNsense webUI direct)

**VLAN → LAN:**

- NPM → LAN network, any port (see Decisions)

- NPM → This Firewall, TCP 8443 (covers OPNsense admin domain proxied through NPM)

- k3s → Pi-hole, UDP 53 (DNS)

- k3s → Pi-hole, TCP 9001 (Portainer ↔ Agent)

- k3s → Pi-hole, TCP 2235 (Semaphore access)

- k3s → each Proxmox node, TCP 22 (Semaphore/Ansible)

- k3s → Nextcloud, TCP 9001

**Application layer (NPM Access Lists):**

- Firewall rules above control which network can reach NPM's ports. Access Lists control which source IP NPM will actually proxy to a given backend, independent of firewall — see Decisions and Issues encountered for why this layer was needed.

## WGLAN

- Second, independent wg-easy instance, installed on the Pi-hole VM (separate from WGVLAN on the k3s VM).

- Grants access to the flat network (LAN, `192.168.X.X/X`) only — not VLAN.

- WAN port UDP 51823, forwarded LAN → wg-easy on the Pi-hole VM.

- Purpose: keep a way to reach the flat network by VPN even after VLAN access is fully locked down, without needing WGVLAN scope for that use case.

- Known issue: WGLAN clients cannot reach VLAN services (see Issues encountered) — traced to inside the Pi-hole/wg-easy VM itself, not to OPNsense firewall rules.

## Decisions

- Network segmentation only with a single VLAN, to isolate critical services without segmenting by service.

- I decided to place the reverse proxy inside the VLAN; internal DNS queries pass through Pi-hole and are forwarded to NPM, while OPNsense acts as the bridge to return the resolution to the client.

- Internal services that do not have access to the external network were placed in the VLAN, leaving only end-user services in the flat network to avoid lateral movement.

- Initial risk acceptance due to the absence of any explicit network-flow rules, taking an approach of making it more restrictive over time instead of closing everything at the outset and then opening it up later.

- I decided to use the local DNS records in Pi-hole rather than conditional forwarding, since I keep that list updated. When the VLAN was created, it was enough to point the existing records to the new NPM IP so domain resolution continued to work without needing to configure conditional forwarding.

- Hardening pattern: ALLOW rule on the correct interface → temporary DENY test → validate → remove ANY-ANY once every critical service has its own rule. wg-easy was the reference implementation.

- NPM source rule kept broad (`NPM → LAN network, any port`) instead of one rule per backend. NPM already has high blast radius by design; restricting by host doesn't reduce that, only adds maintenance for a homelab-scale project.

- Admin SSH (NPM, k3s) allowed from flat network, restricted to fixed admin IP, same pattern as Portainer. Vaultwarden stays fully behind VPN at the application layer — reachable only from LAN/VLAN via NPM Access List, not from WAN under any source. Nextcloud is the only genuinely public-facing service (external family access), so it's the only one with WAN-facing rules and no NPM Access List restriction.

- Outbound NAT mode changed from Automatic to Hybrid, with explicit "Do not NAT" for VLAN→flat traffic (flat-network hosts need to see the real source IP, not OPNsense's own).

- Found and removed 5 SSH port-forwards on the router (unrelated to OPNsense, ~3 weeks old). Rule going forward: no administrative port ever exposed directly to the internet, only genuinely public-facing services.

- NPM Access Lists reconsidered and implemented for all Proxy Hosts except Nextcloud (previously discarded as "not worth it for this project" — reversed after confirming the actual exposure, see Issues encountered). Rule of thumb going forward: any new Proxy Host defaults to an `internal-only` Access List (LAN + VLAN); Publicly Accessible is an explicit, deliberate exception, not a default.

### Issues encountered

- Rules are evaluated by the interface where the packet *enters* OPNsense, not the logical direction. Traffic leaving VLAN toward the internet enters through the VLAN interface, not WAN. Mistake made: put the GitHub outbound rule on WAN instead of VLAN.

- Anti-lockout rule only covers direct access from flat network to the firewall's own IP. Traffic that reaches it indirectly (client → NPM → OPNsense, admin domain proxied through NPM) isn't covered and needs its own rule.

- Automatic outbound NAT was rewriting VLAN→flat traffic with OPNsense's own IP, breaking source-IP filtering on flat-network services (found via Zabbix agent, before Zabbix was decommissioned). Fixed with Hybrid NAT + "Do not NAT" rule. Caution: badly ordered, this rule can take down all internal access at once. Rollback path: console access to the OPNsense VM via Proxmox, `pfctl -d`.

- VLAN isolation at network level isn't isolation at application level. NPM forwards by Host header/SNI, not by whether a public DNS record exists — confirmed with `curl --resolve` against the public IP: services with no public DNS record (Vaultwarden, Keycloak, OPNsense webUI, NPM admin) were still fully reachable from WAN by anyone who knew the exact subdomain. Reversed the earlier "NPM Access Lists discarded" decision — rolled out to every Proxy Host except Nextcloud.

- OPNsense webUI Listen Interfaces was set to "All", so the webUI itself listened on WAN even though no firewall rule allowed reaching it — port 80 leaked an identifiable `Server: OPNsense` banner to a plain port scan. Fixed by restricting to LAN + VLAN. Caution: wrong interface choice can lock out the webUI; rollback via OPNsense VM console through Proxmox. Brief self-resolving interruption observed right after applying (service restart).

- WGLAN clients cannot reach VLAN services. ICMP from inside the Pi-hole/wg-easy VM never reaches OPNsense at all (100% packet loss before the firewall), ruling out an OPNsense rule as the cause. MTU and systemd-resolved ruled out as differentiators from the working WGVLAN tunnel. Root cause not yet resolved — investigation points to something inside the Pi-hole/wg-easy VM itself, not OPNsense. Not blocking in practice: VLAN access is intentionally treated as the higher-trust tunnel (WGVLAN), while WGLAN is scoped to the flat network only.