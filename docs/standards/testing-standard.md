# Testing Standard

## Objective
Ensure every phase introduces verifiable checks and keeps quality gates executable in CI.

## Baseline testing requirements
- Validation checks must be runnable locally and in CI.
- Failures must return non-zero exit codes.
- Error output must identify what failed and where.

## Current phase test scope
Phase 01 requires the following checks:
1. File length policy enforcement
2. Required docs presence
3. Required top-level files presence

## Command contract
- Primary local command: `make validate`
- Direct script execution must also be supported.

## Future phase expectations
As implementation layers are added (Docker, dbt, simulation), extend test standards with:
- environment readiness checks
- data quality checks
- transformation test coverage
- operator runbook verification steps
