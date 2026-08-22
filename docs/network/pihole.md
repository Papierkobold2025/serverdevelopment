# Pi-hole

- Pi-hole configuration as the main DNS and DHCP replacement for the router, leaving the router as a secondary DNS server in case of any type of failure.

- Reservation of IP addresses through DHCP lease so that the main nodes that need to be reached as services have a fixed IP.

## Decisions

- Keep the router as a secondary DNS server in case the container were to fail.

- Point all domains to the NPM IP as the DNS server to allow clean resolution of subdomains.

- Configure subdomains using the format: application.service.domain.com (for example, vaultwarden.apps.domain.com).

- IP range: 192.168.X.101 - 192.168.X.220 with the standard gateway.

### Runbook

- Configuration of compose.yaml at /srv/pihole/compose.yaml

- ``` bash
  services:
    pihole:
      container_name: pihole
      image: pihole/pihole:latest
      network_mode: host
      environment:
        TZ: 'Europe/Zurich'
        FTLCONF_webserver_api_password: 'password'
        FTLCONF_dns_listeningMode: 'ALL'
      volumes:
        - './etc-pihole:/etc/pihole'
      cap_add:
        - NET_ADMIN
      restart: unless-stopped
   ```

## Issues encountered

- Problem found

    - A number of services cannot resolve DNS subdomains unless the domain is inside the service whitelist.

  - Solution found:
    
    - The domain being added had to be added manually to the service's trusted domains.

    - Examples of services that require whitelist configuration: Nextcloud and Homepage.

- Problem found:

    - Because Pi-hole itself is the DHCP server, the VM received its IP dynamically from itself — a risky circular dependency on reboot.

  - Solution found:

    - Configure a static IP at the operating system level (Netplan, /etc/netplan/*.yaml), independent of any DHCP.

- Problem found:

    - With the default network_mode (bridge), the Pi-hole DHCP server did not work: the DHCP broadcast does not cross the Docker bridge network, so devices never received a response and fell back to emergency IPs (APIPA, 169.254.x.x).

  - Solution found:

    - Switch to ``` bash network_mode: host ```, allowing the container to share the network directly with the host and receive broadcasts correctly.
