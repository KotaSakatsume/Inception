#!/bin/sh
set -e

# 1. ディレクトリ準備
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

# 2. データベース未初期化の場合、システムテーブルを作成
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Installing MariaDB system tables..."
    chown -R mysql:mysql /var/lib/mysql
    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null

    # 3. 初期設定 (bootstrapモードで実行)
    # Secretsを安全に読み込んでSQL文に注入
    DB_ROOT_PWD=$(cat /run/secrets/db_root_password)
    DB_PWD=$(cat /run/secrets/db_password)

    echo "Initializing database..."
    mysqld --user=mysql --bootstrap << EOF
USE mysql;
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PWD}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PWD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF
fi

# 4. 本番起動
echo "Starting MariaDB..."
exec mysqld --user=mysql --bind-address=0.0.0.0