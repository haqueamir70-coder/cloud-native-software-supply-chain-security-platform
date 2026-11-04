# Run the lab

## Prerequisites
- Python 3.12 and pip for the API/tests.
- Docker with Compose plugin for the local container.
- Trivy and Syft for local security/SBOM exercises.
- kubectl, kind and Helm for the Kubernetes admission lab.
- A GitHub account with Actions enabled and package publishing permission for the GHCR release workflow.

## 1. Run the API and tests locally

```bash
python -m venv .venv
# Linux/macOS
source .venv/bin/activate
# Windows PowerShell: .venv\Scripts\Activate.ps1
python -m pip install -r requirements-dev.txt
python -m pytest -q
uvicorn app.main:app --reload
```

Check `http://127.0.0.1:8000/healthz`, `/readyz`, and `/version`.

## 2. Build a hardened local container

```bash
docker compose up --build -d
docker compose ps
curl http://127.0.0.1:8000/healthz
docker compose down
```

The Compose stack also starts Prometheus and Grafana:
- Prometheus: `http://127.0.0.1:9090`
- Grafana: `http://127.0.0.1:3000` (local demo default is `admin/admin`; set `GRAFANA_ADMIN_PASSWORD` before starting and never reuse this default outside a disposable lab).
- The provisioned **Supply Chain Demo API** dashboard shows request rate, p95 latency, total requests and status-code distribution.
- Prometheus scrapes the API at `api:8000/metrics`.

Generate traffic by opening `http://127.0.0.1:8000/` and `/healthz` several times, then refresh the Grafana dashboard.

The image runs as UID 10001. Compose adds a read-only root filesystem, drops Linux capabilities and disables privilege escalation. For Windows PowerShell, use `Invoke-RestMethod http://127.0.0.1:8000/healthz` instead of curl if curl is aliased.

## 3. Run local scans and generate an SBOM

```bash
trivy fs --scanners vuln,secret,misconfig --severity HIGH,CRITICAL .
syft dir:. -o spdx-json=sbom.spdx.json
```

A local source-directory SBOM is not the same as an SBOM generated from the final container image. The release workflow generates image build evidence and exports an image SBOM.

## 4. GitHub release workflow

A push to `main` triggers `.github/workflows/release.yml`. It:
1. builds and pushes the API image to GHCR;
2. captures the pushed image digest;
3. scans that digest with Trivy;
4. signs the exact digest using Cosign keyless signing;
5. generates GitHub build provenance;
6. exports an SPDX SBOM as a workflow artifact.

The workflow requires GitHub Actions, GHCR package permissions, and OIDC/attestation permissions. Check the Actions tab for the actual result. The repository being public does not guarantee that package publishing or attestations are enabled in the account/org settings.

## 5. Kubernetes lab

Create a local cluster:

```bash
kind create cluster --name supply-chain-lab
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update
helm install kyverno kyverno/kyverno -n kyverno --create-namespace
kubectl apply -f k8s/namespace.yaml
```

Wait for Kyverno to become ready:

```bash
kubectl -n kyverno rollout status deployment/kyverno-admission-controller
```

After a successful release, copy the exact image digest from the workflow summary. Set the deployment image to:

```
ghcr.io/haqueamir70-coder/cloud-native-software-supply-chain-security-platform/api@sha256:YOUR_REAL_DIGEST
```

Then apply the deployment and service:

```bash
kubectl apply -f k8s/deployment.yaml
kubectl rollout status deployment/supply-chain-demo-api -n supply-chain-demo
kubectl port-forward -n supply-chain-demo svc/supply-chain-demo-api 8080:80
```

In another terminal, call `http://127.0.0.1:8080/healthz`.

## 6. Admission policy exercise

The policy in `k8s/kyverno/verify-image-policy.yaml` constrains the expected keyless GitHub Actions identity and provenance issuer. It starts in **Audit** mode. Apply it:

```bash
kubectl apply -f k8s/kyverno/verify-image-policy.yaml
kubectl get clusterpolicy verify-supply-chain-demo-images
```

Check policy reports and Kyverno logs. First test:
- trusted image with matching signature and provenance;
- unsigned image;
- image signed by another repository/workflow;
- digest that differs from the signed subject.

Only after all cases behave as expected should you change `validationFailureAction: Audit` to `Enforce` and apply the policy again. Do not enable cluster-wide enforcement on a production cluster as part of this demo.

## Troubleshooting
- **GHCR denied:** verify package visibility/permissions and that workflow has `packages: write`.
- **Attestation denied:** verify `id-token: write`, `attestations: write`, repository settings and trusted workflow identity.
- **Kyverno cannot verify:** compare the certificate subject and issuer with the policy exactly; confirm image digest and registry reachability.
- **Image pull fails:** ensure package visibility or configure an image pull secret for a private package.
- **Admission blocks system workloads:** policy is namespace-scoped to `supply-chain-demo`; inspect the match block before changing scope.

This is a learning lab. Use disposable infrastructure and validate all failure cases before adapting it to production.
