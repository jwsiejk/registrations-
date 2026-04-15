#!/usr/bin/env bash
set -euo pipefail

python3 tools/validate/check_file_length.py
python3 tools/validate/check_required_docs.py
python3 tools/validate/check_required_top_level.py
python3 tools/validate/check_docs_index.py

echo "PASS: All validation checks completed successfully."
