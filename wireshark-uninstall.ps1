<#
.SYNOPSIS
    Silently removes Wireshark from the local machine.
    Intended for use in controlled environments. Ensure thorough testing before use in production.
    Requires administrative privileges.


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
    Wireshark Ver.  : 2.2.1 (v2.2.1-0-ga6fbd27 from master-2.2)

.USAGE
    Example:
    PS C:\> .\remove-wireshark.ps1
#>

# Define the expected display name and uninstall path
$applicationName = "Wireshark 2.2.1 (64-bit)"
$uninstallExecutable = Join-Path $env:ProgramFiles "Wireshark\uninstall.exe"
$uninstallArgs = "/S"

# Check for presence of the uninstall executable
function Test-WiresharkPresence {
    return Test-Path -Path $uninstallExecutable
}

# Uninstall routine
function Remove-Wireshark {
    if (Test-WiresharkPresence) {
        Write-Output "Attempting to remove $applicationName..."
        & $uninstallExecutable $uninstallArgs
        Write-Output "$applicationName successfully removed."
    } else {
        Write-Output "$applicationName not found on this system."
    }
}

# Run the uninstall process
Remove-Wireshark
