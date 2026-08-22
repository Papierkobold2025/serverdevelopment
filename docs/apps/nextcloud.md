# Nextcloud integration

- Integration of Nextcloud inside a VM in the node cluster.

- Configuration and setup of a personal file storage environment.

## Decisions

- Isolation of Nextcloud from other services, on its own dedicated node (with replication to Nextcloud-sec for HA, see next point).

- Forced configuration of 2FA as an additional security measure for login.

- Configuration of VM replication to the Nextcloud-sec node and HA setup to prevent service failure or long downtime.

## Runbook

- Installation of the nextcloud_aio_nextcloud Docker container.

```bash
services:
  nextcloud_aio_mastercontainer:
    container_name: nextcloud-aio-mastercontainer
    image: nextcloud/all-in-one:latest
    restart: always
    ports:
      - "8080:8080"
    environment:
      APACHE_PORT: 11000
      APACHE_IP_BINDING: 0.0.0.0
    volumes:
      - nextcloud_aio_mastercontainer:/mnt/docker-aio-config
      - /var/run/docker.sock:/var/run/docker.sock:ro

volumes:
  nextcloud_aio_mastercontainer:
    external: true
```

- SMTP configuration

| Field | Value |
|---|---|
| Protocol | SMTP |
| Encoding | None / STARTTLS |
| Host | smtp.gmail.com |
| Port | 587 |
| Authentication | Yes - Gmail Application Password |

## Issues encountered

- Bug in the Nextcloud administration panel

  - Defining the age of usable passwords is not passed from Frontend to Backend.

  - Defining the maximum number of failed passwords is not passed from Frontend to Backend.

- Workaround found:

```bash
  sudo docker exec -u www-data nextcloud-aio-nextcloud php occ config:app:set password_policy maximumLoginAttempts --value=3
  sudo docker exec -u www-data nextcloud-aio-nextcloud php occ config:app:set password_policy historySize --value=3
```