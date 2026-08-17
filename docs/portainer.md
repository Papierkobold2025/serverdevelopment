# Portainer

- Visual management tool for container clusters (Docker/Kubernetes).

## Decisions

- Authentication through Keycloak: dedicated client with independent tokens for Portainer (inherited from the previous installation and still in use).

## Current status

- It currently manages the K3s cluster. The previous installation (Docker standalone) is documented in [Archive/Services/portainer.md](../Archive/Services/portainer.md) as a historical reference.

## Playbook

- Server installation

- [portainer.yaml](../k3s/manifests/deployment/automation/portainer/portainer.yaml)

- Portainer Agent installation
```bash
services:
  agent:
    image: portainer/agent:latest
    container_name: portainer_agent
    restart: unless-stopped
    ports:
      - "192.168.X.X:9001:9001" #IP address of the client where the portainer agent is installed
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - /var/lib/docker/volumes:/var/lib/docker/volumes
```
- After installation of the client the agent has to be added as a standalone via the agent wizard