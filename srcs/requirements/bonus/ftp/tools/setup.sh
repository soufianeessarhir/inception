#!/bin/sh
FTP_PASS=$(cat /run/secrets/ftp_pass)
adduser -D -h /var/www/html $FTP_USER 
echo "$FTP_USER:$FTP_PASS" | chpasswd
chown -R "$FTP_USER:$FTP_USER" /var/www/html
exec vsftpd /etc/vsftpd/vsftpd.conf