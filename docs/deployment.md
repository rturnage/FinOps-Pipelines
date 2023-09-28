[Back](./readme.md)
# Deploying the Cost Optimization Solution

## Prerequisites
* Az Powershell modules https://docs.microsoft.com/en-us/powershell/azure/new-azureps-module-az
* Azure CLI https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
	* Tested with version 2.39
* SqlServer Powershell module https://www.powershellgallery.com/packages/SqlServer/
* Create a service principal and grant relevant permissions to the cost management and consumption APIs.
* Generate a secret for this Service Principal and note the value down for later use. If you configure an expiry date for this secret, it is your responsibility to refresh the secret value before the expiry date.
* Resource names and SQL Server Admin Password complexity is NOT FULLY validated before attempting to deploy.
* The Managed Service Identity for Azure Data Factory is used to authenticate against the database.  For this to work the AAD Administrator for the SQL Server must either:
    1. Be an AAD user/group account
    2. Be an AAD Service Principal which is a member of the Directory Readers Role
If the deployment fails due to resource name conflicts or password complexity requirements then amend
the parameters and try again.

## Deployment Options

It is important to understand the options you have when running the daily data extraction and loading processes.
### Pipelines dynamically create and run exports:

Azure Data Factory pipelines will dynamially create the cost management exports as needed. The service principal used needs to have permissions over the target blob storage account.

If this service principal does not have permissions to the target storage account (perhaps because it is in a different tenant), then the usage data pipeline runs will fail.

This option has the potential to leave orphaned cost management exports in your tenant if errors occur.  These can be deleted manually.

### Pipelines assume exports have run
> This is the recommended option if you are deploying Azure resources to a different tenant to the tenant you are analysing

You can pre-create the relevant Cost Management exports using the relevant deployment script and then schedule the ADF Pipeline that loads the exported data.
This avoids the need for the service principal to have permissions over the target storage account. However, you must ensure that the exports are scheduled and executed before the data factpry pipeline to load the data is run.


Once you have decided how the exports are to be created and run, you can decide on the deployment topology.
1. Deploy all Cost Management Exports and all Azure components into the same tenant that you are analysing costs for.
2. Deploy all Cost Management Exports into the tenant that you are analysing costs for BUT deploy all other Azure components into a different tenant.

