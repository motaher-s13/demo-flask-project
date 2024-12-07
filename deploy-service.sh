#!/bin/bash

update_code_and_requirements() {
	git pull

  # Activate virtual environment
  source venv/bin/activate

  pip install --upgrade pip
	pip install -r requirements.txt

  # Deactivate virtual environment
  deactivate
}

restart_service() {
    sudo systemctl restart demo-flask-project.service
}

update_code_and_requirements
restart_service

echo "Flask app has been updated and restarted."