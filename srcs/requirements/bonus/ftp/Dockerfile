FROM alpine:3.21
RUN apk add --no-cache vsftpd && mkdir -p /var/www/html
COPY --chmod=644 conf/vsftpd.conf /etc/vsftpd/vsftpd.conf
COPY --chmod=700 tools/setup.sh /usr/local/bin/setup.sh
EXPOSE 12 21000-21010
USER nobody
ENTRYPOINT ["/usr/local/bin/setup.sh"]