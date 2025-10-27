# Python Docker CI/CD Demo

A tiny FastAPI service packaged with Docker, optimized via multi‑stage builds, tested in CI, and auto‑deployed via GitHub Actions.

## What you get
- **FastAPI app** with `/` and `/healthz` endpoints
- **Dockerfile** (multi‑stage + non‑root + cache‑friendly + small final image)
- **.dockerignore** for smaller context
- **Makefile** helpers
- **docker-compose.yml** for local dev/prod parity
- **GitHub Actions**: CI (lint + test + build) and CD (push image to GHCR + remote deploy over SSH)

---
## Quickstart (local)
```bash
# 1) Build & run locally
docker compose up --build

# 2) Open http://localhost:8000
#    Health check: http://localhost:8000/healthz
```

## GitHub Actions Setup
1. Push this repository to GitHub.
2. In **Settings → Actions → General**, ensure workflows are enabled.
3. In **Settings → Actions → General → Workflow permissions**, enable **Read and write permissions**.
4. In **Settings → Secrets and variables → Actions → Secrets**, add (for deploy job):
   - `SSH_HOST` – public IP or host of your Linux box
   - `SSH_USER` – ssh username on the box
   - `SSH_KEY` – private key (PEM) for that user
5. Optional **variables** (Settings → Actions → Variables):
   - `APP_NAME` (default `python-docker-ci-demo`)
   - `APP_PORT` (default `8000`)

## Container Registry (GHCR)
These workflows push to **GitHub Container Registry** at `ghcr.io/<owner>/<repo>:<sha>`.
Make sure **Packages** permissions are enabled: **Settings → Packages → Manage actions access**.

## Remote Host (for CD)
Prepare a Linux host with Docker and Docker Compose v2 installed:
```bash
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER && newgrp docker
DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
mkdir -p "$DOCKER_CONFIG"
```

Create a `.env` file on the server (same directory where deployment will run):
```env
APP_NAME=python-docker-ci-demo
APP_PORT=8000
IMAGE_REF=ghcr.io/<owner>/<repo>:latest
```

## Deploy Flow
- CI builds & tests → pushes image to GHCR with two tags: commit SHA and `latest`.
- CD (deploy) SSHes into your server, `docker login ghcr.io`, pulls `:latest`, and restarts via `docker compose up -d`.

## Teaching notes
- **Dockerfile creation**: multi‑stage, small surface, non‑root, health endpoint.
- **Container optimization**: slim base, wheels cache, `.dockerignore`, `--no-cache-dir`, layer ordering.
- **GitHub Actions setup**: matrix for Python, separate jobs, dependency cache, GHCR auth.
- **Deployment automation**: idempotent deploy script, compose for parity, health check.
```
