#!/bin/bash
set -euo pipefail

POD_NAME="kreplica-pod"
DOCS_REPO="https://github.com/KReplica/KReplica-Docs.git"
DOCS_BRANCH="transfer-docs"
DOCS_DIR="build/KReplica-Docs"

./reset-env.sh

mkdir -p build

# Download KReplica-Docs
if [ ! -d "$DOCS_DIR" ]; then
    echo "[INFO] Cloning $DOCS_REPO, branch $DOCS_BRANCH..."
    git clone --branch "$DOCS_BRANCH" "$DOCS_REPO" "$DOCS_DIR"
else
    echo "[INFO] $DOCS_DIR already exists."
fi

echo "[INFO] Repositories are ready in ./build/"

# Podman build & deploy
podman build -f Containerfile -t kreplica-docs:local "$DOCS_DIR"

podman pod stop $POD_NAME 2>/dev/null || true
podman pod rm $POD_NAME 2>/dev/null || true

podman pod create --name $POD_NAME -p 8080:8080

podman run -d --pod $POD_NAME --name kreplica-docs-app kreplica-docs:local

echo "[INFO] Pod and containers are running. Use 'podman ps --pod' to check status."
