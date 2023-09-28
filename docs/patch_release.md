# Patch Release

Patch releases assume you have already deployed the full solution in your environment.

* Download artifacts
* Update the Infrastructure
* Apply Database Schema changes
* Refresh the Data

## Prerequisites

```bash
# Install azure cli
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# login to azure cli
az login --tenant $TENANT_ID

# Install azcopy
wget https://aka.ms/downloadazcopy-v10-linux
tar -xvf downloadazcopy-v10-linux
rm -Rf downloadazcopy-v10-linux
```

## Download artifacts
```bash
# Download Release Artifacts
wget https://path/to/release/azure_cfm.version

# Unzip files for deployment
# ./script/prep_deployment --file

tar -xvzf /path/to/release/azure_cfm.version.tar.gz
cd /path/to/unzip/release/azure_cfm.version

# Create and Update the environment variables
cp example.env .env
```

## Update Infrastructure

Use the following scripts to deploy changes to the environment. Either call `deploy_all` or each script separately.

|Script | Description |
|-------|-------------|
| `./scripts/deploy_all` | Executes all scripts found in `./scripts/patch/` directory |
| `./scripts/patch/patch_0.1_prereq_test_env_sql` | Creates testing databases `_dev` and `_qa`. <br> Using globals: `"$RESOURCE_GROUP"` <br> `"$SQL_SERVER_NAME"` <br> `"$SQL_DATABASE_NAME"` |
| `./scripts/patch/patch_0.2_prereq_test_env_storage` | Creates testing storage accounts `dev` and `qa`. <br> Using parameters: `--resource-group "$RESOURCE_GROUP"` <br> `--name "${STORAGE_ACCOUNT_NAME}dev"`|
| `./scripts/patch/patch_0.3_prereq_test_env_datafactory` | Creates a Patch Datafactory. <br> Using parameters:  `--resource-group "$PIPELINE_ADF_PATCH_RG"` <br> `--factory-name "$PIPELINE_ADF_NAME"` |
| `./scripts/patch/patch_0.4_prereq_test_env_role_assignment` | Create a Storage Blob Contributor role assignment for the data factory managed identity <br> Using globals:  `"$PIPELINE_ADF_IDENTITY_NAME"` <br> `"$RESOURCE_GROUP"` <br> `"$STORAGE_ACCOUNT_NAME"` |
| `./scripts/patch/patch_issue_35_duplicate_data_data_factory` | Deploys latest changes to `ProcessInboundUsageData` Data Factory Pipeline |

```bash
# Create .env file and update with correct values
cp example.env .env

# Create a "patch datafactory" if not already exists
az datafactory create --resource-group "$PIPELINE_ADF_PATCH_RG" --factory-name "$PIPELINE_ADF_NAME"

# Edit arm template parameters if needed
vi ./pipeline/azure_data_factory_patch/ARMTemplateParametesForFactory.json

# Run patch script to deploy all
./script/deploy_all

# Or Run individual patch script
./script/patch/patch_0.1_prereq_test_env_sql
./script/patch/patch_0.2_prereq_test_env_storage
./script/patch/patch_0.3_prereq_test_env_datafactory
./script/patch/patch_0.4_prereq_test_env_role_assignment
./script/patch/patch_issue_35_duplicate_data_data_factory
```

## Apply SQL Schema Changes
Schema changes require logging onto the Server `$SQL_SERVER_NAME` and running `sql` script files targeting a specific `target_database`:

|Environment | Database Name            |
|------------|--------------------------|
| Dev        | `$SQL_DATABASE_NAME_dev` |
| QA         | `$SQL_DATABASE_NAME_qa`  |
| Prod       | `SQL_DATABASE_NAME`      |


