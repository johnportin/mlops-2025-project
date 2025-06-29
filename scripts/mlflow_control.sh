#!/usr/bin/env bash
# Simple MLflow server control script
# Usage: ./mlflow_control.sh [start|stop|restart|status]

MLFLOW_BACKEND_URI="sqlite:///$(pwd)/mlruns/mlflow.db"
MLFLOW_ARTIFACT_ROOT="$(pwd)/mlruns/artifacts"
MLFLOW_PORT=5000
MLFLOW_PID_FILE="mlflow_server.pid"

start() {
  echo "Starting MLflow server on port $MLFLOW_PORT..."
  nohup mlflow server \
    --backend-store-uri "$MLFLOW_BACKEND_URI" \
    --default-artifact-root "$MLFLOW_ARTIFACT_ROOT" \
    --host 0.0.0.0 \
    --port $MLFLOW_PORT > mlflow_server.log 2>&1 &
  echo $! > "$MLFLOW_PID_FILE"
  echo "MLflow server started."
}

stop() {
  if [ -f "$MLFLOW_PID_FILE" ]; then
    echo "Stopping MLflow server..."
    kill $(cat "$MLFLOW_PID_FILE") && rm "$MLFLOW_PID_FILE"
    echo "MLflow server stopped."
  else
    echo "MLflow server is not running."
  fi
}

status() {
  if [ -f "$MLFLOW_PID_FILE" ] && kill -0 $(cat "$MLFLOW_PID_FILE") 2>/dev/null; then
    echo "MLflow server is running (PID: $(cat $MLFLOW_PID_FILE))"
  else
    echo "MLflow server is not running."
  fi
}

restart() {
  stop
  sleep 2
  start
}

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    restart
    ;;
  status)
    status
    ;;
  *)
    echo "Usage: $0 {start|stop|restart|status}"
    exit 1
    ;;
esac
