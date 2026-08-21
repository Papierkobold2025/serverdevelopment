# Integration of Ntopng

- Ntopng is an application that improves Network security and facilitates debugging of network troubles.

- It's an overkill equally as wazuh, but proves to be valuable to debug where network packages fall or are blocked.

## Decisions

- I decided to implement ntopng in docker through ```bash network_mode: host ``` 

- Active Network Discovery and Active Monitoring were not activated as their function is already covered by wazuh and Netdata

- Network configuration was enabled and configured with expected DHCP and DNS servers as well as known Gateways to detect unknown servers.

- As notifications were expected SMTP was configured over msmtpd as the sending of emails didn't work natively in the ntopng interface.

## Issues

- Ntopng doesn't construct correctly the EHLO, as it uses the domain of the recipient as the domain as follows: dario@moralesdario.com/gmail.com

  - Workaround: using a recipient under the same domain as the sender avoids the malformed EHLO, since ntopng incorrectly builds it from the recipient's domain instead of its own.

- The Docker image crazymax/msmtpd doesn't worked as expected, using variable SMTP_DEFAULT_* is completely ignored if SMTP_HOST does not exist.

  - Normal compose configuration file was omitted, executing directly the binary through file mounted in volumes of the compose file

- Redis didn't save persistently changes made in ntopng, including password, activated toggles in the GUI and SMTP Alert configuration

  - Configuration file changed for redis, so that changes are written once every 60 seconds this worked until the second reboot

- Redis permissions didn't permit running the docker for redis.

  - chown configuration on file had to be corrected with permissions 101:101.

## Runbook
```bash
services:
  ntopng:
    image: ntop/ntopng:latest
    container_name: ntopng
    restart: unless-stopped
    network_mode: host
    cap_add:
      - NET_ADMIN
      - NET_RAW
    command: >
      --interface=eth0
      --http-port=3000
      --data-dir=/var/lib/ntopng
    volumes:
      - ./data:/var/lib/ntopng
      - ./redis-data:/var/lib/redis
      - ./redis.conf:/etc/redis/redis.conf:ro

  msmtpd:
    image: crazymax/msmtpd:latest
    container_name: msmtpd
    restart: unless-stopped
    network_mode: host
    entrypoint: ["msmtpd"]
    command: ["--interface=127.0.0.1", "--port=2500"]
    volumes:
      - /etc/msmtprc:/root/.msmtprc:ro
```