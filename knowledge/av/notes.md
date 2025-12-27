| 🏠 [Home](../../pentesting.md) | ⬅️ ⬅️ [Part](../_part) | ⬅️ [Chapter](./_chapter) |
|--------------------------------|----------------------|-------------------------|

* [Antivirus](../../knowledge/av/notes.md)
    * [Signature databases](../../knowledge/av/notes.md#signature-databases)
    * [Static analysis](../../knowledge/av/notes.md#static-analysis)
    * [Heuristic and behavioural detection](../../knowledge/av/notes.md#heuristic-and-behavioural-detection)
    * [Import Address Table (IAT) inspection](../../knowledge/av/notes.md#import-address-table-iat-inspection)
    * [Antimalware Scan Interface AMSI)](../../knowledge/av/notes.md#antimalware-scan-interface-amsi)
        * [links](../../knowledge/av/notes.md#links)
    * [Event Tracing for Windows ETW)](../../knowledge/av/notes.md#event-tracing-for-windows-etw)
        * [links](../../knowledge/av/notes.md#links-1)
    * [API Hooking](../../knowledge/av/notes.md#api-hooking)
    * [Network detection](../../knowledge/av/notes.md#network-detection)

# Antivirus

## Signature databases

Signature-based analysis involves storing a list of all signatures known to belong to malicious programs, and then comparing each new signature with this list.

Although this approach is interesting, it is not sufficient on its own to guarantee the effectiveness of an antivirus. In fact, it is relatively easy to bypass. The slightest change, however minor, in a program will completely alter its signature.

Furthermore, this security method does not protect against new threats whose signatures are not yet listed.

## Static analysis

Static analysis consists of searching a program for one or more strings of characters known to belong to a malicious program.

## Heuristic and behavioural detection

The aim of heuristic detection is to understand how a program works and to determine what actions it is about to perform on a system.

This can be achieved by using a **sandbox**: an isolated virtual machine in which the potentially dangerous program can run. The antivirus software can then check the actions taken by the program during execution and look for indicators of malicious action.

Similarly, behavioural detection consists of observing the actions performed by a program during execution in order to spot any suspicious activity.

For example, certain calls to the Windows API made in a certain order are known to be typical malware patterns.

## Import Address Table (IAT) inspection

The Import Address Table is a table relating to each Portable Executable (contained in the import directory of the PE's optional header) which contains a list of loaded DLLs and their exported functions used by the program.

his table is observed by most antivirus software, and the presence of certain functions can trigger an alert.

For example, the presence of the functions `OpenProcess`, `VirtualAllocEx`, `WriteProcessMemory` and `CreateRemoteThreadEx` (all exported by `kernel32.dll`) together in the same program will make it highly suspect. These 4 functions used together enable process injection techniques often used by malicious programs.

[Import Adress Table (IAT) Hooking](https://www.ired.team/offensive-security/code-injection-process-injection/import-adress-table-iat-hooking)

## Antimalware Scan Interface (AMSI)

AMSI is an interface provided by the Windows operating system that any developer can use to integrate antivirus protection into their program.

More specifically, developers can choose to load the `AMSI.dll` DLL into their program and use the functions exported by this DLL. For example, the `AmsiScanString\verb` function takes a string of characters as input and returns `AMSI_RESULT_CLEAN` if no threat is detected and `AMSI_RESULT_DETECTED` otherwise.

AMSI therefore acts as a bridge between a given program and an antivirus

### links

* [Maelstrom 6: Working with AMSI and ETW for Red and Blue](https://pre.empt.blog/2023/maelstrom-6-working-with-amsi-and-etw-for-red-and-blue)

## Event Tracing for Windows (ETW)

ETW is a mechanism for tracking and logging a large number of events triggered by applications and drivers. Historically, ETW was mainly used for debugging purposes. Over time, the large amount of data reported by this system became of interest to vendors of protection solutions, who saw an opportunity to detect malicious activity by analysing the flows reported by the ETW.

ETW is made up of three distinct components:

* Providers: **Threat Intelligence provider** In several places in the Windows code associated with critical functionalities, function calls associated with the Event Tracing for Windows -- Threat Intelligence provider are observed. For example, the `MiReadWriteVirtualMemory` function makes a call to `EtwTiLogReadWriteVm`

* Consumers: various programs that will use the logs provided by the suppliers to act accordingly.

* Controllers: software components responsible for managing the event tracing process. Their main role is to initiate, monitor and control tracing sessions.

It should therefore be noted that for most of the actions we perform on a Windows system, event logs are sent back to the antivirus/EDR, which adds another method of detecting suspicious actions.

### links

* [Maelstrom 6: Working with AMSI and ETW for Red and Blue](https://pre.empt.blog/2023/maelstrom-6-working-with-amsi-and-etw-for-red-and-blue)

## API Hooking

Most Windows API functions are exported by `kernel32.dll`. These functions do not communicate directly with the kernel; to do so, they must use syscalls.

These system calls act as an interface enabling programs to interact with the Windows operating system. Most of them are exported as `ntdll.dll`, and the naming convention is that they begin with the letters `Nt`

very few actions are performed inside `Nt` functions. This is because, most of its code is actually in the kernel. The `ntdll` versions of these functions simply perform syscalls to invoke their kernel-mode counterparts.

When a security solution (such as an EDR) is installed on a machine, it may seek to perform API hooking. To do this, the security solution will monitor the machine to detect the creation of new processes.

When a new process is launched, the EDR will inject its own DLL into it. The EDR will look for the memory addresses of other DLLs whose functions it wishes to monitor. For example, an EDR wishing to monitor `NtProtectVirtualMemory` of `ntdll.dll` will first find the base address of `ntdll.dll` in the injected process, then the address of the `NtProtectVirtualMemory` function.

Once these actions have been carried out, the EDR will replace the first bytes at the base address of the targeted function (responsible for executing the syscall) with bytes corresponding to a jump instruction (`jmp`) to the code of its own DLL.

In this way, the EDR is free to perform the security tests it deems necessary and is able to monitor any calls to Windows API functions.

This will allow to defend against Address Import Table (IAT) evastion technics

## Network detection

Finally, some security solutions may monitor the connections made by the machine and block a threat based on certain indicators.

For example, a block might be decided if a program initiates a connection to an IP address known to be associated with malicious servers. This strengthens security by preventing malicious software from communicating with dangerous servers.

## links

* [Antivirus and EDR Bypass Techniques](https://www.vaadata.com/blog/antivirus-and-edr-bypass-techniques/#how-does-an-antivirus-edr-work)
