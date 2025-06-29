#!/usr/bin/env bash
# Simple Airflow server/scheduler control script
# Usage: ./airflow_control.sh [start|stop|restart|status]

export AIRFLOW_HOME="$(pwd)/airflow"

WEB_PID_FILE="$AIRFLOW_HOME/webserver.pid"
SCHED_PID_FILE="$AIRFLOW_HOME/scheduler.pid"

start() {
  echo "Starting Airflow webserver..."
  nohup airflow webserver > "$AIRFLOW_HOME/webserver.log" 2>&1 &
  echo $! > "$WEB_PID_FILE"
  echo "Starting Airflow scheduler..."
  nohup airflow scheduler > "$AIRFLOW_HOME/scheduler.log" 2>&1 &
  echo $! > "$SCHED_PID_FILE"
  echo "Airflow webserver and scheduler started."
}

stop() {
  if [ -f "$WEB_PID_FILE" ]; then
    echo "Stopping Airflow webserver..."
    kill $(cat "$WEB_PID_FILE") && rm "$WEB_PID_FILE"
  fi
  if [ -f "$SCHED_PID_FILE" ]; then
    echo "Stopping Airflow scheduler..."
    kill $(cat "$SCHED_PID_FILE") && rm "$SCHED_PID_FILE"
  fi
  echo "Airflow webserver and scheduler stopped."
}

status() {
  if [ -f "$WEB_PID_FILE" ] && kill -0 $(cat "$WEB_PID_FILE") 2>/dev/null; then
    echo "Webserver is running (PID: $(cat $WEB_PID_FILE))"
  else
    echo "Webserver is not running."
  fi
  if [ -f "$SCHED_PID_FILE" ] && kill -0 $(cat "$SCHED_PID_FILE") 2>/dev/null; then
    echo "Scheduler is running (PID: $(cat $SCHED_PID_FILE))"
  else
    echo "Scheduler is not running."
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
