#!/bin/bash

# loglevel critical|error|warning|info|debug|trace (default: info)
if [[ -z ${LOGLEVEL} ]] ; then
  export LOGLEVEL=info
else
  set -x
  echo "LOGLEVEL=${LOGLEVEL}"
fi

# check environment variables
if [[ -z ${MODE} ]] ; then
  echo "MODE not set!"
  exit 1
else
  if [[ ${MODE} == server || ${MODE} == client ]] ; then
    echo "MODE=${MODE}"
  else
    echo "MODE must contain server or client!"
    exit 1
  fi
  if [[ ${MODE} == client && -z ${FORWARD_HOST} ]] ; then
    echo "FORWARD_HOST not set!"
    exit 1
  else
    echo "FORWARD_HOST=${FORWARD_HOST}"
  fi
  if [[ ${MODE} == client && -z ${FORWARD_PORT} ]] ; then
    echo "FORWARD_PORT not set!"
    exit 1
  else
    echo "FORWARD_PORT=${FORWARD_PORT}"
  fi
  if [[ ${MODE} == client && -z ${HOST} ]] ; then
    echo "HOST not set!"
    exit 1
  else
    echo "HOST=${HOST}"
  fi
fi
if [[ -z ${PORT} ]] ; then
  echo "PORT not set!"
  exit 1
else
  echo "PORT=${PORT}"
fi

# start ssf server or client
cd /app
ls /app/certs
ls /app/certs/trusted
if [[ ${MODE} == server ]] ; then
  /app/upx-ssfd -v ${LOGLEVEL} -p ${PORT} -g
else
  /app/upx-ssf -v ${LOGLEVEL} -p ${PORT} -R ${FORWARD_PORT}:${FORWARD_HOST}:${FORWARD_PORT} ${HOST}
fi
