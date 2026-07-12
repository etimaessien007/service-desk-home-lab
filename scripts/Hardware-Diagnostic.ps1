Windows PowerShell
Copyright (C) Microsoft Corporation. All rights reserved.

Install the latest PowerShell for new features and improvements! https://aka.ms/PSWindows

PS C:\WINDOWS\system32> # First, check top processes consuming CPU
>> Get-Process | Sort-Object CPU -Descending |
>> Select-Object -First 10 Name, CPU, WorkinSet |
>> Format-Table -AutoSize

Name                   CPU WorkinSet
----                   --- ---------
svchost         109.078125
System           85.015625
MsMpEng          78.203125
svchost           32.34375
svchost           31.84375
svchost          20.109375
TiWorker         19.671875
svchost          16.765625
explorer          15.40625
MoUsoCoreWorker  14.390625


PS C:\WINDOWS\system32> # Second, Check RAM usage
>> $os = Get-WmiObject Win32_OperatingSystem
>> $totalRAM = [math]::Round($os.TotalVisibleMemorySize/1MB, 2)
>> $freeRAM = [math]::Round($os.FreePhysicalMemory/1MB, 2)
>> $usedRAM = [math]::Round($totalRAM - $freeRAM, 2)
>> Write-Host "Total RAM: $totalRAM GB"
>> Write-Host "Used RAM: $usedRAM GB"
>> Write-Host "Free RAM: $freeRAM GB"
Total RAM: 3.98 GB
Used RAM: 2.64 GB
Free RAM: 1.34 GB
PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32> # Third, Check disk space
>> Get-PSDrive C | Select-Object `
>>  @{N='Total(GB)';E={[math]::Round($_.Used/1GB + $_.Free/1GB,2)}},
>>  @{N='Used(GB)';E={[math]::Round($_.Used/1GB,2)}},
>>  @{N='Free(GB)';E={[math]::Round($_.Free/1GB,2)}}

Total(GB) Used(GB) Free(GB)
--------- -------- --------
    59.94    35.51    24.42


PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32> # Fourth, Check recent system errors
>> Get-EventLog -LogName System -EntryType Error -Newest 5 |
>> select-Object TimeGenerated, Source, Message | Format-List


TimeGenerated : 2026-07-06 12:09:08 AM
Source        : DCOM
Message       : The description for Event ID '10010' in Source 'DCOM' cannot be found.  The local computer
                may not have the necessary registry information or message DLL files to display the message,
                or you may not have permission to access them.  The following information is part of the even
                t:'MicrosoftWindows.Client.WebExperience_526.15201.50.0_x64__cw5n1h2txyewy!WindowsUdk.UI.Shel
                l.Dashboard.DashboardExtension'

TimeGenerated : 2026-07-06 12:09:08 AM
Source        : DCOM
Message       : The description for Event ID '10010' in Source 'DCOM' cannot be found.  The local computer
                may not have the necessary registry information or message DLL files to display the message,
                or you may not have permission to access them.  The following information is part of the even
                t:'MicrosoftWindows.Client.WebExperience_526.15201.50.0_x64__cw5n1h2txyewy!WindowsUdk.UI.Shel
                l.Dashboard.DashboardExtension'

TimeGenerated : 2026-07-05 11:53:23 PM
Source        : DCOM
Message       : The description for Event ID '10010' in Source 'DCOM' cannot be found.  The local computer
                may not have the necessary registry information or message DLL files to display the message,
                or you may not have permission to access them.  The following information is part of the even
                t:'MicrosoftWindows.Client.WebExperience_526.15201.50.0_x64__cw5n1h2txyewy!WindowsUdk.UI.Shel
                l.Dashboard.DashboardExtension'

TimeGenerated : 2026-07-05 11:53:23 PM
Source        : DCOM
Message       : The description for Event ID '10010' in Source 'DCOM' cannot be found.  The local computer
                may not have the necessary registry information or message DLL files to display the message,
                or you may not have permission to access them.  The following information is part of the even
                t:'MicrosoftWindows.Client.WebExperience_526.15201.50.0_x64__cw5n1h2txyewy!WindowsUdk.UI.Shel
                l.Dashboard.DashboardExtension'

TimeGenerated : 2026-07-05 11:53:23 PM
Source        : DCOM
Message       : The description for Event ID '10010' in Source 'DCOM' cannot be found.  The local computer
                may not have the necessary registry information or message DLL files to display the message,
                or you may not have permission to access them.  The following information is part of the even
                t:'MicrosoftWindows.Client.WebExperience_526.15201.50.0_x64__cw5n1h2txyewy!WindowsUdk.UI.Shel
                l.Dashboard.DashboardExtension'



PS C:\WINDOWS\system32>
PS C:\WINDOWS\system32> # lastly, Clean temp files
>> Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
>> Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
>> Write-Host "Temporary files cleared successfully"
Temporary files cleared successfully
PS C:\WINDOWS\system32>
