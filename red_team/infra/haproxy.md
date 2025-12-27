| 🏠 [Home](../../redteam.md) | ⬅️ ⬅️ [Part](../_part) | ⬅️ [Chapter](./_chapter) |
|-----------------------------|----------------------|-------------------------|

* [haproxy](../../red_team/infra/haproxy.md)


# haproxy
## todo
* integrate `ligolo-ng` ? tcp + tls donc dechiffrement TLS + analyse de la comm
```
# Detect TLS
    acl is_tls req.ssl_hello_type 1

```
* simplify to let haproxy route to non http sliver listeners:
```bash
acl path_lab     req.payload(0,20) -m sub /lab/
acl path_sliver  req.payload(0,20) -m sub /sliver/
acl path_sl_cyber req.payload(0,20) -m sub /sl_cyber/
acl path_sl_test req.payload(0,20) -m sub /sl_test/
acl path_obf     req.payload(0,20) -m sub /obf/

use_backend lab     if is_http path_lab
...SNIP...

backend lab
    mode tcp
    server lab1 127.0.0.1:8884
...SNIP...
```
* tcp with https nginx
## config
* listen on specific ips ports
* send http to nginx
* send tcp to penelope

```bash
global
  # log /dev/log local0 info
  log stdout format raw local0 info
  stats socket /var/lib/haproxy/stats level admin
  chroot /var/lib/haproxy
  user haproxy
  group haproxy
  daemon
  pidfile /run/haproxy.pid

defaults
  log global
  option  dontlognull
  option tcplog
  timeout connect 5s
  timeout client 50s
  timeout server 10m
  timeout connect 5s
  timeout client 50s
  timeout server 50s
  timeout tunnel 1h

frontend jubeaz
    bind *:80
    mode tcp
    log global
    log-format "src=%ci:%cp fe=%f be=%b srv=%s bytes=%B"
    tcp-request inspect-delay 2s
    tcp-request content accept if { req_len gt 0 }
    acl is_http req.proto_http
    acl from_10net src 10.0.0.0/8
    acl from_192net src 192.168.0.0/16
    use_backend nginx_backend if is_http
    use_backend tcp_backend if !is_http from_10net
    use_backend tcp_backend if !is_http from_192net
    default_backend backend_tcp_reject

backend nginx_backend
    mode tcp
    server nginx1 127.0.0.1:80
backend penelope_backend
    mode tcp
    timeout tunnel 12h
    server penelope 127.0.0.1:4444
backend backend_tcp_reject
    mode tcp
```

## ACLs to investiguate
* tcp:
    * src
    * dst
    * sport
    * dport
* tcp payload inspection
    * req.payload(offset,length) (req.payload(0,7) -m reg "^(GET|POST|HEAD)")
* SSL/TLS inspection (if bind ssl)
    * req.ssl_hello_type
    * req.ssl_sni
    * req.ssl_ver
    * ssl_fc_cipher
* 