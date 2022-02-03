﻿<#
.SYNOPSIS
   Read outLook Exchange Emails

   Author: @r00t-3xp10it
   Tested Under: Windows 10 (19043) x64 bits
   Required Dependencies: Outlook ComObject {native}
   Optional Dependencies: none
   PS cmdlet Dev version: v1.2.6

.DESCRIPTION
   CmdLet to enumerate OutLook Exchange Emails, read is contents
   on terminal console or dump found Email Objects to a logfile.

.NOTES
   If invoked -verb 'true' then the Email <Body> will be dumped.

   Remark: This Cmdlet will try to stop OUTLOOK process in the end.
   Remark: Cmdlet default is to display the first 5 Objects, But ..
   that can be changed with the help of -EmailsCount 'int' parameter.

   Remark: The parameter -filter 'Google' can be invoked together with
   -action 'enum' to filter only for 'Google' Exchange Emails Objects.
   Remark: Filter param limmits the search to 6 Objects (fast reports)

.Parameter Action
   Accepts arguments: enum, folders, contacts (default: enum)

.Parameter EmailsCount
   How many outlook item objects to display (default: 5)

.Parameter Filter
   Filter Objects by is 'SenderName'? (default: false)

.Parameter Verb
   Display verbose outputs? (default: false)

.Parameter Logfile
   Create report logfile? (default: false)

.EXAMPLE
   PS C:\> .\ReadEmails.ps1 -action 'folders'
   Enumerate OutLook Exchange Folders

.EXAMPLE
   PS C:\> .\ReadEmails.ps1 -action 'enum'
   Enumerate (5 = default) OutLook Exchange Emails

.EXAMPLE
   PS C:\> .\ReadEmails.ps1 -action 'enum' -EmailsCount '10'
   Enumerate (10) OutLook Exchange Emails (non-verbose)

.EXAMPLE
   PS C:\> .\ReadEmails.ps1 -action 'enum' -EmailsCount '2' -filter 'Google'
   Enumerate (2) OutLook Exchange Emails only with (Google SenderName set)

.EXAMPLE
   PS C:\> .\ReadEmails.ps1 -action 'enum' -EmailsCount '3' -verb 'true'
   Enumerate (3) OutLook Exchange Emails in verbose mode (Email <BODY>)

.EXAMPLE
   PS C:\> .\ReadEmails.ps1 -action 'enum' -logfile 'true'
   Enumerate (5) OutLook Exchange Emails and create logfile

.INPUTS
   None. You cannot pipe objects into ReadEmails.ps1

.OUTPUTS
   * Read Exchange Emails with PowerShell ..
   ItemsCount         : '5694'          
   RegisteredUser     : pedroubuntu10@gmail.com
   -------------------------------------
   SenderName         : Odyssey Hotels
   SenderEmailAddress : info@newsletter.odisseias.com
   TaskSubject        : Suite + Hot Tub? promotion  💑
   To                 : pedroubuntu10@gmail.com
   SentOn             : 11/01/2022 08:41:07
   ReceivedTime       : 11/01/2022 09:49:07
   UnRead             : True
   Links              : 

   SenderName         : Uber Eats
   SenderEmailAddress : uber@uber.com
   TaskSubject        : Enjoy your favorite dishes in bed with Uber Eats. 🥞
   To                 : pedroubuntu10@gmail.com
   SentOn             : 12/01/2022 08:06:09
   ReceivedTime       : 12/01/2022 08:06:11
   UnRead             : True
   Links              : 

.LINK
   https://github.com/r00t-3xp10it/redpill
   http://squareclouds.net/exporting-outlook-contacts-with-powershell
   https://sqlnotesfromtheunderground.wordpress.com/2014/09/06/by-example-powershell-commands-for-outlook
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$Logfile="false",
   [string]$Filter="false",
   [string]$Action="enum",
   [string]$Verb="false",
   [int]$EmailsCount='5',
   [string]$Egg="false"
)


