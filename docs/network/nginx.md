# Nginx

- Reverse proxy configuration inside the infrastructure to use subdomains within the domain.

- Domain configuration with SSL certificates.

## Runbook

Configuration of the /srv/nginx/compose.yml file:

```bash
services:
  npm:
    image: 'jc21/nginx-proxy-manager:latest'
    container_name: npm
    restart: unless-stopped
    ports:
      - '80:80'
      - '443:443'
      - '81:81'
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt

```

- Opening ports at the router level: 80 and 443 directed to the Nginx IP, and 11000 to Nextcloud.

## Issues encountered

- The Apache container was not updating the port because it was cached by the master container.

  - Found solution: uninstall the Apache container and reinstall it with the specified port.
