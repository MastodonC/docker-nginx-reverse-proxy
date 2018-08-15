a simple fun and lightweight nginx reverse proxy with enviroment variable

```docker run yourbuildtag -e NGINX_SERVER_ADDR:YourIpOrDns -e NGINX_SERVER_PORT:YourPort```

for create htpasswd use your own commandline htpasswd tool and creat htpasswd.users in htpasswd directory like this 

```htpasswd -c htpasswd.users admin```

### todo 
- [x] change ubuntu base image to alpine 
- [x] add satisfy or allow deney access or basic auth 
