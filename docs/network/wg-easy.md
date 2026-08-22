# WG-Easy

- Installation of the wg-easy server on the K3s VM and on the Pi-hole VM.

## Decisions

- Because it is a minimal and lightweight service, I decided to keep it inside a VM.

- Installation of two separate wg-easy instances so that, when the time comes to restrict VLAN access, there is still a method to connect to the VLAN.

## Issues encountered

- The WG_PORT (UDP) and PORT (TCP) environment variables must match exactly the ports mapped in the `ports:` section of the compose file — Docker does not validate this consistency, so a mismatch does not generate any visible error, only causing wg-easy to fail silently in the connection.

  - Found solution: normalize the internal and external port to the same number (for example, `WG_PORT=1234` with mapping `"1234:1234/udp"`) instead of using different numbers, to eliminate that source of misalignment.

## Runbook

- Configuration of /srv/wg-easy/compose.yaml

```bash
services:
  wg-easy:
    image: ghcr.io/wg-easy/wg-easy
    container_name: wg-easy
    restart: unless-stopped
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    environment:
      - WG_HOST=${WG_PUBLIC_HOST} # fixed public IP or DDNS domain — not the VM's internal IP
      - PASSWORD_HASH=${WGEASY_PASSWORD_HASH}
      - PORT=51821
      - WG_PORT=51823
    volumes:
      - ./etc-wireguard:/etc/wireguard
    ports:
      - "51823:51823/udp"
      - "51821:51821/tcp"
    sysctls:
      - net.ipv4.ip_forward=1
      - net.ipv4.conf.all.src_valid_mark=1
```