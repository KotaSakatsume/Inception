#!/bin/sh
set -e

SSL_DIR=/etc/nginx/ssl

if [ ! -f "$SSL_DIR/nginx.crt" ]; then
	mkdir -p $SSL_DIR

	#証明書（x509形式）作成
	openssl req -x509 -nodes \
		#期限
		-days 365 \
		#鍵作成
		-newkey rsa:2048 \
		#鍵の置き場
		-keyout $SSL_DIR/nginx.key \
		#証明書の置き場
		-out $SSL_DIR/nginx.crt \
		-subj "/C=JP/ST=Tokyo/L=Tokyo/O=42/OU=student/CN=kosakats.42.fr"
fi

exec nginx -g "daemon off;"
