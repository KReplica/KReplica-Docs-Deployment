#!/usr/bin/env bash
set -euo pipefail

HOST_PORTS=(80 8080)

echo "[INFO] --reset flag detected. Deleting build/ directory..."
rm -rf build

echo "[INFO] Stopping and removing all Podman pods and containers..."
podman pod stop -a 2>/dev/null || true
podman pod rm -a -f 2>/dev/null || true
podman rm -a -f 2>/dev/null || true

echo "[INFO] Pruning Podman networks, volumes, and dangling images..."
podman network prune -f 2>/dev/null || true
podman volume  prune -f 2>/dev/null || true
podman image   prune -f 2>/dev/null || true

echo "[INFO] Killing any processes using ports: ${HOST_PORTS[*]}..."
for port in "${HOST_PORTS[@]}"; do
  if pids=$(lsof -t -i :"$port" 2>/dev/null); then
    echo "  [INFO] Port $port in use by PID(s): $pids — killing"
    kill "$pids" || true
    sleep 1
  fi
done

echo "[INFO] Environment reset complete."
