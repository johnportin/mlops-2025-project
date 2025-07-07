.PHONY: airflow-setup airflow-start airflow-stop airflow-restart airflow-status

export AIRFLOW_HOME := $(shell pwd)/airflow

environment-setup:
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

airflow-setup:
	@echo "Setting up Airflow..."
	@bash scripts/airflow-setup.sh
	@echo "Airflow setup complete."

airflow-start:
	@echo "Starting Airflow standalone in the background..."
	@airflow standalone

airflow-stop:
	@echo "Stopping Airflow..."
	@if [ -f $(AIRFLOW_PID_FILE) ]; then \
		kill "$(shell cat $(AIRFLOW_PID_FILE))"; \
		rm $(AIRFLOW_PID_FILE); \
		echo "Airflow stopped."; \
	else \
		echo "Airflow is not running (PID file not found)."; \
	fi

airflow-restart:
	@$(MAKE) airflow-stop
	@sleep 2
	@$(MAKE) airflow-start

airflow-status:
	@if [ -f $(AIRFLOW_PID_FILE) ]; then \
		if ps -p "$(shell cat $(AIRFLOW_PID_FILE))" > /dev/null; then \
			echo "Airflow is running with PID $(shell cat $(AIRFLOW_PID_FILE))"; \
		else \
			echo "Airflow is not running, but a stale PID file was found."; \
			rm $(AIRFLOW_PID_FILE); \
		fi; \
	else \
		echo "Airflow is not running."; \
	fi
