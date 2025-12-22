| 🏠 [Home](../../redteam.md) | ⬅️ ⬅️ [Part](../_part) | ⬅️ [Chapter](./_chapter) |
|-----------------------------|----------------------|-------------------------|


# minifilter drivers


Minifilter drivers are a major security-sensitive part of the Windows I/O stack, used by:
* Antivirus / EDR (defender, CrowdStrike, Elastic, etc.)
* Ransomware protection engines
* Encryption tools (BitLocker)
* Virtualization tools (Hyper-V, VMware)
* Backup/snapshot tools (VSS)
* File system redirectors (OneDrive, Dropbox)
* Data loss prevention tools (DLP)
* This is legitimate system-administration and defensive knowledge.

They intercept I/O operations on files:
* Create/open (IRP_MJ_CREATE)
* Read
* Write
* Query information
* Rename
* Delete
* Directory enumeration
* …and many others

Minifilter drivers attach to file system volumes at specific altitudes, which determine processing order.

```powershell
Get-CimInstance Win32_SystemDriver | Where-Object {$_.State -eq "Running"} | Format-Table Name, DisplayName, PathName 
```