# Configuration
$CSVPath  = "C:\ServiceDeskLab\Scripts\NewUsers.csv"
$TempPass = "Welcome123!"
$Domain   = "servercorp.local"
$Counter  = 0
$Errors   = 0

# STEP 1 - Verify CSV
Write-Host "`n[STEP 1] Loading CSV File..." -ForegroundColor Cyan
If (-Not (Test-Path $CSVPath)) {
    Write-Host "CSV file not found" -ForegroundColor Red
    Exit
}
$Users = Import-Csv $CSVPath
Write-Host "CSV loaded - $($Users.Count) users found" -ForegroundColor Green

# STEP 2 - Create Users
Write-Host "`n[STEP 2] Creating User Accounts..." -ForegroundColor Cyan

ForEach ($User in $Users) {
    If (Get-ADUser -Filter {SamAccountName -eq $User.Username} -ErrorAction SilentlyContinue) {
        Write-Host "Skipped: $($User.Username) already exists" -ForegroundColor Yellow
        Continue
    }
    Try {
        New-ADUser `
            -Name "$($User.FirstName) $($User.LastName)" `
            -GivenName $User.FirstName `
            -Surname $User.LastName `
            -UserPrincipalName "$($User.Username)@$Domain" `
            -SamAccountName $User.Username `
            -EmailAddress $User.Email `
            -Path $User.OUPath `
            -AccountPassword (ConvertTo-SecureString $TempPass -AsPlainText -Force) `
            -Enabled $true `
            -ChangePasswordAtLogon $true `
            -Department $User.Department `
            -Title $User.JobTitle
        Write-Host "Created: $($User.FirstName) $($User.LastName) | $($User.Email)" -ForegroundColor Green
        $Counter++
    } Catch {
        Write-Host "Failed: $($User.Username) - $($_.Exception.Message)" -ForegroundColor Red
        $Errors++
    }
}

# STEP 3 - Verify Users
Write-Host "`n[STEP 3] Verifying Created Users..." -ForegroundColor Cyan
ForEach ($User in $Users) {
    $ADUser = Get-ADUser -Filter {SamAccountName -eq $User.Username} -ErrorAction SilentlyContinue
    If ($ADUser) {
        Write-Host "Verified: $($User.FirstName) $($User.LastName)" -ForegroundColor Green
    } Else {
        Write-Host "Missing: $($User.FirstName) $($User.LastName)" -ForegroundColor Red
    }
}

# STEP 4 - Generate Report
Write-Host "`n[STEP 4] Generating Report..." -ForegroundColor Cyan
$ReportPath = "C:\ServiceDeskLab\BulkCreationRecords"
If (-Not (Test-Path $ReportPath)) {
    New-Item -Path $ReportPath -ItemType Directory -Force
}
$ReportFile = "$ReportPath\BulkCreation_$(Get-Date -Format 'yyyyMMdd_HHmm').txt"
"BULK USER CREATION REPORT" | Out-File $ReportFile
"==========================" | Out-File $ReportFile -Append
"Date: $(Get-Date -Format 'MM/dd/yyyy HH:mm')" | Out-File $ReportFile -Append
"Total Users: $($Users.Count)" | Out-File $ReportFile -Append
"Created: $Counter" | Out-File $ReportFile -Append
"Errors: $Errors" | Out-File $ReportFile -Append
"" | Out-File $ReportFile -Append
"USERS CREATED:" | Out-File $ReportFile -Append
ForEach ($User in $Users) {
    "$($User.FirstName) $($User.LastName) | $($User.Email) | $($User.Department)" | Out-File $ReportFile -Append
}
Write-Host "Report saved to $ReportFile" -ForegroundColor Green

# SUMMARY
Write-Host "`n=======================================" -ForegroundColor Yellow
Write-Host "BULK CREATION SUMMARY" -ForegroundColor Yellow
Write-Host "=======================================" -ForegroundColor Yellow
Write-Host "Total Users:  $($Users.Count)" -ForegroundColor White
Write-Host "Created:      $Counter" -ForegroundColor Green
Write-Host "Errors:       $Errors" -ForegroundColor Red
Write-Host "=======================================" -ForegroundColor Yellow
