# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability in `az-investigator`, **please do not open a public GitHub issue**. Instead, email the maintainers via the nano-step GitHub org page (https://github.com/nano-step) or open a private security advisory:

https://github.com/nano-step/az-investigator/security/advisories/new

We aim to respond within 72 hours.

## What counts as a security issue

This skill helps engineers query Azure logs. The interesting threat models are:

| Concern | Severity |
|---|---|
| **Secret in published file** — a real Azure tenant ID, subscription ID, instrumentation key, access token, or service-principal credential committed to this repo by mistake | **High** — please report privately |
| **Destructive command in a "read-only" skill path** — a query template or script that mutates / deletes Azure resources (the skill is supposed to be read-only by design) | **High** |
| **Privilege escalation** — script that asks the user to grant broader RBAC than needed for the documented use case | Medium |
| **Authentication confusion** — a snippet that suggests using a personal access token where a managed identity is appropriate | Medium |
| **Cross-tenant data leak** — a query template that, if copy-pasted to a different tenant, would accidentally surface data from this org's tenant | Medium |

## What is NOT a security issue (please open a public issue instead)

- Bugs in KQL templates that produce empty results when they shouldn't
- The skill failing to install on an exotic OS
- Documentation errors
- Unfriendly error messages

## Disclosure timeline

We follow standard responsible-disclosure:

- 0 days: report received
- ≤3 days: acknowledgement + initial severity assessment
- ≤30 days: fix released or, if not possible, public advisory with mitigation steps

## Hall of fame

Researchers who responsibly disclose security issues will be credited in the [`CHANGELOG.md`](CHANGELOG.md) entry that ships the fix, unless they request anonymity.
