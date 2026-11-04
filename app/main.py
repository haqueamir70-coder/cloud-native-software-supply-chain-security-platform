"""Small, non-sensitive API used to demonstrate secure container delivery."""
import os
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse

VERSION = os.getenv("APP_VERSION", "0.1.0")
app = FastAPI(
    title="Supply Chain Demo API",
    description="A minimal workload for demonstrating image provenance and admission verification.",
    version=VERSION,
    docs_url="/docs",
    redoc_url=None,
)

@app.middleware("http")
async def security_headers(request: Request, call_next):
    response = await call_next(request)
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
