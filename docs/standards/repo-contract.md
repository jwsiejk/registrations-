# Repository Contract

This contract defines **mandatory rules** for contributors. These rules are actionable and enforceable.

## 1) File length rule
- Files must not exceed **500 lines**.
- If a file must exceed 500 lines, add a documented exception in the file header and reference the reason in the relevant phase document.
- Keep exceptions rare and review them in PRs.
- See [`file-size-policy.md`](./file-size-policy.md).

## 2) Documentation update requirement
- Every new functionality change must include updated documentation.
- At minimum, update the relevant document in `docs/` and any impacted run instructions.
- If user-facing setup changes, update `README.md` in the same PR.
- See [`documentation-standard.md`](./documentation-standard.md).

## 3) Phase discipline
- Every phase implementation must update:
  - Its phase file in [`../phases/`](../phases/)
  - `README.md` if setup or usage changes are user-facing
- Do not merge phase code without phase doc updates.

## 4) No hidden fallbacks
- Do not add implicit or undocumented fallback behavior.
- Any fallback must be explicitly documented with trigger conditions and rationale.
- Silent behavior changes are not allowed.

## 5) Separation of responsibilities
- Keep responsibilities separated by folder:
  - `docs/`: documentation and process records
  - `tools/validate/`: validation and policy checks
  - `.github/`: CI and PR process templates
- Avoid mixing operational scripts with documentation or policy files.

## 6) Script documentation
- Every script must be documented with:
  - purpose
  - inputs/arguments
  - exit behavior
  - example usage
- Script documentation location: [`../operations/validation-tools.md`](../operations/validation-tools.md)

## 7) Naming convention
- Names must be explicit and readable.
- Avoid cryptic abbreviations unless they are industry-standard and documented.
- Prefer descriptive filenames over short aliases.

## 8) Enforcement mechanism
- Required checks run through validation scripts in `tools/validate/`.
- CI must execute the same checks in pull requests and push events.
- Contributors are expected to run `make validate` locally before opening a PR.
