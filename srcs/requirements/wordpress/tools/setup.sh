DB_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/credentials)
if [! -f "/var/www/html/index.php"]; then 
    cd /var/www/html
     wget https://wordpress.org/wordpress-6.4.3.tar.gz
    tar -xzf wordpress-6.4.3.tar.gz --strip-components=1
    rm wordpress-6.4.3.tar.gz
fi

