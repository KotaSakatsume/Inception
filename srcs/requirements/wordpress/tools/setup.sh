#!/bin/sh
set -e

WP_PATH="/var/www/html"

echo "Starting WordPress setup..."

# secrets から DB パスワード取得
MYSQL_PASSWORD=$(cat /run/secrets/db_password)

# MariaDB が「接続＋DB存在＋権限OK」になるまで待つ
until mysql -h mariadb \
            -u"${MYSQL_USER}" \
            -p"${MYSQL_PASSWORD}" \
            "${MYSQL_DATABASE}" \
            -e "SELECT 1" >/dev/null 2>&1
do
    echo "Waiting for MariaDB..."
    sleep 3
done

echo "MariaDB is ready."

# wp-config.php がなければ初期セットアップ
if [ ! -f "${WP_PATH}/wp-config.php" ]; then
    echo "Installing WordPress..."

    # WP-CLI install
    if [ ! -x /usr/local/bin/wp ]; then
        curl -sO https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
        chmod +x wp-cli.phar
        mv wp-cli.phar /usr/local/bin/wp
    fi

    cd "$WP_PATH"

    # WordPress 本体
    wp core download --allow-root

    # wp-config.php 作成
    wp config create \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost="mariadb" \
        --allow-root

    # WordPress インストール
    wp core install \
        --url="${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root

    # 一般ユーザー作成
    wp user create \
        "${WP_USER}" \
        "${WP_USER_EMAIL}" \
        --user_pass="${WP_USER_PASSWORD}" \
        --role=author \
        --allow-root

    echo "WordPress installation completed."
else
    echo "WordPress already installed."
fi

echo "Starting PHP-FPM..."
exec /usr/sbin/php-fpm7.4 -F
