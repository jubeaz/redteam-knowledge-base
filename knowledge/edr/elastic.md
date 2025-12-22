| 🏠 [Home](../../redteam.md) | ⬅️ ⬅️ [Part](../_part) | ⬅️ [Chapter](./_chapter) |
|-----------------------------|----------------------|-------------------------|


# Intoduction

hings/redteam/evasion/elastic-edr/


* **elastic-agent**: This is the main controller for Elastic’s unified agent:
    *  used for:
        * Logging
        * Metrics
        * Fleet management
        * Integrations
        * Running endpoint security modules
    * It’s the “host” process that installs, updates, and manages other Elastic components.

* **ElasticEndpoint**: This is the EDR/Endpoint Security component:
    * responsible for:
        * Behavioral monitoring
        * Malware detection
        * Elastic EDR rules
        * Memory scanning
        * Telemetry collection
        * Anti-tamper protections
    * It runs as a separate, protected service so the AV/EDR portion remains active even if Elastic Agent fails. 

* **elastic-endpoint-driver.sys**: the kernel driver runs early and monitor
    * Process creation
    * Thread injection
    * DLL loads
    * Network connections
    * File modifications

# Enumeration
```powershell
Get-Service | where {$_.Name -like '*Elastic*'}
Get-Service ElasticEndpoint | fl *
Get-CIMInstance -Class Win32_Service -Filter "name ='ElasticEndpoint' " | Select-Object *
# File System Minifilter Drivers
fltmc filters
Get-WmiObject Win32_SystemDriver | Where-Object { $_.Name -like "*elastic*" } | fl *
```
## Current Config

Beeing able to access the config stored in `C:\Program Files\Elastic\Endpoint\state\artifacts\global-artifacts` require SYSTEM. But with an administrator account it is possible to leverage  `elastic-agent` (under `C:\Program Files\Elastic\Agent\data\elastic-agent-<version>\` or its link `C:\Program Files\Elastic\Agent\`)

`elastic-agent.exe diagnostics` will produce an archive containing `json` `zlib-flate` compressed files

```bash
$ cat user-artifacts\\endpoint-blocklist-windows-v1 |zlib-flate -uncompress | jq
{
  "entries": [
    {
      "type": "simple",
      "entries": [
        {
          "field": "file.path",
          "operator": "included",
          "type": "exact_caseless_any",
          "value": [
            "c:\\windows\\tasks\\*",
            "*sliver*",
```



# links
* [](https://swisskyrepo.github.io/InternalAllTheThings/redteam/evasion/elastic-edr/)