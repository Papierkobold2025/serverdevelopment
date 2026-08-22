# Vaultwarden

- Self-hosted password manager, owned by Bitwarden in Open Source format.

## Decisions

- Internal access only to avoid compromising all passwords for accessing services.

- HA replicated to nextcloud-sec due to the critical importance of having access to passwords.

- Watchtower installed to ensure the Docker container was always running the latest version to avoid deprecated versions.

## Issues encountered

- Creating a user via the admin panel's "Invite User" fails (a known bug with the organizationId in the link) — the user must be created by going directly to the root URL.

## Runbook

``` bash 
services:
  vaultwarden:
    container_name: vaultwarden
    image: vaultwarden/server:latest
    restart: always
    ports:
      - "192.168.X.X:1620:80"
    volumes:
      -  /srv/vaultwarden:/data/
    environment:
      ADMIN_TOKEN: '${VAULTWARDEN_TOKEN}'
      DOMAIN: '${DOMAIN_VAULTWARDEN}'
      SIGNUPS_ALLOWED: "false"
      SMTP_HOST: '${SMTP_DOMAIN}'
      SMTP_FROM: '${SMTP_SEND}'
      SMTP_PORT: 587
      SMTP_SECURITY: starttls
      SMTP_USERNAME: '${SMTP_SEND}'
      SMTP_PASSWORD: '${SMTP_PASSWORD}'
```