$CmdletVersion = "v1.2.6"
#Local variable declarations
$GetProcessStateDelay = "500"
$LocalPath = (Get-Location).Path
$ErrorActionPreference = "SilentlyContinue"
#Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
$host.UI.RawUI.WindowTitle = "@ReadEmails $CmdletVersion {SSA@RedTeam}"
$RegisteredUser = (Get-CimInstance -ClassName Win32_OperatingSystem).RegisteredUser
$Rand = -join (((48..57)+(65..90)+(97..122)) * 80 |Get-Random -Count 8 |%{[char]$_})


If($Egg -ieq "False")
{
   Write-Host "`n* Read Exchange Emails with PowerShell" -ForegroundColor Green
}
#Read Exchange Emails with PowerShell
$outlook = New-Object -ComObject outlook.application
$olFolders ="Microsoft.Office.Interop.Outlook.OlDefaultFolders" -as [type]
$namespace = $Outlook.GetNameSpace("MAPI")
$inbox = $namespace.GetDefaultFolder($olFolders::olFolderInbox)
$ITemsInside = $inbox.items.count


If($Action -ieq "Folders")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Display Outlook Folder Names

   .OUTPUTS
      Name                                                       FolderPath                                                                          
      ----                                                       ----------                                                                          
      Caixa de Entrada                                           \\pedroubuntu10@gmail.com\Caixa de Entrada                                          
      A enviar                                                   \\pedroubuntu10@gmail.com\A enviar                                                  
      Rascunhos                                                  \\pedroubuntu10@gmail.com\Rascunhos                                                 
      Feeds RSS (Apenas este computador)                         \\pedroubuntu10@gmail.com\Feeds RSS (Apenas este computador)                             
      [Gmail]                                                    \\pedroubuntu10@gmail.com\[Gmail]                                                   
      Pessoal                                                    \\pedroubuntu10@gmail.com\Pessoal                                                   
      Recibos                                                    \\pedroubuntu10@gmail.com\Recibos                                                   
      Trabalho                                                   \\pedroubuntu10@gmail.com\Trabalho  
   #>

   $CurrentItem = 0      #ProgressBar
   $PercentComplete = 0  #ProgressBar
   $DefaultFolderName = ($inbox).Name
   #Display OnScreen Outlook Folder Names

   $TerminalDisplay = $namespace.Folders.Item(1).Folders | Select-Object Name,FolderPath
   $TotalItems = $TerminalDisplay.Count #ProgressBar

   ForEach($Token in $TerminalDisplay)
   {
      $CurrentItem++
      Write-Progress -Activity "Checking OutLook Folders" -Status "$PercentComplete% Complete:" -PercentComplete $PercentComplete
      $PercentComplete = [int](($CurrentItem / $TotalItems) * 100)
      Start-Sleep -Milliseconds 35
   }

   #Final OutPut Table
   echo $TerminalDisplay | Format-Table -AutoSize | Out-String -Stream | ForEach-Object {
      $stringformat = If($_ -Match '^(Name)')
      {
         @{ 'ForegroundColor' = 'Green' }
      }
      ElseIf($_ -Match "($DefaultFolderName|\[Gmail\])")
      {
         @{ 'ForegroundColor' = 'Yellow' }      
      }
      Else
      {
         @{ 'ForeGroundColor' = 'white' }
      }
      Write-Host @stringformat $_
   }

}


