# Requires: Run as Administrator
# Windows Post-install Tweaks

$ErrorActionPreference = "SilentlyContinue"
$DisablePrintSpooler = $true

function Write-Status {
    param(
        [Parameter(Mandatory = $true)][string]$Tag,
        [Parameter(Mandatory = $true)][string]$Message
    )

    Write-Host "[$Tag] $Message"
}

function Test-IsAdministrator {
    $currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentIdentity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Set-RegistryDwordSafe {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][int]$Value
    )

    New-Item -Path $Path -Force | Out-Null
    New-ItemProperty -Path $Path -Name $Name -PropertyType DWord -Value $Value -Force | Out-Null
    Write-Status -Tag "OK" -Message "Set registry $Path -> $Name=$Value"
}

function Disable-ServiceSafe {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [string]$DisplayName = $Name
    )

    $service = Get-Service -Name $Name -ErrorAction SilentlyContinue
    if ($null -eq $service) {
        Write-Status -Tag "SKIP" -Message "Service not found: $DisplayName ($Name)"
        return
    }

    if ($service.Status -ne "Stopped") {
        Stop-Service -Name $Name -Force -ErrorAction SilentlyContinue
    }

    Set-Service -Name $Name -StartupType Disabled -ErrorAction SilentlyContinue
    Write-Status -Tag "OK" -Message "Disabled service: $DisplayName ($Name)"
}

Write-Host "=== Post-install tweaks start ==="

if (-not (Test-IsAdministrator)) {
    Write-Status -Tag "SKIP" -Message "Script should be run as Administrator. Exiting safely."
    exit 1
}

Set-RegistryDwordSafe -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" -Name "EnableFeeds" -Value 0
Set-RegistryDwordSafe -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds" -Name "ShellFeedsTaskbarViewMode" -Value 2

Disable-ServiceSafe -Name "SysMain"
Disable-ServiceSafe -Name "DiagTrack" -DisplayName "Telemetry (DiagTrack)"
Disable-ServiceSafe -Name "dmwappushservice" -DisplayName "Telemetry (dmwappushservice)"

Set-RegistryDwordSafe -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0

$xboxServices = @(
    "XblAuthManager",
    "XblGameSave",
    "XboxNetApiSvc",
    "XboxGipSvc"
)

foreach ($serviceName in $xboxServices) {
    Disable-ServiceSafe -Name $serviceName -DisplayName "Xbox service"
}

if ($DisablePrintSpooler) {
    Disable-ServiceSafe -Name "Spooler" -DisplayName "Print Spooler"
} else {
    Write-Status -Tag "SKIP" -Message "Print Spooler kept enabled by toggle."
}

Disable-ServiceSafe -Name "Fax"

$oneDriveProcess = Get-Process -Name "OneDrive" -ErrorAction SilentlyContinue
if ($null -ne $oneDriveProcess) {
    $oneDriveProcess | Stop-Process -Force -ErrorAction SilentlyContinue
    Write-Status -Tag "OK" -Message "Stopped OneDrive process."
} else {
    Write-Status -Tag "SKIP" -Message "OneDrive process not running."
}

$oneDriveSetup64 = "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"
$oneDriveSetup32 = "$env:SystemRoot\System32\OneDriveSetup.exe"

if (Test-Path -Path $oneDriveSetup64) {
    Start-Process -FilePath $oneDriveSetup64 -ArgumentList "/uninstall" -Wait -NoNewWindow
    Write-Status -Tag "OK" -Message "Requested OneDrive uninstall via SysWOW64."
} elseif (Test-Path -Path $oneDriveSetup32) {
    Start-Process -FilePath $oneDriveSetup32 -ArgumentList "/uninstall" -Wait -NoNewWindow
    Write-Status -Tag "OK" -Message "Requested OneDrive uninstall via System32."
} else {
    Write-Status -Tag "SKIP" -Message "OneDriveSetup.exe not found."
}

Set-RegistryDwordSafe -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Name "DisableFileSyncNGSC" -Value 1

Write-Host "=== Post-install tweaks done ==="
Write-Host "Disarankan restart Windows agar semua perubahan aktif penuh."
