# ADR 0002: Verify artifact identity at Kubernetes admission

- **Status:** Accepted for this lab design
- **Decision:** Kubernetes admission independently verifies container signature and configured trusted identity.

## Context
CI controls can be bypassed by alternate deployers, mutable tags, compromised registry permissions or drift between build and deployment. A cluster boundary provides a final independent check.

## Decision
Use a policy engine such as Kyverno to verify signatures for selected namespaces and repositories. Constrain accepted signing identity/issuer to expected release workflow. Roll out in audit mode before enforcement.

## Consequences
- Admission introduces availability and latency dependencies.
- Policy scope, exclusions and break-glass access require review.
- Positive and negative tests are mandatory.
- Runtime teams need visibility into denial reasons and a tested recovery path.
