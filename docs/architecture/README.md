# Architecture and trust boundaries

## Four trust zones
1. **Source zone** — reviewed source, protected branches, dependency metadata and workflow definitions.
2. **Build zone** — isolated CI execution, workload identity, build process, scanning, SBOM and provenance.
3. **Artifact zone** — registry, immutable digest, signature and attestations.
4. **Runtime zone** — Kubernetes admission verification, policy enforcement, deployment and monitoring.

Trust chain: `reviewed commit → trusted workflow identity → controlled build → image digest → scan + SBOM + provenance → signature → admission verification → runtime`. Every arrow is a security boundary; downstream components verify evidence rather than trusting an earlier job's green status.

## Release sequence
1. A pull request runs tests, static checks, dependency review and source scanning.
2. A protected-branch event starts release.
3. GitHub Actions requests short-lived credentials using OIDC.
4. The workflow builds the container and captures its immutable digest.
5. Trivy evaluates filesystem and image against severity/exception policy.
6. Syft creates an SBOM for the built image.
7. The workflow publishes the image and generates provenance/attestations.
8. Cosign signs the digest using intended keyless identity.
9. Kubernetes admission receives a workload request; Kyverno verifies signature and allowed issuer/identity.
10. Only then can the workload be admitted. Runtime monitoring continues after deployment.

## Security design decisions

| Decision | Rationale | Trade-off |
|---|---|---|
| Digest pinning | Prevents tag movement silently changing deployed content | Requires digest promotion automation |
| Keyless signing | Avoids distributing long-lived signing keys to CI | Depends on identity/transparency services |
| Admission verification | Enforces trust at cluster boundary | Misconfiguration can block releases |
| Scan + exception policy | Converts findings into governed decisions | Requires owners, expiry and review |
| SBOM per digest | Inventory tied to exact artifact | Must be regenerated for changed artifacts |
| Provenance verification | Validates build origin and identity | Policy must constrain trusted builders |

## Failure paths to test
- OIDC trust condition does not match repository or branch.
- Image changes after signing, producing digest mismatch.
- Vulnerability policy blocks release.
- SBOM generation fails or refers to different digest.
- Signature is absent, invalid or created by untrusted identity.
- Provenance subject does not match deployed image.
- Registry unavailable during admission.
- Kyverno policy audit/enforce mode or unavailable.
- Emergency rollback requires a previously verified digest.

See [interactive architecture](interactive.html), [threat model](../security/threat-model.md) and [roadmap](../implementation/roadmap.md).
