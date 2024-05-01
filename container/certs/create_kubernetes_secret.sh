#!/bin/bash

# create kubernetes secret
DH4096_PEM=$(base64 -w 0 dh4096.pem)
CA_CRT=$(base64 -w 0 ca.crt)
PRIVATE_KEY=$(base64 -w 0 private.key)
CERTIFICATE_CRT=$(base64 -w 0 certificate.crt)

cat - > ssf-secret.yaml << EOF_SECRET
apiVersion: v1
kind: Secret
metadata:
  name: ssf-secret
type: Opaque
data:
  dh4096.pem : ${DH4096_PEM}
  ca.crt : ${CA_CRT}
  private.key : ${PRIVATE_KEY}
  certificate.crt : ${CERTIFICATE_CRT}
EOF_SECRET