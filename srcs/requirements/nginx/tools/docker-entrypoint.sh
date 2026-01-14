#!/bin/sh
set -e

# default.conf 内の $DOMAIN_NAME を環境変数の値に置換する
# 注意: コンテナ内に 'gettext' (envsubst) がインストールされている必要があります
envsubst '$DOMAIN_NAME' < /etc/nginx/conf.d/default.conf > /etc/nginx/conf.d/default.conf.tmp
mv /etc/nginx/conf.d/default.conf.tmp /etc/nginx/conf.d/default.conf

# Dockerfile の CMD で指定されたコマンド（nginx）を実行
exec "$@"
