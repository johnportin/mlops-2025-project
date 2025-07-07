# MLOps Project

## Project Overview

## Project Setup
### Environment Setup
For this project, use python 3.12.7.

Using pyenv to manage the python version, run the following:
```bash
pyenv install 3.12.7
pyenv local 3.12.7
```

After installing the python version, run the following to create a virtual environment for the project:

```bash
python -m venv .venv
source .venv/bin/activate
```

### Airflow Setup
Run the following script:
```bash
make airflow-setup
```

