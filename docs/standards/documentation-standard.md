# Documentation Standard

## Scope
This standard applies to all repository documentation in `README.md` and `docs/`.

## Required behavior
1. **Update docs with code changes**
   - Any change that adds functionality, changes workflows, or modifies setup must update relevant docs in the same PR.
2. **Keep phase docs current**
   - Each phase must track what was added, what changed, and what remains out of scope.
3. **Cross-link related documents**
   - Link standards, phase docs, and operational docs when concepts overlap.
4. **Write for operators and contributors**
   - Use clear steps and explicit assumptions.
5. **Prefer explicit over implicit**
   - Document constraints, limitations, and expected behavior.

## Documentation structure
- `README.md`: project overview, current status, entry point
- `docs/architecture/`: system architecture and design references
- `docs/operations/`: operational usage and validation runbooks
- `docs/standards/`: policies, rules, and contribution contract
- `docs/phases/`: phase planning and progress records

## Pull request checklist expectations
PRs must confirm:
- docs were updated for behavior/setup changes
- phase file was updated when implementing phase scope
- README was updated when user-facing setup changed
