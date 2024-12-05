#!/bin/bash

APP_MODULE="app:app"

WORKERS=4

HOST="0.0.0.0"
PORT=8000
LOG_FILE="app.log"

update_code_and_requirements() {
  source /home/ubuntu/demo-flask-project/venv/bin/activate
	git pull
	pip install -r requirements.txt
}

kill_existing_process() {
    echo "Killing existing Gunicorn process..."
    pkill -f "gunicorn.*${APP_MODULE}"
    sleep 2  # Give some time for the process to be killed
}

start_flask_app() {
    echo "Starting Flask app with Gunicorn..."
    nohup gunicorn -w $WORKERS --timeout 120 -b $HOST:$PORT $APP_MODULE > $LOG_FILE 2>&1 &
}

update_code_and_requirements
kill_existing_process
start_flask_app

echo "Flask app is now running on http://$HOST:$PORT"
