# mlops-2025-project

## Environment Setup

1. Ensure you have Python 3.12 installed on your system.
2. Set up the virtual environment and install all dependencies using the Makefile command:

```bash
make setup
```

This command will run the setup script (`scripts/setup_env.sh`) to create a virtual environment and install dependencies using [uv](https://github.com/astral-sh/uv).

3. Activate the environment:

```bash
source .venv/bin/activate
```

---

## Airflow Management

To start, stop, restart, or check the status of the Airflow webserver and scheduler, use the Makefile commands:

```bash
make airflow-start     # Start webserver and scheduler
make airflow-stop      # Stop both
make airflow-restart   # Restart both
make airflow-status    # Show running status
```

The Airflow UI will be available at [http://localhost:8080](http://localhost:8080) after running `make airflow-start`.

# Problem Description

The dataset used is the Boston House Prices-Advanced Regression Techniques dataset from Kaggle.

The problem is to predict the house prices in the Boston area using the provided columns, such as crime rate, housing density, property tax rate, and amount of commercial land in the area. 

# Project Plan

1. Store data in an S3 bucket?
2.