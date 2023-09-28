SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*************************************
General Checks - For each release
**************************************/

-- Show row count, size of data and index
sp_spaceused N'costmanagement.ActualCost';
GO
sp_spaceused N'costmanagement.AmortizedCost';
GO


/*************************************
General Cost Tables
**************************************/

SELECT
    N'Actual Cost' AS table_name
    , YEAR([Date]) AS billing_year
    , MONTH([Date]) AS billing_month
    , CONVERT(
        varchar, CONVERT(money, SUM([CostInBillingCurrency])), 1
     ) AS [CostInBillingCurrency]
FROM [costmanagement].[ActualCost]
GROUP BY YEAR([Date]), MONTH([Date])
UNION
SELECT
    N'Amortized Cost' AS table_name
    , YEAR([Date]) AS billing_year
    , MONTH([Date]) AS billing_month
    , CONVERT(
        varchar, CONVERT(money, SUM([CostInBillingCurrency])), 1
     ) AS [CostInBillingCurrency]
FROM [costmanagement].[AmortizedCost]
GROUP BY YEAR([Date]), MONTH([Date])
UNION
SELECT
    N'Actual Cost Summary' AS table_name
    , YEAR([Date]) AS billing_year
    , MONTH([Date]) AS billing_month
    , CONVERT(
        varchar, CONVERT(money, SUM([CostInBillingCurrency])), 1
     ) AS [CostInBillingCurrency]
FROM [costmanagement].[ActualCostSummary]
GROUP BY YEAR([Date]), MONTH([Date])
UNION
SELECT
    N'Amortized Cost Summary' AS table_name
    , YEAR([Date]) AS billing_year
    , MONTH([Date]) AS billing_month
    , CONVERT(
        varchar, CONVERT(money, SUM([CostInBillingCurrency])), 1
     ) AS [CostInBillingCurrency]
FROM [costmanagement].[AmortizedCostSummary]
GROUP BY YEAR([Date]), MONTH([Date])


/*************************************
Spot Check Cost and Summary Tables
**************************************/

DECLARE @CheckDate date = '2022-10-07'
SELECT
    N'Actual Cost' AS table_name
    , [Date]
    , CONVERT(
        varchar, CONVERT(money, SUM([CostInBillingCurrency])), 1
     ) AS [CostInBillingCurrency]
FROM [costmanagement].[ActualCost]
WHERE [Date] = @CheckDate
GROUP BY [Date]
UNION
SELECT
    N'Amortized Cost' AS table_name
    , [Date]
    , CONVERT(
        varchar, CONVERT(money, SUM([CostInBillingCurrency])), 1
     ) AS [CostInBillingCurrency]
FROM [costmanagement].[AmortizedCost]
WHERE [Date] = @CheckDate
GROUP BY [Date]
UNION
SELECT
    N'Actual Cost Summary' AS table_name
    , [Date]
    , CONVERT(
        varchar, CONVERT(money, SUM([CostInBillingCurrency])), 1
     ) AS [CostInBillingCurrency]
FROM [costmanagement].[ActualCostSummary]
WHERE [Date] = @CheckDate
GROUP BY [Date]
UNION
SELECT
    N'Amortized Cost Summary' AS table_name
    , [Date]
    , CONVERT(
        varchar, CONVERT(money, SUM([CostInBillingCurrency])), 1
     ) AS [CostInBillingCurrency]
FROM [costmanagement].[AmortizedCostSummary]
WHERE [Date] = @CheckDate
GROUP BY [Date]
