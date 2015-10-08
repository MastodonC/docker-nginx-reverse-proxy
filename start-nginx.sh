#!/bin/sh

MAX_BODY_SIZE=${NGINX_MAX_BODY_SIZE:-16M}
SERVER_ADDR=${NGINX_SERVER_ADDR:?not set}
SERVER_PORT=${NGINX_SERVER_PORT:-8080}

PROXY_CONFIG_FILE=/etc/nginx/sites-available/reverse-proxy

echo "MAX_BODY_SIZE is ${MAX_BODY_SIZE}"
echo "SERVER_ADDR is ${SERVER_ADDR}:${SERVER_PORT}"

cat > ${PROXY_CONFIG_FILE} <<EOF
server {

        listen 80 default_server;

        error_log /var/log/nginx/error.log;

        server_name reverse-proxy;

        # special handling for the status url, so can separate out
        # the access logs for that.
        location /_elb_status {
            access_log /var/log/nginx/elb_status_access.log;
            proxy_pass http://${SERVER_ADDR}:${SERVER_PORT};
        }

        # All requests passed through.
        location / {
            access_log /var/log/nginx/access.log;

            client_max_body_size ${MAX_BODY_SIZE};

            # Assumes we are already behind a reverse proxy (e.g. ELB)
            real_ip_header X-Forwarded-For;
            set_real_ip_from 0.0.0.0/0;

            proxy_pass http://${SERVER_ADDR}:${SERVER_PORT};

        }

}
EOF

rm /etc/nginx/sites-enabled/*

ln -sf ${PROXY_CONFIG_FILE} /etc/nginx/sites-enabled/default

nginx
