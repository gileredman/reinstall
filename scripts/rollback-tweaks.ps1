$ErrorActionPreference = "SilentlyContinue"

function Write-Status {
    param(
        [Parameter(Mandatory = $true)][string]$Tag,
        [Parameter(Mandatory = $true)][string]$Message
    )

    Write-Host "[$Tag] $Message"
}

function Enable-ServiceSafe {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][ValidateSet("Automatic", "Manual")][string]$StartupType
    )

    $service = Get-Service -Name $Name -ErrorAction SilentlyContinue
    if ($null -eq $service) {
        Write-Status -Tag "SKIP" -Message "Service not found: $Name"
        return
    }

    Set-Service -Name $Name -StartupType $StartupType -ErrorAction SilentlyContinue

    if ($StartupType -in @("Automatic", "Manual")) {
        Start-Service -Name $Name -ErrorAction SilentlyContinue
    }

    Write-Status -Tag "OK" -Message "Enabled service: $Name (StartupType=$StartupType)"
}

function Remove-RegistryValueSafe {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Name
    )

    $currentValue = Get-ItemPropertyValue -Path $Path -Name $Name -ErrorAction SilentlyContinue
    if ($null -ne $currentValue) {
        Remove-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
        Write-Status -Tag "OK" -Message "Removed registry value: $Path -> $Name"
    } else {
        Write-Status -Tag "SKIP" -Message "Registry value not set: $Path -> $Name"
    }
}

Write-Host "=== Rollback tweaks start ==="

Enable-ServiceSafe -Name "SysMain" -StartupType "Automatic"
Enable-ServiceSafe -Name "DiagTrack" -StartupType "Automatic"
Enable-ServiceSafe -Name "dmwappushservice" -StartupType "Manual"
Enable-ServiceSafe -Name "XblAuthManager" -StartupType "Manual"
Enable-ServiceSafe -Name "XblGameSave" -StartupType "Manual"
Enable-ServiceSafe -Name "XboxNetApiSvc" -StartupType "Manual"
Enable-ServiceSafe -Name "XboxGipSvc" -StartupType "Manual"
Enable-ServiceSafe -Name "Spooler" -StartupType "Automatic"
Enable-ServiceSafe -Name "Fax" -StartupType "Manual"

Remove-RegistryValueSafe -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" -Name "EnableFeeds"
Remove-RegistryValueSafe -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry"
Remove-RegistryValueSafe -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Name "DisableFileSyncNGSC"

Write-Host "=== Rollback tweaks done ==="
Write-Host "Disarankan restart Windows agar layanan kembali normal."
