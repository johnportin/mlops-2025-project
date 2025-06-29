.PHONY: format lint isort test install clean precommit-install airflow-start airflow-stop airflow-restart airflow-status mlflow-start mlflow-stop mlflow-restart mlflow-status

mlflow-start:
	bash scripts/mlflow_control.sh start

mlflow-stop:
	bash scripts/mlflow_control.sh stop

mlflow-restart:
	bash scripts/mlflow_control.sh restart

mlflow-status:
	bash scripts/mlflow_control.sh status


airflow-start:
	bash scripts/airflow_control.sh start

airflow-stop:
	bash scripts/airflow_control.sh stop

airflow-restart:
	bash scripts/airflow_control.sh restart

airflow-status:
	bash scripts/airflow_control.sh status


format:
	black .

isort:
	isort .

lint:
	flake8 .

test:
	pytest

install:
	pip install -r requirements.txt

clean:
	find . -type d -name "__pycache__" -exec rm -r {} +
	rm -rf .pytest_cache

precommit-install:
	pre-commit install