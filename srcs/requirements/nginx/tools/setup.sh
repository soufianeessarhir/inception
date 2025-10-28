#!/bin/sh

if [ ! -f "${CERTS_PATH}/nginx.cert" ] || [ ! -f "${CERTS_PATH}/nginx.key" ] ; then #the check is of restart cases
    mkdir -p ${CERTS_PATH}
    openssl req -nodes -x509 -days 365  -newkey rsa:2048 \
    -out ${CERTS_PATH}/nginx.cert \
    -keyout ${CERTS_PATH}/nginx.key \
    -subj  "/C=MA/ST=khouribga/L=khouribga/O=1337/CN=${DOMAIN_NAME}"
    chmod 644  "${CERTS_PATH}/nginx.cert"
    chmod 600  "${CERTS_PATH}/nginx.key"
fi
exec nginx