#!/usr/bin/env bash
set -euo pipefail

: "${IMAGE_REF:?IMAGE_REF is required}"
: "${APP_PORT:=8000}"

echo "[deploy] Logging in to GHCR"
echo "${GHCR_TOKEN}" | docker login ghcr.io -u "${GHCR_USERNAME}" --password-stdin

echo "[deploy] Pulling image ${IMAGE_REF}"
docker pull "${IMAGE_REF}"

echo "[deploy] Starting with docker compose"
IMAGE_TAG=latest GITHUB_REPOSITORY="${GITHUB_REPOSITORY}" APP_PORT="${APP_PORT}" docker compose up -d --remove-orphans

echo "[deploy] Pruning old images"
docker image prune -af || true

echo "[deploy] Done."
