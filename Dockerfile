#
# Nginx Dockerfile
#

# Pull base image.
FROM alpine:edge
MAINTAINER behroozam <b.hasanbg@gmail.com>

WORKDIR /var/www/html

RUN apk --update add \
        nginx \
        bash
# Install Nginx.
RUN mkdir -p /run/nginx
RUN chown nobody:nobody /var/tmp/nginx/
# Define working directory.
WORKDIR /etc/nginx

ADD start-nginx.sh /start-nginx
ADD ./htpasswd/htpasswd.users /etc/nginx/

# Define default command.
CMD ["/bin/bash","/start-nginx"]

# Expose ports.
EXPOSE 80
EXPOSE 443
