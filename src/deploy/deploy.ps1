#########################################################
#
# To run this script you will need Az powershell modules,
# the Azure CLI and the sqlserver powershell module
# Run in x64 Powershell as an administrator
# You may need to set the execution policy to be able to run this script
# e.g. Set-ExecutionPolicy -ExecutionPolicy Unrestricted
#
#
#########################################################
param (
    [Parameter(mandatory)][string] $CostOptimizationTenantId,
    [Parameter(mandatory)][string] $StorageAccountSubscriptionId,
    [Parameter(mandatory)][string]  $ResourceGroup,
    [Parameter(mandatory)][string]  $DataFactoryName,
    [Parameter(mandatory)][string] $keyvaultname,
    [Parameter(mandatory)][string] $StorageAccountName,
    [Parameter(mandatory)][string] $SQLServerName,
    [Parameter(mandatory)][string] $SQLDBName,
    [Parameter(mandatory)][string] $SQLAdminUserName,
    [Parameter(mandatory)][string] $ResourceLocation,
    [Parameter(mandatory)][SecureString]$SQLAdminPassword,
    [Parameter(mandatory)][string] $ServicePrincipalClientId,
    [Parameter(mandatory)][SecureString]$ServicePrincipalSecret,
    [Parameter(mandatory)][string] $EnrollmentNumber,
    [Parameter()][string] $DeploymentTenantId,
    [Parameter()][string] $PricesheetSubscriptionId,
    [Parameter()][string] $firewallRuleName,
    [Parameter()][bool] $ServicePrincipalAsSQLAdmin,
    [Parameter()][string] $StorageContainerName,
    [Parameter()][string] $RegionsBlobPath
     )


#########################################################
# Validate Parameters
#########################################################

if ($DeploymentTenantId -eq ""){
    Write-Host '$DeploymentTenantId not supplied, deploying to CostOptimizationTenantId' -ForegroundColor Yellow
    $DeploymentTenantId = $CostOptimizationTenantId
}

if ($PricesheetSubscriptionId -eq ""){
    Write-Host '$PricesheetSubscriptionId not supplied, PriceSheet API will be called with Subscription Scope: $StorageAccountSubscriptionId' -ForegroundColor Yellow
    $PricesheetSubscriptionId = $StorageAccountSubscriptionId
}

if ($firewallRuleName -eq ""){
    Write-Host 'firewallRuleName not supplied, using default value' -ForegroundColor Yellow
    $firewallRuleName = "fw_cost_optimization"
}

if ($ResourceGroup -notmatch "^[-\w\._\(\)]{1,90}$") {
   throw "Invalid Resource Group Name supplied: $ResourceGroup"

}

if ($DataFactoryName -notmatch "^[a-zA-Z0-9][a-z0-9-]{1,61}[a-zA-Z0-9]$") {
   throw "Invalid Datafactory Name supplied: $DataFactoryName"

}


if ($keyvaultname -notmatch "^[a-zA-Z](?=[a-zA-Z0-9-]{2,21})(?:[a-z0-9]|[-](?![-])){1,21}[a-z0-9]$") {
   throw "Invalid KeyVault Name supplied: $keyvaultname"

}

if ($StorageAccountName -notmatch "^[a-z0-9]{3,24}$") {
   throw "Invalid Storage Account Name supplied: $StorageAccountName"

}

if ($SQLServerName -notmatch "^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$") {
   throw "Invalid SQL Server Name supplied: $SQLServerName"

}

if ($SQLDBName -notmatch "^[a-z0-9][a-z0-9-]{1,126}[a-z0-9]$") {
   throw "Invalid SQL database name supplied: $SQLDBName"

}

if ($firewallRuleName -notmatch "^[^<>*%&:;\/\\?]{1,127}[^\.^<>*%&:;\/\\?]$") {
   throw "Invalid firewall rule name supplied: $firewallRuleName"

}
if ($SQLAdminUserName -eq ""){
    Write-Host '$SQLAdminUserName not supplied, using default value SQLAdmin' -ForegroundColor Yellow
    $SQLAdminUserName = "SQLAdmin"
}

if ($StorageContainerName -eq ""){
    Write-Host '$StorageContainerName not supplied, using default value costopt' -ForegroundColor Yellow
    $StorageContainerName = "costopt"
}

if ($RegionsBlobPath -eq ""){
    Write-Host '$RegionsBlobPath not supplied, using default value download/regions/azure regionsv2.json' -ForegroundColor Yellow
    $RegionsBlobPath = "download/regions/azure regionsv2.json"
}


$adf_template_params = @{
    dataFactory_factoryName = $DataFactoryName
    factoryName = $DataFactoryName
    dataFactory_properties_globalParameters_costopt_sqlservername_value = $SQLServerName
    dataFactory_properties_globalParameters_costopt_sqldbname_value = $SQLDBName
    dataFactory_properties_globalParameters_costopt_KeyVaultName_value = $keyvaultname
    dataFactory_properties_globalParameters_costopt_StorageAccountName_value = $StorageAccountName
    dataFactory_properties_globalParameters_costopt_StorageAccountSubscriptionId_value = $StorageAccountSubscriptionId
    dataFactory_properties_globalParameters_costopt_PriceSheetSubscriptionId_value = $PricesheetSubscriptionId
    dataFactory_properties_globalParameters_costopt_ResourceGroupName_value = $ResourceGroup
    dataFactory_properties_globalParameters_costopt_EnrollmentNumber_value = $EnrollmentNumber
    dataFactory_properties_globalParameters_costopt_Container_value = $StorageContainerName
    dataFactory_location = $ResourceLocation
    AubiSQLDatabase_connectionString = "Integrated Security=False;Encrypt=True;Connection Timeout=30;Data Source=@{linkedService().servername}.database.windows.net;Initial Catalog=@{linkedService().databasename}"
}

