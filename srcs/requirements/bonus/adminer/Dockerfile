FROM alpine:3.21
RUN apk add --no-cache  php83 php83-session php83-mysqli php83-pdo_mysql php83-json \
    && mkdir -p /var/www/html && wget -O /var/www/html/index.php \
    https://github.com/vrana/adminer/releases/download/v5.4.1/adminer-5.4.1-mysql.php \
    && chown -R nobody:nobody /var/www/html

EXPOSE 8080
CMD ["php", "-S", "0.0.0.0:8080", "-t", "/var/www/html"]