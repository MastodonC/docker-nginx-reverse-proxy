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

http {
server {

        listen 80 default_server;

        error_log /var/log/nginx/error.log;

        server_name _;

        location /events {
            access_log /var/log/nginx/access.log;

	    client_max_body_size ${MAX_BODY_SIZE};

            # Assumes we are already behind a reverse proxy (e.g. ELB)
            real_ip_header X-Forwarded-For;
            set_real_ip_from 0.0.0.0/0;

            proxy_pass http://${SERVER_ADDR}:${SERVER_PORT};

        }

	location /_elb_status {
            access_log /var/log/nginx/elb_status_access.log;
            proxy_pass http://${SERVER_ADDR}:${SERVER_PORT};
        }

    }
}
EOF
rm -rf /etc/nginx/nginx.conf
ln -sf ${PROXY_CONFIG_FILE} /etc/nginx/nginx.conf

nginx -g 'daemon off;'