If($Action -ieq "Contacts")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Credits: @chrisprevel
      Helper - Display Outlook Contacts Names

   .OUTPUTS
      * Read Exchange Emails with PowerShell

      ShowItemCount       : 1
      CustomViewsOnly     : False
      DefaultMessageClass : IPM.Contact
      AddressBookName     : Contactos (Apenas este computador)
      FullFolderPath      : \\pedroubuntu10@gmail.com\Contactos (Apenas este computador)
      Items               : 

      FullName            : Ines Santos
      CompanyName         : 
      Anniversary         : 14/05/1985 00:00:00
      Birthday            : 14/05/1985 00:00:00
      Email1Address       : 
      MailingAddress      : P.O Box 10005 Palo Alto CA 94303
      HomeAddress         : 
      HomeTelephoneNumber : 9142349210
   #>

   write-host ""
   $CurrentItem = 0      #ProgressBar
   $PercentComplete = 0  #ProgressBar
   $ContactsInfo = $outlook.session.GetDefaultFolder(10)
   $TotalItems = $ContactsInfo.Count

   ForEach($Token in $ContactsInfo)
   {
      $CurrentItem++
      Write-Progress -Activity "Checking OutLook Contacts" -Status "$PercentComplete% Complete:" -PercentComplete $PercentComplete
      $PercentComplete = [int](($CurrentItem / $TotalItems) * 100)
      Start-Sleep -Milliseconds 35
   }

   #OutPut Table
   $ContactsInfo | Format-List ShowItemCount,CustomViewsOnly,DefaultMessageClass,AddressBookName,FullFolderPath,@{Name='Items';Expression={''}} |
   Out-String -Stream | Select-Object -Skip 2 | Select-Object -SkipLast 2 | ForEach-Object {
      $stringformat = If($_ -Match '^(AddressBookName)')
      {
         @{ 'ForegroundColor' = 'Green' }
      }
      ElseIf($_ -Match '^(DefaultMessageClass)')
      {
         @{ 'ForegroundColor' = 'DarkGray' }   
      }
      ElseIf($_ -Match '^(FullFolderPath)')
      {
         @{ 'ForegroundColor' = 'Yellow' }   
      }
      Else
      {
         @{ 'ForeGroundColor' = 'white' }
      }
      Write-Host @stringformat $_
   }


   #Store the Contacts objects
   $Contacts = $outlook.session.GetDefaultFolder(10).items
   #Store the folder objects
   $Contactsfolders = $outlook.session.GetDefaultFolder(10).Folders
   Start-Sleep -Milliseconds 800

   #Make sure we have any returned Object
   If([string]::IsNullOrEmpty($Contacts) -and [string]::IsNullOrEmpty($Contactsfolders))
   {
      write-host "*" -ForegroundColor Red -NoNewline;
      write-host " Error: " -ForegroundColor DarkGray -NoNewline;
      write-host "fail to retrieve Contacts from OutLook?" -ForegroundColor Red -BackgroundColor Black
      #Remark: Let CmdLet finish to stop OutLook process
   }
   Else
   {

      #Contacts folder exemption
      $folderexempt1 = "*Recipient*"
      #Create array for nested contacts (within folders)
      $ContactsNested = @()

      For ($i = 1;$i -le $ContactFolders.count;$i++)
      {

         <#
         .SYNOPSIS
            Author: @chrisprevel
            Helper - Get Outlook Contacts Information
            http://squareclouds.net/exporting-outlook-contacts-with-powershell

         .NOTES
            The script block cycles through each Object in the Item array
            where the Object name is not like the exemption and we add this
            to the variable $conectsnested
         #>

         $ContactsFoldersItems = $ContactFolders.Item($i) | Where-Object {($_.Name -notlike "$folderexempt1")}
         $ContactsNested += $ContactsFoldersItems.Items
      }

      ## Add the contacts within the contact
      # folders to the original $Contacts variable.
      $Contacts += $Contactsnested
      $TerMinalOutPut = $Contacts | Select-Object -First 1

      #Select attributes from Contacts
      $TerMinalOutPut | Select-Object FullName,CompanyName,Anniversary,Birthday,Email1Address,MailingAddress,HomeAddress,HomeTelephoneNumber | Format-list | Out-String -Stream | Select-Object -Skip 2
   }
}


