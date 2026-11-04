"""Small, non-sensitive API used to demonstrate secure container delivery."""
import os
from time import perf_counter

from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse, Response
from prometheus_client import CONTENT_TYPE_LATEST, Counter, Histogram, generate_latest

VERSION = os.getenv("APP_VERSION", "0.1.0")
REQUEST_COUNT = Counter(
    "http_requests_total",
    "Total HTTP requests handled by the demo API.",
    ["method", "path", "status"],
)
REQUEST_DURATION = Histogram(
    "http_request_duration_seconds",
    "HTTP request duration in seconds.",
    ["method", "path"],
)

app = FastAPI(
    title="Supply Chain Demo API",
    description="A minimal workload for demonstrating secure container delivery and runtime observability.",
    version=VERSION,
    docs_url="/docs",
    redoc_url=None,
)

@app.middleware("http")
async def security_headers_and_metrics(request: Request, call_next):
    if request.url.path == "/metrics":
        return await call_next(request)

    started = perf_counter()
    response = await call_next(request)
    route = request.scope.get("route")
    path = getattr(route, "path", "unmatched")
    REQUEST_COUNT.labels(request.method, path, str(response.status_code)).inc()
    REQUEST_DURATION.labels(request.method, path).observe(perf_counter() - started)

    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["X-Frame-Options"] = "DENY"
    response.headers["Referrer-Policy"] = "no-referrer"
    response.headers["Cache-Control"] = "no-store"
    return response

@app.get("/healthz", tags=["operations"])
async def healthz():
    return {"status": "ok"}

@app.get("/readyz", tags=["operations"])
async def readyz():
    # Extend this with dependency checks when the demo gains external services.
    return {"status": "ready"}

@app.get("/version", tags=["operations"])
async def version():
    return {"name": "supply-chain-demo-api", "version": VERSION}

@app.get("/metrics", include_in_schema=False)
async def metrics():
    return Response(content=generate_latest(), headers={"Content-Type": CONTENT_TYPE_LATEST})

@app.get("/", tags=["application"])
async def root():
    return {
        "service": "Cloud-Native Supply Chain Security Demo",
        "message": "Artifact trust is verified at deployment time.",
        "version": VERSION,
    }

@app.exception_handler(Exception)
async def unexpected_error_handler(request: Request, exc: Exception):
    # Do not leak stack traces or internal exception details to clients.
    return JSONResponse(status_code=500, content={"detail": "Internal server error"})
