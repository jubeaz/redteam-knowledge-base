| 🏠 [Home](../../redteam.md) | ⬅️ ⬅️ [Part](../_part) | ⬅️ [Chapter](./_chapter) |
|-----------------------------|----------------------|-------------------------|




# Export section (.edata)

[The .edata
Section](https://learn.microsoft.com/en-us/windows/win32/debug/pe-format#the-edata-section-image-only)

The export data section, named .edata, contains information about
symbols that other images can access through dynamic linking. Exported
symbols are generally found in DLLs, but DLLs can also import symbols.

At the beginning of the Exports section, we have a structure of type
`ImageExportDirectory` that gives the few information there is to know
about this section. While other sections make a multitude of calls to
other structures, VA and others, this section is rather simple to
explore.
