# Demo Instance Metadata Service (IMDS)
# -------------------------------------
# 1) What is IMDS?
# 2) Call IMDS Api to get information about compute and networking
# 3) Call IMDS Api to get a Managed Identity OAuth token
# 4) Create a resource (routing table) in Azure using the OAuth token

# Calling REST Api IMDS - No authentication, no encryption
$uri = "http://169.254.169.254/metadata/instance?api-version=2021-01-01"

$response = Invoke-RestMethod -Headers @{"Metadata"="true"} -Method GET -Proxy $null -Uri $uri

# Response contains two properties 'compute' and 'network'
$response | Format-List

# Response is a nice PowerShell object. Yoy can convert it into json
$response | ConvertTo-Json -Depth 6

$response | Get-Member -MemberType Properties

# What information can I get from IDMS? Some examples:
$response.compute
$response.compute.resourceGroupName
$response.compute.resourceId
$response.compute.location
$response.compute.vmSize
$response.network
$response.network.interface.macaddress
$response.network.interface.ipv4.ipAddress.privateIpAddress

# Calling REST Api for OAuth 2.0 token
$uri = 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fmanagement.azure.com%2F'

$response = Invoke-RestMethod -Headers @{"Metadata"="true"} -Method GET -Proxy $null -Uri $uri

# Response contains a bearer token
$response
$token = $response.access_token

# $token > $HOME/Desktop/token.txt
# Inspect token at https://jwt.ms

$Header = @{
    "authorization" = "Bearer $token"
}

$subscriptionId = '6d8a949f-78ab-45f4-909a-1a97c83b5735'

$uri = "https://management.azure.com/subscriptions/$subscriptionId/resourcegroups?api-version=2017-05-10"

$response = Invoke-RestMethod -Method Get -Uri $uri -Headers $Header
$response.value

Invoke-RestMethod -Method Get 

# Service Principal (SP) VM1
# --------------------------
# List all SPs
az ad sp list --all --query "sort_by([].{displayName:displayName,appId:appId,publisherName:publisherName}, &displayName)" --output table

# List SP 'VM1' only
az ad sp list --all --query "[?displayName=='VM1'].{displayName:displayName,objectId:objectId,appId:appId,publisherName:publisherName}"
az ad sp list --display-name 'VM1' --query "[].{displayName:displayName,objectId:objectId,appId:appId,publisherName:publisherName}"

# Get SP's objectId
$spObjectId = $(az ad sp list --all --query "[?displayName=='VM1'].[objectId]" --output tsv)

# Get details of SP
az ad sp show --id $spObjectId
az ad sp show --id $spObjectId --query "{objectType:objectType,servicePrincipalType:servicePrincipalType}"


