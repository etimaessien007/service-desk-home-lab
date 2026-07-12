# ============================================
# Script: Offboard-Employee.ps1
# Description: Automates employee offboarding
# Author: Eti-ima Essien
# Date: 07/05/2026
# ============================================

# Employee Details — Edit for each offboarding
$Username    = "jdoe"
$FullName    = "Jane Doe"
$Department  = "IT"
$DisabledOU  = "OU=Disabled Users,OU=SERVERCORP Company,DC=servercorp,DC=local"

# ============================================
# STEP 1 — Verify Account Exists
# ============================================
Write-Host "`n[STEP 1] Verifying Account..." -ForegroundColor Cyan

$User = Get-ADUser -Identity $Username -Properties MemberOf, Department
If (-Not $User) {
    Write-Host " User $Username not found in AD" -ForegroundColor Red
    Exit
}
Write-Host " Account found: $FullName ($Username)" -ForegroundColor Green

# ============================================
# STEP 2 — Disable The Account
# ============================================
Write-Host "`n[STEP 2] Disabling Account..." -ForegroundColor Cyan

Disable-ADAccount -Identity $Username
Write-Host " Account disabled: $Username" -ForegroundColor Green

# ============================================
# STEP 3 — Remove From All Groups
# ============================================
Write-Host "`n[STEP 3] Removing Group Memberships..." -ForegroundColor Cyan

$Groups = Get-ADUser $Username -Properties MemberOf | 
          Select-Object -ExpandProperty MemberOf

If ($Groups) {
    ForEach ($Group in $Groups) {
        Remove-ADGroupMember -Identity $Group -Members $Username -Confirm:$false
        Write-Host " Removed from: $Group" -ForegroundColor Green
    }
} Else {
    Write-Host " No group memberships found" -ForegroundColor Yellow
}

# ============================================
# STEP 4 — Move to Disabled Users OU
# ============================================
Write-Host "`n[STEP 4] Moving to Disabled Users OU..." -ForegroundColor Cyan

Move-ADObject `
    -Identity (Get-ADUser $Username).DistinguishedName `
    -TargetPath $DisabledOU
Write-Host " Account moved to Disabled Users OU" -ForegroundColor Green

# ============================================
# STEP 5 — Reset Password to Random String
# ============================================
Write-Host "`n[STEP 5] Resetting Password..." -ForegroundColor Cyan

$RandomPass = -join ((33..126) | Get-Random -Count 16 |
    ForEach-Object {[char]$_})
Write-Host " Random password generated" -ForegroundColor Green
Set-ADAccountPassword `
    -Identity $Username `
    -NewPassword (ConvertTo-SecureString $RandomPass -AsPlainText -Force) `
    -Reset
Write-Host " Password reset to random string" -ForegroundColor Green

# ============================================
# STEP 6 — Generate Offboarding Report
# ============================================
Write-Host "`n[STEP 6] Generating Offboarding Report..." -ForegroundColor Cyan

$ReportPath = "C:\ServiceDeskLab\OffboardingRecords"
If (-Not (Test-Path $ReportPath)) {
    New-Item -Path $ReportPath -ItemType Directory -Force
}

$Report = @"
OFFBOARDING REPORT
==================
Date:       $(Get-Date -Format "MM/dd/yyyy HH:mm")
Analyst:    Service Desk
Employee:   $FullName
Username:   $Username
Department: $Department

TASKS COMPLETED:
- Account disabled in Active Directory
- Removed from all security groups
- Account moved to Disabled Users OU
- Password reset to random string
- Access to all systems revoked

SECURITY NOTES:
- Account disabled immediately upon offboarding
- All group memberships removed
- Account retained in Disabled OU for 90 days
  per company policy before permanent deletion

STATUS: Offboarding Complete 
"@

$Report | Out-File "$ReportPath\$Username`_Offboarding_$(Get-Date -Format 'yyyyMMdd').txt"
Write-Host " Report saved to $ReportPath" -ForegroundColor Green

Write-Host "`n========================================" -ForegroundColor Yellow
Write-Host " OFFBOARDING COMPLETE FOR $FullName" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Yellow
