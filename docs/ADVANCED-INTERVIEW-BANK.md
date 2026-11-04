# Supply-chain security — Advanced Interview Question Bank

> 40 additional questions and answers for deeper project understanding. Use with [ZERO-TO-HERO.md](./ZERO-TO-HERO.md). Validate every implementation claim against source, workflow and deployment evidence.

## Project context
- **Architecture:** Git commit → CI build → SBOM/provenance → signed immutable OCI digest → registry → Kyverno admission verification
- **Tools:** GitHub Actions, Docker/BuildKit, OCI registry, SBOM generator, Cosign/Sigstore, SLSA provenance, Kyverno, Kubernetes
- **Failure scenarios:** unsigned image, mutable tag, untrusted signer, compromised runner
- **Response approach:** Verify digest, signer identity/issuer, source repository, workflow identity and provenance predicate; reject untrusted artifacts at admission.

## Answer framework
For each question, explain context → decision → implementation → trade-off → failure handling → evidence. For scenario questions, say what you inspect first and what observation confirms the hypothesis.

## 40 questions with answers

### 1. What business problem does this project solve?

Explain the user/operator pain, its business impact and measurable outcome. The architecture is a means to that outcome, not the goal.

### 2. Who are the actors and trust boundaries?

Identify users, developers, platform operators, workload identities and external services. Mark where authentication, authorization and network trust change.

### 3. Explain the end-to-end flow.

Walk through every component and hand-off, naming protocol, identity, persistence boundary and response/feedback path.

### 4. Why is the architecture split into these components?

Each component has a bounded responsibility, independent scaling/failure domain and explicit interface. Avoid splitting services without a real operational reason.

### 5. Which non-functional requirements matter?

Availability, latency, throughput, security, recoverability, auditability, operability and cost. Rank them and define measurable acceptance criteria.

### 6. Why use the primary IaC/orchestration tool?

It makes desired state repeatable, reviewable and automatable. Compare alternatives and explain lifecycle, drift and operational trade-offs.

### 7. What does CI validate—and not validate?

Static checks prove only what they test. They do not prove cloud deployment, live permissions, network reachability, runtime behavior or disaster recovery.

### 8. How are environment differences handled?

Separate reusable logic from environment inputs, validate types/allowed values, keep secrets out of source and promote artifacts/configuration explicitly.

### 9. How do you make deployments reproducible?

Pin tool/provider/action versions, lock dependencies, use immutable artifacts, version modules and preserve reviewed plans/manifests.

### 10. How are secrets managed?

Prefer managed/workload identity or OIDC, least privilege and a dedicated secret manager. Rotate credentials, audit access and never print secrets.

### 11. What failure would you test first?

Choose a likely high-impact dependency failure. Define detection, user impact, mitigation, recovery and evidence before testing safely.

### 12. How do you troubleshoot an outage?

Scope impact, inspect recent changes, logs/events/metrics, identity, DNS/network, dependencies and saturation. Isolate layers and mitigate safely.

### 13. Authentication versus authorization?

Authentication proves identity; authorization decides allowed actions at a resource/data scope. A successful login does not imply permission.

### 14. How do you enforce least privilege?

Use dedicated identities, narrow scopes and minimum actions; avoid shared admin credentials and review privileged operations.

### 15. How do you prevent drift?

Use reviewed desired state, scheduled drift detection and controlled break-glass changes followed by reconciliation.

### 16. What should logs contain or exclude?

Log timestamps, correlation IDs, outcomes, timings and security events. Exclude passwords, tokens, keys and sensitive payloads.

### 17. How do you retry safely?

Use bounded exponential backoff with jitter for transient failures and idempotency/deduplication for repeat delivery.

### 18. How do you design recovery?

Set RPO/RTO with owners, protect backups/replicas, test restore and validate application consistency—not just backup job success.

### 19. How would you scale it?

Measure the bottleneck and latency/throughput/saturation, scale the constrained tier, respect service limits and validate cost.

### 20. Which metrics should operators monitor?

Availability, error rate, latency percentiles, throughput, saturation, queue/consumer lag, dependency health and domain-specific freshness.

### 21. How do you reduce alert noise?

Alert on sustained actionable symptoms, use appropriate windows, suppress duplicates, include ownership/runbooks and review false positives.

### 22. What security gates belong in CI?

Combine secret, dependency, source, image and IaC scans with policy checks. Define severity, owners and expiry for exceptions.

### 23. What are the cost drivers?

Compute, storage/retention, egress, managed service tiers, telemetry ingestion and idle capacity. Track cost per useful workload unit.

### 24. How do you roll back safely?

Keep a known-good immutable artifact/configuration, define triggers and data compatibility, restore previous version and monitor recovery.

### 25. What evidence proves implementation?