If($Action -ieq "Enum")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Display Outlook Exchange Email Items!

   .NOTES
      The parameter -filter 'Google' can be invoked together with
      -action 'enum' to filter only 'Google' Exchange Emails Objects ..
      Remark: Filter param limmits the search to 6 Objects (fast reports)

   .OUTPUTS
      * Read Exchange Emails with PowerShell ..
      ItemsCount         : '5694'          
      RegisteredUser     : pedroubuntu10@gmail.com
      -------------------------------------
      SenderName         : Odyssey Hotels
      SenderEmailAddress : info@newsletter.odisseias.com
      TaskSubject        : Suite + Hot Tub? promotion  💑
      To                 : pedroubuntu10@gmail.com
      SentOn             : 11/01/2022 08:41:07
      ReceivedTime       : 11/01/2022 09:49:07
      UnRead             : True
      Links              : 

      SenderName         : Uber Eats
      SenderEmailAddress : uber@uber.com
      TaskSubject        : Enjoy your favorite dishes in bed with Uber Eats. 🥞
      To                 : pedroubuntu10@gmail.com
      SentOn             : 12/01/2022 08:06:09
      ReceivedTime       : 12/01/2022 08:06:11
      UnRead             : True
      Links              : 
   #>

   $CurrentItem = 0      #ProgressBar
   $PercentComplete = 0  #ProgressBar
   #Display OnScreen how many item does outlook as
   Write-Host "Outlook Items      : '$ITemsInside'           " -ForegroundColor black -BackgroundColor DarkGray
   Write-Host "RegisteredUser     : $RegisteredUser" -ForegroundColor black -BackgroundColor DarkGray
   write-host "--------------------------------------"

   If($verb -ieq "True")
   {
      If($Filter -ne "False")
      {
         If($EmailsCount -gt 6){$EmailsCount = "6"} #Limmit the search to 6 Objects for fast reports
         $TerminalDisplay = $inbox.items | Select-Object SenderName,SenderEmailAddress,TaskSubject,To,SentOn,ReceivedTime,ExpiryTime,UnRead,SenderEmailType,Links,ConversationID,Body | Where-Object { $_.SenderName -iMatch "$Filter" } | Select-Object -First $EmailsCount
      }
      Else
      {
         $TerminalDisplay = $inbox.items | Select-Object SenderName,SenderEmailAddress,TaskSubject,To,SentOn,ReceivedTime,ExpiryTime,UnRead,SenderEmailType,Links,ConversationID,Body | Select-Object -First $EmailsCount      
      }
   }
   Else
   {
      If($Filter -ne "False")
      {
         If($EmailsCount -gt 6){$EmailsCount = "6"} #Limmit the search to 6 Objects for fast reports
         $TerminalDisplay = $inbox.items | Select-Object SenderName,SenderEmailAddress,TaskSubject,To,SentOn,ReceivedTime,UnRead,Links | Where-Object { $_.SenderName -iMatch "$Filter" } | Select-Object -First $EmailsCount
      }
      Else
      {
         $TerminalDisplay = $inbox.items | Select-Object SenderName,SenderEmailAddress,TaskSubject,To,SentOn,ReceivedTime,UnRead,Links | Select-Object -First $EmailsCount      
      }
   }

   $TotalItems = $TerminalDisplay.Count #ProgressBar
   ForEach($Token in $TerminalDisplay)
   {
      $CurrentItem++
      Write-Progress -Activity "Checking OutLook Folders" -Status "$PercentComplete% Complete:" -PercentComplete $PercentComplete
      $PercentComplete = [int](($CurrentItem / $TotalItems) * 100)
      Start-Sleep -Milliseconds 40
   }

   #Display onscreen inbox items information { verbose }
   echo $TerminalDisplay | Format-List | Out-String -Stream | Select-Object -Skip 2 | ForEach-Object {
      $stringformat = If($_ -Match '^(SenderEmailAddress)')
      {
         @{ 'ForegroundColor' = 'Green' }
      }
      ElseIf($_ -Match '^(To)')
      {
         @{ 'ForegroundColor' = 'Yellow' }   
      }
      ElseIf($_ -Match '^(TaskSubject)')
      {
         @{ 'ForegroundColor' = 'DarkGray' }  
      }
      Else
      {
         @{ 'ForeGroundColor' = 'white' }
      }
      Write-Host @stringformat $_
   }

}


