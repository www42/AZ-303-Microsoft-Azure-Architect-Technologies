$RgName = "Web-RG"
$SubscriptionId = "26994ff8-a16e-48ed-9eca-8597519aaa5c"
$RgId    = "/subscriptions/$SubscriptionId/resourceGroups/$RgName"

# Request OAuth 2.0 token
#
$Uri      = "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fmanagement.azure.com%2F"
$Header   = @{"Metadata" = "true"}
$response = Invoke-RestMethod -Headers $Header -Method GET -Proxy $null -Uri $Uri
$token    = $response.access_token



# Enumerate Resources via ARM Api
# See ARM Api Browser  https://docs.microsoft.com/en-us/rest/api/resources/resources/listbyresourcegroup
#
$uri     = "https://management.azure.com$RgId/resources?api-version=2021-04-01"
$Header  = @{"authorization" = "Bearer $token"}
$response = Invoke-RestMethod -Method Get -Uri $uri -Headers $Header
$response.value
