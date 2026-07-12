# ============================================

# Script: Onboard-Employee.ps1

# Description: Automates new employee setup

# Author: Eti-ima Essien

# Date: 07/05/2026

# ============================================

# Employee Details — Edit these for each new hire

$FirstName   = "Sarah"

$LastName    = "Connor"

$Username    = "sconnor"

$Department  = "Finance"

$JobTitle    = "Financial Analyst"

$Manager     = "mjohnson"

$TempPass    = "Welcome123!"

$OUPath      = "OU=Finance Department,OU=SERVERCORP Company,DC=servercorp,DC=local"

$SharePath   = "C:\Shares\Finance"

# ============================================

# STEP 1 — Create AD User Account

# ============================================

Write-Host "`n[STEP 1] Creating AD User Account..." -ForegroundColor Cyan

New-ADUser `

    -Name "$FirstName $LastName" `

    -GivenName $FirstName `

    -Surname $LastName `

    -UserPrincipalName "$Username@servercorp.local" `

    -SamAccountName $Username `

    -Path $OUPath `

    -AccountPassword (ConvertTo-SecureString $TempPass -AsPlainText -Force) `

    -Enabled $true `

    -ChangePasswordAtLogon $true `

    -Department $Department `

    -Title $JobTitle `

    -Manager $Manager

Write-Host " AD Account created: $Username@servercorp.local" -ForegroundColor Green

# ============================================

# STEP 2 — Verify Account Created

# ============================================

Write-Host "`n[STEP 2] Verifying Account..." -ForegroundColor Cyan

Get-ADUser -Identity $Username -Properties Department, Title |

Select-Object Name, UserPrincipalName, Department, Title |

Format-Table -AutoSize

# ============================================

# STEP 3 — Create and Assign Shared Folder

# ============================================

Write-Host "`n[STEP 3] Setting Up Folder Access..." -ForegroundColor Cyan

If (-Not (Test-Path $SharePath)) {

    New-Item -Path $SharePath -ItemType Directory -Force

    Write-Host " Folder created: $SharePath" -ForegroundColor Green

}

$Acl = Get-Acl $SharePath

$Permission = New-Object System.Security.AccessControl.FileSystemAccessRule(

    "SERVERCORP\$Username","Modify",

    "ContainerInherit,ObjectInherit",

    "None","Allow"

)

$Acl.SetAccessRule($Permission)

Set-Acl $SharePath $Acl

Write-Host " Folder access granted to $Username" -ForegroundColor Green

# ============================================

# STEP 4 — Generate Onboarding Report

# ============================================

Write-Host "`n[STEP 4] Generating Onboarding Report..." -ForegroundColor Cyan

$ReportPath = "C:\ServiceDeskLab\OnboardingRecords"

If (-Not (Test-Path $ReportPath)) {

    New-Item -Path $ReportPath -ItemType Directory -Force

}

$Report = @"

ONBOARDING REPORT

=================

Date:       $(Get-Date -Format "MM/dd/yyyy HH:mm")

Analyst:    Service Desk

Employee:   $FirstName $LastName

Username:   $Username@servercorp.local

Department: $Department

Title:      $JobTitle

Manager:    $Manager

Temp Pass:  $TempPass

TASKS COMPLETED:

- Domain account created

- Account placed in $Department OU

- Folder access granted: $SharePath

- Password change required at first login

STATUS: Ready for first day 

"@

$Report | Out-File "$ReportPath\$LastName`_$FirstName`_Onboarding.txt"

Write-Host " Report saved to $ReportPath" -ForegroundColor Green

Write-Host "`n========================================" -ForegroundColor Yellow

Write-Host " ONBOARDING COMPLETE FOR $FirstName $LastName" -ForegroundColor Green

Write-Host "========================================`n" -ForegroundColor Yellow
