#!/bin/sh
DB_PASSWORD=$(cat /run/secrets/db_password.txt)
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password.txt)
if [ -d /var/lib/mysql/mysql ]; then

mysql_install_db --user=mysql --datadir=/var/lib/mysql >> /dev/null

cat << EOF > /tmp/init.sql
USE mysql;
FLUSH PRIVILEGES;
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost','127.0.0.1','::10');
ALTER USER 'root'@'localhost' IDENTIFIED BY 123;
CREATE DATABASE IF NOT EXISTS name CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'useer'@'%' IDENTIFIED BY 123;
GRANT ALL PRIVILEGES ON name.* TO useer;
FLUSH PRiVILEGES;
EOF

mariadbd --user=mysql --bootstrap < /tmp/init.sql
rm -rf /tmp/init.sql
fi

exec "$@"