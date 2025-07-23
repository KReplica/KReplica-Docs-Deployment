#!/bin/bash
set -euo pipefail

POD_NAME="kreplica-pod"
DOCS_REPO="https://github.com/KReplica/KReplica-Docs.git"
DOCS_BRANCH="transfer-docs"
SANDBOX_REPO="https://github.com/KReplica/KReplica-Sandbox.git"
DOCS_DIR="build/KReplica-Docs"
SANDBOX_DIR="build/KReplica-Sandbox"

# Clear build folder on reset
if [[ "${1:-}" == "--reset" ]]; then
    echo "[INFO] --reset flag detected. Deleting build/ directory..."
    rm -rf build
fi

mkdir -p build

# Download KReplica-Docs
if [ ! -d "$DOCS_DIR" ]; then
    echo "Cloning $DOCS_REPO, branch $DOCS_BRANCH..."
    git clone --branch "$DOCS_BRANCH" "$DOCS_REPO" "$DOCS_DIR"
else
    echo "$DOCS_DIR already exists."
fi


# Download KReplica-Sandbox
if [ ! -d "$SANDBOX_DIR" ]; then
    echo "Cloning $SANDBOX_REPO..."
    git clone "$SANDBOX_REPO" "$SANDBOX_DIR"
else
    echo "$SANDBOX_DIR already exists."
fi

echo "Repositories are ready in ./build/"