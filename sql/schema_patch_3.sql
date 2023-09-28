/***************************
Map Staging Table Columns
****************************/

-- USE CostManagementDev
-- USE CostManagementQA
-- USE CostManagementDemo

DROP PROCEDURE IF EXISTS [costmanagement].[CalculateStagingColumns]
GO
CREATE PROCEDURE [costmanagement].[CalculateStagingColumns](
    @TableName sysname
)
WITH EXECUTE AS OWNER
AS
BEGIN
    -- Calculate Columns
    -- DECLARE @DynamicSQL nvarchar(max);

    -- SET @DynamicSQL = N'
    -- SELECT "Map Columns here"
    -- '

    -- EXEC sp_executesql  @DynamicSQL


END
GO
GRANT EXECUTE ON [costmanagement].[CalculateStagingColumns] TO [CostManagementDataLoader]
GO
