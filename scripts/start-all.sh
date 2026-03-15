#!/bin/bash
# =============================================================================
# Start all homelab stacks in dependency order.
# Skips any stack that does not yet have a docker-compose.yml.
# Run from repository root. Requires: Docker, Docker Compose, .env in root.
# =============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

echo "Creating shared network 'proxy' if missing..."
docker network inspect proxy >/dev/null 2>&1 || docker network create proxy

STACKS=(
  traefik
  authentik
  nginx
  portainer
  monitoring
  wazuh
  uptime-kuma
  wireguard
  bookstack
)

for stack in "${STACKS[@]}"; do
  compose_file="stacks/$stack/docker-compose.yml"
  if [ -f "$compose_file" ]; then
    echo "Starting $stack..."
    docker compose -f "$compose_file" --env-file .env up -d
    echo "  $stack started."
  else
    echo "Skipping $stack (not yet created)"
  fi
done

echo "Done."
