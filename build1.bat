@echo off
echo ... > build.log
start cmd /k tail -f build.log
podman build -t rabbitmq --layers --logfile build.log .
