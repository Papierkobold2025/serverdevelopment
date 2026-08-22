# Serverdevelopment

Personal infrastructure (homelab) documented — a technical portfolio based on Proxmox. This repository demonstrates skills in systems administration, network segmentation, automation (Semaphore / Ansible / Terraform), and service deployment (K3s, Keycloak, Nextcloud). It is intended to showcase design decisions, runbooks, and IaC examples.

---

## Quick overview

- Stack: Proxmox · K3s · Keycloak · Vaultwarden · wg-easy · Immich · Pterodaktyl 
- Network: Nginx Proxy Manager · Pi-hole · OPNSense
- Security: Wazuh · Ntopng
- IaC / Automation: Terraform · Ansible · Semaphore · Portainer
- Observability: Homarr

## General architecture (summary)

Infrastructure designed around **service isolation** to reduce the attack surface and limit lateral movement. The topology includes a flat network plane and a VLANs hosting infrastructure services, with OPNSense acting as the bridge/firewall between planes.

### Cluster nodes

| Node | Purpose |
|---|---|
| **Panel** | Main hypervisor, new hardware, hosts critical services |
| **API-Panel** | Hypervisor dedicated to APIs, dashboards, and cluster/service status visualizations |
| **Nextcloud** | Hypervisor for personal storage (Nextcloud) |
| **Nextcloud-sec** | Hypervisor for High Availability and replication |
| **i5** | Hypervisor for replication and non-critical services |
| **PBS** | Daily backups of all nodes and their VMs/containers |
| **Datacenter** | Node for Immich service |

📄 Complete hardware specifications in [cluster/nodes.md](cluster/nodes.md)

## Services

| Service | Where it lives | Documentation |
|---|---|---|
| Nextcloud | VM | [Nextcloud](docs/apps/nextcloud.md) |
| NPM | VM | [Nginx](docs/network/nginx.md) |
| Pi-hole | VM | [Pihole](docs/network/pihole.md) |
| Vaultwarden | LXC | [Vaultwarden](docs/identity/vaultwarden.md) |
| Keycloak | LXC | [Keycloak](docs/identity/keycloak.md) |
| K3s (lightweight cluster) | VM | [K3s](docs/apps/k3s.md) — hosts Portainer, Semaphore and Homarr |
| Netdata (New Monitoring Panel) | Panel | [Netdata](docs/monitoring/netdata.md) |
| Backups (PBS) | Dedicated VM | [cluster/backup.md](cluster/backup.md) |
| Immich (Datacenter) | VM | [Immich](docs/apps/immich.md) |
| Wazuh | VM | [Wazuh](docs/security/wazuh.md) |
| OPNSense | VM | [OPNSense](docs/network/opnsense.md) |
| Ntopng | VM | [Ntopng](docs/security/ntopng.md) |

## Automation and Infrastructure as Code

| Tool | Purpose | Documentation |
|---|---|---|
| Semaphore | Deployment pipelines | [Semaphore](docs/automation/semaphore.md) |
| Ansible | Playbooks for configuration and patching | [Ansible](docs/automation/semaphore.md#ansible) |
| Terraform | Repeatable VM deployment | [Terraform](docs/automation/semaphore.md#terraform) |
| Portainer | Deployment and configuration of containers and the Kubernetes cluster | [Portainer](docs/automation/portainer.md) |

## Network policies

| Tool | Purpose | Documentation |
|---|---|---|
| OPNSense | Firewall/router for the VLANs and flat network | [OPNSense](docs/network/opnsense.md) |
| K3s | Firewall inside the K3s cluster | [K3s](docs/apps/k3s.md#network-policies) |
| wg-easy | VPN for accessing the flat network and VLANs | [wg-easy](docs/network/wg-easy.md) |
| Network Diagram | Network Topology Diagram | [Network Diagram](docs/network/network-diagram.md) |

## Roadmap / Pending items

- [x] Configuration of firewall in K3s
- [ ] Configuration of firewall in Proxmox
- [ ] Expansion of automation tasks in Semaphore, Terraform, and Linux cron jobs
- [ ] Cloudflare Access as an extra layer for exposed services (Keycloak)
- [x] ntopng — visibility into network traffic
- [x] Wazuh — SIEM, centralization of security logs
- [ ] HA / multi-node replication of k3s

## Current status / In progress

> 🚧 **Network segmentation in progress.** A VLANs has been created and part of the infrastructure is being migrated; the rules in OPNSense and the DNS validations are still under development. Details and runbooks in [Network segmentation](docs/network/opnsense.md).

## Archived documentation index

- Historical / archived documentation (reference) — folder `Archive/Services/`:
    - [Automation (migrated)](Archive/Services/automation.md)
    - [Homepage (historical)](Archive/Services/homepage.md)
    - [Monitoring (historical)](Archive/Services/monitoring.md)
    - [Portainer (migrated)](Archive/Services/portainer.md)
    - [Netbird (historical)](Archive/Services/netbird.md)
    - [Zabbix (historical)](Archive/Services/zabbix.md)

## Quick reference index

- Development support documentation
    - [Docker](ops/docker.md) — base installation

---

Last updated: 2026-08-22
