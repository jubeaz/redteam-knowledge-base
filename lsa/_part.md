# LSA

## Knowledge {#lsa:knowledge}

### Notes

#### Extracting Secrets from LSA 

-   [Extracting Secrets from LSA by Use of PowerShell](https://blog.syss.com/posts/powershell-lsa-parsing/)

-   [C# implementation of mimikatz/pypykatz minidump functionality to get credentials from LSASS dumps](https://github.com/cube0x0/MiniDump)

-   [Python library to parse and read Microsoft minidump file format](https://github.com/skelsec/minidump)

-   [Windows MiniDump: format specification](https://formats.kaitai.io/windows_minidump/)

-   [Dumping lsass using only NTAPIs by hand-crafting Minidump files](https://ricardojoserf.github.io/nativedump/)

#### Usefull libs

-   [tlhelp32.h](https://learn.microsoft.com/fr-fr/windows/win32/api/tlhelp32/)

#### Staying Under the Radar

-   [Staying Under the Radar - Part 1 - PPID Spoofing and Blocking DLLs](https://crypt0ace.github.io/posts/Staying-under-the-Radar/)

-   [Staying Under the Radar - Part 3 - Unhooking DLLs](https://crypt0ace.github.io/posts/Staying-under-the-Radar-Part-3/)

#### Check sandboxing

-   Call rare-enumated API

                if (VirtualAllocExNuma(GetCurrentProcess(), IntPtr.Zero, 0x1000, 0x3000, 0x4, 0) == IntPtr.Zero)
                {
                    return;
                }

#### Evade in-memory scan

-   Sleep to evade in-memory scan + check if the emulator did not
    fast-forward through the sleep instruction

                var rand = new Random();
                uint dream = (uint)rand.Next(10000, 20000);
                double delta = dream / 1000 - 0.5;
                DateTime before = DateTime.Now;
                Sleep(dream);
                if (DateTime.Now.Subtract(before).TotalSeconds < delta)
                {
                    Console.WriteLine("Charles, get the rifle out. We're being fucked.");
                    return;
                }

### links

-   
