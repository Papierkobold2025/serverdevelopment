# Proxmox cluster node rundown

Hardware specs for each physical node, without IP addresses (internal documentation, not exposed in public DNS records).

## nextcloud-prim
- **CPU(s)**: 4 x Intel Core i7-7567U @ 3.50GHz (1 Socket)
- **Total RAM**: 62.69 GiB
- **Total storage**: 1.69 TiB
- **Kernel**: 7.0.2-6-pve
- **Manager**: pve-manager/9.2.2
- **Boot Mode**: EFI

## nextcloud-sec
- **CPU(s)**: 4 x Intel Core i7-7567U @ 3.50GHz (1 Socket)
- **Total RAM**: 62.68 GiB
- **Total storage**: 1.26 TiB
- **Kernel**: 7.0.2-6-pve
- **Manager**: pve-manager/9.2.4
- **Boot Mode**: EFI

## api-panel
- **CPU(s)**: 4 x Intel Core i7-7567U @ 3.50GHz (1 Socket)
- **Total RAM**: 62.68 GiB
- **Total storage**: 1.28 TiB
- **Kernel**: 7.0.2-6-pve
- **Manager**: pve-manager/9.2.4
- **Boot Mode**: EFI

## panel
- **CPU(s)**: 16 x Intel Core i7-13620H, 13th Gen (1 Socket)
- **Total RAM**: 62.44 GiB
- **Total storage**: 1.71 TiB
- **Kernel**: 7.0.2-6-pve
- **Manager**: pve-manager/9.2.2
- **Boot Mode**: EFI

## i5
- **CPU(s)**: 4 x Intel Core i5-7260U @ 2.20GHz (1 Socket)
- **Total RAM**: 46.94 GiB
- **Total storage**: 1.37 TiB
- **Kernel**: 7.0.14-8-pve
- **Manager**: pve-manager/9.2.6
- **Boot Mode**: EFI

## datacenter
- **CPU(s)**: 8 x Intel(R) Core(TM) i7-8559U @ 2.70GHz (1 Socket)
- **Total RAM**: 46.94 GiB
- **Total storage**: 2.71 TiB
- **Kernel**: 7.0.2-6-pve
- **Manager**: pve-manager/9.2.2
- **Boot Mode**: EFI

## Comparative summary

| Node | CPU | Cores/Threads | Total RAM | Total storage |
|---|---|---|---|---|
| nextcloud-prim | i7-7567U | 4 | 62.69 GiB | 1.69 TiB |
| nextcloud-sec | i7-7567U | 4 | 62.68 GiB | 1.26 TiB |
| api-panel | i7-7567U | 4 | 62.68 GiB | 1.28 TiB |
| panel | i7-13620H | 16 | 62.44 GiB | 1.71 TiB |
| i5 | i5-7260U | 4 | 46.94 GiB | 1.37 TiB |
| datacenter | i7-8559U | 8 | 46.94 | 2.71 TiB |

> **Note:** `pbs-homelab` does not appear in this table — it is a Proxmox Backup Server, physically separate from the Proxmox VE cluster (it does not participate in corosync/pvecm). See `cluster/backup.md` for its specs.

---

# Cluster VMs

Specs assigned to each VM (vCPU, RAM, disk), without IPs.

| VM ID | Name | Physical node | vCPU | RAM | Disk | Notes |
|---|---|---|---|---|---|---|
| 100 | Minecraft | panel | 8 (1 socket) | 25.39 GiB | 300GiB | BIOS OVMF (UEFI) |
| 101 | immich | datacenter | 3 (1 socket) | 19.53 GiB | 1.5 TiB | |
| 102 | nextcloud | nextcloud-prim | 2 (1 socket) | 7.81 GiB | 1.62 TB | |
| 103 | opnsense | api-panel | 2 (1 socket) | 7.81 GiB | 100GiB | |
| 104 | Wireguard | panel | 3 (1 socket) | 9.77 GiB | 400GiB | |
| 105 | Nginx | panel | 2 (1 socket) | 9.77 GiB | 400GiB | |
| 106 | pterodaktyl | i5 | 2 (1 socket) | 3.91 GiB | 100 GiB | |
| 107 | pihole | api-panel | 2 (1 socket) | 5.86 GiB | 100GiB | VM running wg-easy client |
| 111 | wazuh | i5 | 2 (1 socket) | 2 GiB | 50 GiB | |
| 112 | k3s | panel | 2 (1 socket) | 5.86 GiB | 300 GiB | VM running the Kubernetes cluster and wg-easy client |

# Cluster containers

Specs assigned to each CT (vCPU, RAM, disk), without IPs.

| CT ID | Name | Physical node | vCPU | RAM | Disk | Notes |
|---|---|---|---|---|---|---|
| 108 | keycloak | panel | 2 (1 socket) | 3.91 GiB | 30G | |
| 110 | vaultwarden | panel | 1 (1 socket) | 512 MiB | 10G | |

