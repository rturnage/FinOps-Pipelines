#########################################################
#
# To run this script you will need Az powershell modules,
# the Azure CLI and the sqlserver powershell module
#
#
#
#
#########################################################
param (
    [Parameter(mandatory)][string] $DeploymentTenantId,
    [Parameter(mandatory)][string] $DeploymentSubscriptionId,
    [Parameter(mandatory)][string]  $ResourceGroup,
    [Parameter(mandatory)][string] $SQLServerName,
    [Parameter(mandatory)][string] $SQLDBName,
    [Parameter(mandatory)][string] $DataFactoryName
     )

$myAzconn = connect-azaccount -TenantId $DeploymentTenantId -SubscriptionId $DeploymentSubscriptionId
Set-AzContext -TenantId $DeploymentTenantId -SubscriptionId $DeploymentSubscriptionId

$myIp = (Invoke-WebRequest -uri "https://api.ipify.org/" -UseBasicParsing).Content

#az sql server firewall-rule create -g $ResourceGroup -s $SQLServerName -n DeploymentIP --start-ip-address $myIp --end-ip-address $myIp

Set-AzSqlServer -ResourceGroupName $ResourceGroup -ServerName $SQLServerName -AssignIdentity

$AADAdminDisplayName = ""
$AADAdminObjectId = ""
$token = ""
$dexResourceUrl='https://database.windows.net/'

if ($ServicePrincipalAsSQLAdmin -eq $true){
	Write-Host "Using Service Principal as SQL Admin" -ForegroundColor Green
	[pscredential]$credObject = New-Object System.Management.Automation.PSCredential ($ServicePrincipalClientId, $ServicePrincipalSecret)

	$AADSP = Get-AzADServicePrincipal -ApplicationId $ServicePrincipalClientId
	if ($AADSP -eq ""){
		throw "Could not find Service Principal for ApplicationId: $ServicePrincipalClientId"
	}
	#Login to az cli using the service principal to obtain an access token for the database
	az login --service-principal -u $credObject.UserName -p $credObject.GetNetworkCredential().Password --tenant $DeploymentTenantId
	Write-Host "Getting Access Token to run database script" -ForegroundColor Green
	$token = az account get-access-token --resource $dexResourceUrl --query accessToken --output tsv

	$AADAdminDisplayName = $AADSP.DisplayName
	$AADAdminObjectId = $AADSP.Id
}
else {
	Write-Host "Using Logged In User as SQL Admin" -ForegroundColor Green
	$SQLAdminUPN = az account show --query user.name --output tsv


	$AADAdminDisplayName = az ad signed-in-user show --query displayName --output tsv


	$AADAdminObjectId = az ad signed-in-user show --query objectId --output tsv

	Write-Host "Getting Access Token to run database script" -ForegroundColor Green
	$token = az account get-access-token --resource $dexResourceUrl --query accessToken --output tsv

}

Write-Host "Setting SQL Database AAD Admin to: $AADAdminDisplayName" -ForegroundColor Green

az sql server ad-admin create --resource-group $ResourceGroup --server $SQLServerName --display-name $AADAdminDisplayName --object-id $AADAdminObjectId

$VarsStringArray = "DATAFACTORYMSI="+$DataFactoryName

Write-Host "Running Database schema script" -ForegroundColor Green
Invoke-Sqlcmd -InputFile "./sql/init_sqldb.sql" -AccessToken $token -Variable $VarsStringArray -ServerInstance "$SQLServerName.database.windows.net" -Database $SQLDBName

Write-Host "Completed Running Database schema script" -ForegroundColor Green

Write-Host "Creating Database user for Data Factory Managed Identity ** Requires SQL Server AAD Admin ** " -ForegroundColor Green

Invoke-Sqlcmd -InputFile "./sql/init_sqldb_adfuser.sql" -AccessToken $token -Variable $VarsStringArray -ServerInstance "$SQLServerName.database.windows.net" -Database $SQLDBName
