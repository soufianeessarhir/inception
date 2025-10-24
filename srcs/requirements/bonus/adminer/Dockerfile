FROM alpine:3.21
RUN apk add --no-cache  php81 php81-session php81-mysqli php81-pdo_mysql php81-json wget \
    && mkdir -p /var/www/html && wget -O adminer.php https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1-mysql.php
EXPOSE 8080
CMD ["php", "-S", "0.0.0.0:8080", "-t", "/var/www/html"]