|Script | Description |
|-------|-------------|
| `./sql/deplosp_whoisactive.12.0/sp_whoisactive.12.0.sql` | Helper script use to monitor active queries on the database. |
| `./sql/data_patch_valdate.sql` | Used to validate data after importing data into the database. |
| `./sql/data_patch.sql`         | Script to update data in the database.|
| `./sql/monitor.sql`            | Helper script used to monitor running queries. Uses `sp_whoisactive.12.0.sql` |
| `./sql/schema_patch_0.sql`     | Optional. Creates testing databases `_dev` and `_qa` and permission to ADF managed identity <br> Using globals: `"$PIPELINE_ADF_IDENTITY_NAME"` |
| `./sql/schema_patch_1.sql`     | Clean up database |
| `./sql/schema_patch_2.sql`     | Dynamic staging tables |
| `./sql/schema_patch_3.sql`     | Map Staging Table Columns |
| `./sql/schema_patch_4.sql`     | Update Target table from Staging |

```sql
USE target_database

-- /sql/schema_patch.sql contents
```

## Data Patch

Update data in the database by importing previous `cost_type/month` billing files into the `target_database` by running a pipeline.

* Stage data files for import
* Run the `pre_pipeline` section of the `data_patch.sql` script on the `target_database`
* Initiate the Ingestion Pipeline
* Run the `post_pipeline` section of the `data_patch.sql` script on the `target_database`

### Stage data files for Import

The pipeline will import any files it finds in the staging container. Use the `./script/stage_files` script to copy billing files from a backup container to the staging container.

The `./script/stage_files` uses two files to lookup the billing file name in the backup container.
* `./script/data_files/actual_cost_files`
*  `./script/data_files/amortized_cost_files`

|File | Description |
|-------|-------------|
| `./script/data_files/actual_cost_files` | List of actual cost file names saved in the backup storage account.|
| `./script/data_files/amortized_cost_files` | List of amortized cost file names saved in the backup storage account.|
| `./scripts/stage_files` | Copies the `cost_type/month` billing file to the staging location for ingestion.. <br> Using parameters: <br> `"$AZCOPY_PATH"` <br> `"$LOCAL_BILLING_LOOKUP_PATH"` <br> `"$STORAGE_ACCOUNT_NAME"` <br> `"$STORAGE_BACKUP_CONTAINER_NAME"` <br> `"$STORAGE_STAGING_CONTAINER_NAME"` <br> `"$STORAGE_BILLING_DIRECTORY"` <br> `"$STORAGE_BILLING_ACTUAL_PATH"` <br> `"$STORAGE_BILLING_AMORTIZED_PATH"` <br> `"$STORAGE_SAS_QUERY_ARG"`|

```bash
# Stage amortized billing data from backup container to staging
./script/stage_files --cost_type amortized --month 202202
```

### Initiate the Ingestion Pipeline

Data changes require logging onto the Azure Data Factory in a specific `environment` and running the `ProcessInboundUsageData` pipeline :

|Environment | Azure Data Factory Name  |
|------------|--------------------------|
| Dev        | `$PIPELINE_ADF_NAMEdev`  |
| QA         | `$PIPELINE_ADF_NAMEqa`   |
| Prod       | `$PIPELINE_ADF_NAME`     |

Modify the parameters

| Global Parameter          | Value                     |
|---------------------------|---------------------------|
| aubi_StorageAccountName   | `"$STORAGE_ACCOUNT_NAME"` |
| aubi_sqldbname            | `"$SQL_SERVER_NAME"`      |
| aubi_sqlservername        | `"$SQL_DATABASE_NAME"`    |

| Parameter                          | Value                               |
|------------------------------------|-------------------------------------|
| ActualCostExportName               | `"$STORAGE_BILLING_ACTUAL_PATH"`    |
| AmortizedCostExportName            | `"$STORAGE_BILLING_AMORTIZED_PATH"` |
| TargetSqlDbName                    | `target_database`                   |
| UsageDownload_StorageAccountName   | `"$STORAGE_ACCOUNT_NAME"` |
| UsageDownload_StorageBlobContainer | `"$STORAGE_STAGING_CONTAINER_NAME"` |
| UsageDownload_StorageBlobDirectory | `"$STORAGE_BILLING_DIRECTORY"`      |
