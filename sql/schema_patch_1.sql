/***************************
Clean up Databases
****************************/

-- USE CostManagementDev
-- USE CostManagementQA
-- USE CostManagementProd

DROP TABLE IF EXISTS [costmanagement].[ActualCost_Last_30_days];
GO

DROP TABLE IF EXISTS [costmanagement].[AmortizedBudgets];
GO

DROP TABLE IF EXISTS [costmanagement].[AmortizedBudgetVariance];
GO

DROP TABLE IF EXISTS [costmanagement].[AmortizedCost_Last_30_days];
GO

DROP TABLE IF EXISTS [costmanagement].[TaggedResources];
GO

DROP PROCEDURE IF EXISTS [costmanagement].[DeleteActualCostDataForDateRange];
GO

DROP PROCEDURE IF EXISTS [costmanagement].[DeleteAmortizedCostDataForDateRange];
GO

DROP PROCEDURE IF EXISTS [costmanagement].[UpdateActualCost_Last_30_Days];
GO

DROP PROCEDURE IF EXISTS [costmanagement].[UpdateAmortizedCost_Last_30_Days];
GO

DROP PROCEDURE IF EXISTS [costmanagement].[UpdateActualCostFromStaging]
GO

DROP PROCEDURE IF EXISTS [costmanagement].[UpdateActualCostFromStaging]
GO
