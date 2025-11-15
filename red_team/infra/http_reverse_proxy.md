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
