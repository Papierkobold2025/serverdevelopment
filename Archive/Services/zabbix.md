# Zabbix

- Installation of monitoring for nodes, VMs, and containers in Proxmox-style environments.

## Decisions

- Replacement of Grafana/Prometheus with native network scan coverage.

- Integration of Zabbix into the k3s cluster.

- PostgreSQL with persistence enabled, installed as a sub-chart within the same Helm release.

## Issues encountered

- Difficulty configuring dashboards and importing templates.

## Runbook

- Installation of Helm and cloning the official Zabbix repository.

```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
git clone https://github.com/zabbix-community/helm-zabbix.git
```

- Configuration of the Zabbix .yaml file.

```bash
zabbixServer.service.type: ClusterIP
postgresql.persistence.enabled: true # In this chart version it already came enabled by default; it is left explicit here so it does not depend on that behavior in future updates.
```

- Installation of the Zabbix client.

```bash
helm install zabbix ./charts/zabbix --dependency-update -f $HOME/zabbix_values.yaml -n monitoring
```

- Access to the frontend: Service `zabbix-zabbix-web`, NodePort port 31080 (internal 80).

```bash
kubectl get svc zabbix-zabbix-web -n monitoring
```