## Deployment Tools
1. [Deploy the entire solution](#deploy-the-entire-solution)

Use this option to perform a completely fresh deployment to a subscription.

You can also use this option to deploy over the top of a previous deployment.

This script will drop and recreate objects in the database.  Existing database tables containing data will be dropped.

Files in the Azure Blob Storage Account will not be deleted.

2. [Deploy the Data Factory only](#deploy-the-data-factory-only)

Use this option to deploy only the data factory component.  This is useful if you have lots of data in the database that you dont want to lose.

3. [Create Cost Management Exports](#create-cost-management-exports)

This deployment option deploys two Cost Management Export definitions configured at the billing account scope.

Use this if you dont want the solution to dynamially create Cost Management exports for each run.


## Deploy the Entire Solution
1. Extract the CostManagement.zip file to a location on your deployment machine
2. Edit the powershell command below, setting the parameters as required

    * CostOptimizationTenantId - The TenantId that you want to analyse for cost optimizations
    * StorageAccountSubscriptionId - the SubscriptionId into which this solution will be deployed
    * ResourceGroup - Resources will be deployed to this Resource Group. The Resource Group will be created if it doesn't exist.
    * DataFactoryName - The name of the Data Factory that will be created
    * keyvaultname - The name of the Azure Key Vault that will be created
    * StorageAccountName - The name of the Azure Storage Account that will be created
    * SQLServerName - The name of the Azure SQL Server that will be created
    * SQLDBName - The name of the Azure SQL Database that will be created
    * SQLAdminUserName - The SQL Admin User name
    * ResourceLocation - The Azure region to create all resources in
    * ServicePrincipalClientId - The ClientId of the Service Principal that has been created for accessing the Consumption & Cost Management APIs.
    * EnrollmentNumber - The Billing Account number for your Azure Enrollment.
    * DeploymentTenantId - OPTIONAL - The Azure Tenant into which you are deploying this solution (Defaults to CostOptimizationTenantId)
    * PricesheetSubscriptionId - OPTIONAL - The Subscription scope for calling the PriceSheet api (Defaults to StorageAccountSubscriptionId)
    * firewallRuleName - OPTIONAL - The name of the firewall rule to setup for the SQL Database (Defaults to fwcostoptimization)
    * ServicePrincipalAsSQLAdmin - OPTIONAL - When set to $true, the ServicePrincipal will be used as the SQL Administrator and these credentials will be used to run the SQL Script (Defaults to false).  Ensure that the Service Principal is a member of the Directory Readers role.  https://docs.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-service-principal#enable-service-principals-to-create-azure-ad-users

```
.\deploy.ps1 -CostOptimizationTenantId 72xxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx47 `
	-StorageAccountSubscriptionId 88xxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx7f `
	-ResourceGroup MyResourceGroupName `
	-DataFactoryName MyDataFactoryName `
	-keyvaultname MyKeyVaultName `
	-StorageAccountName MyStorageAcctName `
	-SQLServerName MySQLServerName `
	-SQLDBName MyDatabaseName `
	-SQLAdminUserName SQLAdmin `
	-ResourceLocation westeurope `
	-ServicePrincipalClientId 20xxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx17 `
	-EnrollmentNumber 1xxxx3 `
    	-DeploymentTenantId 72xxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx47 `
    	-PricesheetSubscriptionId 88xxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx7f `
    	-firewallRuleName fwcostoptimization
```

3. Open a powershell commandshell
* Start --> Run --> Powershell

4. Change directory to the location where you extracted the CostManagement.zip file
    e.g.
```
 cd C:\temp\Releases\CostManagement\
```

5. Copy and paste the command that you edited in step 2 and press <Enter> to run it.
If you are pasting secure strings (passwords/secrets) into a Powershell cmd window (not ISE) then note that ctrl-v may not behave as expected. Right click to paste works fine.  Check the number of * characters is as expected.

    * You will be prompted for a SQL Administrator password - Enter a secure complex password.
    * You will be prompted for a Service Principal Secret - Enter the secret generated when you created the service principal (pre-requisites)
    * You will be promoted to sign in to your Microsoft account (this account needs permissions to deploy resources to the Azure Resource Group specified)


## Deploy the Data Factory only
1. Extract the CostManagement.zip file to a location on your deployment machine
2. Edit the powershell command below, setting the parameters as required

    * CostOptimizationTenantId - The TenantId that you want to analyse for cost optimizations
    * StorageAccountSubscriptionId - the SubscriptionId into which this solution will be deployed
    * ResourceGroup - Resources will be deployed to this Resource Group. The Resource Group will be created if it doesn't exist.
    * DataFactoryName - The name of the Data Factory that will be created
    * keyvaultname - The name of the Azure Key Vault that will be created
    * StorageAccountName - The name of the Azure Storage Account that will be created
    * SQLServerName - The name of the Azure SQL Server that will be created
    * SQLDBName - The name of the Azure SQL Database that will be created
    * ResourceLocation - The Azure region to create all resources in
    * EnrollmentNumber - The Billing Account number for your Azure Enrollment.
```
.\deploydatafactory.ps1 -CostOptimizationTenantId 72xxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx47 `
	-StorageAccountSubscriptionId 88xxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx7f `
	-ResourceGroup MyResourceGroupName `
	-DataFactoryName MyDataFactoryName `
	-keyvaultname MyKeyVaultName `
	-StorageAccountName MyStorageAcctName `
	-SQLServerName MySQLServerName `
	-SQLDBName MyDatabaseName `
	-ResourceLocation westeurope `
	-EnrollmentNumber 1xxxx3 `
```

3. Open a powershell commandshell
* Start --> Run --> Powershell

4. Change directory to the location where you extracted the CostManagement.zip file
    e.g.
```
 cd C:\temp\Releases\CostManagement\
```

5. Copy and paste the command that you edited in step 2 and press <Enter> to run it.
If you are pasting secure strings (passwords/secrets) into a Powershell cmd window (not ISE) then note that ctrl-v may not behave as expected. Right click to paste works fine.  Check the number of * characters is as expected.

    * You will be promoted to sign in to your Microsoft account (this account needs permissions to deploy resources to the Azure Subscription and Resource Group specified)


## Create Cost Management Exports
1. Extract the CostManagement.zip file to a location on your deployment machine
2. Edit the powershell command below, setting the parameters as required

    * CostOptimizationTenantId - The TenantId that you want to analyse for cost optimizations
    * StorageAccountSubscriptionId - the SubscriptionId into which this solution will be deployed
    * ResourceGroup - Resources will be deployed to this Resource Group. The Resource Group will be created if it doesn't exist.
    * StorageAccountName - The name of the Azure Storage Account that will be created
    * ResourceLocation - The Azure region to create all resources in
    * ServicePrincipalClientId - The ClientId of the Service Principal that has been created for accessing the Consumption & Cost Management APIs.
    * EnrollmentNumber - The Billing Account number for your Azure Enrollment.
    * ActualCostExportName - Name of the Export to create for Actual Costs - Defaults to msftCostManagementExportActualCost
    * AmortizedCostExportName - Name of the Export to create for Amortized Costs - Defaults to msftCostManagementExportAmortizedCost

# To use a service principal to create the exports:
```
.\CreateExportsBillingAccount.ps1 -CostOptimizationTenantId 72xxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx47 `
	-StorageAccountSubscriptionId 88xxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx7f `
    -ServicePrincipalClientId 20xxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx17 `
	-ResourceGroup MyResourceGroupName `
	-StorageAccountName MyStorageAcctName `
	-EnrollmentNumber 1xxxx3 `
```
# To use your Azure Active Directory User to create the exports:
```
.\CreateExportsBillingAccount.ps1 -CostOptimizationTenantId 72xxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx47 `
	-StorageAccountSubscriptionId 88xxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx7f `
	-ResourceGroup MyResourceGroupName `
	-StorageAccountName MyStorageAcctName `
	-EnrollmentNumber 1xxxx3 `
    [-ActualCostExportName <ActualCostExportName>]
    [-AmortizedCostExportName <AmortizedCostExportName>]

```

3. Open a powershell commandshell
* Start --> Run --> Powershell

4. Change directory to the location where you extracted the CostManagement.zip file
    e.g.
```
 cd C:\temp\Releases\CostManagement\
```

5. Copy and paste the command that you edited in step 2 and press <Enter> to run it.
If you are pasting secure strings (passwords/secrets) into a Powershell cmd window (not ISE) then note that ctrl-v may not behave as expected. Right click to paste works fine.  Check the number of * characters is as expected.

    * You will be promoted to sign in to your Microsoft account (this account needs permissions to deploy resources to the Azure Subscription and Resource Group specified)
