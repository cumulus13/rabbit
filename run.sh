#!/bin/sh

podman -d run --memory=512m --cpus=2 --log-level=debug --name rabbitmq -p 5672:5672 -p 15672:15672 -p 61613:61613 -p 2222:22 -v "../../:/projects" rabbitmq
