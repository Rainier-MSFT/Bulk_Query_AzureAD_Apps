$appids= Get-Content -path "c:\SHA\appids.txt"
#$appids = "76fefbf3-9ae0-46c9-a6b3-110a19c40226","e25f6207-1931-4268-bc03-262947c21830","061905c8-2100-435d-b7f1-217fd00c12f1"

# Get tenant details to test that Connect-AzureAD has been called
try {
    $tenant_details = Get-AzureADTenantDetail
} catch {
    throw "You must call Connect-AzureAD before running this script."
}
Write-Verbose ("TenantId: {0}, InitialDomain: {1}" -f `
                $tenant_details.ObjectId, `
                ($tenant_details.VerifiedDomains | Where-Object { $_.Initial }).Name)

$i = 1
$App_List = @()
$count = $appids.count
Foreach ($appid in $appids)
{
    Write-Progress -Activity "Getting $($appid.DisplayName) App information" -Status "$i of $count" -PercentComplete ($i/$count*100)
      try {
            $f5apps = Get-AzureADApplication -Filter "AppId eq '$appid'" -ErrorAction Stop
            $result = " " | Select-Object DisplayName, ObjectId, AppId, HomePage, ReplyUrls
            $result.DisplayName = $($f5apps.Displayname)
            $result.ObjectId = $($f5apps.ObjectId)
            $result.AppId = $($f5apps.AppId)
            $result.HomePage = $($f5apps.HomePage)
            $result.ReplyUrls = $($f5apps.ReplyUrls)
            $App_List += $result
          }
      catch {   
             $Problem = $PSItem.exception.message         
            }
    $i++
}

$App_List | Out-GridView
