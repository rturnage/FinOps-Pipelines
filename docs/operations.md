[Back](./readme.md)

# Operations

## Cost Management Exports

Use the instructions in the [deployment guide](./deployment.md) to create cost management exports


## Data Factory

### Initial load

You can use the UsageExportOrchestrator pipeline to populate the reporting database with large amounts of historical data.
Trigger a one-off run of this pipeline with the following parameters:

|Parameter|Value|Description|
---|---|---|
|exportName_prefix|msftxportUsageInitial|Cost Management Exports will be created with this prefix|
|scope|providers/Microsoft.Billing/billingAccounts/<BillingAccountNum>|Sets scope to the top level billing account|
|CostManagementApiVersion|2021-01-01||
|UsageDownload_StorageBlobDirectory|download/usage/initialload|Cost Management Exports will be stored here|
|UsageDownload_StorageBlobContainer|aubi|Cost Management Exports will be stored here|
|MaxExportExecutionRetries|3||
|StartDate|<Start Date>|YYYY-MM-DD format|
|EndDate|<Current Date>|YYYY-MM-DD format|
|ExportTimeframe|Custom||
|ExportTypeArray|["ActualCost","AmortizedCost"]|Copy string as shown (including square brackets)|
|StorageAccountResourceGroup|<ResourceGroupName>|Resource Group used for deployment|
|StorageAccountSubscriptionId|<StorageAccountSubscriptionId>|SubscriptionId used for deployment|
|ExportStatusCheckLoopTime|60|Configures how often the pipeline polls to see if export has completed|
|DateRangeInterval|14|Configures the export data range length.  Smaller number will result in more exports|


### Incremental Load
If you have chosen to create Daily Month-to-Date Cost Management Exports for Amortized and Actual Costs, then use the following steps to add a daily trigger for the RefreshAllData_ExistingExports pipeline


1. Navigate to and open Data Factory Studio.
2. Under Factory Resources, expand the Pipelines resources and select the RefreshAllData_ExistingExports pipeline.
3. On the design canvas menu, select "Add Trigger" --> "New/Edit"
4. On the Add Traggers blade, select "Choose Trigger" --> "+ New"
5. Enter a name for the trigger e.g. DailyOvernightProcessing
6. Enter the following configuration values:

|Configuration Item|Value|
---|---|
|Type|Schedule|
|Start Date|e.g. < Tomorrows date, 1AM >|
|Time zone| < Select your time zone >|
|Recurrence|Every 1 Day|

7. Ensure that "Start trigger on creation" is selected
8. Click on OK
9. Fill in the following parameters:

|Parameter|Value|
---|---|
|FullRefreshStartDate|The same start date used for the full load|
|aubi_StorageContainerName|aubi|
|aubi_StorageDirectoryName|download|
|AdvisorGenerationWaitSecs|600|
|CostManagementExportsAPIVersion|2021-01-01|
|ConsumptionAPIVersion|2019-10-01|
|AdvisorAPIVersionGenerateRecs|2017-04-19|
|AdvisorAPIVersionGetRecs|2020-01-01|
|CostMangementReservationDetailsAPIVersion|2019-11-01|
|UsageExportDirectory|download/usage/scheduled_exports|

10. Click Save
11. Click Publish


## Power BI

### Publishing the Power BI report to a shared Workspace
1. Open the pbit file using Power BI desktop and enter the relevant parameters as per the [Power BI guide](./powerbi.md).
2. In power BI, log in to your Power BI tenant
3. Publish the report to a shared workspace.
4. Navigate to the shared workspace and edit the data source credentials for the report dataset. You will need to input a SQL credentials and also a storage account key.
5. Set up a daily scheduled refresh.  The time should be set to a few hours after the Data Factory pipeline trigger. [Scheduled Refresh Docs](https://docs.microsoft.com/en-us/power-bi/connect-data/refresh-scheduled-refresh#scheduled-refresh)

#### Note:
You have two options when setting up SQL credentials in step 4 above, in **settings** for the dataset, under **Data source credentials**, click on **Edit credentials**, under **Authentication method**
  1. If you choose "basic" in the dropdown, input your sql username and password, power bi will use the service account to connect to your sql database directly. If you prefer to use AAD to authenticate, use option 2 instead.
  2. If you choose "OAuth2" in the dropdown
  - A. If you do not check the box **Report viewers can only access this data source with their own Power BI identities using DirectQuery**, Power BI will use your AAD credentials to authenticate against SQL database no matter who is accessing the Power BI report.
  - B. If you do check the box **Report viewers can only access this data source with their own Power BI identities using DirectQuery**, Power BI will use the AAD credentials of report viewer to authenticate against SQL database. By doing this, you will have more control in who has access to the data compared to "basic" amd "Oauth2" option A. However you will have the additional maintenance overhead to give report viewers access to the underlying SQL database.


## Storage Account
The export files written to storage are deleted by the daily data factroy processing.  If the files build up (e.g. if the data factory pipelines dont run for a few days) then it may be necessary to manually clear up files.
The exports generated by the provided deployment script generate "Month to Date" files.  This means that the files generated throughout the month contain all the data from the 1st up to the current day.
i.e.
The files generated on the 10th Jan contain data from the 1st --> 10th Jan.
The files generated on the 11th Jan contain data from the 1st --> 11th Jan.

It is therefore only necessary to load the latest file for any given month.


## Key Vault

The app registration secret may need to be updated periodically if secrets are configured with expiry dates
The enrollmentId may need to be updated if the EnrollmentId changes (e.g. due to a new agreement)
