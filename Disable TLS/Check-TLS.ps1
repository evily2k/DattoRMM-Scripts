$protocolEnabled = $false

# Check if TLS 1.0 is enabled
$protocols = [System.Net.ServicePointManager]::SecurityProtocol

# TLS 1.0 is enabled if the SecurityProtocol contains Tls or Tls11
if ($protocols -band [System.Net.SecurityProtocolType]::Tls -or
    $protocols -band [System.Net.SecurityProtocolType]::Tls11) {
    $protocolEnabled = $true
}

# Output the result
if ($protocolEnabled) {
    Write-Host "TLS 1.0 is enabled."
    exit 1
} else {
    Write-Host "TLS 1.0 is not enabled."
    exit 0
}
