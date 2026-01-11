| 🏠 [Home](../../redteam.md) | ⬅️ ⬅️ [Part](../_part) | ⬅️ [Chapter](./_chapter) |
|-----------------------------|----------------------|-------------------------|



* [Relocation section (.reloc)](../../knowledge/portable_executable/reloc.md)
    * [Introduction](../../knowledge/portable_executable/reloc.md#introduction)
    * [Relocating](../../knowledge/portable_executable/reloc.md#relocating)

# Relocation section (.reloc)
## Introduction
The Base Relocation Table field in the optional header data directories
gives the number of bytes in the base relocation table.

The base relocation table is divided into blocks. Each block represents
the base relocations for a 4K page. Each block must start on a 32-bit
boundary.

The loader is not required to process base relocations that are resolved
by the linker, unless the load image cannot be loaded at the image base
that is specified in the PE header.

Each base relocation block starts with the following structure:

    typedef struct _IMAGE_BASE_RELOCATION {
    /*0x00*/    DWORD   pageRVA;
    /*0x04*/    DWORD   SizeOfBlock;
    } IMAGE_BASE_RELOCATION;
    typedef IMAGE_BASE_RELOCATION UNALIGNED * PIMAGE_BASE_RELOCATION;

-   `VirtualAddress`: Relative (to image base) Virtual Address location

-   verb+SizeOfBlock+: The total number of bytes in the base relocation
    block, including the Page RVA and Block Size fields and the
    Type/Offset fields that follow.

After the block size, there is a list of 2 byte pairs denoting the
patching instructions.

-   Stored in the high 4 bits of the WORD, a value that indicates the
    type of base relocation to be applied. For more information, see
    [Base Relocation
    Types](https://learn.microsoft.com/en-us/windows/win32/debug/pe-format#base-relocation-types).

-   Stored in the remaining 12 bits of the WORD, an offset from the
    starting address that was specified in the Page RVA field for the
    block. This offset (`ImageBase ` pageRVA+) specifies where the base
    relocation is to be applied.

## Relocating

To apply a base relocation, the difference is calculated between the
preferred base address and the base where the image is actually loaded.
If the image is loaded at its preferred base, the difference is zero and
thus the base relocations do not have to be applied.

Each relocation entry gets processed by adding the RVA of the page to
the image base address, then by adding the offset specified in the
relocation entry, an absolute address of the location that needs fixing
can be obtained.

Below loop will fix up the required memory locations. It works by:

-   finding the relocation table and cycling through the relocation
    blocks

-   getting the nuber of required relocations in each relocation block

-   reading bytes in the specified relocation addresses

-   applying delta (between source and destination imageBaseAddress) to
    the values specified in the relocation addresses

-   writing the new values to specified relocation addresses

-   repeating the above until the entire relocation table is traversed

<!-- -->

-   [Process Hollowing and Portable Executable
    Relocations](https://www.ired.team/offensive-security/code-injection-process-injection/process-hollowing-and-pe-image-relocations)

-   [What Every Malware Analyst Should Know About PE
    Relocations](http://malwareid.in/unpack/unpacking-basics/pe-relocation-table)
