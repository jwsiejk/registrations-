.PHONY: help validate validate-file-length validate-required-docs validate-required-top-level validate-docs-index validate-docker-infra docker-up docker-down docker-status docker-reset

help:
	@echo "Available targets:"
	@echo "  make validate                    # Run all repository validation checks"
	@echo "  make validate-file-length        # Enforce 500-line file length policy"
	@echo "  make validate-required-docs      # Check required docs exist"
	@echo "  make validate-required-top-level # Check required top-level files exist"
	@echo "  make validate-docs-index         # Check key docs index targets exist"
	@echo "  make validate-docker-infra       # Check Docker compose/env/script requirements"
	@echo "  make docker-up                   # Start local Postgres services"
	@echo "  make docker-down                 # Stop local Postgres services"
	@echo "  make docker-status               # Show local Postgres service status"
	@echo "  make docker-reset                # Remove containers and named volumes"

validate:
	bash tools/validate/run_all.sh

validate-file-length:
	python3 tools/validate/check_file_length.py

validate-required-docs:
	python3 tools/validate/check_required_docs.py

validate-required-top-level:
	python3 tools/validate/check_required_top_level.py

validate-docs-index:
	python3 tools/validate/check_docs_index.py

validate-docker-infra:
	python3 tools/validate/check_docker_infra.py

docker-up:
	bash infra/docker/scripts/up

docker-down:
	bash infra/docker/scripts/down

docker-status:
	bash infra/docker/scripts/status

docker-reset:
	bash infra/docker/scripts/reset
