FROM alpine:3.21
RUN apk add --no-cache nginx openssl && mkdir -p /var/cache/nginx /var/log/nginx && \
    chown -R nginx:nginx /var/cache/nginx /var/log/nginx /etc/nginx
COPY --chmod=644 conf/nginx.conf /etc/nginx/nginx.conf
COPY --chmod=700 --chown=nginx:nginx tools/setup.sh /usr/local/bin/setup.sh
USER nginx
EXPOSE 443
ENTRYPOINT ["/usr/local/bin/setup.sh"]