| 🏠 [Home](../../redteam.md) | ⬅️ ⬅️ [Part](../_part) | ⬅️ [Chapter](./_chapter) |
|-----------------------------|----------------------|-------------------------|



* [Notes](../../knowledge/pe/_notes.md)
    * [Image Access Functions](../../knowledge/pe/_notes.md#image-access-functions)
    * [PE loader](../../knowledge/pe/_notes.md#pe-loader)
    * [Memory aligment](../../knowledge/pe/_notes.md#memory-aligment)

# Notes

## Image Access Functions

[Image Access
Functions](https://learn.microsoft.com/en-us/windows/win32/debug/image-access-functions)

## PE loader

The PE Loader is responsible for:

-   Loading the PE File into Memory: The loader maps the executable file
    into the process's virtual memory space. This involves loading the
    code, data, and other sections from the file into appropriate memory
    locations.

-   Resolving Dependencies: The loader resolves all dependencies, such
    as linked DLLs. It uses the Import Table to load and link the
    required libraries dynamically.

-   Relocation: If the executable or DLL cannot be loaded at its
    preferred base address (due to address space conflicts), the PE
    Loader adjusts addresses in the code to accommodate the new memory
    location.

-   Setting Up the Execution Environment: The loader initializes the
    stack, heap, and other structures necessary for the program to run.
    It also prepares the entry point of the program, which is where
    execution begins.

-   Initializing Global Variables: If the executable or DLL has any
    global constructors or initializers, the loader calls them before
    transferring control to the main program entry point.

How the PE Loader Works

-   

-   Loading into Virtual Memory:

    -   The operating system reads the PE file from disk and loads it
        into the process's virtual address space.

    -   Memory pages are marked as executable, readable, or writable
        based on the section headers.

-   Resolving Imports and Exports:

    -   The loader scans the Import Address Table (IAT) to resolve
        external function calls. It ensures that all functions
        referenced in the executable are available in memory and updates
        the IAT with the actual addresses of these functions.

    -   If a required DLL is not found, the loader will throw an error
        and the executable will not run.

-   Handling Relocations:

    -   If the PE file cannot be loaded at its preferred base address
        (as specified in the PE header), the loader applies relocations.
        This involves adjusting memory addresses for variables,
        functions, and pointers to reflect the actual load address.

-   Transferring Control:

    -   Once everything is set up, the PE Loader transfers control to
        the program's entry point, starting the program's execution.

Related Concepts:

-   Dynamic Linking: The process of loading and linking libraries at
    runtime, which the PE Loader manages.

-   Address Space Layout Randomization (ASLR): A security feature that
    randomizes the load address of executables and libraries to make it
    harder for attackers to predict memory layout.

-   Loader Lock: A mechanism that prevents multiple threads from
    initializing or modifying the loader's data structures
    simultaneously, ensuring thread safety during the loading process.

## Memory aligment

Memory Mapping: When the PE Loader maps sections of the executable or
DLL into memory, it uses SectionAlignment to determine where each
section begins. This ensures that the sections are properly aligned in
memory for efficient access and to meet architectural requirements.
Performance and Safety: Proper alignment can improve performance and
ensure that certain types of data (e.g., code) are accessed correctly by
the CPU.
