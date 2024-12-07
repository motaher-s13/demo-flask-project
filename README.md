# Run Flask App on AWS EC2 Instance

Note: Modified the Gunicorn command so Gunicorn runs in the foreground instead of being backgrounded by removing nohup and '&'. Systemd expects the process started by ExecStart to keep running as long as the service is active.

Install Python Virtualenv
```bash
sudo apt-get update
sudo apt-get install python3-venv
```
pull the project. inside the project create virtual-environment
Create directory
```bash
cd demo-flask-project
python3 -m venv venv
```

Use systemd to manage Gunicorn

Systemd is a boot manager for Linux. We are using it to restart gunicorn if the EC2 restarts or reboots for some reason.
We create a demo-flask-project.service file in the /etc/systemd/system folder, and specify what would happen to gunicorn when the system reboots.
We will be adding 3 sections inside the service file — Unit, Service, Install.

Unit — This section is for description about the project and some dependencies.

Service — To specify user/group we want to run this service after. Also some information about the executables and the commands.

Install — tells systemd at which moment during boot process this service should start. it actually links the service with a target(collection of other services/units.)

With that said, make a service file in systemd directory
	
```bash
sudo nano /etc/systemd/system/demo-flask-project.service
```
```bash
[Unit]
Description=Gunicorn instance for a simple hello world Flask app
After=network.target

[Service]
User=ubuntu
Group=www-data
WorkingDirectory=/home/ubuntu/demo-flask-project
ExecStart=/home/ubuntu/demo-flask-project/venv/bin/gunicorn \
          -w 4 --timeout 120 -b 0.0.0.0:8000 app:app
Restart=on-failure
RestartSec=5


[Install]
WantedBy=multi-user.target
```
Then enable the service:
```bash
sudo systemctl daemon-reload
sudo systemctl start demo-flask-project
sudo systemctl enable demo-flask-project
```
Check if the app is running with 
```bash
curl localhost:8000
```

Cross check if the symbolic link with the target been created
```bash
ls -l /etc/systemd/system/multi-user.target.wants/ | grep demo-flask-project.service
```

check the service related logs to ensure if it's running correctly
```bash
sudo journalctl -u demo-flask-project.service -f
``` 

**Test auto start**

Restart the EC2 from AWS dashboard and test if the app api still works. also check the service status

```bash
sudo systemctl status demo-flask-project.service
```

**Test restart after crash**

Manually kill the Gunicorn process associated with your Flask app:
```bash
sudo pkill -SIGABRT gunicorn
```
This simulates the app crashing unexpectedly. Since Restart=on-failure is set, systemd should automatically restart the service.

Monitor the Restart. Check the service status to verify that it restarted. 

```bash
sudo systemctl status demo-flask-project.service
```
Alternatively, tail the logs to watch the restart in real-time:

```bash
sudo journalctl -u demo-flask-project.service -f
```



**How to Remove the service**

first stop and detach the service
```bash
sudo systemctl stop demo-flask-project.service
sudo systemctl disable demo-flask-project.service
```

Remove the Service File
```bash
sudo rm /etc/systemd/system/demo-flask-project.service
```
Reload systemd. check the service status
```bash
sudo systemctl daemon-reload
systemctl status myapp.service
```


reference: https://github.com/yeshwanthlm/YouTube/blob/main/flask-on-aws-ec2.md
