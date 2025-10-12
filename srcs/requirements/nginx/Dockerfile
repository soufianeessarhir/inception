FROM alpine:3.21
RUN apk add --no-cache nginx openssl && rm -rf /var/cache/apk/* && rm -rf /var/lib/apk
COPY --chmod=644 conf/nginx.conf /etc/nginx/nginx.conf
COPY --chmod=700 --chown=nginx tools/setup.sh /usr/local/bin/setup.sh
EXPOSE 443
ENTRYPOINT ["/usr/local/bin/setup.sh"]
CMD ["nginx"]