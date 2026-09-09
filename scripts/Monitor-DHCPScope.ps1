# ============================================
# Script: Monitor-DHCPScope.ps1
# Description: Monitors DHCP scope and
#              alerts when utilization
#              exceeds threshold
# Author: Et-ima Essien
# Date: 09/09/2026
# ============================================

$ScopeId   = "192.168.100.0"
$Threshold = 80
$ReportPath = "C:\ServiceDeskLab\DHCPReports"

If (-Not (Test-Path $ReportPath)) {
    New-Item -Path $ReportPath -ItemType Directory -Force
}

$stats = Get-DhcpServerv4ScopeStatistics `
    -ScopeId $ScopeId

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  $script = @'DHCP SCOPE MONITORING ALERT" -ForegroundColor Cyan
Write-Host "  $(Get-Date -Format 'MM/dd/yyyy HH:mm')" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Scope ID:      $ScopeId"
Write-Host "Total IPs:     $($stats.Total)"
Write-Host "In Use:        $($stats.InUse)"
Write-Host "Available:     $($stats.Free)"
Write-Host "Percent Used:  $($stats.PercentageInUse)%"
Write-Host "Threshold:     $Threshold%"

Write-Host ""

If ($stats.PercentageInUse -ge $Threshold) {
    Write-Host "   CRITICAL: Scope at $($stats.PercentageInUse)%" `
        -ForegroundColor Red
    Write-Host "   Immediate action required!" `
        -ForegroundColor Red
    Write-Host "   Consider expanding scope range" `
        -ForegroundColor Yellow

    # Log alert to file
    $Alert = "$(Get-Date) — CRITICAL: DHCP scope at $($stats.PercentageInUse)% — Action Required"
    $Alert | Out-File "$ReportPath\DHCP_Alerts.txt" -Append

} ElseIf ($stats.PercentageInUse -ge 60) {
    Write-Host "  WARNING: Scope at $($stats.PercentageInUse)%" `
        -ForegroundColor Yellow
    Write-Host "   Monitor closely — approaching threshold" `
        -ForegroundColor Yellow

    $Alert = "$(Get-Date) — WARNING: DHCP scope at $($stats.PercentageInUse)% — Monitor Closely"
    $Alert | Out-File "$ReportPath\DHCP_Alerts.txt" -Append

} Else {
    Write-Host " NORMAL: Scope at $($stats.PercentageInUse)%" `
        -ForegroundColor Green
    Write-Host "   No action required" -ForegroundColor Green
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host " DHCP Monitoring Check Complete" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan
