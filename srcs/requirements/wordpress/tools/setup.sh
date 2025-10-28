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

    wp config set WP_REDIS_HOST redis --type=constant --allow-root
    wp config set WP_REDIS_PORT 6379 --type=constant --raw --allow-root
    wp config set WP_CACHE true --type=constant --raw --allow-root

    wp core install --url="https://${DOMAIN_NAME}" \
    --title="${WP_TITLE}" --admin_user="${WP_ADMIN_USER}" \
    --admin_email="${WP_ADMIN_EMAIL}" --admin_password="${WP_ADMIN_PASSWORD}" \
    --path="/var/www/html" --allow-root --skip-email

    wp user create  "${WP_USER}" "${WP_USER_EMAIL}"\
    --user_pass="${WP_USER_PASSWORD}" --role=author \
    --path="/var/www/html" --allow-root

    wp plugin install redis-cache --activate --allow-root
    wp redis enable --allow-root
fi

exec php-fpm83 -F