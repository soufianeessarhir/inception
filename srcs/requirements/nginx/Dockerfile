FROM alpine:3.21
RUN apk add --no-cache nginx openssl && mkdir -p /var/cache/nginx /var/log/nginx  /run/nginx && \
    chown -R nginx:nginx /var/cache/nginx /var/log/nginx /etc/nginx /run/nginx
COPY --chmod=600 --chown=nginx:nginx  conf/nginx.conf /etc/nginx/nginx.conf
COPY --chmod=700 --chown=nginx:nginx  tools/setup.sh  /usr/local/bin/setup.sh
ENTRYPOINT ["/usr/local/bin/setup.sh"]