Source/configuration, tests, workflow runs, deployment/resource IDs, live behavior checks, security evidence, telemetry and runbooks.

### 26. What is implemented versus planned?

Inspect repository source and workflows. Mark implemented, CI-validated, cloud-deployed or planned; never infer runtime from a diagram.

### 27. How do you test end to end?

Test happy path, invalid input, permission denial, dependency outage, retry/deduplication, scale, rollback and recovery.

### 28. What are the key trade-offs?

Discuss simplicity/flexibility, cost/availability, centralization/autonomy, security friction/usability and latency/consistency.

### 29. What would you improve next?

Prioritize measurable risk or toil: missing tests, weak identity, unverified recovery, missing telemetry, unclear ownership or no reproducible deployment.

### 30. Give a 2-minute project explanation.

State business problem, architecture, decisions, security/reliability controls, one difficult failure scenario and evidence. Explain why tools were chosen.

### 31. Explain the architecture for Supply-chain security.

Git commit → CI build → SBOM/provenance → signed immutable OCI digest → registry → Kyverno admission verification. Explain each trust boundary, failure domain and data/control hand-off.

### 32. Which tools are central and why?

The project toolset is GitHub Actions, Docker/BuildKit, OCI registry, SBOM generator, Cosign/Sigstore, SLSA provenance, Kyverno, Kubernetes. Explain each tool's responsibility, configuration, integration point, limitation and alternative. Distinguish mandatory tools from optional examples.

### 33. What are the critical failure modes?

The main risks include unsigned image, mutable tag, untrusted signer, compromised runner. Prioritize by impact and likelihood; define detection, containment, recovery and prevention.

### 34. How would you troubleshoot the most likely incident?

Verify digest, signer identity/issuer, source repository, workflow identity and provenance predicate; reject untrusted artifacts at admission. Start with scope/recent changes, inspect telemetry, isolate one layer at a time and verify the fix with a regression test.

### 35. How do you prove the security boundary works?

Create positive and negative tests for identity, authorization and network paths. Verify expected principals can do only required actions and unauthorized paths fail.

### 36. How do you prove this is more than a diagram?

Show repository source, tests, workflow runs, deployment/resource IDs and live behavior checks. Label each capability implemented, CI-validated, cloud-deployed or planned.

### 37. What would you demonstrate to a CTO?

A reproducible validation/build, architecture trace, relevant source/config, successful test, deliberately failing scenario, logs and safe cleanup/rollback.

### 38. What are the operational limits?

Identify service quotas, throughput/concurrency limits, state/partition constraints, dependency availability and recovery objectives; validate under representative load.

### 39. How do you improve maintainability?

Use cohesive modules, explicit interfaces, typed configuration, versioned dependencies, automated tests, consistent naming and actionable runbooks.

### 40. How do you measure success?

Select business and service indicators such as reliability, latency, freshness, deployment lead time, policy compliance or unit cost. Establish baseline and target.

## Source-code deep-dive checklist

For each actual source file, prepare a line-by-line explanation and record its exact path:
1. **Terraform:** required_version, required_providers, provider, backend, variables, validation, locals, data sources, resources, depends_on, lifecycle, outputs and state addresses.
2. **GitHub Actions:** triggers, permissions, runner, checkout/setup, env/secrets/identity, working-directory, each step, artifacts, conditions, dependencies and failure behavior.
3. **Docker:** base image, build context, layers, ARG/ENV, COPY/ADD, ENTRYPOINT/CMD, user, ports, health check and runtime filesystem.
4. **Kubernetes:** apiVersion/kind, metadata, selectors, replicas, strategy, pod template, image digest, probes, resources, securityContext, serviceAccount, volumes, Service and Ingress.
5. **Application code:** entry point, config loading, validation, business logic, error handling, retries/timeouts, authN/authZ, logging, metrics and tests.
6. **Security policy:** rule, input schema, allowed/denied case, exception, severity and CI exit code.
7. **Observability:** metric type/labels, scrape path, PromQL, dashboard panel, alert window, routing and runbook.
8. **Operations:** deployment, verification, rollback, backup/restore, cost, ownership and incident procedure.

## Hands-on interview labs
- Trace one real change from commit to final resource or workload.
- Break a non-production dependency and diagnose it from telemetry.
- Demonstrate an expected and denied access path.
- Change one input and explain the resulting plan/build diff.
- Reproduce a CI failure and show the exact remediation.
- Roll back to a known-good version.
- Build an evidence matrix: implemented | CI-validated | cloud-deployed | planned.

## Scope rule
Optional tools in examples are not automatically dependencies. Legacy/conceptual projects must be presented as design exercises until functionality exists and has tests. Never claim a deployment based only on a diagram or successful static validation.
