.PHONY: install test run build up down scan sbom

install:
	python -m pip install -r requirements-dev.txt

test:
	python -m pytest -q

run:
	uvicorn app.main:app --reload --host 127.0.0.1 --port 8000

build:
	docker build -t supply-chain-demo-api:local .

up:
	docker compose up --build -d

down:
	docker compose down

scan:
	trivy fs --scanners vuln,secret,misconfig .

sbom:
	syft dir:. -o spdx-json=sbom.spdx.json
