#!/bin/sh
FTP_PASS=$(cat /run/secrets/ftp_pass)
echo "${FTP_USER}" > /etc/vsftpd/user_list

if ! getent group www > /dev/null 2>&1; then
    addgroup -g 1337 -S www
fi

if ! id -u "${FTP_USER}" > /dev/null 2>&1; then
    adduser -u 1337 -D -S -G www -h /var/www/html -s /sbin/nologin "${FTP_USER}"
fi

echo "$FTP_USER:$FTP_PASS" | chpasswd
chown -R "$FTP_USER:www" /var/www/html
exec vsftpd /etc/vsftpd/vsftpd.conf