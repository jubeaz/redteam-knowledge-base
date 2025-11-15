# Glossary

## Misc

-   **Trusted path functionality** prevents Trojan horse programs from
    being able to intercept users' names and passwords as they try to
    log on. The trusted path functionality in Windows comes in the form
    of its Ctrl+Alt+Delete logon-attention sequence, which cannot be
    intercepted by nonprivileged applications.

-   secure attention sequence (SAS):

## Components

-   [CSRSS (Client/Server Runtime
    Subsystem)](https://medium.com/@ijaz.faheem/windows-environment-subsystems-csrss-synch-with-windows-kernel-on-the-windows-user-process-164d57f2a81b):
    System process that plays a vital role in managing user-mode
    processes, supporting the overall graphical user interface (GUI)
    experience and Various housekeeping tasks related to creating and
    deleting processes and threads.

-   ALPC (Advanced Local Procedure Call): modern IPC mechanism. ALPC is
    a high-speed, scalable, and secured facility for message passing
    arbitrary-size messages.

-   SMSS (Session Manager Subsystem): responsible for initializing the
    user session and several key system components (CSRSS, winlogon,
    subsystems)

-   SxS (Side-by-Side): feature in Windows that allows multiple versions
    of the same DLL or other shared components to coexist on the same
    system.

## DLLs

-   `advapi32.dll` Provides security features like authentication,
    access control and registry manipulation

-   `user32.dll` Provides functions for managing windows, menus,
    controls and handling user input

-   `kernel32.dll`: Exposes functions for memory management, file system
    access and console I/O, thread creation ...
