# Interview project walkthrough — senior DevSecOps (8+ years)

Use this as a truthful walkthrough of the repository. Separate controls already demonstrated by CI from the Kubernetes admission lab steps that still require a disposable cluster.

## 60-second introduction

"I built a cloud-native software supply-chain security lab that protects an application from source commit to Kubernetes runtime. The pipeline runs tests and security scans, builds a container using a pinned base-image digest, publishes the image by immutable digest, scans it with Trivy, generates an SPDX SBOM with Syft, signs it with Cosign keyless identity and generates GitHub build provenance. The release workflow verifies the signature against the expected GitHub Actions identity. At runtime, a Kyverno policy is designed to verify the same signing identity and provenance before admitting the workload. I also added Terraform for an optional AKS lab, hardened Kubernetes manifests, Prometheus metrics, Grafana dashboards, threat modelling and operational runbooks."

## Three-minute architecture explanation

### 1. Source and CI trust
- Protected source and pull-request checks are the first trust boundary.
- CI runs API tests, Trivy source/secret checks, Kubernetes manifest scanning, Terraform fmt/validate, Docker Compose smoke tests and Hadolint.
- CI permissions are read-only unless a job requires more.

### 2. Artifact creation
- BuildKit creates an OCI image and records the resulting digest.
- The image uses a digest-pinned Python base image and runs as UID 10001.
- The final image is scanned, not just the source tree. High/critical findings block promotion.

### 3. Evidence and authenticity
- Syft produces SPDX inventory for the exact image digest.
- Cosign keyless signing uses the GitHub Actions OIDC identity.
- The workflow verifies certificate identity and issuer, then generates GitHub build provenance.
- The SBOM is retained as a workflow artifact.

### 4. Runtime enforcement
- Kubernetes uses a restricted namespace and non-root deployment settings.
- Kyverno's verifyImages policy checks the expected workflow identity and SLSA provenance.
- The policy starts in Audit mode; move to Enforce only after valid, unsigned, wrong-identity and changed-digest test cases have been run.

### 5. Operations
- Prometheus scrapes API request and latency metrics.
- Grafana dashboard shows request rate, p95 latency, total requests and HTTP status distribution.
- Runbooks cover vulnerabilities, signing failure, admission denial, registry outage and workflow compromise.

## Five-minute demo sequence

1. Open the architecture diagram and explain the four trust zones.
2. Run `python -m pytest -q` and show the API tests.
3. Run `docker compose up --build -d`; show the API health endpoint.
4. Open Prometheus and Grafana; generate API requests and show the dashboard.
5. Open the GitHub Actions release run; show the successful Trivy image scan, Cosign signing, signature verification, provenance and SBOM artifact.
6. Show the published image digest and explain why deployment uses the digest rather than a mutable tag.
7. Show the Kyverno policy and explain how you would test signed and unsigned images in a disposable kind/AKS cluster.
8. Close with a failure scenario: a malicious or unsigned image is rejected at admission even if someone attempts to bypass the CI release path.

## Senior-level design decisions to defend

| Decision | Interview explanation |
|---|---|
| Why digest instead of tag? | Tags are mutable; digest identifies the exact artifact bytes. |
| Why scan after build? | Source scanning cannot see every package introduced by the final image/base image. |
| Why SBOM? | It supports inventory, impact analysis and license/vulnerability response; it is not proof of safety. |
| Why sign and attest? | Signature binds identity to digest; provenance describes the build origin and materials. |
| Why verify at admission? | CI success alone does not prove that the deployed artifact is the one that was scanned and signed. |
| Why keyless signing? | It avoids long-lived private signing keys in CI; trust must still constrain issuer and identity. |
| Why Audit before Enforce? | It reveals false positives and scope mistakes before a policy can block production workloads. |
| Why keep runbooks? | A control without an outage and rollback plan is not production-ready. |

## Honest status statement

The repository has a successful GitHub release run demonstrating image build, Trivy image scan, Cosign keyless signing, signature verification, GitHub provenance and SPDX SBOM artifact upload. The local Kubernetes/Kyverno policy is provided with an Audit-first guide; do not claim a production cluster admission test has passed until you run the positive and negative cases in a disposable cluster. The optional AKS Terraform root is validated in CI but has not been applied, because it provisions billable Azure infrastructure.

## How to make the story credible

Use the exact workflow run and digest as evidence. Explain one failure you encountered: the first image scan found vulnerable transitive/vendor packages in the container, so the dependency/base-image layer was upgraded and the security gate was kept blocking until the scan passed. This demonstrates remediation rather than hiding findings.
