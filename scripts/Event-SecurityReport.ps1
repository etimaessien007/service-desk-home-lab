# ============================================
# Script: Event-SecurityReport.ps1
# Description: Automated Security Event Report
# Author: Eti-ima Essien
# Date: 08/01/2026
# ============================================

$ReportPath = "C:\ServiceDeskLab\SecurityReports"
$ReportFile = "$ReportPath\Security_Report_$(Get-Date -Format 'yyyyMMdd_HHmm').txt"
$StartTime  = (Get-Date).AddHours(-24)

If (-Not (Test-Path $ReportPath)) {
    New-Item -Path $ReportPath -ItemType Directory -Force
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  SERVERCORP SECURITY EVENT REPORT" -ForegroundColor Cyan
Write-Host "  Generated: $(Get-Date -Format 'MM/dd/yyyy HH:mm')" -ForegroundColor Cyan
Write-Host "  Period: Last 24 Hours" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# ============================================
# SECTION 1 — Failed Login Attempts (4625)
# ============================================
Write-Host "[SECTION 1] Failed Login Attempts" -ForegroundColor Yellow

Try {
    $FailedLogins = Get-WinEvent -FilterHashtable @{
        LogName   = 'Security'
        Id        = 4625
        StartTime = $StartTime
    } -ErrorAction Stop

    Write-Host "Total Failed Logins: $($FailedLogins.Count)" -ForegroundColor Red

    $FailedLogins | Select-Object TimeCreated,
        @{N='Username';E={$_.Properties[5].Value}},
        @{N='WorkStation';E={$_.Properties[13].Value}},
        @{N='FailureReason';E={$_.Properties[8].Value}} |
    Format-Table -AutoSize

} Catch {
    Write-Host "No failed login events found in last 24 hours" -ForegroundColor Green
}

# ============================================
# SECTION 2 — Account Lockouts (4740)
# ============================================
Write-Host "`n[SECTION 2] Account Lockouts" -ForegroundColor Yellow

Try {
    $Lockouts = Get-WinEvent -FilterHashtable @{
        LogName   = 'Security'
        Id        = 4740
        StartTime = $StartTime
    } -ErrorAction Stop

    Write-Host "Total Lockouts: $($Lockouts.Count)" -ForegroundColor Red

    $Lockouts | Select-Object TimeCreated,
        @{N='LockedAccount';E={$_.Properties[0].Value}},
        @{N='CallerMachine';E={$_.Properties[1].Value}} |
    Format-Table -AutoSize

} Catch {
    Write-Host "No lockout events found in last 24 hours" -ForegroundColor Green
}

# ============================================
# SECTION 3 — Successful Logins (4624)
# ============================================
Write-Host "`n[SECTION 3] Successful Logins" -ForegroundColor Yellow

Try {
    $SuccessLogins = Get-WinEvent -FilterHashtable @{
        LogName   = 'Security'
        Id        = 4624
        StartTime = $StartTime
    } -ErrorAction Stop |
    Where-Object {$_.Properties[8].Value -eq 2 -or
                  $_.Properties[8].Value -eq 3}

    Write-Host "Total Successful Logins: $($SuccessLogins.Count)" -ForegroundColor Green

    $SuccessLogins | Select-Object TimeCreated,
        @{N='Username';E={$_.Properties[5].Value}},
        @{N='WorkStation';E={$_.Properties[11].Value}},
        @{N='LogonType';E={$_.Properties[8].Value}} |
    Format-Table -AutoSize

} Catch {
    Write-Host "No successful login events found" -ForegroundColor Green
}

# ============================================
# SECTION 4 — Account Unlocks (4767)
# ============================================
Write-Host "`n[SECTION 4] Account Unlocks" -ForegroundColor Yellow

Try {
    $Unlocks = Get-WinEvent -FilterHashtable @{
        LogName   = 'Security'
        Id        = 4767
        StartTime = $StartTime
    } -ErrorAction Stop

    Write-Host "Total Unlocks: $($Unlocks.Count)" -ForegroundColor Green

    $Unlocks | Select-Object TimeCreated,
        @{N='UnlockedAccount';E={$_.Properties[0].Value}},
        @{N='UnlockedBy';E={$_.Properties[4].Value}} |
    Format-Table -AutoSize

} Catch {
    Write-Host "No unlock events found in last 24 hours" -ForegroundColor Green
}

# ============================================
# SECTION 5 — User Account Changes (4720/4725/4726)
# ============================================
Write-Host "`n[SECTION 5] User Account Changes" -ForegroundColor Yellow

Try {
    $AccountChanges = Get-WinEvent -FilterHashtable @{
        LogName   = 'Security'
        Id        = 4720, 4722, 4725, 4726, 4767
        StartTime = $StartTime
    } -ErrorAction Stop

    Write-Host "Total Account Changes: $($AccountChanges.Count)" -ForegroundColor Yellow

    $AccountChanges | Select-Object TimeCreated, Id,
        @{N='AffectedAccount';E={$_.Properties[0].Value}},
        @{N='ChangedBy';E={$_.Properties[4].Value}} |
    Format-Table -AutoSize

} Catch {
    Write-Host "No account change events found in last 24 hours" -ForegroundColor Green
}

# ============================================
# SECTION 6 — Policy Changes (4719)
# ============================================
Write-Host "`n[SECTION 6] Policy Changes" -ForegroundColor Yellow

Try {
    $PolicyChanges = Get-WinEvent -FilterHashtable @{
        LogName   = 'Security'
        Id        = 4719
        StartTime = $StartTime
    } -ErrorAction Stop

    Write-Host "Total Policy Changes: $($PolicyChanges.Count)" -ForegroundColor Yellow
    $PolicyChanges | Select-Object TimeCreated, Message |
    Format-List

} Catch {
    Write-Host "No policy change events found in last 24 hours" -ForegroundColor Green
}

# ============================================
# SECTION 7 — Currently Locked Accounts
# ============================================
Write-Host "`n[SECTION 7] Currently Locked AD Accounts" -ForegroundColor Yellow

$LockedAccounts = Search-ADAccount -LockedOut |
    Select-Object Name, SamAccountName, LockedOut, LastLogonDate

If ($LockedAccounts) {
    Write-Host "  Locked Accounts Found:" -ForegroundColor Red
    $LockedAccounts | Format-Table -AutoSize
} Else {
    Write-Host " No accounts currently locked" -ForegroundColor Green
}

# ============================================
# GENERATE TEXT REPORT FILE
# ============================================
$ReportContent = @"
================================================
SERVERCORP SECURITY EVENT REPORT
Generated: $(Get-Date -Format 'MM/dd/yyyy HH:mm')
Period: Last 24 Hours
================================================

SUMMARY:
Failed Login Attempts : Check Section 1
Account Lockouts      : Check Section 2
Successful Logins     : Check Section 3
Account Unlocks       : Check Section 4
Account Changes       : Check Section 5
Policy Changes        : Check Section 6
Currently Locked      : Check Section 7

EVENT ID REFERENCE:
4624 = Successful Logon
4625 = Failed Logon Attempt
4634 = Account Logoff
4719 = Audit Policy Changed
4720 = User Account Created
4722 = User Account Enabled
4725 = User Account Disabled
4726 = User Account Deleted
4740 = Account Locked Out
4767 = Account Unlocked

ANALYST NOTES:
- Review failed logins for brute force patterns
- Investigate any after-hours successful logins
- Verify all policy changes were authorized
- Unlock accounts per Service Desk ticket only
================================================
"@

$ReportContent | Out-File $ReportFile -Encoding UTF8
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host " Report saved to: $ReportFile" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan
