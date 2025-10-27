# ---------- Base builder: install deps & build wheels ----------
FROM python:3.12-slim AS builder

ENV PYTHONDONTWRITEBYTECODE=1             PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends             build-essential curl &&             rm -rf /var/lib/apt/lists/*

WORKDIR /wheels
COPY requirements.txt .
RUN pip wheel --no-cache-dir --wheel-dir=/wheels -r requirements.txt

# ---------- Runtime: small, non-root, copy wheels ----------
FROM python:3.12-slim

LABEL org.opencontainers.image.source="https://github.com/OWNER/REPO"

ENV PYTHONDONTWRITEBYTECODE=1             PYTHONUNBUFFERED=1             PORT=8000

# Add a non-root user
RUN useradd -m appuser

WORKDIR /app
COPY --from=builder /wheels /wheels
RUN pip install --no-cache-dir /wheels/*.whl && rm -rf /wheels

# Copy source
COPY app/ app/

EXPOSE 8000
HEALTHCHECK --interval=10s --timeout=3s --retries=3 CMD curl -f http://localhost:8000/healthz || exit 1

USER appuser

# Gunicorn + Uvicorn workers for production
CMD ["gunicorn", "-k", "uvicorn.workers.UvicornWorker", "app.main:app", "--bind", "0.0.0.0:8000", "--workers", "2", "--threads", "4", "--timeout", "60"]
