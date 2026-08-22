# Watchtower

- Integration of Watchtower within the cluster to keep the installed Docker containers up to date.

- This is a service that must be installed on each node, VM, or container that contains Docker so that automatic updates can be applied and old containers can be removed.

## Decisions

- Watchtower is reinstated, as the network has a lot of dockers that need to be updated.

### Runbook
```bash
services:
  watchtower:
    image: nickfedor/watchtower
    restart: unless-stopped
    environment:
      WATCHTOWER_NOTIFICATIONS: shoutrrr
      WATCHTOWER_NOTIFICATION_URL: '${TELEGRAM}'
      WATCHTOWER_SCHEDULE: "0 0 3 * * *"
      WATCHTOWER_NOTIFICATION_TITLE_TAG: "service"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
```
