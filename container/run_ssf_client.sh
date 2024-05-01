#!/bin/bash

# forward localhost:8080 to 192.168.178.59:8080
FORWARD_HOST=127.0.0.1
FORWARD_PORT=8080
HOST=192.168.178.59
PORT=9011

# run container with podman or docker
RUN="run -it -e LOGLEVEL=trace -e MODE=client -e FORWARD_HOST=${FORWARD_HOST} -e FORWARD_PORT=${FORWARD_PORT} -e HOST=${HOST} -e PORT=${PORT} -v ./certs/dh4096.pem:/certs/dh4096.pem:ro -v ./certs/ca.crt:/certs/ca.crt:ro -v ./certs/private.key:/certs/private.key:ro -v ./certs/certificate.crt:/certs/certificate.crt:ro localhost/ssf:3.0.0"
which podman
[ $? -eq 0 ] && podman $RUN && exit $?

which docker
[ $? -eq 0 ] && docker $RUN && exit $?
