# Senior DevSecOps / Platform Security Interview Handbook

**Target:** senior / lead engineer interviews (8+ years).  
**Answer method:** state the decision, explain the mechanism, cover failure modes, define evidence, then discuss trade-offs. Avoid reciting tool names without demonstrating operational ownership.

## 1. Architecture and strategy

### Q1. Design an end-to-end secure software supply chain for 50 engineering teams.
**Answer:** Establish paved-road templates rather than one bespoke pipeline per team. Source controls include protected branches, CODEOWNERS and required checks. Reusable workflows enforce pinned actions and least-privilege permissions. CI builds immutable artifacts, scans dependencies and images, generates SBOM and provenance, and signs the digest. A registry stores artifacts and evidence. Kubernetes admission independently verifies signatures and identity. Dashboards measure adoption, policy denials, vulnerabilities and exceptions. Roll out in rings—pilot, audit, enforce—with migration guidance and break-glass procedures.

### Q2. Why is a green pipeline not enough to trust a production image?
**Answer:** A green pipeline describes jobs that ran, not proof that deployed bytes are exactly those bytes or that the cluster independently trusts their origin. The image might be retagged, replaced, pulled from another workflow, or deployed through a path that bypasses CI. Bind evidence to immutable digest and verify signature, issuer, workflow identity and provenance at admission.

### Q3. How would you build a multi-tenant platform without weakening isolation?
**Answer:** Separate untrusted PR execution from privileged release execution, use isolated ephemeral runners, scope OIDC trust to repository/ref/environment, isolate namespaces and service accounts, enforce network/RBAC boundaries, and avoid shared writable caches across trust levels. For stronger isolation, use dedicated runner pools or sandboxed build infrastructure. Prove isolation with negative tests and audit evidence.

### Q4. How do you decide between central platform ownership and team autonomy?
**Answer:** Centralize non-negotiable controls and paved-road capabilities—identity, workflow templates, policy bundles, artifact verification and evidence collection. Keep service-specific test logic, release cadence and risk context with product teams. Version platform interfaces, publish deprecation windows and measure adoption/friction. Avoid a central bottleneck with self-service onboarding and clear exception SLAs.

## 2. CI/CD and workload identity

### Q5. Explain GitHub OIDC and why it is safer than stored cloud credentials.
**Answer:** A workflow requests a short-lived OIDC token containing signed claims such as repository, ref, workflow and audience. The cloud or registry identity provider validates those claims against a trust relationship and exchanges the token for short-lived credentials. This removes long-lived static secrets only if trust conditions are narrow. Constrain audience, repository, branch/tag, environment and workflow identity; grant minimum permissions; audit token use. A broad wildcard trust rule moves the secret-management problem into identity policy.

### Q6. A fork pull request modifies your workflow. How do you prevent credential theft?
**Answer:** Treat fork code and workflow output as untrusted. Do not expose release secrets or write permissions to the PR job. Separate validation from publishing, use read-only permissions, avoid privileged pull_request_target patterns that execute untrusted code, and promote only after a trusted event on a protected ref. Use ephemeral isolated runners and review workflow changes as security-sensitive code.

### Q7. How do you secure reusable workflows?
**Answer:** Pin reusable workflows to immutable commit SHAs, review source, constrain inputs, declare minimum permissions, avoid passing secrets unnecessarily, and scope caller trust explicitly. Centrally maintained workflows are high-value dependencies: use CODEOWNERS, tests, change logs and staged version upgrades.

### Q8. How would you prevent dependency confusion and compromised actions?
**Answer:** Pin actions and dependencies, use trusted registries/namespaces, lockfiles with integrity hashes, dependency review, allowlists where justified, provenance/attestation verification and regular update automation. Monitor upstream advisories and assess blast radius through SBOMs. Pinning reduces surprise but requires a deliberate patch process.

## 3. Artifact integrity, SBOM and provenance

### Q9. Explain image digest versus image tag.
**Answer:** A tag is a human-friendly mutable pointer; a digest identifies content cryptographically. Verification and deployment should be digest-based so exact bytes scanned and signed are the bytes admitted. Tags remain useful for discovery and release channels, but are not integrity guarantees.

### Q10. What does a container signature prove—and what does it not prove?
**Answer:** A valid signature proves that the signing identity signed the content digest and that verification accepts the identity under configured trust policy. It does not prove software is safe, vulnerability-free, compliant or correctly configured. Those need additional evidence and controls.

