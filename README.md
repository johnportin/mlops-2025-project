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

After setting the python environment, you can use the commands within the Makefile to setup the environment.

Run the following commands
```bash
make environment-setup
```

You should see a `.venv` directory in your current working directory. Check out the list of available packages automatically installed with `pip list`. 

### Airflow Setup
Run the following script:
```bash
make airflow-setup
```

At this point, you won't see the airflow folder locally. To do so, you will need to execute `airflow standalone`. This has been packaged into a make command also:

```bash
make airflow-start
```

To stop the airflow services, simply press `^C` (`Ctrl + C`).

