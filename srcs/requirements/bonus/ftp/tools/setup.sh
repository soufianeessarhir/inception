#!/bin/sh
FTP_PASS=$(cat /run/secrets/ftp_pass)
addgroup -g 1337 -S www && \
adduser -u 1337 -D -S -G www -h /var/www/html -s /sbin/nologin $FTP_USER
echo "$FTP_USER:$FTP_PASS" | chpasswd
chown -R "$FTP_USER:www" /var/www/html
exec vsftpd /etc/vsftpd/vsftpd.conf