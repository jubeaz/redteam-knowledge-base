| 🏠 [Home](../../redteam.md) | ⬅️ ⬅️ [Part](../_part) | ⬅️ [Chapter](./_chapter) |
|-----------------------------|----------------------|-------------------------|

* [Security](../../knowledge/internals/security.md)
    * [Security system components](../../knowledge/internals/security#security-system-components)
    * [Object protection](../../knowledge/internals/security#object-protection)
        * [Access checks](../../knowledge/internals/security#access-checks)
        * [Access mask](../../knowledge/internals/security#access-mask)
    * [Tokens](../../knowledge/internals/security#tokens)
        * [Access token](../../knowledge/internals/security#access-token)
        * [Impersonation](../../knowledge/internals/security#impersonation)
        * [Restricted tokens](../../knowledge/internals/security#restricted-tokens)


# Security

## Security system components

## Object protection

-   essence of discretionary access control and auditing

-   Theoretically, anything managed by the executive object manager

-   objects that are not exposed to user mode (such as driver objects)
    are usually not protected

To control who can manipulate an object, the security system must first
be sure of each user's identity.

When a process requests a handle to an object, the object manager and
the security system use the **caller's security identification** and the
**object's security descriptor** to determine whether the caller should
be assigned a handle that grants the process access to the object it
desires.

thread can assume a different security context than that of its process.
This mechanism is called **impersonation**.

It's important to keep in mind that all the threads in a process share
the same handle table, so when a thread opens an object---even if it's
impersonating---all the threads of the process have access to the
object.

Sometimes, validating the identity of a user isn't enough for the system
to grant access to a resource that should be accessible by the account.
Windows achieves this kind of intra-user isolation with the **Windows
integrity mechanism**, which implements integrity levels.

The Windows integrity mechanism is used by:

-   User Account Control (UAC)

-   User Interface Privilege Isolation (UIPI)

-   AppContainers

### Access checks

thread must specify up front, at the time that it opens an object, what
types of actions it wants to perform on the object.

The object manager calls the SRM to perform access checks based on a
thread's desired access. If the access is granted, a handle is assigned
to the thread's process with which the thread (or other threads in the
process) can perform further operations on the object.

Events causing the object manager to perform security access validation:

-   a thread opening an existin object using a name

-   a process references an object using an existing handle

**thread opening an existin object using a name**:

1.  Obj manager call `ObpCreateHandle` to create an entry in the process
    handle table that becomes associated with the object.

2.  `ObpCreateHandle` call `ObpGrantAccess` to see if the thread has
    permission to access the object

3.  `ObpGrantAccess` call `ObCheckObjectAccess` with the **Security
    context** represented by an **access token** the access type
    (**access mask**) and a pointer to the object.

4.  `ObCheckObjectAccess` lock the object's security descriptor and the
    security context of the thread (to prevent their modification)

5.  `ObCheckObjectAccess` then calls the object's **security method** to
    obtain the security settings of the object.

6.  `ObCheckObjectAccess` then call `SeAccessCheck` from SRM with the
    object's security information, the security identity of the thread
    and the access that the thread is requesting which return `true` or
    `false`

7.  On success `ObpCreateHandle` calls the executive function
    `ExCreateHandle` to create the entry in the process handle table

**process references an object using an existing handle**: The types of
accesses the threads in the process are granted through the handle are
stored with the handle by the object manager.

Some System services (for exemple NtWriteFile) uses the object manager
function `ObReferenceObjectByHandle` to obtain a pointer to the file
object from the handle

`ObReferenceObjectByHandle` accepts the access that the caller wants
from the object as a parameter. After finding the handle entry in the
process handle table, `ObReferenceObjectByHandle` compares the access
being requested with the access granted for the thread.

The Windows security functions also enable Windows applications to
define their own private objects and to call on the services of the SRM
(through the `AuthZ` user-mode APIs) to enforce the Windows security
model on those objects. Many kernel-mode functions that the object
manager and other executive components use to protect their own objects
are exported as Windows user-mode APIs. The user-mode equivalent of
`SeAccessCheck` is the `AuthZ API AccessCheck`. Windows applications can
therefore leverage the flexibility of the security model and
transparently integrate with the authentication and administrative
interfaces that are present in Windows.

The essence of the SRM's security model is an equation that takes three
inputs: the security identity of a thread, the access that the thread
wants to an object, and the security settings of the object. The output
is either yes or no and indicates whether the security model grants the
thread the access it desires. The following sections describe the inputs
in more detail and then document the model's access-validation
algorithm.

### Access mask

[Access Mask Format](https://learn.microsoft.com/en-us/windows/win32/secauthz/access-mask-format)

## Tokens

### Access token

### Impersonation

### Restricted tokens
