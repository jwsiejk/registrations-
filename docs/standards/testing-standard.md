# Testing Standard

## Objective
Ensure every phase introduces verifiable checks and keeps quality gates executable in CI.

## Baseline testing requirements
- Validation checks must be runnable locally and in CI.
- Failures must return non-zero exit codes.
- Error output must identify what failed and where.

## Current repository validation scope
The repository validation/testing standard must cover:
1. Repository validation checks (policy and required-documentation gates).
2. Docker/bootstrap path validation (required runtime files/directories and compose validation).
3. Raw-source readiness validation as a separate, explicit gate before downstream dbt execution.
4. Source-side mutation execution verification for deterministic simulation scenarios.
5. Source reseed/reset verification where applicable to restore baseline state.

## Command contract
- Primary local command: `make validate`
- Direct script execution must also be supported.
