#!/bin/bash

echo "Start RabbitMQ server in the background"
rabbitmq-server -detached
# rabbitmq-server &
# service rabbitmq-server start
echo "Start monitor [1] 5 seconds"
monitor

# Wait for RabbitMQ to start
# echo "Waiting for RabbitMQ to start..."
# rabbitmqctl wait --timeout 5000 /var/lib/rabbitmq/mnesia/rabbit@$HOSTNAME.pid
# rabbitmqctl wait /var/lib/rabbitmq/mnesia/rabbit@$HOSTNAME.pid
# service rabbitmq-server start
# sleep 30

echo "Configuring RabbitMQ..."
rabbitmqctl --node rabbit@$HOSTNAME add_user "$RABBITMQ_USER" "$RABBITMQ_PASSWORD"
rabbitmqctl --node rabbit@$HOSTNAME set_user_tags "$RABBITMQ_USER" administrator
rabbitmqctl --node rabbit@$HOSTNAME set_permissions -p / "$RABBITMQ_USER" ".*" ".*" ".*"

echo "Starting SSH server..."
service sshd start
echo "Start monitor [2] 300 seconds"
monitor -m -t 300
echo "Bring RabbitMQ to the foreground"
exec rabbitmq-server
