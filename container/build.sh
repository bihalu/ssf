#!/bin/bash

which podman
[ $? -eq 0 ] && podman build --build-arg HOST=$1 --build-arg FORWARD_HOST=$2 -t localhost/ssf:3.0.0 .

which docker
[ $? -eq 0 ] && docker build --build-arg HOST=$1 --build-arg FORWARD_HOST=$2 -t localhost/ssf:3.0.0 .


if [[ -f ssf.tar ]] ; then
  rm -f ssf.tar
fi

which podman
[ $? -eq 0 ] && podman image save -o ssf.tar localhost/ssf:3.0.0

which docker
[ $? -eq 0 ] && docker image save -o ssf.tar localhost/ssf:3.0.0
