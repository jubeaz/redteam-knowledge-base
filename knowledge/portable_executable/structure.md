| 🏠 [Home](../../redteam.md) | ⬅️ ⬅️ [Part](../_part) | ⬅️ [Chapter](./_chapter) |
|-----------------------------|----------------------|-------------------------|



* [Structure](../../knowledge/portable_executable/structure.md)
    * [General concepts](../../knowledge/portable_executable/structure.md#general-concepts)
        * [Relative Virtual Address (RVA)](../../knowledge/portable_executable/structure.md#relative-virtual-address-rva)
    * [Introduction](../../knowledge/portable_executable/structure.md#introduction)
    * [DOS](../../knowledge/portable_executable/structure.md#dos)
        * [DOS Header](../../knowledge/portable_executable/structure.md#dos-header)
        * [DOS stub (Image Only)](../../knowledge/portable_executable/structure.md#dos-stub-image-only)
    * [Rich Header](../../knowledge/portable_executable/structure.md#rich-header)
    * [NT Headers](../../knowledge/portable_executable/structure.md#nt-headers)
        * [(COFF) File Header](../../knowledge/portable_executable/structure.md#coff-file-header)
        * [Optional Header](../../knowledge/portable_executable/structure.md#optional-header)
        * [Data Directories](../../knowledge/portable_executable/structure.md#data-directories)
    * [Section Table (Section Headers)](../../knowledge/portable_executable/structure.md#section-table-section-headers)
    * [sections](../../knowledge/portable_executable/structure.md#sections)

# Structure

## General concepts

### Relative Virtual Address (RVA)

An RVA specifies the offset of an element (like a function, data
structure, or section) from the base address where the PE file is loaded
into memory.

When a PE file is loaded into memory, the operating system assigns it a
**base address**. This is the starting point in virtual memory where the
entire image of the PE file is mapped.

Mathematically: `RVA=Virtual Address - Base Address`

Absolute Virtual Address is the `RVA + Base Address`

RVAs are heavily used in the PE file's import and export tables to
specify the locations of functions and data. For example, the addresses
of imported functions are given as RVAs, which are resolved to actual
virtual addresses at runtime.

RVAs are crucial for relocating a PE file when it cannot be loaded at
its preferred base address. The loader adjusts all RVAs accordingly.

the PE file sections are aligned differently in memory compared to how
they are laid out on disk, the RVA does not directly correspond to an
offset in the file.

To convert an RVA to a file offset (or vice versa), you need to:

-   Identify the section in which the RVA falls.

-   Use the section's information (like `PointerToRawData` and
    `VirtualAddress`) to compute the corresponding file offset.


## Introduction

![PE overview](images/Gen_DD_Win_PE_Format.png){#fig:pe_overview
width="\\linewidth"}

![PE Details](images/pe-format.pdf){#fig:pe_details
width="\\linewidth"}

All structures are defined in
[winnt.h](https://learn.microsoft.com/fr-fr/windows/win32/api/winnt/)

## DOS

### DOS Header

The DOS header (also called the MS-DOS header) is a 64-byte-long
structure that exists at the start of the PE file.

It's there because of backward compatibility reasons.

This header makes the file an MS-DOS executable, so when it's loaded on
MS-DOS the DOS stub gets executed instead of the actual program. Without
this header, if you attempt to load the executable on MS-DOS it will not
be loaded and will just produce a generic error.

    typedef struct _IMAGE_DOS_HEADER {      // DOS .EXE header
      WORD   e_magic;                     // Magic number
      WORD   e_cblp;                      // Bytes on last page of file
      WORD   e_cp;                        // Pages in file
      WORD   e_crlc;                      // Relocations
      WORD   e_cparhdr;                   // Size of header in paragraphs
      WORD   e_minalloc;                  // Minimum extra paragraphs needed
      WORD   e_maxalloc;                  // Maximum extra paragraphs needed
      WORD   e_ss;                        // Initial (relative) SS value
      WORD   e_sp;                        // Initial SP value
      WORD   e_csum;                      // Checksum
      WORD   e_ip;                        // Initial IP value
      WORD   e_cs;                        // Initial (relative) CS value
      WORD   e_lfarlc;                    // File address of relocation table
      WORD   e_ovno;                      // Overlay number
      WORD   e_res[4];                    // Reserved words
      WORD   e_oemid;                     // OEM identifier (for e_oeminfo)
      WORD   e_oeminfo;                   // OEM information; e_oemid specific
      WORD   e_res2[10];                  // Reserved words
      LONG   e_lfanew;                    // File address of new exe header
    } IMAGE_DOS_HEADER, *PIMAGE_DOS_HEADER;

-   `e_magic`: This is the first member of the DOS Header, it's a `WORD`
    (2 bytes), it's usually called the magic number. It has a fixed
    value of `0x5A4D` or `MZ` in ASCII, and it serves as a signature
    that marks the file as an MS-DOS executable.

-   `e_lfanew`: This is the last member of the DOS header structure,
    it's located at offset `0x3C` into the DOS header and it holds an
    offset to the start of the NT headers. This member is important to
    the PE loader on Windows systems because it tells the loader where
    to look for the file header.

### DOS stub (Image Only)

The DOS stub is an MS-DOS program that prints an error message saying
that the executable is not compatible with DOS then exits.

This is what gets executed when the program is loaded in MS-DOS, the
default error message is "This program cannot be run in DOS mode.",
however this message can be changed by the user during compile time.

## Rich Header

Chunk of data we haven't talked about lying between the DOS Stub and the
start of the NT Headers.

The [Rich header](https://github.com/RichHeaderResearch/RichPE) is an
undocumented header contained within PE files compiled and linked using
the Microsoft Visual Studio toolset. It contains information about the
build environment that the PE file was created in.

See also [Rich
Header](https://0xrick.github.io/win-internals/pe3/#rich-header)

## NT Headers

    typedef struct _IMAGE_NT_HEADERS {
    /*0x00*/    DWORD                 Signature; // PE\0\0 or 0x00004550
    /*0x04*/    IMAGE_FILE_HEADER     FileHeader; 
    /*0x18*/    IMAGE_OPTIONAL_HEADER OptionalHeader; 
    } IMAGE_NT_HEADERS, *PIMAGE_NT_HEADERS;

    typedef struct _IMAGE_NT_HEADERS64 {
    /*0x00*/  DWORD                   Signature;
    /*0x04*/  IMAGE_FILE_HEADER       FileHeader;
    /*0x18*/  IMAGE_OPTIONAL_HEADER64 OptionalHeader;
    } IMAGE_NT_HEADERS64, *PIMAGE_NT_HEADERS64;

### (COFF) File Header

Structure that holds some information about the PE file.

    typedef struct _IMAGE_FILE_HEADER {
    /*0x00*/    WORD  Machine;              // machine type used for compilation
    /*0x02*/    WORD  NumberOfSections; 
    /*0x04*/    DWORD TimeDateStamp;        // of the file creation  
    /*0x08*/    DWORD PointerToSymbolTable;
    /*0x0c*/    DWORD NumberOfSymbols;
    /*0x10*/    WORD  SizeOfOptionalHeader;
    /*0x12*/    WORD  Characteristics;
    } IMAGE_FILE_HEADER, *PIMAGE_FILE_HEADER;

-   `Machine`: This is a number that indicates the type of machine (CPU
    Architecture) the executable is targeting, this field can have a lot
    of values.For a complete list of possible values you can check the
    [official Microsoft
    documentation](https://learn.microsoft.com/en-us/windows/win32/debug/pe-format#machine-types).

-   `NumberOfSections`: This field holds the number of sections (or the
    number of section headers aka. the size of the section table.).

-   `TimeDateStamp`: A unix timestamp (`time_t`) that indicates when the
    file was created.

-   `PointerToSymbolTable` and `NumberOfSymbols`: These two fields hold
    the file offset to the COFF symbol table and the number of entries
    in that symbol table, however they get set to 0 which means that no
    COFF symbol table is present, this is done because the COFF
    debugging information is deprecated.

-   `SizeOfOptionalHeader`: The size of the Optional Header. 0 for
    object file.

-   `Characteristics`: A flag that indicates the attributes of the file,
    these attributes can be things like the file being executable, the
    file being a system file and not a user program, and a lot of other
    things. A complete list of these flags can be found on the [official
    Microsoft
    documentation](https://learn.microsoft.com/en-us/windows/win32/debug/pe-format#characteristics).

### Optional Header

The most important header of the NT headers, the PE loader looks for
specific information provided by that header to be able to load and run
the executable.

It's called the optional header because some file types like object
files don't have it, however this header is essential for image files.

`IMAGE_OPTIONAL_HEADER` is defined as `IMAGE_OPTIONAL_HEADER32`.
However, if `_WIN64` is defined, then `IMAGE_OPTIONAL_HEADER` is defined
as `IMAGE_OPTIONAL_HEADER64`.

    typedef struct _IMAGE_OPTIONAL_HEADER {
    /*0x00*/    WORD                 Magic;
    /*0x02*/    BYTE                 MajorLinkerVersion;
    /*0x03*/    BYTE                 MinorLinkerVersion;
    /*0x04*/    DWORD                SizeOfCode;
    /*0x08*/    DWORD                SizeOfInitializedData;
    /*0x0c*/    DWORD                SizeOfUninitializedData;
    /*0x10*/    DWORD                AddressOfEntryPoint;
    /*0x14*/    DWORD                BaseOfCode;
    /*0x18*/    DWORD                BaseOfData;
    /*0x1C*/    DWORD                ImageBase;
    /*0x20*/    DWORD                SectionAlignment;
    /*0x24*/    DWORD                FileAlignment;
    /*0x28*/    WORD                 MajorOperatingSystemVersion;
    /*0x2a*/    WORD                 MinorOperatingSystemVersion;
    /*0x2c*/    WORD                 MajorImageVersion;
    /*0x2e*/    WORD                 MinorImageVersion;
    /*0x30*/    WORD                 MajorSubsystemVersion;
    /*0x32*/    WORD                 MinorSubsystemVersion;
    /*0x34*/    DWORD                Win32VersionValue;
    /*0x38*/    DWORD                SizeOfImage;
    /*0x3c*/    DWORD                SizeOfHeaders;
    /*0x40*/    DWORD                CheckSum;
    /*0x44*/    WORD                 Subsystem;
    /*0x46*/    WORD                 DllCharacteristics;
    /*0x48*/    DWORD                SizeOfStackReserve;
    /*0x4c*/    DWORD                SizeOfStackCommit;
    /*0x50*/    DWORD                SizeOfHeapReserve;
    /*0x54*/    DWORD                SizeOfHeapCommit;
    /*0x58*/    DWORD                LoaderFlags;
    /*0x5c*/    DWORD                NumberOfRvaAndSizes;
    /*0x60*/    IMAGE_DATA_DIRECTORY DataDirectory[IMAGE_NUMBEROF_DIRECTORY_ENTRIES];
    } IMAGE_OPTIONAL_HEADER32, *PIMAGE_OPTIONAL_HEADER32;

    typedef struct _IMAGE_OPTIONAL_HEADER64 {
    /*0x00*/    WORD        Magic;
    /*0x02*/    BYTE        MajorLinkerVersion;
    /*0x03*/    BYTE        MinorLinkerVersion;
    /*0x04*/    DWORD       SizeOfCode;
    /*0x08*/    DWORD       SizeOfInitializedData;
    /*0x0c*/    DWORD       SizeOfUninitializedData;
    /*0x10*/    DWORD       AddressOfEntryPoint;
    /*0x14*/    DWORD       BaseOfCode;
    /*0x18*/    ULONGLONG   ImageBase;
    /*0x20*/    DWORD       SectionAlignment;
    /*0x24*/    DWORD       FileAlignment;
    /*0x28*/    WORD        MajorOperatingSystemVersion;
    /*0x2a*/    WORD        MinorOperatingSystemVersion;
    /*0x2c*/    WORD        MajorImageVersion;
    /*0x2e*/    WORD        MinorImageVersion;
    /*0x30*/    WORD        MajorSubsystemVersion;
    /*0x32*/    WORD        MinorSubsystemVersion;
    /*0x34*/    DWORD       Win32VersionValue;
    /*0x38*/    DWORD       SizeOfImage;
    /*0x3c*/    DWORD       SizeOfHeaders;
    /*0x40*/    DWORD       CheckSum;
    /*0x44*/    WORD        Subsystem;
    /*0x46*/    WORD        DllCharacteristics;
    /*0x48*/    ULONGLONG   SizeOfStackReserve;
    /*0x50*/    ULONGLONG   SizeOfStackCommit;
    /*0x58*/    ULONGLONG   SizeOfHeapReserve;
    /*0x60*/    ULONGLONG   SizeOfHeapCommit;
    /*0x68*/    DWORD       LoaderFlags;
    /*0x6c*/    DWORD       NumberOfRvaAndSizes;
    /*0x70*/    IMAGE_DATA_DIRECTORY DataDirectory[IMAGE_NUMBEROF_DIRECTORY_ENTRIES];
    } IMAGE_OPTIONAL_HEADER64, *PIMAGE_OPTIONAL_HEADER64;

It doesn't have a fixed size, that's why the
`IMAGE_FILE_HEADER.SizeOfOptionalHeader` member exists.

-   `MMagic`:integer that identifies the state of the image, the
    documentation mentions three common values:

    -   `0x10B`: Identifies the image as a PE32 executable.

    -   `0x20B`: Identifies the image as a PE32+ executable.

    -   `0x107`: Identifies the image as a ROM image.

    The value of this field is what determines whether the executable is
    32-bit or 64-bit, `IMAGE_FILE_HEADER.Machine` is ignored by the
    Windows PE loader.

-   `MajorLinkerVersion` and `MinorLinkerVersion`: The linker major and
    minor version numbers.

-   `SizeOfCode`: size of the code (`.text`) section, or the sum of all
    code sections if there are multiple sections.

-   `SizeOfInitializedData`: size of the initialized data (`.data`)
    section, or the sum of all initialized data sections if there are
    multiple sections.

-   `SizeOfUninitializedData`: size of the uninitialized data (`.bss`)
    section, or the sum of all uninitialized data sections if there are
    multiple sections.

-   `AddressOfEntryPoint`: An RVA of the entry point when the file is
    loaded into memory. The documentation states that for program images
    this relative address points to the starting address and for device
    drivers it points to initialization function. For DLLs an entry
    point is optional, and in the case of entry point absence the
    `AddressOfEntryPoint` field is set to 0.

-   `BaseOfCode`: An RVA of the start of the code section when the file
    is loaded into memory.

-   `BaseOfData` (PE32 Only): An RVA of the start of the data section
    when the file is loaded into memory.

-   `ImageBase`: This field holds the preferred address of the first
    byte of image when loaded into memory (the preferred base address),
    this value must be a multiple of 64K. Due to memory protections like
    ASLR, and a lot of other reasons, the address specified by this
    field is almost never used, in this case the PE loader chooses an
    unused memory range to load the image into, after loading the image
    into that address the loader goes into a process called the
    **relocating** where it fixes the constant addresses within the
    image to work with the new image base, there's a special section
    that holds information about places that will need fixing if
    relocation is needed, that section is called the relocation section
    (.reloc), more on that in the upcoming posts.

-   `SectionAlignment`: value that gets used for section alignment in
    memory (in bytes), sections are aligned in memory boundaries that
    are multiples of this value. The documentation states that this
    value defaults to the page size for the architecture and it can't be
    less than the value of `FileAlignment`.

-   `FileAlignment`: Similar to `SectionAligment` value that gets used
    for section raw data alignment on disk (in bytes), if the size of
    the actual data in a section is less than the `FileAlignment` value,
    the rest of the chunk gets padded with zeroes to keep the alignment
    boundaries. The documentation states that this value should be a
    power of 2 between 512 and 64K, and if the value of
    `SectionAlignment` is less than the architecture's page size then
    the sizes of `FileAlignment` and `SectionAlignment` must match.

-   `MajorOperatingSystemVersion`, `MinorOperatingSystemVersion`,
    `MajorImageVersion`, `MinorImageVersion`, `MajorSubsystemVersion`
    and `MinorSubsystemVersion`: These members of the structure specify
    the major version number of the required operating system, the minor
    version number of the required operating system, the major version
    number of the image, the minor version number of the image, the
    major version number of the subsystem and the minor version number
    of the subsystem respectively.

-   `Win32VersionValue`: A reserved field that the documentation says
    should be set to 0.

-   `SizeOfImage`: The size of the image file (in bytes), including all
    headers. It gets rounded up to a multiple of `SectionAlignment`
    because this value is used when loading the image into memory.

-   `SizeOfHeaders`: The combined size of the DOS stub, PE header (NT
    Headers), and section headers rounded up to a multiple of
    `FileAlignment`.

-   `CheckSum`: A checksum of the image file, it's used to validate the
    image at load time.

-   `Subsystem`: This field specifies the Windows subsystem (if any)
    that is required to run the image, A complete list of the possible
    values of this field can be found on the [official Microsoft
    documentation](https://learn.microsoft.com/en-us/windows/win32/debug/pe-format#windows-subsystem).

-   `DLLCharacteristics`: This field defines some characteristics of the
    executable image file, like if it's NX compatible and if it can be
    relocated at run time. I have no idea why it's named
    DLLCharacteristics, it exists within normal executable image files
    and it defines characteristics that can apply to normal executable
    files. A complete list of the possible flags for DLLCharacteristics
    can be found on the [official Microsoft
    documentation](https://learn.microsoft.com/en-us/windows/win32/debug/pe-format#windows-subsystem).

-   `SizeOfStackReserve`, `SizeOfStackCommit`, `SizeOfHeapReserve` and
    `SizeOfHeapCommit`: These fields specify the size of the stack to
    reserve, the size of the stack to commit, the size of the local heap
    space to reserve and the size of the local heap space to commit
    respectively.

-   `LoaderFlags`: A reserved field that the documentation says should
    be set to 0.

-   `NumberOfRvaAndSizes` : Size of the `DataDirectory` array.

-   `DataDirectory`: An array of `IMAGE_DATA_DIRECTORY` structures which
    size is at least 16.

### Data Directories

Each data directory gives the address and size of a table or string that
Windows uses. These data directory entries are all loaded into memory so
that the system can use them at run time.

It's a very simple structure with only two members, first one being an
RVA pointing to the start of the Data Directory and the second one being
the size of the Data Directory.

    typedef struct _IMAGE_DATA_DIRECTORY {
    /*0x00*/    DWORD   VirtualAddress;
    /*0x04*/    DWORD   Size;
    } IMAGE_DATA_DIRECTORY, *PIMAGE_DATA_DIRECTORY;    

Basically a Data Directory is a piece of data located within one of the
sections of the PE file. Data Directories contain useful information
needed by the loader.

**Note:**

-   the number of directories is not fixed. Before looking for a
    specific directory, check the NumberOfRvaAndSizes field in the
    optional header.

-   do not assume that the RVAs in this table point to the beginning of
    a section or that the sections that contain specific tables have
    specific names.

<!-- -->

    #define IMAGE_DIRECTORY_ENTRY_EXPORT          0   // Export Directory
    #define IMAGE_DIRECTORY_ENTRY_IMPORT          1   // Import Directory
    #define IMAGE_DIRECTORY_ENTRY_RESOURCE        2   // Resource Directory
    #define IMAGE_DIRECTORY_ENTRY_EXCEPTION       3   // Exception Directory
    #define IMAGE_DIRECTORY_ENTRY_SECURITY        4   // Security Directory
    #define IMAGE_DIRECTORY_ENTRY_BASERELOC       5   // Base Relocation Table
    #define IMAGE_DIRECTORY_ENTRY_DEBUG           6   // Debug Directory
    #define IMAGE_DIRECTORY_ENTRY_COPYRIGHT       7   // (X86 usage must be 0)
    #define IMAGE_DIRECTORY_ENTRY_ARCHITECTURE    7   // Architecture Specific Data
    #define IMAGE_DIRECTORY_ENTRY_GLOBALPTR       8   // RVA of GP
    #define IMAGE_DIRECTORY_ENTRY_TLS             9   // TLS Directory
    #define IMAGE_DIRECTORY_ENTRY_LOAD_CONFIG    10   // Load Configuration Directory
    #define IMAGE_DIRECTORY_ENTRY_BOUND_IMPORT   11   // Bound Import Directory in headers
    #define IMAGE_DIRECTORY_ENTRY_IAT            12   // Import Address Table
    #define IMAGE_DIRECTORY_ENTRY_DELAY_IMPORT   13   // Delay Load Import Descriptors
    #define IMAGE_DIRECTORY_ENTRY_COM_DESCRIPTOR 14   // COM Runtime descriptor
    #define IMAGE_DIRECTORY_RESERVED             15   // must be 0

The Certificate Table entry points to a table of attribute certificates.
These certificates are not loaded into memory as part of the image. As
such, the first field of this entry, which is normally an RVA, is a file
pointer instead.

## Section Table (Section Headers)

This table immediately follows the optional header, if any. This
positioning is required because the file header does not contain a
direct pointer to the section table. Instead, the location of the
section table is determined by calculating the location of the first
byte after the headers. Make sure to use the size of the optional header
as specified in the file header.

These headers contain information about the sections of the PE file. The
number of entries in the section table is given by
`_IMAGE_FILE_HEADER.NumberOfSections`

In an image file, the `VA`s for sections must be assigned by the linker
so that they are in ascending order and adjacent, and they must be a
multiple of the `IMAGE_OPTIONAL_HEADE.SectionAlignment`.

Each section header (section table entry) has the following format, for
a total of 40 bytes per entry.

It's an array of `IMAGE_SECTION_HEADER` structures, each of which
describes a single section, denoting its size in the file and in memory
(`SizeOfRawData` and `VirtualSize`), its file offset and virtual address
(`PointerToRawData` and `VirtualAddress`), relocation information, and
any flags (`Characteristics`).

    typedef struct _IMAGE_SECTION_HEADER {
    /*0x00*/    BYTE    Name[IMAGE_SIZEOF_SHORT_NAME];
        union {
    /*0x08*/            DWORD   PhysicalAddress;
    /*0x08*/            DWORD   VirtualSize;
        } Misc;
    /*0x0c*/    DWORD   VirtualAddress;
    /*0x10*/    DWORD   SizeOfRawData;
    /*0x14*/    DWORD   PointerToRawData;
    /*0x18*/    DWORD   PointerToRelocations;
    /*0x1c*/    DWORD   PointerToLinenumbers;
    /*0x20*/    WORD    NumberOfRelocations;
    /*0x22*/    WORD    NumberOfLinenumbers;
    /*0x24*/    DWORD   Characteristics;
    } IMAGE_SECTION_HEADER, *PIMAGE_SECTION_HEADER;    

-   `Name`: First field of the Section Header, a byte array (no
    terminating null. ) of the size `IMAGE_SIZEOF_SHORT_NAME (8 bytes)`
    that holds the name of the section. For longer names the official
    documentation mentions a work-around by filling this field with an
    offset in the string table, however executable images do not use a
    string table so this limitation of 8 characters holds for executable
    images.

-   `PhysicalAddress` or `VirtualSize`: A union defines multiple names
    for the same thing, this field contains the total size of the
    section when it's loaded in memory.

-   `VirtualAddress`: The documentation states that for executable
    images this field holds the address of the first byte of the section
    relative to the image base when loaded in memory, and for object
    files it holds the address of the first byte of the section before
    relocation is applied.

-   `SizeOfRawData`: This field contains the size of the section on
    disk, it must be a multiple of
    `IMAGE_OPTIONAL_HEADER.FileAlignment`. `SizeOfRawData` and
    `VirtualSize` can be different.

-   `PointerToRawData`: A pointer to the first page of the section
    within the file, for executable images it must be a multiple of
    `IMAGE_OPTIONAL_HEADER.FileAlignment`.

-   `PointerToRelocations`: A file pointer to the beginning of
    relocation entries for the section. It's set to 0 for executable
    files.

-   `PointerToLineNumbers`: A file pointer to the beginning of COFF
    line-number entries for the section. It's set to 0 because COFF
    debugging information is deprecated.

-   `NumberOfRelocations`: The number of relocation entries for the
    section, it's set to 0 for executable images.

-   `NumberOfLinenumbers`: The number of COFF line-number entries for
    the section, it's set to 0 because COFF debugging information is
    deprecated.

-   `Characteristics`: Flags that describe the characteristics of the
    section. These characteristics are things like if the section
    contains executable code, contains initialized/uninitialized data,
    can be shared in memory. A complete list of section characteristics
    flags can be found on the [official Microsoft
    documentation](https://learn.microsoft.com/en-us/windows/win32/debug/pe-format#section-flags).

## Sections

Sections are the containers of the actual data of the executable file,
they occupy the rest of the PE file.

Some sections have special names that indicate their purpose, we'll go
over some of them, and a full list of these names can be found on the
[official Microsoft
documentation](https://learn.microsoft.com/en-us/windows/win32/debug/pe-format#special-sections).
