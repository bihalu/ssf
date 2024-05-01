#!/bin/bash

# check certs
[ ! -f certs/dh4096.pem ] && echo missing certs/dh4096.pem && exit 1
[ ! -f certs/trusted/ca.crt ] && echo missing certs/trusted/ca.crt && exit 1
[ ! -f certs/private.key ] && echo missing certs/private.key && exit 1
[ ! -f certs/certificate.crt ] && echo missing certs/certificate.crt && exit 1

# run container with podman or docker
RUN="run -it -e LOGLEVEL=trace -e MODE=server -p 9011:8011 -v ./certs/dh4096.pem:/certs/dh4096.pem:ro -v ./certs/trusted/ca.crt:/certs/ca.crt:ro -v ./certs/private.key:/certs/private.key:ro -v ./certs/certificate.crt:/certs/certificate.crt:ro localhost/ssf:3.0.0"
which podman
[ $? -eq 0 ] && podman $RUN && exit $?

which docker
[ $? -eq 0 ] && docker $RUN && exit $?
