
| 🏠 [Home](../../redteam.md) | ⬅️ ⬅️ [Part](../_part) | ⬅️ [Chapter](./_chapter) |
|-----------------------------|----------------------|-------------------------|



# Notes



## Introduction
DCOM (Distributed Component Object Model) is the networked extension of COM.
DCOM = COM + RPC + object activation

**Service Control Manager (SCM)**: `rpcss` service A network-enabled service for:
* Creating/instantiating COM objects
* Managing COM object lifetime
* Resolving CLSIDs
* Looking up servers

How Remote DCOM Activation Works:
* Client calls: `CoCreateInstanceEx(CLSID, ...)`
* Client contacts Remote SCM over RPC (tcp, pipe...)
* **Remote Service Control Manager** checks (DCOMCNFG):
    * AppID permissions
    * Launch permissions
    * Access permissions
* **OXIDResolver** exchanges object references. Once the COM object lives in the remote server:
    * The object exposes an OXID (Object Exporter ID)
    * DCOM retrieves its network binding info
    * The client receives:
    * OXID
    * IP/endpoint bindings
    * Interface references
* RPC calls are made directly to the object

DCOM Uses These RPC Interfaces
    * IOXIDResolver: Object reference resolution
    * IORPCSS: COM activation + SCM
    * IRemoteActivation: Launching remote COM objects
    * IObjectExporter: Provides binding information

* **COM Object**: A reusable component identified by a CLSID (GUID).
    * `combase.dll = "18f70770-8e64-11cf-9af1-0020af6e72f4"`
* **Interfaces**: Each COM object exposes interfaces (IUnknown, IDispatch, etc.).
* **Marshaling / Unmarshaling**: When you use a COM object in a different process, Windows serializes the reference into a blob called `OBJREF`. This blob includes:
    * `OXID` — object exporter ID
    * `OID` — object ID
    * `IPID` — interface pointer ID
    * `DualStringArray` — binding strings (RPC endpoints)

This is where Potato exploits attack.
* DCOM automatically performs:
    * RPC connections
    * Impersonation
    * Remote activation
    * Authentication delegation
    * Elevation checks


* Attack Vector 1: Privilege Escalation (Potato chain)
    * Classic Potato family: RottenPotato, RottenPotatoNG, JuicyPotato, PrintSpoofer, RoguePotato, RemotePotato, EfsPotato, SigmaPotato (your code)
    *  These exploit:
        * SYSTEM process → unmarshals a malicious **OBJREF**
        * SYSTEM connects back to your RPC endpoint
        * You impersonate SYSTEM → spawn SYSTEM shell

    * Why?: Because DCOM will “blindly” trust the binding information inside the **OBJREF**. If you replace binding with: `ncacn_np:localhost[\pipe\YourPipe]`. SYSTEM connects,  impersonation works, elevation.

* Attack Vector 2: Remote Code Execution via DCOM Activation
    * Some COM objects allow remote activation if you have permissions. For emaple: ShellWindows, MMC20.Application, Excel.Application can be remotely activated via DCOM.
    * Tools: dcomexec.py (Impacket) wmiexec.py (uses DCOM behind WMI)
    * If DCOM permissions are misconfigured → you get remote code execution without SMB, WinRM, or RDP.

* Attack Vector 3: Lateral Movement through WMI (which uses DCOM)
    * WMI = RPC/DCOM internally. So when attackers use: `mic /node:TARGET process call create ...` or tools like: CrackMapExec,  Metasploit psexec modules Impacket wmiexec, …it’s all DCOM under the hood.

* Attack Vector 4: UAC Bypass Using COM Elevation Monikers
    * Some COM objects automatically elevate via UAC if called through: `Elevation:Administrator!new:CLSID`
    * If UAC settings allow “auto-elevate”, this leads to UAC bypass. Examples: FileOperation, ShellExecute, TaskScheduler
    * Tools: UACME uses dozens of COM elevation tricks.


* **OXID / OID / IPID**: Identifiers inside **OBJREF**. You usually keep them unchanged when crafting a malicious **OBJREF**.
* **DualStringArray**: This is the blob inside **OBJREF** that stores **RPC binding** (ncacn_np, ncacn_ip_tcp, etc.) **Security bindings**.If you change it → you control where the other process connects.
* **Security Descriptor & Access Control**: COM uses ACLs to decide who can Activate COM object, Access its interfaces, Perform remote calls. Misconfigured DCOM permissions = easy lateral movement.

**ioxidresolver**: is a Windows DCOM/RPC interface implemented by the RPCSS service (`rpcss.dll`) and defined in `dcom.idl` used for resolving and locating COM objects across machines. It’s part of the Windows Distributed Component Object Model (DCOM) infrastructure. iT handles:
* OXID Resolution
* Resolve Binding Information. Given an OXID, the resolver returns: Network addresses, ,RPC bindings,Authentication capabilities,Object references
* Ping Logic. t is part of the distributed garbage collection mechanism — periodic pings detect when remote COM objects should be cleaned up

Enum: `netsh rpc show`


registry
```
HKCR\CLSID\{CLSID}\LocalServer32
HKCR\CLSID\{CLSID}\InprocServer32
HKCR\CLSID\{CLSID}\AppID
HKCR\AppID\{APPID}
```

# security

