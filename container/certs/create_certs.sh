#!/bin/bash

# adjust common name if you like
CN=example.com

rm -f dh4096.pem ca.crt ca.srl ca.key extfile.txt private.key certificate.csr certificate.crt server.crt server.key trusted/ca.crt ssf-secret.yaml

# generate Diffie-Hellmann parameters
openssl dhparam -outform PEM -out dh4096.pem 4096

# generating a self-signed certification authority (CA) ca.crt and its private key ca.key
openssl req -x509 -nodes -newkey rsa:4096 -keyout ca.key -subj "/CN=ca ${CN}" -out ca.crt -days 3650

# create extfile.txt
cat - > extfile.txt << EOF_EXTFILE
[ v3_req_p ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
[ v3_ca_p ]
basicConstraints = CA:TRUE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment, keyCertSign
EOF_EXTFILE

# generating a private key private.key and its certificate certificate.cst signed with a CA ca.crt
openssl req -newkey rsa:4096 -nodes -keyout private.key -subj "/CN=key ${CN}" -out certificate.csr

# then, sign with the CA (ca.crt, ca.key) the signing request to get the certificate certificate.crt
openssl x509 -extfile extfile.txt -extensions v3_req_p -req -sha256 -days 3650 -CA ca.crt -CAkey ca.key -CAcreateserial -in certificate.csr -out certificate.crt

cat ca.crt >> certificate.crt
cp ca.crt trusted/ca.crt
