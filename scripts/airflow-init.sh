#!/bin/bash

# Convenience script for running Airflow commands
# Usage: ./scripts/airflow.sh <command> [args...]
# Example: ./scripts/airflow.sh version
# Example: ./scripts/airflow.sh standalone

# Check if virtual environment exists
if [ ! -d ".venv" ]; then
    echo "Error: Virtual environment not found. Run 'make environment-setup' first."
    exit 1
fi

# Activate virtual environment
source .venv/bin/activate
which python
pip list | grep apache-airflow

# Set AIRFLOW_HOME if not already set
if [ -z "$AIRFLOW_HOME" ]; then
    export AIRFLOW_HOME="$(pwd)/airflow"
    echo "Set AIRFLOW_HOME to: $AIRFLOW_HOME"
fi

# Run the airflow command with all arguments
.venv/bin/airflow  standalone
