#!/bin/bash

if [ -z $1 ] ; then
  SECRET_YAML=ssf-secret.yaml
else
  SECRET_YAML=$1
fi

# restore kubernetes secret
mkdir -p certs/trusted
yq '.data."dh4096.pem"' $SECRET_YAML | tr -d '"' | base64 -d > certs/dh4096.pem
yq '.data."ca.crt"' $SECRET_YAML | tr -d '"' | base64 -d > certs/trusted/ca.crt
yq '.data."private.key"' $SECRET_YAML | tr -d '"' | base64 -d > certs/private.key
yq '.data."certificate.crt"' $SECRET_YAML | tr -d '"' | base64 -d > certs/certificate.crt
