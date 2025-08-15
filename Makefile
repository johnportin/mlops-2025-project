.PHONY: log-env-variables airflow-setup airflow-start airflow-stop airflow-restart airflow-status

export AIRFLOW_HOME := $(shell pwd)/airflow

log-env-variables:
	@echo "Testing environment..."
	@echo "AIRFLOW_HOME: $(AIRFLOW_HOME)"

environment-setup: log-env-variables
	@echo "Setting up environment..."
	@pyenv local 3.12.7
	@python -m venv .venv
	@echo "Environment setup complete."
	@echo "Run 'source .venv/bin/activate' to activate it."

environment-cleanup:
	@echo "Cleaning up environment..."
	@rm -rf .venv
	@rm -rf airflow
	@pyenv local --unset
	@echo "Environment cleanup complete."

airflow-setup: log-env-variables
	@echo "Setting up Airflow..."
	@bash scripts/airflow-setup.sh
	@echo "Airflow is not installed in the virtual environment."
	@echo "Running 'airflow standalone' for the first time will initialize the airflow directory in $(shell pwd)/airflow".
	@echo "Airflow setup complete."

airflow-start:
	@echo "Starting Airflow standalone..."
	@bash scripts/airflow-init.sh