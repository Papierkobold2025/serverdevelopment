# Immich Integration

- Immich was integrated into the infrastructure to take over picture storage instead of Nextcloud.

## Decisions

- Immich was integrated as a more targeted solution for storing pictures.

## Issues encountered

- API key generated with granular/limited permissions (deliberate choice, avoided granting all scopes by default) caused a 403 on the Homarr integration — Homarr's Immich widget hits endpoints beyond `/api/server/ping` (which works with any valid key) and needs broader scopes to actually pull data.

  - Solution found: regenerate the API key granting the scopes Homarr actually needs, instead of the full "all permissions" preset.

### Runbook

- Docker Compose configuration for Immich

```bash
services:
  immich-server:
    container_name: immich_server
    image: ghcr.io/immich-app/immich-server:${IMMICH_VERSION:-release}
    volumes:
      - ${UPLOAD_LOCATION}:/usr/src/app/upload
      - /etc/localtime:/etc/localtime:ro
    env_file:
      - .env
    ports:
      - '2283:2283'
    depends_on:
      - redis
      - database
    restart: unless-stopped
    healthcheck:
      disable: false

  immich-machine-learning:
    container_name: immich_machine_learning
    image: ghcr.io/immich-app/immich-machine-learning:${IMMICH_VERSION:-release}
    volumes:
      - model-cache:/cache
    env_file:
      - .env
    restart: unless-stopped
    healthcheck:
      disable: false

  redis:
    container_name: immich_redis
    image: docker.io/redis:6.2-alpine
    restart: unless-stopped

  database:
    container_name: immich_postgres
    image: ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0
    environment:
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      POSTGRES_USER: ${DB_USERNAME}
      POSTGRES_DB: ${DB_DATABASE_NAME}
      POSTGRES_INITDB_ARGS: '--data-checksums'
    volumes:
      - ${DB_DATA_LOCATION}:/var/lib/postgresql/data
    restart: unless-stopped

volumes:
  model-cache:
```