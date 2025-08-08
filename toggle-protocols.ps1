<#
.SYNOPSIS
    Enables or disables legacy cryptographic protocols to harden or loosen system security posture.
    Ensure this script is run with administrative privileges and tested in a non-production environment before full deployment.


.NOTES
    Author        : Jeremy Odekerken
    Date Created  : 2025-08-07
    Last Modified : 2025-08-07
    Version       : 1.1

.TESTED ON
    Date(s) Tested  : 2025-08-07
    Tested By       : Jeremy Odekerken
    Systems Tested  : Windows Server 2019 Datacenter, Build 1809
    PowerShell Ver. : 5.1.17763.6189

.USAGE
    Set `$hardenSystem = $true` to apply secure protocol settings.
    Example:
    PS C:\> .\configure-protocols.ps1
#>

# Set to $true for secure configuration, $false to re-enable legacy protocols
$hardenSystem = $true

# Function to confirm script is being run as Administrator
function Confirm-Elevation {
    $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Confirm-Elevation)) {
    Write-Error "This script must be run with Administrator privileges."
    exit 1
}

# Helper function to configure each protocol
function Set-ProtocolState {
    param (
        [string]$protocol,
        [bool]$enable
    )

    $paths = @(
        "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$protocol\Server",
        "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$protocol\Client"
    )

    foreach ($path in $paths) {
        if (-not (Test-Path $path)) {
            New-Item -Path $path -Force | Out-Null
        }

        if ($enable) {
            New-ItemProperty -Path $path -Name 'Enabled' -Value 1 -PropertyType 'DWord' -Force | Out-Null
            New-ItemProperty -Path $path -Name 'DisabledByDefault' -Value 0 -PropertyType 'DWord' -Force | Out-Null
        } else {
            New-ItemProperty -Path $path -Name 'Enabled' -Value 0 -PropertyType 'DWord' -Force | Out-Null
            New-ItemProperty -Path $path -Name 'DisabledByDefault' -Value 1 -PropertyType 'DWord' -Force | Out-Null
        }
    }

    $status = if ($enable) { "enabled" } else { "disabled" }
    Write-Host "$protocol has been $status."
}

# List of protocols to configure
$protocols = @(
    "SSL 2.0",
    "SSL 3.0",
    "TLS 1.0",
    "TLS 1.1",
    "TLS 1.2"
)

# Apply settings
foreach ($proto in $protocols) {
    if ($proto -eq "TLS 1.2") {
        # Always enable TLS 1.2 when hardening
        Set-ProtocolState -protocol $proto -enable:$hardenSystem
    } else {
        Set-ProtocolState -protocol $proto -enable:(!$hardenSystem)
    }
}

Write-Host "`nConfiguration complete. Please restart the system for changes to take effect."
