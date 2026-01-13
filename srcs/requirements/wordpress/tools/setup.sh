#!/bin/sh

# WordPressがインストールされていない場合のみ実行
if [ ! -f "/var/www/html/wp-config.php" ]; then
    echo "Setting up WordPress..."

    # WP-CLIのダウンロード
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp

    # WordPress本体のダウンロード
    wp core download --allow-root --path=/var/www/html

    # wp-config.php の生成 (環境変数はdocker-compose.ymlから渡される想定)
    wp config create \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost="mariadb" \
        --allow-root \
        --path=/var/www/html

    # WordPressのインストール
    wp core install \
        --url="${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --allow-root \
        --path=/var/www/html
        
    # 一般ユーザーの作成
    wp user create "${WP_USER}" "${WP_USER_EMAIL}" --user_pass="${WP_USER_PASSWORD}" --role=author --allow-root --path=/var/www/html
fi

echo "Starting PHP-FPM..."
exec /usr/sbin/php-fpm7.4 -F