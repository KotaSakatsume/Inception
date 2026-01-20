FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    mariadb-server \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# bind-address を 127.0.0.1 から 0.0.0.0 に変更（外部接続を許可）
RUN sed -i 's/bind-address            = 127.0.0.1/bind-address            = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf

COPY tools/init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh

# MariaDBが必要なディレクトリを作成し、権限を付与（エラー防止）
RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

# ポート3306を宣言
EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/init.sh"]