If($Logfile -ieq "True")
{

   <#
   .SYNOPSIS
      Author: @r00t-3xp10it
      Helper - Create report logfile

   .NOTES
      The logfile will be created in %tmp% directory
   #>

   $LogName = "${Env:TMP}\${Rand}" + ".log" -join ''
   echo "* Read Exchange Emails with PowerShell .." > $LogName
   echo "OutLook Items      : $ITemsInside" >> $LogName
   echo "RegisteredUser     : $RegisteredUser" >> $LogName
   echo "------------------------------------" >> $LogName

   If($Action -ieq "Contacts")
   {
      $Final = $ContactsInfo | Format-List ShowItemCount,CustomViewsOnly,DefaultMessageClass,AddressBookName,FullFolderPath,@{Name='Items';Expression={''}}
      $Primeiro = $TerMinalOutPut | Select-Object FirstName,MiddleName,LastName,CompanyName,Department,JobTitle,Anniversary,Birthday,Email1Address,BusinessAddressCity,HomeAddressStreet,HomeAddressCity,HomeAddressState,HomeTelephoneNumber
      echo $Final >> $LogName
      echo $Primeiro >> $LogName
   }
   Else
   {
      echo $TerminalDisplay >> $LogName
   }

   Write-Host "*" -ForegroundColor Green -NoNewline;
   Write-Host " Logfile created: '" -ForegroundColor DarkGray -NoNewline;
   Write-Host "$LogName" -ForegroundColor Green -NoNewline;
   Write-Host "'" -ForegroundColor DarkGray;
}



<#
.SYNOPSIS
   Author: @r00t-3xp10it
   Helper - Stop OUTLOOK process by is Id identifier
#>
[string]$GetOutLookProcessPid = (Get-Process -Name * | Where-Object { $_.ProcessName -iMatch '^(OUTLOOK)$'} ).Id | Select-Object -Last 1
If([string]::IsNullOrEmpty($GetOutLookProcessPid))
{
   write-host "[error] CmdLet cant find a valid OUTLOOK Pid .." -ForegroundColor Red -BackgroundColor Black
   write-host "The OUTLOOK appl will require manual shutdown .." -ForegroundColor DarkGray
}
Else
{
   try{#Stop OUTLOOK process
      write-host "*" -ForegroundColor Green -NoNewline;
      write-host " Stoping OUTLOOK process Id:" -ForegroundColor DarkGray -NoNewline;
      write-host "$GetOutLookProcessPid" -ForegroundColor Green -NoNewline;
      Stop-Process -Id "$GetOutLookProcessPid" -EA SilentlyContinue -Force|Out-Null
      Start-Sleep -Milliseconds "$GetProcessStateDelay"

      If((Get-Process -Id "$GetOutLookProcessPid" -EA SilentlyContinue).Responding -ieq "True")
      {
         write-host "[" -ForegroundColor DarkGray -NoNewline;
         write-host "FAIL" -ForegroundColor Red -BackGroundColor Black -NoNewline;
         write-host "]" -ForegroundColor DarkGray;      
      }
      Else
      {
         write-host "[" -ForegroundColor DarkGray -NoNewline;
         write-host "OK" -ForegroundColor Green -NoNewline;
         write-host "]" -ForegroundColor DarkGray;      
      }
   }catch{
      write-host "[ERROR] Fail to stop OUTLOOK process by is Id .." -ForegroundColor Red -BackgroundColor Black   
   }
}
Write-Host ""