# Local Fivetran ELT Lab (Foundation)

## Purpose
This repository is the structured foundation for a **local Fivetran ELT lab** that will be implemented in later phases. In this phase, the focus is on project structure, standards, contracts, validation tooling, and documentation discipline.

## What will be built in later phases
Future phases will incrementally add:

1. Dockerized local data services (Postgres and supporting components)
2. Seed data and baseline datasets
3. dbt project setup and transformations
4. Simulation workflows and repeatable experiments
5. Operator runbooks for local operation and troubleshooting

See phase tracking docs in [`docs/phases/`](docs/phases/) for planned scope and status.

## Current status (after Phase 01)
This repository currently includes:

- A clean folder skeleton for docs, tooling, and CI
- A repository contract with enforceable rules
- Documentation, testing, and file-size standards
- Validation scripts under `tools/validate/`
- A minimal GitHub Actions workflow that runs validation checks

No full ELT implementation has been added yet by design.

## Repository standards and enforcement
Standards are defined under [`docs/standards/`](docs/standards/):

- Repository contract: [`repo-contract.md`](docs/standards/repo-contract.md)
- Documentation standard: [`documentation-standard.md`](docs/standards/documentation-standard.md)
- File size policy: [`file-size-policy.md`](docs/standards/file-size-policy.md)
- Testing standard: [`testing-standard.md`](docs/standards/testing-standard.md)

Automated enforcement (for this phase) runs via scripts in [`tools/validate/`](tools/validate/):

- `check_file_length.py`
- `check_required_docs.py`
- `check_required_top_level.py`
- `check_docs_index.py`
- `run_all.sh`

CI executes these checks on pull requests and pushes to `main`.

## Quick start
Run all current validation checks locally:

```bash
make validate
```

Or run scripts directly:

```bash
python3 tools/validate/check_file_length.py
python3 tools/validate/check_required_docs.py
python3 tools/validate/check_required_top_level.py
python3 tools/validate/check_docs_index.py
```

## Repository structure

```text
.
├── .github/
│   ├── workflows/
│   └── pull_request_template.md
├── docs/
│   ├── architecture/
│   ├── operations/
│   ├── phases/
│   └── standards/
├── tools/
│   └── validate/
├── .editorconfig
├── .gitignore
├── Makefile
└── README.md
```
