#!/bin/bash
# =============================================================================
# Stop all homelab stacks in reverse dependency order.
# Skips any stack that does not have a docker-compose.yml.
# Run from repository root. Requires: Docker, Docker Compose, .env in root.
# =============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

STACKS=(
  bookstack
  wireguard
  uptime-kuma
  wazuh
  monitoring
  portainer
  nginx
  authentik
  traefik
)

for stack in "${STACKS[@]}"; do
  compose_file="stacks/$stack/docker-compose.yml"
  if [ -f "$compose_file" ]; then
    echo "Stopping $stack..."
    docker compose -f "$compose_file" --env-file .env down
    echo "  $stack stopped."
  else
    echo "Skipping $stack (not present)"
  fi
done

echo "All stacks are down."
