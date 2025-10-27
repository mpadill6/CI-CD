from fastapi import FastAPI
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST
from fastapi.responses import PlainTextResponse

app = FastAPI(title="Python Docker CI Demo", version="1.0.0")
hits = Counter("hits_total", "Total HTTP hits", ["endpoint"])

@app.get("/")
def root():
    hits.labels(endpoint="/").inc()
    return {"message": "Hello from Dockerized FastAPI!"}

@app.get("/healthz")
def healthz():
    hits.labels(endpoint="/healthz").inc()
    return {"status": "ok"}

@app.get("/metrics")
def metrics():
    data = generate_latest()
    return PlainTextResponse(content=data.decode("utf-8"), media_type=CONTENT_TYPE_LATEST)
