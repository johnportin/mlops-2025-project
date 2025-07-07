#!/bin/bash

# AIRFLOW_HOME is inherited from the Makefile
echo "AIRFLOW_HOME is set to: ${AIRFLOW_HOME}"

# Activate the virtual environment so packages are installed there
source .venv/bin/activate

# Install uv  as recommended by Airflow docs
brew install uv
echo "uv version: $(uv --version)"

# Install Airflow via the script provided in the docs
# Ensure you are using a compatible versin of python
# We are using 3.12.7 for this project
AIRFLOW_VERSION=3.0.2
PYTHON_VERSION="$(python -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')"
CONSTRAINT_URL="https://raw.githubusercontent.com/apache/airflow/constraints-${AIRFLOW_VERSION}/constraints-${PYTHON_VERSION}.txt"
uv pip install "apache-airflow==${AIRFLOW_VERSION}" --constraint "${CONSTRAINT_URL}"
echo "Airflow version: $(uv pip show apache-airflow | grep Version | awk '{print $2}')"