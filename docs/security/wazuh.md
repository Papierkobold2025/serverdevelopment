# Wazuh

- Integration into the cluster to have a centralized SIEM

- Installation on LAN to make accessibility to the network logs easier

## Decisions

- Wazuh was integrated even knowing the complexity that it may bring the project in order to practice reading logs and detecting anomalies

## Issues encountered

- During the installation of wazuh I encountered a major problem finding where to reset the administrator password as it is not reset-able on the GUI

## Playbook

- Wazuh server installation on /srv/wazuh
```bash
git clone https://github.com/wazuh/wazuh-docker.git -b v4.14.7
cd wazuh-docker/single-node
docker compose -f generate-indexer-certs.yml run --rm generator
docker compose up -d
```
- Wazuh Agent isntallation on VMs, Containers and Hypervisors
```bash
apt install lsb-release -y
wget https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.14.7-1_amd64.deb && sudo WAZUH_MANAGER='192.168.X.X' WAZUH_AGENT_NAME='NAME' dpkg -i ./wazuh-agent_4.14.7-1_amd64.deb
```