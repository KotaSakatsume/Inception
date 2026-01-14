#!/bin/sh
set -e

# mysqld 用ディレクトリ
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

# 初期化フラグ
INIT_FILE="/var/lib/mysql/.initialized"

if [ ! -f "$INIT_FILE" ]; then
    echo "Initializing MariaDB..."

    chown -R mysql:mysql /var/lib/mysql
    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null

    DB_ROOT_PWD=$(cat /run/secrets/db_root_password)
    DB_PWD=$(cat /run/secrets/db_password)

    mysqld --user=mysql --bootstrap << EOF
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PWD}';

CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PWD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

    touch "$INIT_FILE"
    echo "MariaDB initialized"
fi

echo "Starting MariaDB..."
exec mysqld --user=mysql --bind-address=0.0.0.0
