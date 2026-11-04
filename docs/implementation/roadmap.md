# Implementation roadmap

This roadmap distinguishes **implemented configuration** from **verified operational behavior**. A file existing is not proof that a control has passed its acceptance test.

## Phase 0 — Repository and developer experience
- [x] Architecture narrative, premium static/interactive diagrams and trust boundaries.
- [x] Senior-level 8+ years interview handbook and scenario framework.
- [x] Threat model, architecture decision records and security disclosure guidance.
- [x] Local prerequisites and repeatable lab guide.
- [x] Operational runbooks.
- [ ] Add CODEOWNERS and contribution workflow.

## Phase 1 — Application and container
- [x] Non-sensitive FastAPI demo API with health, readiness, version and metrics endpoints.
- [x] Automated API and metrics tests.
- [x] Non-root container (UID 10001), pinned application dependencies and health check.
- [x] Hardened Compose service settings: read-only root filesystem, dropped capabilities and no-new-privileges.
- [x] Docker build and Hadolint validation in CI.
- [ ] Confirm the full Compose smoke test (API + Prometheus + Grafana) passes in the latest CI run.

## Phase 2 — Continuous integration and release
- [x] Pull request workflow for tests, Trivy source/secret scanning, Kubernetes manifest scanning and Terraform validation.
- [x] Release workflow builds and publishes an OCI image to GHCR.
- [x] Least-privilege workflow permissions and OIDC-based keyless signing.
- [x] CI action references pinned to immutable commit SHAs.
- [ ] Pin all release workflow actions to immutable SHAs as well.

## Phase 3 — Image and security evidence
- [x] Build OCI image and capture immutable digest.
- [x] Scan the pushed image digest with Trivy; high/critical findings block promotion.
- [x] Generate SPDX SBOM for the exact pushed image using Syft.
- [x] Upload SBOM and build evidence as workflow artifacts.
- [x] A release run completed successfully with image scan, signing, provenance and SBOM generation.
- [ ] Retain and verify the evidence in the Kubernetes admission lab.

## Phase 4 — Signing and provenance
- [x] Publish image to GHCR.
- [x] Cosign keyless signature using GitHub Actions identity.
- [x] GitHub build provenance attestation.
- [x] Release workflow includes a Cosign verification step constrained to the expected workflow identity.
- [ ] Confirm the latest release run passes the explicit signature-verification step.

## Phase 5 — Kubernetes admission
- [x] Kubernetes namespace, hardened Deployment and Service manifests.
- [x] Kyverno policy checks keyless signature identity and SLSA provenance.
- [x] Policy starts in Audit mode; lab guide documents staged enforcement.
- [x] Local kind + Kyverno installation instructions.
- [ ] Run positive and negative admission tests against the published signed digest.
- [ ] Switch the demo namespace policy to Enforce only after those tests pass.

## Phase 6 — Observability and governance
- [x] Prometheus request counters and latency histograms exposed by the API.
- [x] Prometheus scrape configuration.
- [x] Provisioned Grafana datasource and API dashboard (request rate, p95 latency, total requests and status codes).
- [x] Runbooks for vulnerability gate, signature verification, admission denial, compromised workflow and registry outage.
- [ ] Add a time-bound security exception register with owner, rationale, compensating control and expiry.
- [ ] Exercise incident response and rollback in a disposable cluster.

## Definition of done

A control is complete only when code/configuration exists, positive and negative tests are repeatable, expected evidence is captured, and failure/rollback behavior is documented. Cloud infrastructure is intentionally not applied by CI because the optional Azure AKS lab creates billable resources.
