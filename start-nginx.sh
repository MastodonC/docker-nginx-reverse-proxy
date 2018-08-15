#!/bin/sh

MAX_BODY_SIZE=${NGINX_MAX_BODY_SIZE:-16M}
SERVER_ADDR=${NGINX_SERVER_ADDR:?not set}
SERVER_PORT=${NGINX_SERVER_PORT:-8080}

PROXY_CONFIG_FILE=/etc/nginx/reverse.conf

echo "MAX_BODY_SIZE is ${MAX_BODY_SIZE}"
echo "SERVER_ADDR is ${SERVER_ADDR}:${SERVER_PORT}"

cat > ${PROXY_CONFIG_FILE} <<EOF
user nobody;
worker_processes 4;

events {
    worker_connections 1024;
}
error_log /dev/stdout info;
http {
    access_log /dev/stdout;
    include mime.types;
    default_type application/octet-stream;
    sendfile on;
    keepalive_timeout 65;
    server_tokens off;
    add_header X-Frame-Options SAMEORIGIN;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    auth_basic "Restricted Access";
    auth_basic_user_file /etc/nginx/htpasswd.users;
    server {
        listen 80;
        server_name _;

        client_max_body_size 4M;
        client_body_buffer_size 128k;
        real_ip_header X-Forwarded-For;
        set_real_ip_from 0.0.0.0/0;
        real_ip_recursive  on;

        location / {
            proxy_pass http://${SERVER_ADDR}:${SERVER_PORT};
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header Host \$http_host;
            proxy_set_header X-NginX-Proxy true;
            # Enables WS support
            proxy_http_version 1.1;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_redirect off;
        }
    }

}

EOF
rm -rf /etc/nginx/nginx.conf
ln -sf ${PROXY_CONFIG_FILE} /etc/nginx/nginx.conf

nginx -g 'daemon off;'
