# # Use the RabbitMQ management image as the base
# FROM rabbitmq:3-management

# # Set environment variables for RabbitMQ
# ENV RABBITMQ_DEFAULT_USER=root \
#     RABBITMQ_DEFAULT_PASS=root

# # Install OpenSSH server
# USER root
# RUN apt-get update && apt-get install -y openssh-server && \
#     mkdir /var/run/sshd && \
#     echo 'root:root' | chpasswd && \
#     sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
#     sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
#     echo "UseDNS no" >> /etc/ssh/sshd_config

# # Ensure permissions and ownership are correct for RabbitMQ
# RUN chown -R rabbitmq:rabbitmq /var/lib/rabbitmq

# # Generate the .erlang.cookie file as root and set correct permissions
# RUN head -c 20 /dev/urandom > /var/lib/rabbitmq/.erlang.cookie && \
#     chmod 600 /var/lib/rabbitmq/.erlang.cookie && \
#     chown rabbitmq:rabbitmq /var/lib/rabbitmq/.erlang.cookie

# # Expose RabbitMQ and SSH ports
# EXPOSE 5672 15672 15671 61613 22

# # Start both SSH and RabbitMQ servers
# CMD service ssh start && rabbitmq-server

# # CMD \
# #     if [ ! -f /var/lib/rabbitmq/.erlang.cookie ]; then \
# #         head -c 20 /dev/urandom > /var/lib/rabbitmq/.erlang.cookie && \
# #         chmod 400 /var/lib/rabbitmq/.erlang.cookie && \
# #         chown rabbitmq:rabbitmq /var/lib/rabbitmq/.erlang.cookie && \
# #         echo ".erlang.cookie created and permissions set."; \
# #     else \
# #         echo ".erlang.cookie already exists."; \
# #     fi && \
# #     service ssh start && rabbitmq-server

# Use the official Alpine base image
# Use the official Alpine base image
# Use the official Alpine base image
FROM alpine:latest

# Set environment variables for RabbitMQ
ENV RABBITMQ_VERSION=3.12.5
ENV RABBITMQ_USER=root
ENV RABBITMQ_PASSWORD=root

# Update and install dependencies
RUN apk update && apk add --no-cache \
    bash \
    rabbitmq-server \
    openssh \
    openrc \
    sudo \
    shadow \
    git \
    gcc \ 
    musl-dev \
    linux-headers \
    python3 \
    python3-dev \
    python3-pyc \
    py3-utils \
    ipython \
    py3-pip \
    py3-setuptools \
    && mkdir -p /var/run/sshd \
    && chmod 0755 /var/run/sshd

RUN pip install pika tenacity python-dotenv ctraceback clipboard pydebugger requests bs4 -t $(python -c "import sys;print(sys.path[-1])")
RUN ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N "" -q && ssh-keygen -A

# Ensure the RabbitMQ configuration directory exists
RUN mkdir -p /etc/rabbitmq && \
    touch /etc/rabbitmq/enabled_plugins

# Add RabbitMQ plugins
RUN rabbitmq-plugins enable rabbitmq_management rabbitmq_stomp

# Configure OpenSSH server
# RUN useradd -m -s /bin/bash admin && \
RUN echo "root:root" | chpasswd && \
    echo "root ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
    rc-update add sshd default && \
    rc-update add rabbitmq-server default

# Expose ports for RabbitMQ and SSH
EXPOSE 5672 15672 22

# Copy entrypoint   script
COPY entrypoint.sh /usr/local/bin/
COPY monitor /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/monitor
CMD /usr/sbin/sshd
# Entry point
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
