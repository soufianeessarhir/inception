FROM alpine:3.21
RUN apk add --no-cache nginx openssl
COPY --chmod=644 conf/nginx.conf /etc/nginx/nginx.conf
COPY --chmod=700 --chown=nginx tools/setup.sh /usr/local/bin/setup.sh
EXPOSE 443
ENTRYPOINT ["/usr/local/bin/setup.sh"]