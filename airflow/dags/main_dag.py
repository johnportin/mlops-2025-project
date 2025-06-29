import os
from datetime import timedelta

import pandas as pd

from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.utils.dates import days_ago


def dummy_task():
    print("This is a placeholder for your ML pipeline step.")


def ingest_task(**context):
    print("Ingesting data...")

    # Define the data path - can be changed to S3 path later
    # In a production setup, this would come from Airflow Variables or environment variables
    data_path = os.path.join(
        os.path.dirname(os.path.dirname(os.path.dirname(__file__))),
        "data",
        "boston.csv",
    )

    print(f"Reading data from: {data_path}")

    # Read the CSV data
    df = pd.read_csv(data_path)

    # Basic data information
    print(f"Data shape: {df.shape}")
    print(f"Columns: {df.columns.tolist()}")

    # Store DataFrame information for downstream tasks
    # For small datasets, we can directly push the dataframe to XCom
    # For larger datasets in production, we would save to a file/S3 and pass the path
    context["ti"].xcom_push(key="boston_data", value=df.to_dict())

    return True


def process_task(**context):
    print("Processing data...")

    # Get the data from XCom
    ti = context["ti"]
    data_dict = ti.xcom_pull(task_ids="ingest_data", key="boston_data")

    # Convert back to DataFrame
    df = pd.DataFrame(data_dict)

    # Define feature and target columns
    target_col = "MEDV"
    feature_cols = [
        "CRIM",
        "INDUS",
        "RM",
        "NOX",
        "AGE",
        "DIS",
        "RAD",
        "PTRATIO",
        "B",
        "TAX",
    ]

    print(f"Target column: {target_col}")
    print(f"Feature columns: {feature_cols}")

    # Basic preprocessing - scale numerical features
    from sklearn.model_selection import train_test_split
    from sklearn.preprocessing import StandardScaler

    # Extract features and target
    X = df[feature_cols]
    y = df[target_col]

    # Scale features
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X)

    # Split into train/test sets (80% train, 20% test)
    X_train, X_test, y_train, y_test = train_test_split(
        X_scaled, y, test_size=0.2, random_state=42
    )

    print(f"Training data shape: {X_train.shape}")
    print(f"Testing data shape: {X_test.shape}")

    # Store processed data for downstream tasks
    processed_data = {
        "X_train": X_train.tolist(),
        "X_test": X_test.tolist(),
        "y_train": y_train.tolist(),
        "y_test": y_test.tolist(),
        "feature_cols": feature_cols,
        # Don't include scaler object as it can't be JSON serialized
    }

    # For scaler, we would normally save this to a file/S3 in a production setup
    # Here, we'll store mean and scale values separately
    processed_data["scaler_mean"] = (
        scaler.mean_.tolist() if hasattr(scaler, "mean_") else []
    )
    processed_data["scaler_scale"] = (
        scaler.scale_.tolist() if hasattr(scaler, "scale_") else []
    )

    # Push to XCom
    ti.xcom_push(key="processed_data", value=processed_data)

    return True


def s3_check_task():
    # Example: check S3 connectivity (expand for real use)
    print("S3 connectivity check placeholder.")


def model_training_task(**context):
    print("Training model...")

    # Get processed data from XCom
    ti = context["ti"]
    processed_data = ti.xcom_pull(task_ids="process_data", key="processed_data")

    # Convert lists back to numpy arrays
    import numpy as np
    from sklearn.linear_model import LinearRegression
    from sklearn.metrics import mean_squared_error, r2_score

    X_train = np.array(processed_data["X_train"])
    X_test = np.array(processed_data["X_test"])
    y_train = np.array(processed_data["y_train"])
    y_test = np.array(processed_data["y_test"])
    feature_cols = processed_data["feature_cols"]

    print(
        f"Training linear regression on {X_train.shape[0]} samples with {X_train.shape[1]} features"
    )

    # Train linear regression model
    model = LinearRegression()
    model.fit(X_train, y_train)

    # Make predictions
    y_train_pred = model.predict(X_train)
    y_test_pred = model.predict(X_test)

    # Calculate metrics
    train_mse = mean_squared_error(y_train, y_train_pred)
    test_mse = mean_squared_error(y_test, y_test_pred)
    train_r2 = r2_score(y_train, y_train_pred)
    test_r2 = r2_score(y_test, y_test_pred)

    print(f"Training MSE: {train_mse:.4f}, R²: {train_r2:.4f}")
    print(f"Testing MSE: {test_mse:.4f}, R²: {test_r2:.4f}")

    # Store model information for downstream tasks
    model_info = {
        "coefficients": model.coef_.tolist(),
        "intercept": float(model.intercept_),
        "feature_cols": feature_cols,
        "metrics": {
            "train_mse": float(train_mse),
            "test_mse": float(test_mse),
            "train_r2": float(train_r2),
            "test_r2": float(test_r2),
        },
        # Store test predictions for evaluation/monitoring
        "y_test_pred": y_test_pred.tolist(),
        "y_test_actual": y_test.tolist(),
    }

    # Push model info to XCom
    ti.xcom_push(key="model_info", value=model_info)

    # In a production setup, we would save the model to a file/S3
    # model_path = os.path.join('models', 'linear_regression_model.pkl')
    # joblib.dump(model, model_path)
    # ti.xcom_push(key='model_path', value=model_path)

    return True


def model_deploy_task():
    print("Model deployment step placeholder.")


def model_monitor_task():
    print("Model monitoring step placeholder.")


default_args = {
    "owner": "airflow",
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

dag = DAG(
    "main_mlops_pipeline",
    default_args=default_args,
    description="Main MLOps pipeline DAG",
    schedule_interval=None,
    start_date=days_ago(1),
    catchup=False,
)

ingest = PythonOperator(
    task_id="ingest_data",
    python_callable=ingest_task,
    dag=dag,
)
s3_check = PythonOperator(
    task_id="s3_check",
    python_callable=s3_check_task,
    dag=dag,
)

process = PythonOperator(
    task_id="process_data",
    python_callable=process_task,
    dag=dag,
)

train = PythonOperator(
    task_id="train_model",
    python_callable=model_training_task,
    dag=dag,
)
deploy = PythonOperator(
    task_id="deploy_model",
    python_callable=model_deploy_task,
    dag=dag,
)
monitor = PythonOperator(
    task_id="monitor_model",
    python_callable=model_monitor_task,
    dag=dag,
)

ingest >> process >> s3_check >> train >> deploy >> monitor
