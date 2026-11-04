# Security exception register

Use one row per accepted risk. An exception is a temporary risk decision, not a way to make a pipeline green.

| ID | Component / image digest | Finding / policy | Business rationale | Compensating control | Risk owner | Approved by | Created | Expires | Status |
|---|---|---|---|---|---|---|---|---|---|
| — | — | — | — | — | — | — | — | — | No active exceptions |

## Required approval record

For each exception, record:
- exact artifact digest, package/version or policy scope;
- scanner/admission finding and evidence;
- exploitability, exposure and business impact;
- why remediation cannot happen before the required release;
- compensating control and monitoring;
- named risk owner and approver;
- creation date, expiry date and review date;
- remediation ticket and closure evidence.

## Rules
1. No wildcard repository, namespace or signing-identity exceptions.
2. Exceptions must expire; renewal requires a new review and approval.
3. A critical, actively exploited or externally reachable issue requires explicit security leadership approval.
4. Expired exceptions revert to the default blocking policy.
5. Preserve the decision and evidence for audit.
