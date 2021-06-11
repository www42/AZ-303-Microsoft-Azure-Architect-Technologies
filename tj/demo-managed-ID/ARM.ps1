# Request OAuth 2.0 token
#
$Uri      = "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fmanagement.azure.com%2F"
$Header   = @{"Metadata" = "true"}

$response = Invoke-RestMethod -Method GET -Uri $Uri -Headers $Header -Proxy $null
$token    = $response.access_token



# Enumerate Resources via ARM Api
# Cf.  https://docs.microsoft.com/en-us/rest/api/resources/resources/listbyresourcegroup
#
$rgId    = "/subscriptions/26994ff8-a16e-48ed-9eca-8597519aaa5c/resourceGroups/Web-RG"
$Uri     = "https://management.azure.com$rgId/resources?api-version=2021-04-01"
$Header  = @{"authorization" = "Bearer $token"}

$response = Invoke-RestMethod -Method Get -Uri $Uri -Headers $Header
$response.value
