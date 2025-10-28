FROM alpine:3.21
RUN apk add --no-cache vsftpd && mkdir -p /var/www/html /var/run/vsftpd/empty
COPY --chmod=444 conf/vsftpd.conf /etc/vsftpd/vsftpd.conf
COPY --chmod=744 tools/setup.sh /usr/local/bin/setup.sh
EXPOSE 21 21000-21010
ENTRYPOINT ["/usr/local/bin/setup.sh"]
