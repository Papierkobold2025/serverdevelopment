# Keycloak Integration

- Keycloak integration to enable SSO sign-in for selected services.

## Decisions

- Keycloak was not used for Vaultwarden to avoid overlap between two critical services for the infrastructure.

- A Homelab realm was created to separate the administration panel from normal users.

### Issues encountered

- Creating a user with public configuration did not work, because to connect services it had to be able to generate an application token.

### Runbook

```bash
services:
  keycloak:
    image: quay.io/keycloak/keycloak:26.5.6
    container_name: keycloak
    restart: unless-stopped
    command: start
    environment:
      KC_BOOTSTRAP_ADMIN_USERNAME: '${KC_ADMIN_USER}'
      KC_BOOTSTRAP_ADMIN_PASSWORD: '${KC_ADMIN_PASSWORD}'
      KC_DB: postgres
      KC_DB_URL: jdbc:postgresql://keycloak-db:5432/keycloak
      KC_DB_USERNAME: '${KC_DB_USER}'
      KC_DB_PASSWORD: '${KC_DB_PASSWORD}'
      KC_HOSTNAME: keycloak.apps.midominio.com
      KC_HOSTNAME_STRICT: "false"
      KC_PROXY_HEADERS: xforwarded
      KC_HTTP_ENABLED: "true"
      KC_HEALTH_ENABLED: "true"
      KC_METRICS_ENABLED: "true"
    ports:
      - "192.168.1.124:8080:8080"
      - "192.168.1.124:9000:9000"
    mem_limit: 2g
    volumes:
      - keycloak-import:/opt/keycloak/data/import
    depends_on:
      keycloak-db:
        condition: service_healthy
    networks:
      - keycloak-net

  keycloak-db:
    image: postgres:16-alpine
    container_name: keycloak-db
    restart: unless-stopped
    environment:
      POSTGRES_DB: keycloak
      POSTGRES_USER: '${KC_DB_USER}'
      POSTGRES_PASSWORD: '${KC_DB_PASSWORD}'
    volumes:
      - keycloak-db-data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${KC_DB_USER}"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - keycloak-net

volumes:
  keycloak-db-data:
  keycloak-import:

networks:
  keycloak-net:
```
