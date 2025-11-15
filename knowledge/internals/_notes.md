| 🏠 [Home](../../redteam.md) | ⬅️ ⬅️ [Part](../_part) | ⬅️ [Chapter](./_chapter) |
|-----------------------------|----------------------|-------------------------|

* [notes](../../knowledge/internals/_notes.md)
    * [Virtual memory](../../knowledge/internals/_notes#virtual-memory)
    * [Kernel mode vs. user mode](../../knowledge/internals/_notes#kernel-mode-vs-user-mode)
    * [Terminal Services and multiple sessions](../../knowledge/internals/_notes#terminal-services-and-multiple-sessions)
    * [Objects and handles](../../knowledge/internals/_notes#objects-and-handles)

# Notes

-   Windows API functions These are documented, callable subroutines in
    the Windows API.

-   Native system services (or system calls) These are the undocumented,
    underlying services in the OS that are callable from user mode

-   Kernel support functions (or routines) These are the subroutines
    inside the Windows OS that can be called only from kernel mode

## Virtual memory

-   virtual memory is composed of 4kb pages (memory chunk)

-   on 32-bits:

    -   lower half of this address space (addresses `0x00000000` through
        `0x7FFFFFFF`) to processes (2GB)

    -   higher half of this address space (addresses `0x80000000`
        through `0xFFFFFFFF`) to OS (2GB)

## Kernel mode vs. user mode

To protect user applications from accessing and/or modifying critical OS
data, Windows uses two processor access modes:

-   user mode

-   kernel mode: mode of execution in a processor that grants access to
    all system memory and all CPU instructions

The architectures of the x86 and x64 processors define four privilege
levels to protect system code and data from being overwritten by code of
lesser privilege. Windows uses privilege level (ring) 0 for kernel mode
and privilege level (ring) 3 for user mode.

Virtual memory Pages in system space can be accessed only from kernel
mode, whereas all pages in the user address space are accessible from
user mode and kernel mode

Windows doesn't provide any protection for private read/write system
memory being used by components running in kernel mode.

## Terminal Services and multiple sessions

The first session is considered the services session, or session zero,
and contains system service hosting processes.

The first login session at the physical console of the machine is
session one, and additional sessions can be created through the use of
the remote desktop connection program (Mstsc.exe) or through the use of
fast user switching

## Objects and handles

-   a **kernel object** is a single, run-time instance of a statically
    defined **object type**

-   **object type** comprises a system-defined data type, functions that
    operate on instances of the data type, and a set of object
    attributes.

-   internal structure of an object is opaque

-   **object manager** must be called o get data out of or put data into
    an object

-   Not all data structures in the Windows OS are objects. Only data
    that needs to be shared, protected, named, or made visible to
    user-mode programs (via system services) is placed in objects
