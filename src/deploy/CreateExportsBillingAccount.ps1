#########################################################
#
# To run this script you will need Az powershell modules
# If $ServicePrincipalClientId is provided then you will be asked for a service principal secret
# If $ServicePrincipalClientId is NOT provided then you will be asked to log in
#
#
#
#########################################################
param (
    [Parameter(mandatory)][string] $CostOptimizationTenantId,
    [Parameter(mandatory)][string] $StorageAccountSubscriptionId,
    [Parameter(mandatory)][string]  $ResourceGroup,
    [Parameter(mandatory)][string] $StorageAccountName,
    [Parameter(mandatory)][string] $EnrollmentNumber,
    [Parameter()][int] $ExportMonths =12,
    [Parameter()][string] $ServicePrincipalClientId,
    [Parameter()][string] $ActualCostExportName = "msftCostManagementExportActualCost",
    [Parameter()][string] $AmortizedCostExportName = "msftCostManagementExportAmortizedCost"
     )

#########################################################
# Validate Parameters
#########################################################


$CostManagementScope = "providers/Microsoft.Billing/billingAccounts/$EnrollmentNumber"
$DestinationContainerName = "aubi"
$DestinationFolderName = "download/usage/scheduled_exports"

$DefinitionTimeFrame = "MonthToDate"
$Granularity  = "Daily"

Write-Host "Deploying all resources" -ForegroundColor Green

if ($ServicePrincipalClientId -ne ""){
    Write-Host 'Using Service Principal to create cost management exports' -ForegroundColor Yellow
    $ServicePrincipalSecret = read-host "Service Principal Secret" -AsSecureString
    [pscredential]$credObject = New-Object System.Management.Automation.PSCredential ($ServicePrincipalClientId, $ServicePrincipalSecret)

    $myAzconn = Connect-AzAccount -ServicePrincipal -Credential $credObject -Tenant $CostOptimizationTenantId
}
else {
    Write-Host 'Log in to create cost management exports' -ForegroundColor Yellow
    $myAzconn = connect-azaccount -TenantId $CostOptimizationTenantId
    Set-AzContext -TenantId $CostOptimizationTenantId -SubscriptionId $StorageAccountSubscriptionId
}


Write-Host "Creating And Running Cost Management Export" -ForegroundColor Green

$DefinitionType= "ActualCost"
New-AzCostManagementExport -Scope $CostManagementScope -Name $ActualCostExportName -ScheduleStatus "Active" -ScheduleRecurrence "Daily" -RecurrencePeriodFrom (get-date).ToString('s') -RecurrencePeriodTo (get-date).addMonths($ExportMonths).ToString('s') -Format "Csv" -DestinationResourceId "/subscriptions/$StorageAccountSubscriptionId/resourceGroups/$ResourceGroup/providers/Microsoft.Storage/storageAccounts/$StorageAccountName" `  -DestinationContainer $DestinationContainerName -DestinationRootFolderPath $DestinationFolderName -DefinitionType $DefinitionType -DefinitionTimeframe $DefinitionTimeFrame -DatasetGranularity $Granularity
Invoke-AzCostManagementExecuteExport -ExportName $ActualCostExportName -Scope $CostManagementScope



$DefinitionType= "AmortizedCost"
New-AzCostManagementExport -Scope $CostManagementScope -Name $AmortizedCostExportName -ScheduleStatus "Active" -ScheduleRecurrence "Daily" -RecurrencePeriodFrom (get-date).ToString('s') -RecurrencePeriodTo (get-date).addMonths($ExportMonths).ToString('s') -Format "Csv" -DestinationResourceId "/subscriptions/$StorageAccountSubscriptionId/resourceGroups/$ResourceGroup/providers/Microsoft.Storage/storageAccounts/$StorageAccountName" `  -DestinationContainer $DestinationContainerName -DestinationRootFolderPath $DestinationFolderName -DefinitionType $DefinitionType -DefinitionTimeframe $DefinitionTimeFrame -DatasetGranularity $Granularity
Invoke-AzCostManagementExecuteExport -ExportName $AmortizedCostExportName -Scope $CostManagementScope
