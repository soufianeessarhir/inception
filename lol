===== ./requirements/nginx/tools/setup.sh =====
#!/bin/sh

if [ ! -f "${CERTS_PATH}/nginx.cert" ] || [ ! -f "${CERTS_PATH}/nginx.key" ] ; then #the check is of restart cases
    mkdir -p ${CERTS_PATH}
    openssl req -nodes -x509 -days 365  -newkey rsa:2048 \
    -out ${CERTS_PATH}/nginx.cert \
    -keyout ${CERTS_PATH}/nginx.key \
    -subj  "/C=MA/ST=khouribga/L=khouribga/O=1337/CN=${DOMAIN_NAME}"
    chmod 644  "${CERTS_PATH}/nginx.cert"
    chmod 600  "${CERTS_PATH}/nginx.key"
fi

exec "nginx"
===== ./requirements/nginx/conf/nginx.conf =====
events {}

daemon off;

http
{
    ssl_session_cache   shared:SSL:10m;
    ssl_session_timeout 10m;

    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;

    server
    {
        listen 443 ssl;
        http2 on;
        server_name sessarhi.42.fr;
        keepalive_timeout 75;

        ssl_certificate /etc/nginx/nginx.cert;
        ssl_certificate_key /etc/nginx/nginx.key;
        ssl_protocols  TLSv1.3;

        root /var/www/html;
        index index.php index.html index.htm;
        location /
        {
            try_files $uri $uri/ /index.php?$args;
        }

        location ~ \.php$
        {
            fastcgi_split_path_info ^(.+\.php)(/.+)$;
            fastcgi_pass wordpress:9000;
            fastcgi_index index.php;
            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            fastcgi_param PATH_INFO $fastcgi_path_info;
        }
        
    }
    server 
    {
        listen 443 ssl;
        server_name static.sessarhi.42.fr;
        http2 on;
        keepalive_timeout 75;

        ssl_certificate /etc/nginx/nginx.cert;
        ssl_certificate_key /etc/nginx/nginx.key;
        ssl_protocols  TLSv1.3;
        location /
        {
            proxy_pass http://static-site:80;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
    server 
    {
        listen 443 ssl;
        server_name adminer.sessarhi.42.fr;
        http2 on;
        keepalive_timeout 75;

        ssl_certificate /etc/nginx/nginx.cert;
        ssl_certificate_key /etc/nginx/nginx.key;
        ssl_protocols  TLSv1.3;
        location /
        {
            proxy_pass http://adminer:8080;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
===== ./requirements/nginx/Dockerfile =====
FROM alpine:3.21
RUN apk add --no-cache nginx openssl && rm -rf /var/lib/apk
COPY --chmod=644 conf/nginx.conf /etc/nginx/nginx.conf
COPY --chmod=700 --chown=nginx tools/setup.sh /usr/local/bin/setup.sh
EXPOSE 443
ENTRYPOINT ["/usr/local/bin/setup.sh"]
===== ./requirements/nginx/.dockerignore =====

===== ./requirements/mariadb/tools/setup.sh =====
#!/bin/sh
DB_PASSWORD=$(cat /run/secrets/db_password)
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

if [ ! -d /var/lib/mysql/mysql  ]; then
mariadb-install-db --user=mysql --datadir=/var/lib/mysql
cat << EOF > /tmp/init_secure.sql
USE mysql;
FLUSH PRIVILEGES;
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost','127.0.0.1','::1');
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
CREATE DATABASE IF NOT EXISTS ${DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
EOF

mariadbd --user=mysql --bootstrap --verbose=0 < /tmp/init_secure.sql
rm -rf /tmp/init_secure.sql
fi
exec mariadbd --user=mysql --datadir=/var/lib/mysql
===== ./requirements/mariadb/conf/server.conf =====
[mysqld]
skip-networking = 0
user = mysql
datadir = /var/lib/mysql
bind-address = 0.0.0.0
socket = /run/mysqld/mysqld.sock
port = 3306
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci
===== ./requirements/mariadb/Dockerfile =====
FROM alpine:3.21
RUN apk add --no-cache mariadb mariadb-client && \
mkdir -p  /run/mysqld/  /var/lib/mysql/ && \
chown -R mysql:mysql /run/mysqld/  /var/lib/mysql
COPY --chmod=644  conf/server.conf /etc/my.cnf.d/mariadb-server.cnf
COPY --chmod=700  tools/setup.sh /usr/local/bin/setup.sh
EXPOSE 3306
ENTRYPOINT ["/usr/local/bin/setup.sh"]
===== ./requirements/mariadb/.dockerignore =====

===== ./requirements/bonus/ftp/tools/setup.sh =====
#!/bin/sh
FTP_PASS=$(cat /run/secrets/ftp_pass)
adduser -D -h /var/www/html -u 82 $FTP_USER 
echo "$FTP_USER:$FTP_PASS" | chpasswd
chown -R "$FTP_USER:$FTP_USER" /var/www/html
exec vsftpd /etc/vsftpd/vsftpd.conf
===== ./requirements/bonus/ftp/conf/vsftpd.conf =====
listen=YES
listen_ipv6=NO
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=NO
chroot_local_user=YES
secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd
pasv_enable=YES
pasv_min_port=21000
pasv_max_port=21010
pasv_address=0.0.0.0
user_sub_token=$USER
local_root=/var/www/html
allow_writeable_chroot=YES
===== ./requirements/bonus/ftp/Dockerfile =====
FROM alpine:3.21
RUN apk add --no-cache vsftpd && mkdir -p /var/www/html &&   mkdir -p /var/run/vsftpd/empty
COPY --chmod=444 conf/vsftpd.conf /etc/vsftpd/vsftpd.conf
COPY --chmod=744 tools/setup.sh /usr/local/bin/setup.sh
EXPOSE 21 21000-21010
ENTRYPOINT ["/usr/local/bin/setup.sh"]

===== ./requirements/bonus/static-site/tools/app/styles.css =====
body {
  background-image: url(https://cdn.freecodecamp.org/curriculum/css-cafe/beans.jpg);
  font-family: sans-serif;
  padding: 20px;
}

h1 {
  font-size: 40px;
  margin-top: 0;
  margin-bottom: 15px;
}

h2 {
  font-size: 30px;
}

.established {
  font-style: italic;
}

h1, h2, p {
  text-align: center;
}

.menu {
  width: 80%;
  background-color: burlywood;
  margin-left: auto;
  margin-right: auto;
  padding: 20px;
  max-width: 500px;
}

img {
  display: block;
  margin-left: auto;
  margin-right: auto;
  margin-top:-25px;
}

hr {
  height: 2px;
  background-color: brown;
  border-color: brown;
}

.bottom-line {
  margin-top: 25px;
}

h1, h2 {
  font-family: Impact, serif;
}

.item p {
  display: inline-block;
  margin-top: 5px;
  margin-bottom: 5px;
  font-size: 18px;
}

.flavor, .dessert {
  text-align: left;
  width: 75%;
}

.price {
  text-align: right;
  width: 25%;
}

/* FOOTER */

footer {
  font-size: 14px;
}

address {
  font-style: normal;
}

.address {
  margin-bottom: 5px;
}

a {
  color: black;
}

a:visited {
  color: black;
}

a:hover {
  color: brown;
}

a:active {
  color: brown;
}
===== ./requirements/bonus/static-site/tools/app/index.html =====
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Cafe Menu</title>
    <link href="styles.css" rel="stylesheet"/>
  </head>
  <body>
    <div class="menu">
      <main>
        <h1>CAMPER CAFE</h1>
        <p class="established">Est. 2020</p>
        <hr>
        <section>
          <h2>Coffee</h2>
          <img src="https://cdn.freecodecamp.org/curriculum/css-cafe/coffee.jpg" alt="coffee icon"/>
          <article class="item">
            <p class="flavor">French Vanilla</p><p class="price">3.00</p>
          </article>
          <article class="item">
            <p class="flavor">Caramel Macchiato</p><p class="price">3.75</p>
          </article>
          <article class="item">
            <p class="flavor">Pumpkin Spice</p><p class="price">3.50</p>
          </article>
          <article class="item">
            <p class="flavor">Hazelnut</p><p class="price">4.00</p>
          </article>
          <article class="item">
            <p class="flavor">Mocha</p><p class="price">4.50</p>
          </article>
        </section>
        <section>
          <h2>Desserts</h2>
          <img src="https://cdn.freecodecamp.org/curriculum/css-cafe/pie.jpg" alt="pie icon"/>
          <article class="item">
            <p class="dessert">Donut</p><p class="price">1.50</p>
          </article>
          <article class="item">
            <p class="dessert">Cherry Pie</p><p class="price">2.75</p>
          </article>
          <article class="item">
            <p class="dessert">Cheesecake</p><p class="price">3.00</p>
          </article>
          <article class="item">
            <p class="dessert">Cinnamon Roll</p><p class="price">2.50</p>
          </article>
        </section>
      </main>
      <hr class="bottom-line">
      <footer>
        <address>
          <p>
            <a href="https://www.freecodecamp.org" target="_blank">Visit our website</a>
          </p>
          <p class="address">123 Free Code Camp Drive</p>
        </address>
      </footer>
    </div>
  </body>
</html>
===== ./requirements/bonus/static-site/conf/nginx.conf =====
events {}

daemon off;

http
{
    sendfile        on;
    keepalive_timeout  65;
    server
    {
        listen 80;
        server_name static-site.42.fr;
        http2 on;
        root /var/lib/html;
        index index.html;
        location /
        {
            try_files $uri $uri/  /index.html;
        }
     }
}
===== ./requirements/bonus/static-site/Dockerfile =====
FROM alpine:3.21
RUN apk add --no-cache nginx
COPY --chmod=644 conf/nginx.conf /etc/nginx/nginx.conf 
COPY --chmod=644 tools/app/ /var/lib/html/
EXPOSE 80
CMD ["nginx"]
===== ./requirements/bonus/portainer/Dockerfile =====
FROM alpine:3.21

RUN wget https://github.com/portainer/portainer/releases/download/2.33.2/portainer-2.33.2-linux-amd64.tar.gz && \
    tar xzf portainer-2.33.2-linux-amd64.tar.gz && \
    rm portainer-2.33.2-linux-amd64.tar.gz
EXPOSE 9000
CMD ["/portainer/portainer", "--data", "/data"]
===== ./requirements/bonus/redis/conf/redis.conf =====
bind 0.0.0.0
protected-mode no
port 6379
tcp-backlog 511
unixsocket /run/redis/redis.sock
unixsocketperm 770
timeout 0
tcp-keepalive 300
loglevel notice
logfile /var/log/redis/redis.log
databases 16
always-show-logo no
set-proc-title yes
proc-title-template "{title} {listen-addr} {server-mode}"
locale-collate ""
stop-writes-on-bgsave-error yes
rdbcompression yes
rdbchecksum yes
dbfilename dump.rdb
rdb-del-sync-files no
dir /var/lib/redis
replica-serve-stale-data yes
replica-read-only yes
repl-diskless-sync yes
repl-diskless-sync-delay 5
repl-diskless-sync-max-replicas 0
repl-diskless-load disabled
repl-disable-tcp-nodelay no
replica-priority 100
acllog-max-len 128
lazyfree-lazy-eviction no
lazyfree-lazy-expire no
lazyfree-lazy-server-del no
replica-lazy-flush no
lazyfree-lazy-user-del no
lazyfree-lazy-user-flush no
oom-score-adj no
oom-score-adj-values 0 200 800
disable-thp yes
appendonly no
appendfilename "appendonly.aof"
appenddirname "appendonlydir"
appendfsync everysec
no-appendfsync-on-rewrite no
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
aof-load-truncated yes
aof-use-rdb-preamble yes
aof-timestamp-enabled no
slowlog-log-slower-than 10000
slowlog-max-len 128
latency-monitor-threshold 0
notify-keyspace-events ""
hash-max-listpack-entries 512
hash-max-listpack-value 64
list-max-listpack-size -2
list-compress-depth 0
set-max-intset-entries 512
set-max-listpack-entries 128
set-max-listpack-value 64
zset-max-listpack-entries 128
zset-max-listpack-value 64
hll-sparse-max-bytes 3000
stream-node-max-bytes 4096
stream-node-max-entries 100
activerehashing yes
client-output-buffer-limit normal 0 0 0
client-output-buffer-limit replica 256mb 64mb 60
client-output-buffer-limit pubsub 32mb 8mb 60
hz 10
dynamic-hz yes
aof-rewrite-incremental-fsync yes
rdb-save-incremental-fsync yes
jemalloc-bg-thread yes

===== ./requirements/bonus/redis/Dockerfile =====
FROM alpine:3.21
RUN apk add --no-cache redis
COPY --chmod=444 conf/redis.conf /etc/redis.conf
CMD ["redis-server", "/etc/redis.conf", "--daemonize", "no"]
===== ./requirements/bonus/adminer/Dockerfile =====
FROM alpine:3.21
RUN apk add --no-cache  php83 php83-session php83-mysqli php83-pdo_mysql php83-json \
    && mkdir -p /var/www/html && wget -O adminer.php https://github.com/vrana/adminer/releases/download/v5.4.1/adminer-5.4.1-mysql.php
EXPOSE 8080
CMD ["php", "-S", "127.0.0.1:8080", "-t", "/var/www/html"]
===== ./requirements/wordpress/tools/setup.sh =====
#!/bin/sh

DB_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)

if [ ! -f "/var/www/html/index.php" ]; then 
    cd /var/www/html
    wget -q https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz --strip-components=1
    rm latest.tar.gz
fi

if [ ! -f "/usr/local/bin/wp" ]; then
    wget -q https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
fi

if [ ! -f "/var/www/html/wp-config.php" ]; then

    wp config create --path="/var/www/html" \
    --dbname="${DB_NAME}" --dbuser="${DB_USER}" \
    --dbhost="${DB_HOST}" --dbpass="${DB_PASSWORD}" \
    --allow-root --force


    wp core install --url="https://${DOMAIN_NAME}" \
    --title="${WP_TITLE}" --admin_user="${WP_ADMIN_USER}" \
    --admin_email="${WP_ADMIN_EMAIL}" --admin_password="${WP_ADMIN_PASSWORD}" \
    --path="/var/www/html" --allow-root --skip-email

    wp user create  "${WP_USER}" "${WP_USER_EMAIL}"\
    --user_pass="${WP_USER_PASSWORD}" --role=author \
    --path="/var/www/html" --allow-root
fi

exec php-fpm83 -F
===== ./requirements/wordpress/conf/www.conf =====
[www]
user = nobody
listen = 9000
pm = dynamic
pm.max_children = 10
pm.start_servers = 3
pm.min_spare_servers = 2
pm.max_spare_servers = 5
pm.process_idle_timeout = 5s;
pm.max_requests = 500
clear_env = no
security.limit_extensions = .php
===== ./requirements/wordpress/Dockerfile =====
FROM alpine:3.21
RUN apk add --no-cache php83 php83-fpm php83-mysqli php83-json php83-curl php83-dom php83-exif \
    php83-fileinfo php83-mbstring php83-openssl php83-xml php83-zip php83-phar php83-intl php83-gd php83-iconv \
    php83-pecl-imagick php83-session php83-tokenizer curl && mkdir -p /var/www/html \
    /run/php 
COPY --chmod=444 conf/www.conf /etc/php83/php-fpm.d/www.conf
COPY --chmod=700 tools/setup.sh /usr/local/bin/setup.sh
EXPOSE 9000
ENTRYPOINT ["/usr/local/bin/setup.sh"]
CMD ["php-fpm83","-F"]
===== ./requirements/wordpress/.dockerignore =====

===== ./.env =====
DOMAIN_NAME=sessarhi.42.fr
WP_TITLE=inception
WP_ADMIN_USER=sessarhi
WP_ADMIN_EMAIL=sessarhi@student.42.fr
WP_USER=soufiane
WP_USER_EMAIL=soufiane@student.42.fr
CERTS_PATH=/etc/nginx
DB_NAME=wordpress
DB_USER=sessarhi
DB_HOST=mariadb:3306
FTP_USER=wordpress

===== ./docker-compose.yml =====
services:
  nginx:
    build:
      context: ./requirements/nginx
      dockerfile: Dockerfile
    image: nginx:inception
    container_name: nginx
    volumes:
      - wordpress-data:/var/www/html:ro
    networks:
      - inception
    ports:
      - "443:443"
    environment:
      - CERTS_PATH
      - DOMAIN_NAME
    restart: unless-stopped
    depends_on:
      - wordpress
  wordpress:
    build:
      context: ./requirements/wordpress
      dockerfile: Dockerfile
    image: wordpress:inception
    container_name: wordpress
    volumes: 
      - wordpress-data:/var/www/html
    networks:
      - inception
    environment:
      - DOMAIN_NAME
      - WP_TITLE
      - WP_ADMIN_EMAIL
      - WP_ADMIN_USER
      - WP_USER
      - WP_USER_EMAIL
      - DB_NAME
      - DB_USER
      - DB_HOST
    secrets:
      - wp_admin_password
      - wp_user_password
      - db_password
    restart: unless-stopped
    depends_on:
      mariadb:
        condition: service_healthy
      redis:
        condition: service_healthy
  mariadb:
    build:
      context: ./requirements/mariadb
      dockerfile: Dockerfile
    image: mariadb:inception
    container_name: mariadb
    volumes:
      - mariadb-data:/var/lib/mysql
    networks:
      - inception
    healthcheck:
      test: ["CMD-SHELL", "mysqladmin ping -u ${DB_USER} -p$$(cat /run/secrets/db_password) --socket=/var/run/mysqld/mysqld.sock --silent || exit 1"]
      interval: 5s
      timeout: 3s
      retries: 5
      start_period: 10s
    environment:
      - DB_NAME
      - DB_USER
    secrets:
      - db_password
      - db_root_password
    restart: unless-stopped
  redis:
    build:
      context: ./requirements/bonus/redis
      dockerfile: Dockerfile
    image: redis:inception
    container_name: redis
    networks:
      - inception
    restart: unless-stopped
    healthcheck:
      test: ["CMD","redis-cli",ping]
      interval: 5s
      timeout: 3s
      retries: 5
      start_period: 10s
  adminer:
    build:
      context: ./requirements/bonus/adminer
      dockerfile: Dockerfile
    image: adminer:inception
    container_name: adminer
    restart: always
    networks:
      - inception
    depends_on:
      mariadb:
        condition: service_healthy
  ftp:
    build:
      context: ./requirements/bonus/ftp
      dockerfile: Dockerfile
    image: ftp:inception
    container_name: ftp
    restart: always
    ports:
      - "21:21"
      - "21000-21010:21000-21010"
    environment:
      - FTP_USER
    secrets:
      - ftp_pass
    volumes:
      - wordpress-data:/var/www/html
  portainer:
    build:
      context: ./requirements/bonus/portainer
      dockerfile: Dockerfile
    image: portainer:inception
    container_name: portainer
    restart: always
  static-site:
    build:
      context: ./requirements/bonus/static-site
      dockerfile: Dockerfile
    image: static-site:inception
    container_name: static-site
    restart: unless-stopped
    networks:
      - inception
volumes:
    mariadb-data:
      driver: local
      driver_opts:
          type: none
          o: bind
          device: /home/${USER}/data/mariadb
    wordpress-data:
      driver: local
      driver_opts:
        type: none
        o: bind
        device: /home/${USER}/data/wordpress
    portainer-data:
        driver: local
        driver_opts:
          o: bind
          device: /home/${USER}/data/portiner
networks:
  inception:
    name: inception
    driver: bridge
secrets:
  db_password:
    file: ../secrets/db_password.txt
  db_root_password:
    file: ../secrets/db_root_password.txt
  wp_admin_password:
    file: ../secrets/wp_admin_password.txt
  wp_user_password:
     file: ../secrets/wp_user_password.txt
  ftp_pass:
    file: ../secrets/ftp_pass.txt

