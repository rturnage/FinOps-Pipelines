/*************************************
Data Patch Script
**************************************/
-- USE CostManagementDev
-- USE CostManagementQA
-- USE CostManagementProd

------------------- Pre-pipeline -------------------

-- Copy Files to staging container
-- ./script/stage_files --billing_type actual --month 202301
-- ./script/stage_files --billing_type amortized --month 202301



------------------- Pipeline Update -------------------

-- Debug_ManualLoadUsageData pipeline



------------------- Post-pipline -----------------------

-- Refresh Summary Tables
DECLARE @DateRangeStart date = '2023-01-01'
DECLARE @DateRangeEnd date = '2023-01-31'
EXECUTE [costmanagement].[UpdateActualCostSummaryTable]
    @DateRangeStart, @DateRangeEnd
EXECUTE [costmanagement].[UpdateActualCostSummaryTable]
    @DateRangeStart, @DateRangeEnd
GO
