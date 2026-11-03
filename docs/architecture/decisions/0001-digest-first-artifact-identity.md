# ADR 0001: Use immutable image digests as artifact identity

- **Status:** Accepted for this lab design
- **Decision:** Security evidence and deployment references are bound to OCI image digests, not mutable tags.

## Context
Tags are convenient labels but can be reassigned. A scan or signature associated only with a tag may no longer describe the bytes later pulled by a cluster.

## Decision
Capture image digest from build/push. Generate SBOM, signature and provenance whose subject references that digest. Deployment manifests reference the same digest. Admission verifies evidence against that exact artifact.

## Consequences
- Promotion must transport the digest, not resolve a tag again.
- Rollback should select a previously verified digest.
- Tags remain useful for discovery, but release record is digest-centric.
- Pipeline tests must fail when evidence and deployment digests differ.
