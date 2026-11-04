# Operational runbooks

These runbooks are intended for the lab. Adapt ownership, communication and recovery steps before production use.

## 1. Vulnerability gate blocks an image
1. Capture the image digest and Trivy report.
2. Identify affected package, fixed version, reachability and runtime exposure.
3. Upgrade the dependency or base image; do not suppress a finding merely to make CI green.
4. Rebuild, rescan and compare digest.
5. Record any accepted risk with owner, rationale, compensating control and expiry.

## 2. Cosign verification fails
1. Confirm the deployed reference is the digest produced by the release job.
2. Verify the signature with the expected OIDC issuer and certificate identity.
3. Check repository, workflow path, branch/ref and release event claims.
4. Confirm registry reachability and evidence availability.
5. Do not weaken identity matching to a wildcard as a quick fix.

## 3. Kyverno rejects a deployment
1. Inspect admission response, policy report and Kyverno controller logs.
2. Confirm image digest, signature identity and provenance subject.
3. Check namespace match, imageReferences and policy version.
4. Roll back to a known-good verified digest if service impact requires it.
5. Keep any break-glass action narrow, approved, time-limited and audited.

## 4. Release workflow is suspected compromised
1. Stop promotion and disable the affected release environment/workflow.
2. Revoke OIDC trust or package permissions that could be abused.
3. Preserve workflow logs, commit history, artifact digests and attestation references.
4. Identify every artifact produced by the affected workflow identity.
5. Block affected digests at admission; rebuild from a known-good commit with reviewed workflow definitions.
6. Rotate any exposed credentials and complete a root-cause review.

## 5. Registry or admission dependency is unavailable
1. Determine whether existing workloads are healthy; avoid unnecessary restarts.
2. Check registry availability, DNS, TLS, rate limits and Kyverno webhook health.
3. Follow the environment's explicit fail-open/fail-closed policy.
4. Do not silently disable admission verification.
5. Restore service, verify a known-good digest and record the outage timeline.

## Evidence to retain
- source commit and workflow run URL;
- image name and immutable digest;
- Trivy report and SBOM;
- Cosign verification result;
- provenance/attestation reference;
- Kyverno policy report and Kubernetes audit events;
- exception approval and incident timeline, where applicable.