Windows COM has its own security model, separate from file/registry ACLs.
For remote COM (DCOM), this determines:
* Who can activate a COM server
* Who can launch a COM server
* Who can call methods on it
* Whether the server enforces impersonation
* What identity the server runs as (SYSTEM? Administrator?)

COM security is complex, but it boils down to 3 big layers:

## COM security layer

### Machine-wide Default Security
fallback if not defined at APP level
```
HKLM\SOFTWARE\Microsoft\Ole\
    DefaultAccessPermission
    DefaultLaunchPermission
    MachineAccessRestriction
    MachineLaunchRestriction
```
### Per-AppID Security
```
HKCR\AppID\{AppIDGUID}\
     AccessPermission
     LaunchPermission
     AuthenticationLevel
```
### Runtime Security (per-call settings)
A COM server and client must agree on:

* Authentication level (None, Connect, Packet, Packet Integrity, Packet Privacy)
* Impersonation level (Anonymous, Identify, Impersonate, Delegate)

These are negotiated during ORPC calls (Object RPC, DCOM layer).

## Key COM Security Concepts

### authentication level
* `None`	No auth	Rare
* `Connect`	Auth only at connect time
* `Packet`	Signs packets
* `Packet Integrity`	Signs + ensures integrity
* `Packet Privacy`	Full encryption	(WMI uses this)

### mpersonation Levels
* `Anonymous`:	Server cannot know caller identity
* `Identify`:	Server can read identity
* `Impersonate`:	Server can impersonate caller for local calls
* `Delegate`:	Server can impersonate caller remotely

## COM Permission Attack Surface
### Remote COM Activation i.e RCE
if "LaunchPermission" allows “Everyone”, “Authenticated Users”, or a domain group:

Attacker can:
* Remotely trigger COM activation (DCOM)
* Force system to launch a COM server (dllhost.exe) running as SYSTEM
* Use AccessPermission to call methods
* Achieve remote code execution

Examples:
* MMC20.Application
* ShellBrowserWindow
* Excel.Application (if remotely activatable)


### Abuse of Misconfigured AppIDs
A common pentest finding:
```
LaunchPermission = Everyone
AccessPermission = Everyone
```
This means:
* Anyone can launch the COM server
* Anyone can call sensitive methods (CreateProcess, File IO, script eval)

Some COM objects provide filesystem/registry/process actions i.e RCE.

### COM + NTLM Relay / Coercion
Some COM interfaces force a target to authenticate to you:
* IOXIDResolver (classic NTLM leak)
* Certain COM objects when instantiating a remote object
* WMI (remote DCOM mode) authentication flows

This is how the “Coerce authentication over DCOM” attacks work.

### SID-Based Misconfigurations
`LaunchPermission` and `AccessPermission` are raw binary ACLs (self-relative security descriptors).

Many admins accidentally include:
* Everyone (S-1-1-0)
* Authenticated Users (S-1-5-11)
* Users (BUILTIN\Users)

This silently exposes DCOM activation to all domain users.

## Tools
`https://github.com/albertony/dcompermex`

Dump LaunchPermission / AccessPermission
Convert binary SD → readable ACL


* `Get-AppLockerFileInformation` (PowerShell)

Reads AppID and COM registry mappings

* `OLEView` / `OLEView.NET`

Enumerate CLSIDs, AppIDs, interfaces, security.

* `rpcdump` / `rpcinfo`

Enumerate underlying RPC interfaces for a COM server

`PyDCOM`, comsvcs.dll tools

Test activation / access.

# Pentest
**How to Spot DCOM Vulnerabilities During Pentests**

* Enumerate COM objects & permissions: 
    * oleview.exe
    * PowerShell COM enumeration scripts
    * nxc dcom module

* Look for:
    * Remote activation allowed
    * Launch/Activation permissions
    * Accessible COM objects running as SYSTEM
    * Misconfigured WMI
    * Known vulnerable CLSIDs used in Potato exploits
    * Services that auto-unmarshal COM references


## High-level architecture — what a “Potato” does (conceptual, non-actionable)

A Potato exploit typically chains these capabilities:
* Find a privileged COM/RPC target that will run code or unmarshal data in a high-privilege process (often SYSTEM).
* Craft or alter an OBJREF / RPC binding so that when the privileged process unmarshals it or activates something, it connects back to a server you control (e.g., a named pipe or TCP RPC endpoint).
* Accept that connection and impersonate the connecting client token (often SYSTEM). From that token, create a process or perform actions as SYSTEM.
* Clean up / restore any hooks to avoid crashing the host.

Key building blocks (conceptual):

* Locating COM structures in memory (e.g., combase.dll) and identifying the dispatch table or the place to intercept/unmarshal.
* Creating a listener that will accept RPC/pipe connections and allow token impersonation.
* Triggering the target to perform the unmarshal/activation with your crafted reference.
* Using impersonation APIs (ImpersonateNamedPipeClient, DuplicateTokenEx, CreateProcessAsUser) to act with the elevated token.



## Development
 * [IMoniker](https://learn.microsoft.com/en-us/windows/win32/api/objidl/nn-objidl-imoniker): Enables you to use a moniker object, which contains information that uniquely identifies a COM object. An object that has a pointer to the moniker object's IMoniker interface can locate, activate, and get access to the identified object without having any other specific information on where the object is actually located in a distributed system.