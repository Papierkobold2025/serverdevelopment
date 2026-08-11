# Serverdevelopment

Personal infrastructure (homelab) documented — a technical portfolio based on Proxmox. This repository demonstrates skills in systems administration, network segmentation, automation (Semaphore / Ansible / Terraform), and service deployment (K3s, Keycloak, Nextcloud). It is intended to showcase design decisions, runbooks, and IaC examples.

---

## Quick overview

- Stack: Proxmox · K3s · OPNSense · Nginx Proxy Manager · Pi-hole · Keycloak · Vaultwarden · wg-easy
- IaC / Automation: Terraform · Ansible · Semaphore · Portainer
- Observability: Homarr · Zabbix

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
| Nextcloud | VM | [Nextcloud](docs/nextcloud.md) |
| NPM | VM | [Nginx](docs/nginx.md) |
| Pi-hole | VM | [Pihole](docs/pihole.md) |
| Vaultwarden | VM | [Vaultwarden](docs/vaultwarden.md) |
| Keycloak | LXC | [Keycloak](docs/keycloak.md) |
| K3s (lightweight cluster) | VM | [K3s](docs/k3s.md) — hosts Portainer, Semaphore and Homarr |
| Netdata (New Monitoring Panel) | Panel | [Netdata](docs/netdata.md) |
| Backups (PBS) | Dedicated VM | [cluster/backup.md](cluster/backup.md) |
| Immich (Datacenter) | VM | [Immich](docs/immich.md) |

## Automation and Infrastructure as Code

| Tool | Purpose | Documentation |
|---|---|---|
| Semaphore | Deployment pipelines | [Semaphore](docs/semaphore.md) |
| Ansible | Playbooks for configuration and patching | [Ansible](docs/semaphore.md#ansible) |
| Terraform | Repeatable VM deployment | [Terraform](docs/semaphore.md#terraform) |
| Portainer | Deployment and configuration of containers and the Kubernetes cluster | [Portainer](docs/portainer.md) |

## Network policies

| Tool | Purpose | Documentation |
|---|---|---|
| OPNSense | Firewall/router for the VLANs and flat network | [OPNSense](docs/opnsense.md) |
| K3s | Firewall inside the K3s cluster | [K3s](docs/k3s.md#network-policies) |
| wg-easy | VPN for accessing the flat network and VLANs | [wg-easy](docs/wg-easy.md) |

## Roadmap / Pending items

- [ ] Configuration of firewall in K3s
- [ ] Configuration of firewall in Proxmox
- [ ] Expansion of automation tasks in Semaphore, Terraform, and Linux cron jobs
- [ ] Cloudflare Access as an extra layer for exposed services (Keycloak)
- [ ] ntopng — visibility into network traffic
- [ ] Wazuh — SIEM, centralization of security logs
- [ ] HA / multi-node replication of k3s

## Current status / In progress

> 🚧 **Network segmentation in progress.** A VLANs has been created and part of the infrastructure is being migrated; the rules in OPNSense and the DNS validations are still under development. Details and runbooks in [Network segmentation](docs/opnsense.md).

## Archived documentation index

- Historical / archived documentation (reference) — folder `Archive/Services/`:
    - [Automation (migrated)](Archive/Services/automation.md)
    - [Homepage (historical)](Archive/Services/homepage.md)
    - [Monitoring (historical)](Archive/Services/monitoring.md)
    - [Watchtower (historical)](Archive/Services/watchtower.md)
    - [Portainer (migrated)](Archive/Services/portainer.md)
    - [Netbird (historical)](Archive/Services/netbird.md)
    - [Zabbix (historical)](Archive/Services/zabbix.md)

## Quick reference index

- Development support documentation
    - [Docker](ops/docker.md) — base installation

---

Last updated: 2026-08-08