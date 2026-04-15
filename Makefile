.PHONY: help validate validate-file-length validate-required-docs validate-required-top-level

help:
	@echo "Available targets:"
	@echo "  make validate                  # Run all repository validation checks"
	@echo "  make validate-file-length      # Enforce 500-line file length policy"
	@echo "  make validate-required-docs    # Check required docs exist"
	@echo "  make validate-required-top-level # Check required top-level files exist"
	@echo "  # Future phases will add targets for docker, dbt, seed data, and simulation"

validate:
	bash tools/validate/run_all.sh

validate-file-length:
	python3 tools/validate/check_file_length.py

validate-required-docs:
	python3 tools/validate/check_required_docs.py

validate-required-top-level:
	python3 tools/validate/check_required_top_level.py
