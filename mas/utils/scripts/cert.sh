#!/usr/bin/env bash

openssl x509 -req -days 365 -in utils/test_certs/client.csr -CA utils/test_certs/ca.cert -CAkey utils/test_certs/ca.key -passin pass:abba -set_serial 01 -out utils/test_certs/shail.cert
