# Senior scenario answer template

Use this for any 8+ year DevOps / DevSecOps architecture scenario.

## 1. Clarify the impact
- Which environment and services are affected?
- Is the concern confidentiality, integrity, availability, compliance or delivery speed?
- What is the blast radius and business criticality?

## 2. Contain safely
- Stop further exposure or promotion.
- Preserve logs, artifacts and timestamps.
- Avoid broad emergency bypasses.

## 3. Diagnose with evidence
- Compare commit, workflow run, builder identity and image digest.
- Verify SBOM, signature and provenance subject.
- Inspect registry events, admission decisions, Kubernetes events and audit logs.

## 4. Recover
- Rebuild or redeploy only from trusted source and workflow.
- Verify final digest and evidence independently.
- Use staged rollout and documented rollback.

## 5. Prevent recurrence
- Narrow identity trust and permissions.
- Add positive and negative automated tests.
- Add policy, alerting, ownership and exception expiry.

## 6. Communicate
- State customer/business impact, confirmed risk, actions, owner and next checkpoint.
- Separate confirmed facts from hypotheses.
