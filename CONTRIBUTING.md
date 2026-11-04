# Contributing

Thanks for improving this learning platform. Keep changes small, reviewable and evidence-driven.

## Before opening a pull request
1. Explain the threat, reliability issue or developer problem being addressed.
2. Update relevant architecture decisions, threat model or runbooks.
3. Run `python -m pytest -q`.
4. Run `docker compose config --quiet` and, where available, `docker compose up --build -d`.
5. Run Trivy and Terraform validation when changing those areas.
6. Include positive and negative tests for security policy changes.

## Security-sensitive changes
Changes to workflows, image identity, signing, provenance, Kyverno policy, Terraform permissions or exception handling require explicit review. Do not broaden trust identities or add permanent policy exclusions to make a test pass.

## Pull request checklist
- [ ] No credentials, private keys, customer data or production identifiers added.
- [ ] Tests and relevant scans pass.
- [ ] Documentation and runbooks updated.
- [ ] Risk, operational impact and rollback are explained.
- [ ] Any accepted exception has an owner and expiry.
