FROM alpine:3.21
RUN apk add --no-cache php83 php83-fpm php83-mysqli php83-json php83-curl php83-dom php83-exif \
    php83-fileinfo php83-mbstring php83-openssl php83-xml php83-zip php83-phar php83-intl php83-gd php83-iconv \
    php83-pecl-imagick php83-session php83-tokenizer curl php83-redis php83-pecl-redis && \
    addgroup -g 1337 -S www && adduser -u 1337 -D -S -G www -s /sbin/nologin www && mkdir -p /var/www/html /run/php \
    && chown -R www:www /var/www/html /run/php
COPY --chmod=444 conf/www.conf /etc/php83/php-fpm.d/www.conf
COPY --chmod=700 --chown=www:www tools/setup.sh /usr/local/bin/setup.sh
EXPOSE 9000
ENTRYPOINT ["/usr/local/bin/setup.sh"]
