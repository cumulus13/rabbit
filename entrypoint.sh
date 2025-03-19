#!/bin/bash
echo "[RABBITMQ] Set Date Time"
export TZ=/etc/localtime
ln -sf /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
echo "[RABBITMQ] Set timezone"
echo "Asia/Jakarta" > /etc/timezone
echo "[RABBITMQ] Start RabbitMQ server in the background"
rabbitmq-server -detached
# rabbitmq-server &
# service rabbitmq-server start
echo "[RABBITMQ] Start monitor [1] 5 seconds"
monitor

echo "[RABBITMQ] Enable rabbitmq_management plugin ..."
rabbitmq-plugins enable rabbitmq_management
echo "[RABBITMQ] Enable rabbitmq_stomp plugin ..."
rabbitmq-plugins enable rabbitmq_stomp
echo "[RABBITMQ] Enable rabbitmq_web_stomp plugin ..."
rabbitmq-plugins enable rabbitmq_web_stomp

# Wait for RabbitMQ to start
# echo "Waiting for RabbitMQ to start..."
# rabbitmqctl wait --timeout 5000 /var/lib/rabbitmq/mnesia/rabbit@$HOSTNAME.pid
# rabbitmqctl wait /var/lib/rabbitmq/mnesia/rabbit@$HOSTNAME.pid
# service rabbitmq-server start
# sleep 30

echo "[RABBITMQ] Configuring RabbitMQ..."
rabbitmqctl --node rabbit@$HOSTNAME add_user "$RABBITMQ_USERNAME" "$RABBITMQ_PASSWORD"
rabbitmqctl --node rabbit@$HOSTNAME set_user_tags "$RABBITMQ_USERNAME" administrator
rabbitmqctl --node rabbit@$HOSTNAME set_permissions -p / "$RABBITMQ_USERNAME" ".*" ".*" ".*"

cat <<EOL > /etc/rsyslog.d/50-rabbitmq.conf
input(type="imfile" File="/var/log/rabbitmq/rabbit@$HOSTNAME.log" Tag="rabbitmq" Severity="info" Facility="local0")
local0.* /var/log/rabbitmq/rabbitmq@$HOSTNAME.log
EOL

echo "[RABBITMQ] Run rsyslogd ..."
# echo "[RABBITMQ] Copying rsyslog configuration..." && cp -f /etc/rsyslog.conf /etc/rsyslog.conf
rsyslogd -f /etc/rsyslog.conf
echo "[RABBITMQ] Starting SSH server ..."
service sshd start
# echo "Start monitor [2] 300 seconds"
monitor -m -t 600
echo "[RABBITMQ] Bring RabbitMQ to the foreground"
exec rabbitmq-server
