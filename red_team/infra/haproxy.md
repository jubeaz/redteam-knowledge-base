```
global
    log /dev/log local0
    daemon

defaults
    log     global
    timeout connect 5s
    timeout client  50s
    timeout server  50s

frontend mixed_listener
    bind *:80

    # Traffic classification
    # req.len > 0 means HAProxy successfully parsed HTTP headers
    mode http
    acl is_http req.len gt 0

    # Source ACLs
    acl from_10net    src 10.0.0.0/8
    acl from_192net   src 192.168.0.0/16

    ### ROUTING LOGIC ###

    # 1. If it's HTTP → forward to nginx on 8080
    use_backend backend_http if is_http

    # 2. If it's NOT HTTP → fallback to raw TCP routing
    use_backend backend_8871 if !is_http from_10net
    use_backend backend_8870 if !is_http from_192net

    # 3. If non-HTTP from unknown networks → drop or send to default
    default_backend backend_reject

### BACKENDS ###

backend backend_http
    mode http
    server nginx1 127.0.0.1:8080

backend backend_8871
    mode tcp
    server s1 127.0.0.1:8871

backend backend_8870
    mode tcp
    server s2 127.0.0.1:8870

backend backend_reject
    mode tcp
    # Reject the connection cleanly
    errorfile 503 /etc/haproxy/errors/503.http
```