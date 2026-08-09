# Docker

- Application for thee deployment of Docker Containers

- Standardization of the deployment of docker compose through the /srv/service directory (/srv/portainer/compose.yaml for example)

## Runbook

```bash
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker $USER ##Important consideration: The command does not require sudo to run afterwards, which is equal to root access on the host (Through the container it's possible mounting and manipulating the complete filesystem)
newgrp docker ##To apply changes
```
