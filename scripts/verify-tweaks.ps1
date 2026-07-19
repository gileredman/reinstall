$services = @(
    "SysMain",
    "DiagTrack",
    "dmwappushservice",
    "XblAuthManager",
    "XblGameSave",
    "XboxNetApiSvc",
    "XboxGipSvc",
    "Spooler",
    "Fax"
)

Write-Host "=== Service Status Check ==="
foreach ($serviceName in $services) {
    $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
    if ($null -eq $service) {
        Write-Host ("{0,-20} NOT FOUND" -f $serviceName)
        continue
    }

    $wmiService = Get-CimInstance -ClassName Win32_Service -Filter "Name='$serviceName'"
    Write-Host ("{0,-20} Status={1,-10} StartMode={2}" -f $serviceName, $service.Status, $wmiService.StartMode)
}

Write-Host "`n=== Registry Policy Check ==="
$registryChecks = @(
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds"; Name = "EnableFeeds" },
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"; Name = "AllowTelemetry" },
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive"; Name = "DisableFileSyncNGSC" }
)

foreach ($check in $registryChecks) {
    $value = Get-ItemPropertyValue -Path $check.Path -Name $check.Name -ErrorAction SilentlyContinue
    if ($null -ne $value -and $value -ne "") {
        Write-Host ("{0} -> {1}={2}" -f $check.Path, $check.Name, $value)
    } else {
        Write-Host ("{0} -> {1}=NOT SET" -f $check.Path, $check.Name)
    }
}
