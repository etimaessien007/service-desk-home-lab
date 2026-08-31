# ============================================
# Script: Get-DHCPReport.ps1
# Description: Automated DHCP Status Report
# Author: Eti-ima Essien
# Date: 08/17/2026
# ============================================

$ReportPath = "C:\ServiceDeskLab\DHCPReports"
$ReportFile = "$ReportPath\DHCP_Report_$(Get-Date -Format 'yyyyMMdd_HHmm').txt"
$ScopeId    = "192.168.100.0"

If (-Not (Test-Path $ReportPath)) {
    New-Item -Path $ReportPath -ItemType Directory -Force
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  SERVERCORP DHCP STATUS REPORT" -ForegroundColor Cyan
Write-Host "  Generated: $(Get-Date -Format 'MM/dd/yyyy HH:mm')" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# SCOPE SUMMARY
Write-Host "[SCOPE SUMMARY]" -ForegroundColor Yellow
$scope = Get-DhcpServerv4Scope
$stats = Get-DhcpServerv4ScopeStatistics -ScopeId $ScopeId
Write-Host "Scope Name:    $($scope.Name)"
Write-Host "IP Range:      $($scope.StartRange) - $($scope.EndRange)"
Write-Host "Total IPs:     $($stats.Total)"
Write-Host "IPs In Use:    $($stats.InUse)"
Write-Host "IPs Available: $($stats.Free)"
Write-Host "Percent Used:  $($stats.PercentageInUse)%"

# ACTIVE LEASES
Write-Host "`n[ACTIVE LEASES]" -ForegroundColor Yellow
$leases = Get-DhcpServerv4Lease -ScopeId $ScopeId
If ($leases) {
    $leases | Select-Object IPAddress, HostName,
        AddressState, LeaseExpiryTime |
    Format-Table -AutoSize
} Else {
    Write-Host "No active leases found" -ForegroundColor Green
}

# RESERVATIONS
Write-Host "`n[RESERVATIONS]" -ForegroundColor Yellow
Get-DhcpServerv4Reservation -ScopeId $ScopeId |
Select-Object IPAddress, Name, Description |
Format-Table -AutoSize

# EXCLUSIONS
Write-Host "`n[EXCLUSION RANGES]" -ForegroundColor Yellow
Get-DhcpServerv4ExclusionRange -ScopeId $ScopeId |
Select-Object StartRange, EndRange |
Format-Table -AutoSize

# SAVE TO FILE
$Report = @"
================================================
SERVERCORP DHCP STATUS REPORT
Generated: $(Get-Date -Format 'MM/dd/yyyy HH:mm')
Scope: $ScopeId
================================================

SCOPE SUMMARY:
Name:          $($scope.Name)
Range:         $($scope.StartRange) - $($scope.EndRange)
Total IPs:     $($stats.Total)
In Use:        $($stats.InUse)
Available:     $($stats.Free)
Percent Used:  $($stats.PercentageInUse)%

RESERVATIONS:
$(Get-DhcpServerv4Reservation -ScopeId $ScopeId |
    ForEach-Object {"$($_.IPAddress) | $($_.Name) | $($_.Description)"})

EXCLUSION RANGES:
$(Get-DhcpServerv4ExclusionRange -ScopeId $ScopeId |
    ForEach-Object {"$($_.StartRange) - $($_.EndRange)"})

ACTIVE LEASES:
$(Get-DhcpServerv4Lease -ScopeId $ScopeId |
    ForEach-Object {"$($_.IPAddress) | $($_.HostName) | $($_.AddressState)"})

================================================
"@

$Report | Out-File $ReportFile -Encoding UTF8

Write-Host "`n========================================"
Write-Host " Report saved to: $ReportFile"
Write-Host "========================================`n" 
