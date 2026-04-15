.PHONY: help validate validate-file-length validate-required-docs validate-required-top-level validate-docs-index validate-docker-infra docker-up docker-down docker-status docker-reset docker-reseed-sources docker-reseed-crm docker-reseed-erp warehouse-bootstrap mutate-list mutate-crm-new-opportunity mutate-crm-stage-progression mutate-crm-schema-drift mutate-erp-new-order mutate-erp-late-invoice mutate-erp-data-quality-edge dbt-profile-setup dbt-install-deps dbt-deps dbt-parse dbt-compile dbt-raw-source-readiness dbt-run dbt-test

DBT_PROJECT_DIR := analytics/dbt
DBT_PROFILES_DIR := $(DBT_PROJECT_DIR)/profiles
DBT_PROFILE_TEMPLATE := $(DBT_PROFILES_DIR)/profiles.template.yml
DBT_PROFILE_FILE := $(DBT_PROFILES_DIR)/profiles.yml
DBT := dbt

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
	@echo "  make docker-reseed-sources       # Rebuild CRM+ERP schema/data on running containers"
	@echo "  make docker-reseed-crm           # Rebuild CRM schema/data on running container"
	@echo "  make docker-reseed-erp           # Rebuild ERP schema/data on running container"
	@echo "  make warehouse-bootstrap         # Apply warehouse bootstrap SQL on running container"
	@echo "  make mutate-list                 # List available source-side mutation scenarios"
	@echo "  make mutate-crm-new-opportunity  # Apply CRM mutation: deterministic new opportunity"
	@echo "  make mutate-crm-stage-progression# Apply CRM mutation: move opportunity 3014 to proposal"
	@echo "  make mutate-crm-schema-drift     # Apply CRM mutation: additive accounts.customer_priority"
	@echo "  make mutate-erp-new-order        # Apply ERP mutation: deterministic order 7091 without invoice"
	@echo "  make mutate-erp-late-invoice     # Apply ERP mutation: late invoice 9091 for order 7091"
	@echo "  make mutate-erp-data-quality-edge# Apply ERP mutation: controlled invoice mismatch"
	@echo "  make dbt-profile-setup           # Copy dbt profile template to active profile"
	@echo "  make dbt-install-deps            # Install pinned dbt dependencies"
	@echo "  make dbt-deps                    # Install dbt package dependencies"
	@echo "  make dbt-parse                   # Parse dbt project"
	@echo "  make dbt-compile                 # Compile dbt models"
	@echo "  make dbt-raw-source-readiness    # Verify expected Fivetran raw tables exist"
	@echo "  make dbt-run                     # Run dbt models (requires raw-source readiness)"
	@echo "  make dbt-test                    # Run dbt tests (requires raw-source readiness)"

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

docker-reseed-sources:
	bash infra/docker/scripts/reseed-sources

docker-reseed-crm:
	bash infra/docker/scripts/reseed-crm

docker-reseed-erp:
	bash infra/docker/scripts/reseed-erp

warehouse-bootstrap:
	bash infra/docker/scripts/bootstrap-warehouse

mutate-list:
	@echo "Available mutation targets:"
	@echo "  make mutate-crm-new-opportunity   # CRM: insert deterministic open opportunity 3091 with history 4091"
	@echo "  make mutate-crm-stage-progression # CRM: advance opportunity 3014 qualification -> proposal (history 4092)"
	@echo "  make mutate-crm-schema-drift      # CRM: additive schema drift (accounts.customer_priority)"
	@echo "  make mutate-erp-new-order         # ERP: insert deterministic booked order 7091 with order items"
	@echo "  make mutate-erp-late-invoice      # ERP: insert deterministic late invoice 9091 for order 7091"
	@echo "  make mutate-erp-data-quality-edge # ERP: insert controlled invoice mismatch scenario for order 7092"

mutate-crm-new-opportunity:
	bash infra/docker/scripts/apply-mutation crm 010_new_opportunity.sql

mutate-crm-stage-progression:
	bash infra/docker/scripts/apply-mutation crm 020_stage_progression.sql

mutate-crm-schema-drift:
	bash infra/docker/scripts/apply-mutation crm 030_schema_change_customer_priority.sql

mutate-erp-new-order:
	bash infra/docker/scripts/apply-mutation erp 010_new_order.sql

mutate-erp-late-invoice:
	bash infra/docker/scripts/apply-mutation erp 020_late_arriving_invoice.sql

mutate-erp-data-quality-edge:
	bash infra/docker/scripts/apply-mutation erp 030_data_quality_invoice_mismatch.sql

$(DBT_PROFILE_FILE): $(DBT_PROFILE_TEMPLATE)
	cp "$(DBT_PROFILE_TEMPLATE)" "$(DBT_PROFILE_FILE)"

dbt-profile-setup: $(DBT_PROFILE_FILE)
	@echo "dbt profile created at $(DBT_PROFILE_FILE)"

dbt-install-deps:
	python3 -m pip install -r $(DBT_PROJECT_DIR)/requirements.txt

dbt-deps: dbt-profile-setup
	DBT_PROFILES_DIR=$(DBT_PROFILES_DIR) $(DBT) deps --project-dir $(DBT_PROJECT_DIR)

dbt-parse: dbt-profile-setup
	DBT_PROFILES_DIR=$(DBT_PROFILES_DIR) $(DBT) parse --project-dir $(DBT_PROJECT_DIR)

dbt-compile: dbt-profile-setup
	DBT_PROFILES_DIR=$(DBT_PROFILES_DIR) $(DBT) compile --project-dir $(DBT_PROJECT_DIR)

dbt-raw-source-readiness:
	python3 tools/validate/check_dbt_raw_sources.py

dbt-run: dbt-profile-setup dbt-raw-source-readiness
	DBT_PROFILES_DIR=$(DBT_PROFILES_DIR) $(DBT) run --project-dir $(DBT_PROJECT_DIR)

dbt-test: dbt-profile-setup dbt-raw-source-readiness
	DBT_PROFILES_DIR=$(DBT_PROFILES_DIR) $(DBT) test --project-dir $(DBT_PROJECT_DIR)
