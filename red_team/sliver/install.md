| 🏠 [Home](../../pentesting.md) | ⬅️ ⬅️ [Part](../_part) | ⬅️ [Chapter](./_chapter) |
|--------------------------------|----------------------|-------------------------|

-   [Install, maintenance and config](#install-and-maintenance){#toc-install-and-maintenance}
    -   [System wide install](#system-wide-install){#toc-system-wide-install}
    -   [Per user install](#per-user-install){#toc-per-user-install}
        -   [Server](#server){#toc-server}
        -   [client](#client){#toc-client}
    - [Config](#config)

# Install and maintenance

## System wide install

    curl https://sliver.sh/install|sudo bash

run as root:
* install the component in root
* launche the server as a service
* Generate a profile for each user in the system

## Per user install

### Server

in `~/.sliver/`

Download the server and manually launch the server
```bash
wget -q https://github.com/BishopFox/sliver/releases/download/v1.5.42/sliver-server_linux ; chmod +x sliver-server_linux ./sliver-server_linux
```
Generate operator profile:
```bash
new-operator -n <name> -l <listening_ip> [-p <listening_port|31337>]
```
### client

in `~/.sliver-client/` and config are stored in in `~/.sliver-client/configs`

install the client and import the profile:
```bash
wget -q https://github.com/BishopFox/sliver/releases/download/v1.5.42/sliver-client_linux ; chmod +x ./sliver-client_linux
./sliver-client_linux import student_127.0.0.1.cfg
./sliver-client_linux 
```


## Config

`/root/.sliver/configs/http-c2.json`
* `"stager_file_ext": ".woff",`
