#!/bin/sh
if [ ! -f "${CERTS_PATH}/nginx.cert"  || ! -f "${CERTS_PATH}/nginx.key" ] ;then #the check is of restart cases
    openssl req -nodes -x509 -days 365  -newkey rsa:2048\
    -out ${CERTS_PATH}/nginx.cert \
    -keyout ${CERTS_PATH}/nginx.key  #paths should be defined explecitly
fi