# Implementation roadmap

Implement in independently verifiable increments. A YAML or policy file existing does not prove its control works.

## Phase 0 — Repository and developer experience
- [x] Architecture narrative, diagrams, trust boundaries and threat model.
- [x] Senior-level interview handbook.
- [ ] Contribution, code-owner and security disclosure guidance.
- [ ] Local prerequisites and repeatable smoke-test entry point.

## Phase 1 — Minimal application and testable container
- [ ] Implement a non-sensitive demo API with health and version endpoints.
- [ ] Add unit tests, non-root container user, minimal base image and pinned dependencies.
- [ ] Add local Docker build and runtime smoke test.
- Acceptance: tests pass; container runs as non-root; health endpoint succeeds.

## Phase 2 — Continuous integration
- [ ] Pull request workflow: tests, lint, secret scan, dependency review and Trivy filesystem scan.
- [ ] Release workflow on protected branch/tag.
- [ ] Pin third-party Actions to reviewed commit SHAs.
- [ ] Set least-privilege job permissions.
- Acceptance: untrusted PR cannot publish image or access release credentials.

## Phase 3 — Image and security evidence
- [ ] Build OCI image and capture digest output.
- [ ] Scan final image with Trivy; fail according to documented policy.
- [ ] Generate Syft SBOM for exact digest.
- [ ] Retain evidence as workflow artifacts.
- Acceptance: SBOM subject and scan target match image digest.

## Phase 4 — Signing and provenance
- [ ] Publish image to registry.
- [ ] Use GitHub OIDC / supported keyless identity for Cosign.
- [ ] Generate artifact attestation/provenance.
- [ ] Verify signature, issuer, certificate identity and subject digest in a separate job.
- Acceptance: altered digest, wrong identity and missing signature fail verification.

## Phase 5 — Kubernetes admission
- [ ] Add local kind cluster setup.
- [ ] Install Kyverno from a pinned chart/release.
- [ ] Add verifyImages policy constrained to trusted CI identity.
- [ ] Add positive and negative policy tests.
- [ ] Start in audit mode, then explicitly switch to enforce in lab namespace.
- Acceptance: trusted image admitted; unsigned, changed and wrong-identity images rejected.

## Phase 6 — Operations and governance
- [ ] Dashboards for scan findings, signature verification, admission denials and deployment evidence.
- [ ] Exception register with owner, rationale and expiry.
- [ ] Runbooks for registry outage, compromised workflow, signing identity compromise and emergency rollback.
- Acceptance: tabletop exercises document detection, containment, recovery and evidence retention.

## Definition of done
A control is complete only when code/configuration exists, positive and negative tests are repeatable, expected evidence is captured, and failure/rollback behavior is documented.
