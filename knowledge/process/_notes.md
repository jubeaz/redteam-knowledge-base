| 🏠 [Home](../../redteam.md) | ⬅️ ⬅️ [Part](../_part) | ⬅️ [Chapter](./_chapter) |
|-----------------------------|----------------------|-------------------------|

* [notes](../../knowledge/process/_notes.md)
    * [Get IAT from process](../../knowledge/process/_notes#get-iat-from-process)
    * [Process Environment Block (PEB)](../../knowledge/process/_notes#process-environment-block-peb)
        * [Structure](../../knowledge/process/_notes#structure)
        * [Access using assembly](../../knowledge/process/_notes#access-using-assembly)
        * [PEB walk](../../knowledge/process/_notes#peb-walk)
        * [Links](../../knowledge/process/_notes#links)
    * [Thread Environment Block (TEB)](../../knowledge/process/_notes#thread-environment-block-teb)
    * [Process and security](../../knowledge/process/_notes#process-and-security)
    * [Protected Process Light (PPL)](../../knowledge/process/_notes#protected-process-light-ppl)

# Notes
## Get IAT from process

        // Get the base address of the current module (EXE)
        HMODULE hModule = GetModuleHandle(NULL);
        // Get the address of the IMAGE_DOS_HEADER (the base of the PE file)
        PIMAGE_DOS_HEADER pDOSHeader = (PIMAGE_DOS_HEADER)hModule;

        // Get the address of the IMAGE_NT_HEADERS
        PIMAGE_NT_HEADERS pNTHeaders = (PIMAGE_NT_HEADERS)((BYTE*)hModule + pDOSHeader->e_lfanew);

        // Get the address of the IMAGE_IMPORT_DESCRIPTOR (the IAT)
        PIMAGE_IMPORT_DESCRIPTOR pImportDescriptor = (PIMAGE_IMPORT_DESCRIPTOR)(
            (BYTE*)hModule + pNTHeaders->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].VirtualAddress
        );

## Process Environment Block (PEB)

[PEB - Part
1.md](https://github.com/Faran-17/Windows-Internals/blob/main/Processes%20and%20Jobs/Processes/PEB%20-%20Part%201.md)

### Structure

`ntdll.lib`

[PEB fields frequently used by malware
developers](https://metehan-bulut.medium.com/understanding-the-process-environment-block-peb-for-malware-analysis-26315453793f),
along with brief descriptions of each:

-   

-   `0x002` `BeingDebugged`, Anti-Debug

-   `0x068` `NtGlobalFlag`, Anti-Debug

-   `0x018` `ProcessHeap`, Anti-Debug

-   `0x00c` `Ldr`, API Hashing

-   `0x008` `ImageBaseAddress`, Process Hollowing

-   `0x010` `ProcessParameters`, UAC Bypass

<!-- -->

    typedef struct _LIST_ENTRY {
        struct _LIST_ENTRY *Flink;
        struct _LIST_ENTRY *Blink;
    } LIST_ENTRY, *PLIST_ENTRY, PRLIST_ENTRY;
        
    typedef struct _UNICODE_STRING {
        USHORT Length;
        USHORT MaximumLength;
        PWSTR  Buffer;
    } UNICODE_STRING, *PUNICODE_STRING;

When a process running, Windows OS will allocates a [Process Environment
Block
(PEB)](http://undocumented.ntinternals.net/index.html?page=UserMode%2FUndocumented%20Functions%2FNT%20Objects%2FProcess%2FPEB.html)
structure for the process. The PEB is created by the kernel and it
basically contains fields that provide information such as loaded
modules, process parameters, environment variables, and many more.

[PEB_LDR_DATA](http://undocumented.ntinternals.net/index.html?page=UserMode%2FUndocumented%20Functions%2FNT%20Objects%2FProcess%2FPEB.html)
structure that contains information of loaded (EXEs/DLLs) modules,
including the doubly-linked list `InMemoryOrderModuleList`

    typedef struct _PEB_LDR_DATA {
        ULONG                   Length;
        BOOLEAN                 Initialized;
        PVOID                   SsHandle;
        LIST_ENTRY              InLoadOrderModuleList;
        LIST_ENTRY              InMemoryOrderModuleList;
        LIST_ENTRY              InInitializationOrderModuleList;
    } PEB_LDR_DATA, *PPEB_LDR_DATA;

-   `Lenght`: Size of structure, used by ntdll.dll as structure version
    ID.

-   `Initialized` If set, loader data section for current process is
    initialized.

-   `SsHandle`: unknown

-   `InLoadOrderModuleList`: doubly linked list containing pointers to
    `LDR_MODULE` structure for previous and next module in load order

-   `InMemoryOrderModuleList`: same as `InLoadOrderModuleList` but in
    memory placement order

-   `InInitializationOrderModuleList`: same as `InLoadOrderModuleList`
    but in memory initialization order

`InMemoryOrderModuleList` a doubly linked list containing pointers to
[LDR_MODULE](http://undocumented.ntinternals.net/index.html?page=UserMode%2FUndocumented%20Functions%2FNT%20Objects%2FProcess%2FPEB.html)
structure for previous and next module in memory placement order.

    typedef struct _LIST_ENTRY {
        struct _LIST_ENTRY *Flink; // 4 or 8 bytes
        struct _LIST_ENTRY *Blink; // 4 or 8 bytes
    } LIST_ENTRY, *PLIST_ENTRY, PRLIST_ENTRY;

    typedef struct _UNICODE_STRING {
        USHORT Length;
        USHORT MaximumLength;
        PWSTR  Buffer;
    } UNICODE_STRING, *PUNICODE_STRING;

    typedef struct _LDR_MODULE {
        LIST_ENTRY              InLoadOrderModuleList;
        LIST_ENTRY              InMemoryOrderModuleList;
        LIST_ENTRY              InInitializationOrderModuleList;
        PVOID                   BaseAddress; // 4 or 8 bytes
        PVOID                   EntryPoint;  // 4 or 8 bytes
        ULONG                   SizeOfImage; // 4 bytes
        UNICODE_STRING          FullDllName;
        UNICODE_STRING          BaseDllName;
        ULONG                   Flags;
        SHORT                   LoadCount;
        SHORT                   TlsIndex;
        LIST_ENTRY              HashTableEntry;
        ULONG                   TimeDateStamp;
    } LDR_MODULE, *PLDR_MODULE;

### Access using assembly

        include <stdio.h>
        #include <Windows.h>
        
        int main() {
            PVOID peb;
        
            __asm {
                mov eax, fs:[0x30]
                mov peb, eax
            }
        
            printf("PEB Address: %p\n", peb);
            return 0;
        }

`fs`, resp. `gs` is a segment register used in 32-bit, resp. 64-bit,
Windows to access memory. In this case, `fs:[0x30]`, resp. `gs:[0x60]`,
is the offset within the TEB that contains a pointer to the PEB.

see [Win32 Thread Information
Block](https://en.wikipedia.org/wiki/Win32_Thread_Information_Block) for
more `gs/fs`

### PEB walk

[PEB Walk](https://fareedfauzi.github.io/2024/07/13/PEB-Walk.html)

### links

## Thread Environment Block (TEB)

-   [Basics Of Threads](https://github.com/Faran-17/Windows-Internals/blob/main/Threads/1.%20Basics%20Of%20Threads.md)

PEB and its content can be accessed from the user mode. However, before
accessing the PEB, we have to first access the Thread Environment Block
(TEB), which serves as an information board like PEB, but for the thread
this time.

As the program code is running in the thread, in other words, the "inner
layer", we have to access the process's PEB, the "outer layer," through
the TEB. Hence, we can say that TEB is a gateway to reach PEB in our
case as illustrated in Figure 2.

## Process and security

`PROCESS_ACCESS_TOKEN`

        BOOL GetTokenInformation(
            [in]            HANDLE                  TokenHandle,
            [in]            TOKEN_INFORMATION_CLASS TokenInformationClass,
            [out, optional] LPVOID                  TokenInformation,
            [in]            DWORD                   TokenInformationLength,
            [out]           PDWORD                  ReturnLength
          );

[TokenInformationClass](https://learn.microsoft.com/fr-fr/windows/win32/api/winnt/ne-winnt-token_information_class)

en gros on appel une premiere fois pour demander la taille necesaire
puis on alloue le buffer et on appel une seconde fois avec le pointeur
sur le buffer

## Protected Process Light (PPL)

-   [Bypass Protected Process Light / ObRegisterCallbacks using Process
    Explorer
    ](https://waawaa.github.io/en/Bypass-PPL-Using-Process-Explorer/)

-   [What are PPL
    Processes](https://itm4n.github.io/lsass-runasppl/#what-are-ppl-processes)
