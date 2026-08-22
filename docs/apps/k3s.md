# K3s

- K3s setup to start learning Kubernetes.

## Decisions

- Isolation of Kubernetes inside a new, specialized hypervisor.

- Installation of K3s on a Proxmox VM because K3s requires access to kernel modules and direct handling of iptables.

- I used hostPath (pointing directly to a folder on the node disk) instead of PVC (where Kubernetes decides and manages storage on its own) — it is the same pattern I already knew from Docker Compose, easier to understand for a first manifest. I should review PVC later if I want Kubernetes to manage the disk instead of me.

## Issues encountered

- kubectl turned out to be the same binary as k3s (a symlink), and by design it looks for its config at /etc/rancher/k3s/k3s.yaml (read-only for root), ignoring the copy I made in ~/.kube/config.

  - Solution: force the correct path with the KUBECONFIG variable, added to ~/.bashrc so it is permanent.

## Runbook

- K3s server installation

```bash
curl -sfL https://get.k3s.io | sh -
```

## Network Policies

- Isolation of traffic between pods inside k3s, and from pods to the internal network.

### Decisions

- Deny-all isolation pattern by namespace, with traffic opened selectively through allow rules.

- The current rules allow traffic to and from the full flat network range (`192.168.X.X/24`) for Portainer and its agent, instead of restricting it to specific IPs — the same initial risk-acceptance approach used in the general network segmentation (see [opnsense](opnsense.md)), pending hardening (see Roadmap: "K3s firewall configuration").

- Homarr's egress policy (`homarr-network.yaml`) includes an `ipBlock: 0.0.0.0/0` rule scoped to TCP/443, required for the Meteo API widget — no `podSelector` is possible for an external service, so the real narrowing of the destination happens at the OPNsense alias layer instead (see [opnsense](opnsense.md), Meteo API section). Same file also defines Homarr's egress toward Nextcloud and Immich in VLAN2.

- Semaphore's egress policy (`semaphore-network.yaml`) consolidates all GitHub access (Terraform, Ansible, and any other automation workload) into a single rule, since every k3s pod shares the same node source IP after SNAT and is indistinguishable to OPNsense — per-pod differentiation for GitHub access, where it matters, is enforced here at the NetworkPolicy layer instead of at the firewall.

### Issues encountered

- Two NetworkPolicies cannot have the same name in the same namespace; the second will always overwrite the first rule.

- An internal ipBlock targeting the IP range of a Service such as 10.43.X.X never works because of how k3s routes traffic (it requires specific IPs, not ranges).

### Note

- `portainer-agent` runs in its own namespace (`portainer`), created automatically when the agent is deployed — it is not part of the `automation` tree at the Kubernetes level, only at the repository organization level.

### Workloads

| Service | Manifest / Installation |
|---|---|
| Portainer | [portainer.yaml](../../k3s/manifests/deployment/automation/portainer.yaml) |
| Semaphore | [semaphore.yaml](../../k3s/manifests/deployment/automation/semaphore.yaml) |
| Homarr | [homarr.yaml](../../k3s/manifests/deployment/monitoring/homarr.yaml) |

### Network Policy Rules

**General layer** — baseline deny-all (Ingress/Egress) and shared DNS/allow rules by namespace:

- [general.yaml](../../k3s/manifests/network-policies/general/general.yaml)

**Service-specific rules:**

| Service | Namespace(s) | File |
|---|---|---|
| Portainer + Portainer-Agent | automation, portainer | [portainer-network.yaml](../../k3s/manifests/network-policies/namespaces/automation/portainer/portainer-network.yaml) |
| Semaphore | automation | [semaphore-network.yaml](../../k3s/manifests/network-policies/namespaces/automation/semaphore/semaphore-network.yaml) |
| Homarr | monitoring | [homarr-network.yaml](../../k3s/manifests/network-policies/namespaces/monitoring/homarr/homarr-network.yaml) |