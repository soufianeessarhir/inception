FROM alpine:3.21
RUN apk add --no-cache php83 php83-fpm php83-mysqli php83-json php83-curl php83-dom php83-exif \
    php83-fileinfo php83-mbstring php83-openssl php83-xml php83-zip php83-phar php83-intl php83-gd php83-iconv \
    php83-pecl-imagick php83-session php83-tokenizer wget curl && rm -rf /var/cache/apk/* && mkdir -p /var/www/html \
    /run/php 
COPY --chmod=700 conf/www.conf /etc/php83/php-fpm.d/www.conf
EXPOSE 9000
USER nobody
ENTRYPOINT ["tools/setup.sh"]