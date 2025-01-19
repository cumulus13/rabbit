FROM alpine:latest

# Set environment variables for RabbitMQ
ENV RABBITMQ_VERSION=3.12.5
ENV RABBITMQ_USER=root
ENV RABBITMQ_PASSWORD=root

# Update and install dependencies
RUN apk update && apk add --no-cache \
    bash \
    zsh \
    zsh-vcs \
    util-linux-misc \
    tzdata \
    curl \
    wget \
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
    rsyslog \
    rsyslog-clickhouse \
    rsyslog-crypto \
    rsyslog-dbg \
    rsyslog-doc \
    rsyslog-elasticsearch \
    rsyslog-gssapi \
    rsyslog-hiredis \
    rsyslog-http \
    rsyslog-imdocker \
    rsyslog-libdbi \
    rsyslog-mmanon \
    rsyslog-mmaudit \
    rsyslog-mmcount \
    rsyslog-mmdblookup \
    rsyslog-mmfields \
    rsyslog-mmjsonparse \
    rsyslog-mmnormalize \
    rsyslog-mmpstrucdata \
    rsyslog-mmrm1stspace \
    rsyslog-mmsequence \
    rsyslog-mmsnmptrapd \
    rsyslog-mmtaghostname \
    rsyslog-mmutf8fix \
    rsyslog-mysql \
    rsyslog-openrc \
    rsyslog-pgsql \
    rsyslog-pmaixforwardedfrom \
    rsyslog-pmlastmsg \
    rsyslog-pmsnare \
    rsyslog-rabbitmq \
    rsyslog-relp \
    rsyslog-snmp \
    rsyslog-testing \
    rsyslog-tls \
    rsyslog-udpspoof \
    rsyslog-uxsock \
    rsyslog-zmq \
    && mkdir -p /var/run/sshd \
    && chmod 0755 /var/run/sshd

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
    chsh -s /bin/zsh
RUN git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k
RUN cp -v ~/.zshrc ~/.zshrc.bck
RUN sed -i 's/^ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel9k\/powerlevel9k"/' ~/.zshrc

RUN pip install pika tenacity python-dotenv ctraceback clipboard pydebugger requests bs4 ipython -t $(python -c "import sys;print(sys.path[-1])")
# RUN ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N "" -q && ssh-keygen -A
COPY conf/id_rsa ~/.ssh/

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
RUN mkdir /etc/rsyslog.d
COPY conf/rsyslog/514-rsyslog.conf /etc/rsyslog.d
COPY conf/rsyslog/50-rabbitmq.conf /etc/rsyslog.d
COPY conf/rsyslog/rsyslog.conf /etc/rsyslog.conf
CMD /usr/sbin/sshd
# Entry point
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
