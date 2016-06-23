# Download current list of Azure Public IP ranges
$downloadUri = "https://www.microsoft.com/en-in/download/confirmation.aspx?id=41653"
$downloadPage = Invoke-WebRequest -Uri $downloadUri
$xmlFileUri = ($downloadPage.RawContent.Split('"') -like "https://*PublicIps*")[0]
$response = Invoke-WebRequest -Uri $xmlFileUri

# Get list of regions & public IP ranges
[xml]$xmlResponse = [System.Text.Encoding]::UTF8.GetString($response.Content)
$regions = $xmlResponse.AzurePublicIpAddresses.Region

$selectedRegions =
    $regions.Name |
    Out-GridView `
        -Title "Select Azure Datacenter Regions..." `
        -PassThru

$ipRange =($regions | where-object Name -In $selectedRegions).IpRange

# Build NSG rules
$rules = @()
$rulePriority = 100

$subnetCount = $ipRange.Subnet.Length
Write-Output "Total subnet count: $subnetCount"

<#
ForEach ($subnet in $ipRange.Subnet) {
    Write-Output $subnet
}
#>