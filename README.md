<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:111827,50:7C3AED,100:06B6D4&height=190&section=header&text=Cloud+Native+Supply+Chain+Security&fontSize=32&fontColor=ffffff&animation=fadeIn" alt="Cloud Native Supply Chain Security project banner" width="100%" />

<img src="https://readme-typing-svg.demolab.com/?font=Inter&weight=600&size=16&pause=1600&color=38BDF8&center=true&vCenter=true&width=900&height=36&lines=Cloud+Native+Supply+Chain+Security+%E2%80%A2+Architecture+%E2%80%A2+Automation+%E2%80%A2+Security" alt="Animated project focus line" />

![Security](https://img.shields.io/badge/Software+Supply+Chain-7C3AED?style=for-the-badge) ![Kubernetes](https://img.shields.io/badge/Cloud+Native-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white) ![CI](https://img.shields.io/badge/GitHub+Actions-2088FF?style=for-the-badge&logo=githubactions&logoColor=white)

</div>

---

# Cloud-Native Software Supply Chain Security Platform

> A production-minded DevSecOps reference implementation establishing verifiable trust from source commit to Kubernetes runtime.

[![CI Security Checks](https://github.com/haqueamir70-coder/cloud-native-software-supply-chain-security-platform/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/haqueamir70-coder/cloud-native-software-supply-chain-security-platform/actions/workflows/ci.yml)
[![Signed Container Release](https://github.com/haqueamir70-coder/cloud-native-software-supply-chain-security-platform/actions/workflows/release.yml/badge.svg?branch=main)](https://github.com/haqueamir70-coder/cloud-native-software-supply-chain-security-platform/actions/workflows/release.yml)

[![Architecture](docs/architecture/architecture.svg)](docs/architecture/interactive.html)

This lab demonstrates controlled builds, vulnerability scanning, SBOM generation, provenance, artifact signing and Kubernetes admission verification. A green build is not automatically a trusted deployment: the cluster independently verifies the artifact.

## Capabilities
- GitHub Actions with least-privilege permissions and OIDC short-lived identity.
- Immutable OCI image digests; do not trust mutable tags as integrity evidence.
- Trivy source/image scanning under explicit block and exception policy.
- Syft SBOM generation tied to the exact artifact digest.
- Cosign/Sigstore signatures and build provenance/attestations.
- Kubernetes admission enforcement with Kyverno verifyImages.
- Operational evidence, threat modelling, runbooks and senior interview preparation.

## Architecture

[Open the interactive architecture preview](https://haqueamir70-coder.github.io/cloud-native-software-supply-chain-security-platform/) after enabling GitHub Pages using [these steps](docs/implementation/github-pages.md).
- [Interactive animated architecture](docs/architecture/interactive.html)
- [Static architecture diagram](docs/architecture/architecture.svg)
- [Architecture and trust boundaries](docs/architecture/README.md)
- [Architecture decision records](docs/architecture/decisions/)

## Run it

The optional [Azure AKS Terraform lab](terraform/azure/README.md) provisions billable infrastructure; review the cost warning before applying. The current Kubernetes Deployment is pinned to a verified signed image digest.

See the [end-to-end lab guide](docs/implementation/run-the-lab.md) for local tests, Docker Compose, Trivy/Syft, GHCR release, Cosign signing and the Kyverno lab.

```bash
python -m pip install -r requirements-dev.txt
python -m pytest -q
docker compose up --build -d
```

## Observability

The Compose stack provisions Prometheus and Grafana with an API dashboard for request rate, p95 latency, request totals and status codes. See the [monitoring configuration](monitoring/) and [lab guide](docs/implementation/run-the-lab.md).

## Learning path
1. [Threat model](docs/security/threat-model.md)
2. [Security exception register](docs/security/exception-register.md)
3. [Implementation roadmap](docs/implementation/roadmap.md)
4. [8+ years senior DevSecOps interview handbook](docs/interview/README.md)
5. [Scenario answer framework](docs/interview/scenario-answer-template.md)
6. [Senior interview project walkthrough](docs/interview/project-walkthrough.md)

## Technology map

| Capability | Tooling | Evidence |
|---|---|---|
| Source CI | GitHub Actions | Workflow run and test results |
| Workload identity | GitHub OIDC | Short-lived federated identity |
| Container build | Docker / BuildKit | Immutable digest |
| Vulnerability scanning | Trivy | Scan report and policy result |
| SBOM | Syft | SPDX / CycloneDX inventory |
| Signing | Cosign / Sigstore | Signature tied to digest and identity |
| Provenance | GitHub attestations / SLSA concepts | Build provenance |
| Admission | Kubernetes + Kyverno | Reject untrusted images |
| Observability | Prometheus / Grafana | Security and delivery signals |

## Security caveats
A signature proves that an identity signed a digest; it does not prove the image is vulnerability-free. An SBOM is an inventory, not a security certification. Provenance is only as trustworthy as its builder, source controls and verification policy. Never commit production credentials, private signing keys, customer telemetry or real secrets.

## Verified release evidence

[Open a successful signed-image release run](https://github.com/haqueamir70-coder/cloud-native-software-supply-chain-security-platform/actions/runs/41786989755). The run passed image scanning, Cosign keyless signing and identity verification, GitHub provenance generation, and SPDX SBOM upload.

## Status
The source-to-image CI/release path is implemented and has a successful GitHub Actions run covering tests, Trivy scans, Terraform validation, Docker Compose smoke tests, image signing, signature verification, provenance and SPDX SBOM upload. Kubernetes admission policy is configured in Audit mode; positive/negative admission tests and Enforce rollout still require a disposable kind/AKS cluster. The optional AKS Terraform root is validated in CI but has not been applied because it creates billable Azure resources. See the [roadmap](docs/implementation/roadmap.md) for exact completion boundaries.


## Architecture and interview preparation

See the [architecture diagram and interview questions](docs/README.md) for the repository-specific design walkthrough and technical interview guide.
