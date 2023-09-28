#########################################################
#
# To run this script you will need Az powershell modules,
#
#
#
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
    [Parameter(mandatory)][string] $ResourceLocation,
    [Parameter(mandatory)][string] $EnrollmentNumber,
	[Parameter()][string] $StorageContainerName,
    [Parameter()][string] $DeploymentTenantId,
    [Parameter()][string] $PricesheetSubscriptionId
     )

#########################################################
# Validate Parameters
#########################################################


#Template File name path for datafactory Ensure that the path is correct
$TemplateFileName=".\ArmTemplate\DataFactory\ARMTemplateForFactory.json"

if ($DeploymentTenantId -eq ""){
    Write-Host '$DeploymentTenantId not supplied, deploying to CostOptimizationTenantId' -ForegroundColor Yellow
    $DeploymentTenantId = $CostOptimizationTenantId
}

if ($PricesheetSubscriptionId -eq ""){
    Write-Host '$PricesheetSubscriptionId not supplied, PriceSheet API will be called with Subscription Scope: $StorageAccountSubscriptionId' -ForegroundColor Yellow
    $PricesheetSubscriptionId = $StorageAccountSubscriptionId
}

if ($StorageContainerName -eq ""){
    Write-Host '$StorageContainerName not supplied, using default value costopt' -ForegroundColor Yellow
    $StorageContainerName = "costopt"
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

Write-Host "Deploying all resources" -ForegroundColor Green

Set-AzContext -TenantId $DeploymentTenantId -SubscriptionId $StorageAccountSubscriptionId -ErrorAction SilentlyContinue -ErrorVariable setContextError 2> $null
if($setContextError){
	Write-Host "Couldn't get context, connect to Azure....." -ForegroundColor Green
	connect-azaccount -TenantId $DeploymentTenantId -SubscriptionId $StorageAccountSubscriptionId
	Set-AzContext -TenantId $DeploymentTenantId -SubscriptionId $StorageAccountSubscriptionId
}
Write-Host "Deploying Data Factory" -ForegroundColor Green
New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroup -TemplateFile $TemplateFileName  -TemplateParameterObject $adf_template_params
