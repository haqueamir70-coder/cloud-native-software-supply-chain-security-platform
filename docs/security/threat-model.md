# Threat model

## Scope and assets
This lab protects source integrity, workflow identity, build execution, container artifacts, software inventory, signing identities, provenance, registry contents, Kubernetes admission and deployment evidence.

Primary assets: source repository and release ref; CI workflow definitions and runner; OIDC trust relationship and registry permissions; dependencies and build materials; image digest, SBOM, signature and provenance; cluster admission configuration and audit records.

## Adversaries and abuse cases

| Threat | Example | Primary control | Residual risk |
|---|---|---|---|
| Malicious source change | Backdoor merged into release | Review, tests, branch protection | Approved malicious change can pass |
| Workflow compromise | Attacker modifies release workflow | CODEOWNERS, pinned Actions, least privilege | Compromised maintainer remains powerful |
| Credential theft | Long-lived registry secret leaked | OIDC, short-lived tokens | Token can be abused while valid |
| Dependency compromise | Malicious package or base image | Pinning, review, scanning, SBOM | Scanner may not detect novel behavior |
| Artifact substitution | Mutable tag points to different image | Digest references and signature verification | Registry/verification outage |
| Signing identity abuse | Wrong workflow signs attacker image | Issuer and certificate identity constraints | Trusted workflow itself may be compromised |
| Provenance spoofing | Untrusted builder claims trusted source | Verify builder and source claims | Trust roots can be misconfigured |
| Admission bypass | Workload uses ungoverned namespace/API path | Policy scope, RBAC, tests, audit | Cluster admins can bypass controls |
| Denial of service | Webhook or registry unavailable | Availability planning and explicit fail policy | Fail-closed can block releases |

## Trust assumptions
- Protected branch and GitHub organization settings are correctly maintained.
- CI identity provider issues verifiable identity claims.
- Registry and transparency/evidence services are available and correctly authenticated.
- Kubernetes control plane and admission components are within the trust boundary.
- Security exceptions are time-bound, owned and reviewed.

## Abuse-case test matrix

| Test | Expected result |
|---|---|
| Trusted image, expected identity | Admit |
| Unsigned image | Deny in enforcement mode |
| Image signed by another repository | Deny |
| Correct signature but altered digest | Deny |
| Tag changes after verification | Deployment digest remains unchanged |
| Missing provenance where required | Deny |
| Expired/revoked exception | Deny until re-approved |
| Registry unavailable | Follow documented fail-open/fail-closed policy; alert |

## Incident response priorities
1. **Compromised workflow:** disable release workflow/environment, revoke federated trust and permissions, preserve logs, identify artifacts built by affected workflow.
2. **Signing identity compromise:** stop promotion, narrow/revoke trust, identify affected digests, rebuild and re-sign from trusted source.
3. **Malicious dependency:** determine affected SBOMs/digests, block promotion/admission, rebuild with remediated dependency, preserve evidence.
4. **Admission policy outage:** follow documented availability decision; do not silently disable verification. Use approved break-glass with expiry and audit.
5. **Registry compromise:** freeze promotion, validate digests/signatures independently, restore from trusted artifacts and rotate access.

This is a lab threat model, not a claim that every control is already deployed.
