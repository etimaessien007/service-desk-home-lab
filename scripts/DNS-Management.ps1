# ============================================
# Script: DNS-Management.ps1
# Description: DNS record management and
#              troubleshooting tool
# Author: Eti-ima Essien
# Date: 08/12/2026
# ============================================

$Zone = "servercorp.local"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  SERVERCORP DNS ZONE REPORT" -ForegroundColor Cyan
Write-Host "  Zone: $Zone" -ForegroundColor Cyan
Write-Host "  Generated: $(Get-Date -Format 'MM/dd/yyyy HH:mm')" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# A Records
Write-Host "[A RECORDS]" -ForegroundColor Yellow
Get-DnsServerResourceRecord -ZoneName $Zone -RRType A |
Select-Object HostName,
    @{N='IPAddress';E={$_.RecordData.IPv4Address}} |
Format-Table -AutoSize

# CNAME Records
Write-Host "[CNAME RECORDS]" -ForegroundColor Yellow
Get-DnsServerResourceRecord -ZoneName $Zone -RRType CName |
Select-Object HostName,
    @{N='Target';E={$_.RecordData.HostNameAlias}} |
Format-Table -AutoSize

# MX Records
Write-Host "[MX RECORDS]" -ForegroundColor Yellow
Get-DnsServerResourceRecord -ZoneName $Zone -RRType MX |
Select-Object HostName,
    @{N='Priority';E={$_.RecordData.Preference}},
    @{N='MailServer';E={$_.RecordData.MailExchange}} |
Format-Table -AutoSize

# TXT Records
Write-Host "[TXT RECORDS]" -ForegroundColor Yellow
Get-DnsServerResourceRecord -ZoneName $Zone -RRType TXT |
Select-Object HostName,
    @{N='Value';E={$_.RecordData.DescriptiveText}} |
Format-Table -AutoSize

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " DNS Zone Report Complete"
Write-Host "========================================`n" -ForegroundColor Cyan
