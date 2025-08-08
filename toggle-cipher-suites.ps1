<#
.SYNOPSIS
    Configures system cipher suites to prioritize either secure or insecure protocols.
    Requires elevated privileges. Test thoroughly before deployment in production environments.
    

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
    Set `$secureConfig = $true` to enforce strong ciphers.
    Example:
    PS C:\> .\configure-ciphers.ps1
#>

# Toggle this flag to switch between secure and insecure configurations
$secureConfig = $true

# Define lists of cipher suites
$secureCiphers = "TLS_AES_256_GCM_SHA384,TLS_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_DHE_RSA_WITH_AES_256_GCM_SHA384,TLS_DHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384,TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256,TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256,TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA,TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA,TLS_RSA_WITH_AES_256_GCM_SHA384,TLS_RSA_WITH_AES_128_GCM_SHA256,TLS_RSA_WITH_AES_256_CBC_SHA256,TLS_RSA_WITH_AES_128_CBC_SHA256,TLS_RSA_WITH_AES_256_CBC_SHA,TLS_RSA_WITH_AES_128_CBC_SHA,TLS_RSA_WITH_NULL_SHA256,TLS_RSA_WITH_NULL_SHA,TLS_PSK_WITH_AES_256_GCM_SHA384,TLS_PSK_WITH_AES_128_GCM_SHA256,TLS_PSK_WITH_AES_256_CBC_SHA384,TLS_PSK_WITH_AES_128_CBC_SHA256,TLS_PSK_WITH_NULL_SHA384,TLS_PSK_WITH_NULL_SHA256"

$insecureCiphers = $secureCiphers + ",TLS_RSA_WITH_DES_CBC_SHA,TLS_RSA_WITH_3DES_EDE_CBC_SHA,TLS_RSA_WITH_RC4_128_SHA,TLS_RSA_WITH_RC4_128_MD5,TLS_RSA_EXPORT1024_WITH_DES_CBC_SHA,TLS_RSA_EXPORT1024_WITH_RC4_56_SHA,TLS_RSA_EXPORT_WITH_RC2_CBC_40_MD5,TLS_RSA_EXPORT_WITH_RC4_40_MD5,SSL_RSA_WITH_DES_CBC_SHA,SSL_RSA_WITH_3DES_EDE_CBC_SHA,SSL_RSA_WITH_RC4_128_SHA,SSL_RSA_WITH_RC4_128_MD5,SSL_RSA_EXPORT1024_WITH_DES_CBC_SHA,SSL_RSA_EXPORT1024_WITH_RC4_56_SHA,SSL_RSA_EXPORT_WITH_RC2_CBC_40_MD5,SSL_RSA_EXPORT_WITH_RC4_40_MD5"

# Registry paths
$cipherRegistryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002"
$gpoCipherBasePath = "HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL"

# Ensure the registry path exists
if (-not (Test-Path $cipherRegistryPath)) {
    New-Item -Path $cipherRegistryPath -Force | Out-Null
}

# Select the appropriate cipher list
$cipherSelection = if ($secureConfig) {
    Write-Output "Applying secure cipher suite configuration..."
    $secureCiphers
} else {
    Write-Output "Applying insecure cipher suite configuration..."
    $insecureCiphers
}

# Apply the cipher suite settings to the registry
Set-ItemProperty -Path $cipherRegistryPath -Name "Functions" -Value $cipherSelection

# Ensure GPO base path and apply cipher configuration again for policy enforcement
if (-not (Test-Path "$gpoCipherBasePath\00010002")) {
    New-Item -Path $gpoCipherBasePath -Name "00010002" -Force | Out-Null
}

Set-ItemProperty -Path "$gpoCipherBasePath\00010002" -Name "Functions" -Value $cipherSelection

# Enable the cipher suite ordering policy
Set-ItemProperty -Path "$cipherRegistryPath" -Name "Enabled" -Value 1

# Output results
Write-Output "`nCipher suite configuration has been successfully updated to:"
(Get-ItemProperty -Path $cipherRegistryPath -Name "Functions").Functions

Write-Output "`nA system restart is required for changes to take full effect."
