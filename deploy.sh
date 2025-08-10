#!/bin/bash
set -euo pipefail

CERTS_PATH="/root/certs"

if [ ! -d "${CERTS_PATH}" ] || [ -z "$(ls -A "${CERTS_PATH}")" ]; then
    echo "[ERROR] Certificates directory not found or is empty at: ${CERTS_PATH}" >&2
    echo "[ERROR] Please ensure your cert.pem and key.pem are placed there." >&2
    exit 1
fi

POD_NAME="kreplica-pod"
DOCS_REPO="https://github.com/KReplica/KReplica-Docs.git"
DOCS_BRANCH="master"
DOCS_DIR="build/KReplica-Docs"

./reset-env.sh

mkdir -p build

# Download KReplica-Docs
if [ ! -d "$DOCS_DIR" ]; then
    echo "[INFO] Cloning $DOCS_REPO, branch $DOCS_BRANCH..."
    git clone --depth 1 --branch "$DOCS_BRANCH" "$DOCS_REPO" "$DOCS_DIR"
else
    echo "[INFO] $DOCS_DIR already exists."
fi

echo "[INFO] Repositories are ready in ./build/"

# Podman build & deploy
podman build -f Containerfile -t kreplica-docs:local "$DOCS_DIR"
podman build -f nginx/Containerfile -t kreplica-nginx:local .

podman pod stop $POD_NAME 2>/dev/null || true
podman pod rm $POD_NAME 2>/dev/null || true

podman pod create --name $POD_NAME -p 80:80 -p 443:443

podman run -d --pod $POD_NAME --name kreplica-nginx \
  -v "${CERTS_PATH}":/etc/nginx/ssl:ro \
  kreplica-nginx:local

podman run -d --pod $POD_NAME --name kreplica-docs-app kreplica-docs:local

echo "[INFO] Pod and containers are running. Use 'podman ps --pod' to check status."