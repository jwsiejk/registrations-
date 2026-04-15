# File Size Policy

## Policy
- Maximum file length is **500 lines**.
- This applies to source code, scripts, workflow files, and documentation.

## Rationale
Smaller files improve readability, review quality, and maintainability.

## Exception process
An exception is allowed only when all are true:
1. Splitting would reduce clarity or correctness.
2. The file contains a header comment explaining the exception.
3. The related phase doc records why the exception was necessary.

## Enforcement
- Automated validation script: `tools/validate/check_file_length.py`
- Local command: `make validate`
- CI command: runs validation scripts on push and pull request
