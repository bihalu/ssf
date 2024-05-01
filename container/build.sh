#!/bin/bash

docker build --build-arg HOST=$1 --build-arg FORWARD_HOST=$2 -t localhost/ssf:3.0.0 .

if [[ -f ssf.tar ]] ; then
  rm -f ssf.tar
fi

docker image save -o ssf.tar localhost/ssf:3.0.0