$rg_params = @{
    rgName = $ResourceGroup
    rgLocation = $ResourceLocation
}

$myIp = (Invoke-WebRequest -uri "https://api.ipify.org/" -UseBasicParsing).Content
Write-Host "Deployment IP Address: $myIp" -ForegroundColor Green

$others_template_params= @{
    factoryName = $DataFactoryName
    SqlServerName = $SQLServerName
    SqlDbName = $SQLDBName
    KeyVaultName = $keyvaultname
    StorageAccountName = $StorageAccountName
    sql_database_size=107374182400
    sql_database_minvcores="0.5"
    sql_database_maxvcores=4
    sql_database_admin=$SQLAdminUserName
    sql_database_admin_password=$SQLAdminPassword
    CostOptServicePrincipalClientId=$ServicePrincipalClientId
    CostOptServicePrincipalSecret=$ServicePrincipalSecret
    CostOptTenantId=$CostOptimizationTenantId
    firewallrulename=$firewallRuleName
    firewallstartip=$myIp
    firewallendip=$myIp
}

#Set SQL Server Firewall to current public IP address.
#If you have trouble with this step and the IP returned is not the same at the one that is
#set then it may be that your VPN is advertising a different IP address
#Set the firewall rule as shown in the error and re-run this script.

Write-Host "Deploying all resources" -ForegroundColor Green

Write-Host "Checking for existing context....." -ForegroundColor Green
Set-AzContext -TenantId $DeploymentTenantId -SubscriptionId $StorageAccountSubscriptionId -ErrorAction SilentlyContinue -ErrorVariable setContextError 2> $null
if($setContextError){
	Write-Host "Couldn't get context, connect to Azure....." -ForegroundColor Green
	connect-azaccount -TenantId $DeploymentTenantId -SubscriptionId $StorageAccountSubscriptionId
	Set-AzContext -TenantId $DeploymentTenantId -SubscriptionId $StorageAccountSubscriptionId
}

Write-Host "Trying to set CLI context to our subscription......" -ForegroundColor Green
az account set -s $StorageAccountSubscriptionId 2> $null

if($? -eq $false){
    Write-Host "Could not set subscription. Login......" -ForegroundColor Green
    az login --tenant $DeploymentTenantId --output none
}
Write-Host "Setting CLI context to SubscriptionId......" -ForegroundColor Green
az account set -s $StorageAccountSubscriptionId


Write-Host "Deploying Resource Group" -ForegroundColor Green
New-AzDeployment -Location $ResourceLocation -TemplateFile ".\ArmTemplate\Others\aubiresourcegroup_ARM_Template.json" -TemplateParameterObject $rg_params

Write-Host "Deploying Data Factory" -ForegroundColor Green
New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroup -TemplateFile ".\ArmTemplate\DataFactory\ARMTemplateForFactory.json"  -TemplateParameterObject $adf_template_params

Write-Host "Deploying other resources" -ForegroundColor Green
New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroup -TemplateFile ".\ArmTemplate\Others\OtherResources_ARM_Template.json" -TemplateParameterObject $others_template_params

Write-Host "Getting list of Azure Regions" -ForegroundColor Green

az account list-locations > .\"azure regionsv2.json"

Write-Host "Uploading Regions file to Storage Account" -ForegroundColor Green

$storageAccountObj = get-AzStorageAccount -ResourceGroupName $ResourceGroup -Name $StorageAccountName
$ctx= $storageAccountObj.Context

# upload a file to the default account (inferred) access tier
Set-AzStorageBlobContent -File ".\azure regionsv2.json" -Container $StorageContainerName -Blob $RegionsBlobPath -Context $ctx -Force

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
	$AADAdminDisplayName = az ad signed-in-user show --query displayName --output tsv
	$AADAdminObjectId = az ad signed-in-user show --query id --output tsv
	Write-Host "Getting Access Token to run database script" -ForegroundColor Green
	$token = (Get-AzAccessToken -ResourceUrl https://database.windows.net).Token
}

Write-Host "Setting SQL Database AAD Admin to: $AADAdminDisplayName" -ForegroundColor Green

az sql server ad-admin create --resource-group $ResourceGroup --server $SQLServerName --display-name $AADAdminDisplayName --object-id $AADAdminObjectId

$VarsStringArray = "DATAFACTORYMSI="+$DataFactoryName

Write-Host "Running Database schema script" -ForegroundColor Green
Invoke-Sqlcmd -InputFile "./sql/init_sqldb.sql" -AccessToken $token -Variable $VarsStringArray -ServerInstance "$SQLServerName.database.windows.net" -Database $SQLDBName
Write-Host "Completed Running Database schema script" -ForegroundColor Green

Write-Host "Creating Database user for Data Factory Managed Identity ** Requires SQL Server AAD Admin ** " -ForegroundColor Green

Invoke-Sqlcmd -InputFile "./sql/init_sqldb_adfuser.sql" -AccessToken $token -Variable $VarsStringArray -ServerInstance "$SQLServerName.database.windows.net" -Database $SQLDBName

Write-Host "Registering Microsoft.CostManagementExports resource provider" -ForegroundColor Green
Register-AzResourceProvider -ProviderNamespace Microsoft.CostManagementExports

Write-Host "Complete" -ForegroundColor Green
