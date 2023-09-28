/***************************
Create Testing Databases
****************************/

-- USE CostManagementDev
-- USE CostManagementQA
-- USE CostManagementProd

USE [MASTER]

CREATE DATABASE [costoptdb_dev] AS COPY OF costoptsqlsvr.costoptdb;
CREATE DATABASE [costoptdb_qa] AS COPY OF costoptsqlsvr.costoptdb;
GO


-- Create Permission to ADF Managed Identity for DEV
-- PIPELINE_ADF_IDENTITY_NAME = <dev value>
USE costoptdb_dev
DROP USER IF EXISTS [$(PIPELINE_ADF_IDENTITY_NAME)];
CREATE USER [$(PIPELINE_ADF_IDENTITY_NAME)] FROM EXTERNAL PROVIDER
GO

ALTER ROLE CostManagementDataLoader ADD MEMBER [$(PIPELINE_ADF_IDENTITY_NAME_DEV)];
GO


-- Create Permission to ADF Managed Identity for QA
-- PIPELINE_ADF_IDENTITY_NAME = <qa value>
USE costoptdb_qa
DROP USER IF EXISTS [$(PIPELINE_ADF_IDENTITY_NAME)];
CREATE USER [$(PIPELINE_ADF_IDENTITY_NAME)] FROM EXTERNAL PROVIDER
GO

ALTER ROLE CostManagementDataLoader ADD MEMBER [$(PIPELINE_ADF_IDENTITY_NAME)];
GO
