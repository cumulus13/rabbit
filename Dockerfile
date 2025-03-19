FROM base-alpine AS rabbitmq-pkgs

RUN apk update
RUN apk add --no-cache rabbitmq-server 

# ENV RABBITMQ_VERSION=3.12.5
# ENV RABBITMQ_USER=root
# ENV RABBITMQ_PASSWORD=root

EXPOSE 5672 15672 22

COPY entrypoint.sh /usr/local/bin/
COPY monitor /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/monitor
RUN mkdir /etc/rsyslog.d
# COPY conf/rsyslog/514-rsyslog.conf /etc/rsyslog.d
# COPY conf/rsyslog/50-rabbitmq.conf /etc/rsyslog.d
# COPY conf/rsyslog/rsyslog.conf /etc/rsyslog.conf
# CMD /usr/sbin/sshd
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
