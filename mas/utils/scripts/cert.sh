#!/usr/bin/env bash

 openssl  genrsa  -des3 -passout pass:abba -out utils/test_certs/client_new.key 1024 && openssl req -new -key utils/test_certs/client_new.key -out utils/test_certs/client_new.csr -passin pass:abba -subj "/C=IN/ST=HR/L=GGN/O=wrinq/CN=www.wrinq.com/emailAddress=akshat@wrinq.com" && openssl x509 -req -days 365 -in utils/test_certs/client_new.csr -CA utils/test_certs/ca.cert -CAkey utils/test_certs/ca.key -passin pass:abba -set_serial 01 -out utils/test_certs/shail.cert

