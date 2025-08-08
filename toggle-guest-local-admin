<#
.SYNOPSIS
    Adds or removes the built-in Guest account from the local Administrators group.
    Use with caution and always test in a non-production environment first.
    Requires Administrator privileges to execute successfully.

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
    Set `$ModifyGuestAccess = $false` to remove the Guest account from the Administrators group.
    Example:
    PS C:\> .\manage-guest-admin-access.ps1
#>

# Set to $true to add Guest to Administrators group, $false to remove it
$ModifyGuestAccess = $false

# Local group and account to target
$adminGroup = "Administrators"
$guestUser = "Guest"

# Function to grant admin access to Guest
function Grant-GuestAdmin {
    if (-not (Get-LocalGroupMember -Group $adminGroup -Member $guestUser -ErrorAction SilentlyContinue)) {
        Add-LocalGroupMember -Group $adminGroup -Member $guestUser
        Write-Output "Guest account has been successfully added to the Administrators group."
    } else {
        Write-Output "Guest account is already in the Administrators group."
    }
}

# Function to revoke admin access from Guest
function Revoke-GuestAdmin {
    if (Get-LocalGroupMember -Group $adminGroup -Member $guestUser -ErrorAction SilentlyContinue) {
        Remove-LocalGroupMember -Group $adminGroup -Member $guestUser
        Write-Output "Guest account has been removed from the Administrators group."
    } else {
        Write-Output "Guest account is not currently a member of the Administrators group."
    }
}

# Execute based on user-defined setting
if ($ModifyGuestAccess) {
    Grant-GuestAdmin
} else {
    Revoke-GuestAdmin
}
