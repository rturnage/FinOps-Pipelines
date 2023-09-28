# Security

## Securables
The following table describes the securable components of the solution and how access control is implemented.


|Securable|Security|Notes|
---|---|---|
|Azure Advisor Recommendations REST API|Azure Active Directory OAuth2 Flow|The solution uses an Azure Active Directory service principal to call this API|
|Azure Cost Management Exports REST API|Azure Active Directory OAuth2 Flow|The solution uses an Azure Active Directory service principal to call this API|
|Azure Consumption REST API|Azure Active Directory OAuth2 Flow|The solution uses an Azure Active Directory service principal to call this API|
|Azure SQL Server|Azure Active Directory & SQL Authentication|An administrative SQL Authentication user with sysadmin permissions is created during deployment.  You provide a complex password for this user at deployment time.  An Azure Active Directory Server administrator is configured at deployment time. This administrative account is never used by operational processes.|
|Azure SQL Database|Azure Active Directory & SQL Authentication| Two database roles are created to encapsulate the two main access modes required. You can choose to use SQL Users or AAD users when report readers connect to the database.  You will need to create these users and manage credentials manually.|
|Azure Storage Account|Azure Active Directory & Shared Key| The Azure Data Factory managed Identity is granted storage blob data contributor rights at deployment time. The Power BI report uses a Storage Account Key to access the stored data files.|
|Azure Key Vault|Azure Active Directory|The Azure Data Factory Managed Identity is granted access to the secrets in the keyvault at deployment time.|



## Pre-requisites

Pre-requisite steps 1 & 2 must be completed by a user who has the **User Access Administrator** Azure RBAC Role at the tenant level:
Pre-requisite step 3 must be completed by a user who has the **EA Admin** role:

1. Create a custom RBAC Role with the following permissions
	- Microsoft.Advisor/generateRecommendations/action
	- Microsoft.Advisor/recommendations/read
	- Microsoft.Advisor/register/action **Still checking this one**
	- Microsoft.Resources/subscriptions/read

2. Create an Azure Active Directory Service Principal and assign to the custom role created in step 1.

3. Add the service principal to the EA Reader role
	This will give it permissions to see cost data for the entire tenant and also to manage cost management exports
	https://docs.microsoft.com/en-us/azure/cost-management-billing/manage/assign-roles-azure-service-principals


## Deployment
The user performing the solution deployment requires at least **OWNER** permissions on a single resource group.  OWNER permissions are required to assign security principals to Azure RBAC roles.
Once the deployment is complete, OWNER permissions can be removed.

Typical Roles required for managing the solution.  These roles can be performed by a single individual.

### Azure Platform Administrator
**Contributor** permissions on the resource group are required for the following administrative tasks
	Can deploy management plane changes to the Azure infrastructure/services
		e.g. scale/configure the SQL Database
		     Update key vault secrets
	Can delete solution components
	No default permissions to access the data in the storage account are needed.
	No default permissions to the Power BI service are needed
	No default permissions to access the secrets in KeyVault are needed.


**Owner** permissions on at least a resource group are required for the following administrative tasks
	Can provide access to manage Azure infrastructure/services


### Power BI Administrator
This solution does not provide any automated deployment/publishing of Power BI reports.
A Power BI **admin** user will need to create a workspace (and optionally an App).
A Power BI **admin** user will need to manage workpace permissions/roles
A Workspace **contributor** will need to manually publish the report to the workspace.
If you have deployed an app then an admin can delegate permissions for contributors to update Apps.


### Data Engineer
Can make changes to the data factory logic and create/update pipelines.
Can't create/update/delete azure resources.
Can't create/delete PBI workspace/app.
Can't assign users to Azure RBAC roles

Requires **Data Factory Contributor** Azure RBAC role permissions.
Requires **Storage Blob Data Contributor** Azure RBAC role permissions.
Requires **CostManagementDataReader** database role permissions. Note this is not an Azure RBAC role.

### Reporting Analyst
Can amend and upload new reports to a shared Power BI workspace
Can query the SQL Database with read-only access to the data.
Requires Power BI workspace **Contributor** permissions.  If you have created an App for the workspace, then contributors can only publish changes if an administrator has explicitly granted permissions for contributors to amend Apps.
Requires CostManagementDataReader **database** role permissions
Users that want to read data from the files in the Azure storage account will need to be added to the **Storage Blob Data Reader** Azure RBAC role
Users will need to be given a Storage Account Key so that the data source connection can be set up in Power BI Desktop and in the service.

### Operations
Can view Data Factory Job Runs and restart jobs
Can view Cost Management Exports and status

Requires **CostManagementDataReader** database role permissions. Note this is not an Azure RBAC role.
Requires **Data Factory Contributor** Azure RBAC role permissions although you may want to restrict permissions further using a custom role.