### Q11. Compare SBOM, signature and provenance.
**Answer:** SBOM answers “what components are in this artifact?” Signature answers “which identity signed this digest?” Provenance answers “how, where and from which inputs was this artifact built?” They complement each other. Verify subject digest across all evidence and constrain trusted builder identities.

### Q12. SPDX versus CycloneDX—how would you choose?
**Answer:** Both are SBOM standards with different ecosystems and feature emphases. Choose based on downstream tooling, regulatory/customer requirements, vulnerability and license workflows, and interoperability. Format choice does not replace completeness, freshness or artifact binding.

### Q13. How do you operationalize SLSA?
**Answer:** Document the build threat model and builder trust. Improve isolation, provenance generation, source and dependency controls, reproducibility where feasible, and verification. Map implementation to the required SLSA level and precise requirements. Never claim a level solely because a pipeline emits a provenance file; builder and process must meet criteria.

### Q14. A signed image has a critical CVE. Should it be deployed?
**Answer:** Signature verifies origin/integrity, not safety. Vulnerability policy determines release eligibility. Assess exploitability, reachability, exposure, compensating controls and business impact; any exception must be owned, documented, time-bound and monitored. For exploitable high-impact risk, block promotion and rebuild with a fix.

## 4. Kubernetes admission and runtime

### Q15. How does admission-time image verification work?
**Answer:** A workload request reaches Kubernetes API server. Admission evaluates policy, resolves the image digest and verifies signature/attestation against trusted keys or identities and policy constraints. If verification fails, the request is rejected under enforcement policy. Test positive and negative cases, webhook availability, namespace scope, caching, registry latency and emergency recovery.

### Q16. What is the risk of a fail-open admission webhook?
**Answer:** If webhook is unavailable, API server may permit workloads without verification. That improves availability but can bypass security boundary. Fail-closed protects integrity but can block deployments. Decide based on risk; prefer resilient webhook deployment, sensible timeouts, monitoring and formal audited break-glass rather than undocumented fail-open.

### Q17. How do you roll out Kyverno policies safely?
**Answer:** Start with policy tests and sample manifests, then audit mode in representative namespaces. Measure false positives and exclusions, classify owners and exceptions, publish migration guidance, and enforce in stages. Monitor policy reports and admission denials. Keep rollback/versioning and emergency access tested.

### Q18. How would you prevent policy bypass?
**Answer:** Map every deployment path, enforce namespace and RBAC boundaries, restrict who can alter policies/webhooks, prevent ungoverned namespaces, and test bypass scenarios. Cluster admins remain a privileged trust boundary and need audit and separation of duties.

## 5. Vulnerability management and risk

### Q19. Your scanner reports 2,000 findings. What do you do?
**Answer:** Normalize and deduplicate by package, image and service; prioritize exploitable and externally reachable issues; map findings to owners; use SBOM for impact analysis; and define remediation SLAs by severity/context. Establish a baseline carefully, but don't hide new findings. Measure age, recurrence, exception expiry and remediation throughput—not just finding count.

### Q20. How do you manage false positives and accepted risks?
**Answer:** A suppression requires evidence, owner, rationale, affected component/digest, compensating control and expiry. Keep the exception centrally visible and review periodically. Scanner suppressions should not silently become permanent policy. Security leadership owns risk acceptance; engineers own remediation.

### Q21. Explain vulnerability SLA design.
**Answer:** Use severity plus exploitability, exposure, asset criticality and compensating controls. Define response/remediation targets, escalation paths and exception authority. Measure time to acknowledge/remediate, overdue exposure and reopened findings. Avoid a universal SLA ignoring production context.

## 6. Incident response and operations

### Q22. You discover a compromised GitHub Actions workflow signed a malicious image. What is your response?
**Answer:** Stop promotions/deployments, disable or isolate workflow, revoke OIDC trust and registry permissions, preserve logs/evidence, enumerate artifacts by digest and workflow identity, then block affected digests at admission. Rebuild from known-good commit using reviewed workflows and verify new evidence. Rotate impacted credentials, notify stakeholders and complete a root-cause review.

### Q23. Production admission suddenly blocks all deployments. What do you do?
**Answer:** Determine whether cause is policy regression, registry/network failure, identity mismatch, expired trust or webhook health. Check API events, Kyverno reports/logs, registry reachability and recent policy/workflow changes. Restore using reviewed rollback or narrowly scoped audited break-glass—not by disabling all verification. Validate availability and trust before normal operation.

### Q24. The registry is unavailable during deployment. What is your design?
**Answer:** Decide which evidence can be cached safely and for how long, keep already verified running workloads stable, and define whether new deployments fail closed. Monitor registry/webhook health, use regional replication and tested recovery, and document emergency path. Never equate a cached tag with a verified digest.

### Q25. A vulnerability is disclosed in a common base image. How do you find exposure quickly?
**Answer:** Query SBOMs and artifact metadata for affected package/version, map image digests to services/environments, prioritize internet-facing and critical workloads, block new promotion, and rebuild patched images. Verify resulting digest and attestations, roll out progressively, and retain affected-artifact list for audit.

## 7. Reliability, scale and engineering leadership

### Q26. How would you scale image verification to hundreds of clusters?
**Answer:** Standardize versioned policy bundles and trust config, use staged rollouts, provide central reporting with cluster-local enforcement, test policy compatibility and latency, and define exception ownership. Design for registry latency, webhook availability, caching, upgrades and drift detection. Measure admission latency and denial rate alongside policy coverage.

### Q27. Which SLOs would you define for a security platform?
**Answer:** Availability of admission verification, p95/p99 admission latency, CI template availability, verification success/error rate, policy coverage, exception age, vulnerability remediation time and evidence completeness. Security controls must be reliable; an unavailable gate is often bypassed. Define error budgets and incident ownership.

### Q28. How do you handle disagreement between security and product teams?
**Answer:** Translate concern into concrete threat and business impact, show evidence and options, and distinguish mandatory controls from configurable risk decisions. Offer a paved-road fix, migration support and time-bound exception path. Escalate residual risk to right owner rather than hiding it in a pipeline bypass.

### Q29. What would you measure to prove this platform is successful?
**Answer:** Percentage of production workloads digest-pinned and verified, percentage with fresh SBOM/provenance, policy coverage, critical exposure age, exception expiry compliance, admission latency/availability, mean time to remediate and developer adoption. Avoid vanity metrics such as scan count alone.

### Q30. How do you lead a migration from legacy pipelines?
**Answer:** Inventory pipeline patterns and critical services, classify risk, identify common templates, pilot with willing teams, provide compatibility and rollback paths, then migrate by risk tier. Use dashboards and office hours to remove friction. Set deprecation timeline with exceptions and executive sponsorship. Avoid big-bang migration.

## 8. Scenario drills — answer on a whiteboard
For each, cover **containment → diagnosis → recovery → prevention → evidence**:
1. Image tag changes between scan and deployment.
2. Cosign verification succeeds locally but fails in cluster.
3. OIDC exchange fails only for release tags.
4. Trivy database is stale and scanner reports no findings.
5. SBOM subject digest differs from deployed image.
6. Provenance names an unexpected reusable workflow.
7. New Kyverno policy blocks system workloads.
8. Registry replication lags in secondary region.
9. Critical CVE appears in 70 deployed services.
10. Maintainer accidentally publishes a secret in workflow logs.
11. Self-hosted runner may have been compromised.
12. Team asks for permanent policy exclusion to meet a deadline.

## 9. Whiteboard checklist
- Assets and trust boundaries identified?
- Untrusted code separated from privileged execution?
- OIDC audience and subject claims narrowly constrained?
- Actions, dependencies and base images pinned and updated?
- Digest captured, scanned, inventoried, signed and deployed consistently?
- Provenance builder/source identity verified?
- Admission positive and negative cases tested?
- Registry/webhook outage and fail behavior documented?
- Exceptions owned, expiring and auditable?
- Metrics, SLOs, runbooks and rollback tested?

## Answer framework for 8+ years
1. **Context:** clarify scale, criticality, compliance and constraints.
2. **Architecture:** explain trust boundaries and control placement.
3. **Decision:** state design and why.
4. **Failure modes:** identify bypasses, outages and compromised components.
5. **Operations:** monitoring, SLOs, incident response, rollback and ownership.
6. **Evidence:** name tests, logs, attestations and metrics that prove it works.

Do not invent production results. Use measured examples from your work and distinguish hands-on implementation from proposed architecture.
