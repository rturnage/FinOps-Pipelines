/***************************
Dynamic Staging Tables
****************************/

-- USE CostManagementDev
-- USE CostManagementQA
-- USE CostManagementDemo

DROP PROCEDURE IF EXISTS [costmanagement].[CreateTempStageTable]
GO
CREATE PROCEDURE [costmanagement].[CreateTempStageTable]
 @TableName sysname
WITH EXECUTE AS OWNER
AS
BEGIN

    DECLARE @DynamicSQL nvarchar(max);

    SET @DynamicSQL = N'
    DROP TABLE IF EXISTS [costmanagement].' + QUOTENAME(@TableName) + ';
    CREATE TABLE [costmanagement].' + QUOTENAME(@TableName) + ' (
    [InvoiceSectionName] [nvarchar](300) NULL
    , [AccountName] [nvarchar](300) NULL
    , [AccountOwnerId] [nvarchar](300) NULL
    , [SubscriptionId] [nvarchar](300) NULL
    , [SubscriptionName] [nvarchar](300) NULL
    , [ResourceGroup] [nvarchar](300) NULL
    , [ResourceLocation] [nvarchar](300) NULL
    , [Date] [date] NOT NULL
    , [ProductName] [nvarchar](300) NULL
    , [MeterCategory] [nvarchar](300) NULL
    , [MeterSubCategory] [nvarchar](300) NULL
    , [MeterId] [nvarchar](300) NULL
    , [MeterName] [nvarchar](300) NULL
    , [MeterRegion] [nvarchar](300) NULL
    , [UnitOfMeasure] [nvarchar](300) NULL
    , [Quantity] [decimal](28, 20) NULL
    , [EffectivePrice] [decimal](28, 20) NULL
    , [CostInBillingCurrency] [decimal](28, 20) NULL
    , [CostCenter] [nvarchar](300) NULL
    , [ConsumedService] [nvarchar](300) NULL
    , [ResourceId] [nvarchar](2000) NULL
    , [Tags] [nvarchar](4000) NULL
    , [OfferId] [nvarchar](300) NULL
    , [AdditionalInfo] [nvarchar](4000) NULL
    , [ServiceInfo1] [nvarchar](300) NULL
    , [ServiceInfo2] [nvarchar](300) NULL
    , [ResourceName] [nvarchar](300) NULL
    , [ReservationId] [nvarchar](300) NULL
    , [ReservationName] [nvarchar](300) NULL
    , [UnitPrice] [decimal](28, 20) NULL
    , [ProductOrderId] [nvarchar](300) NULL
    , [ProductOrderName] [nvarchar](300) NULL
    , [Term] [nvarchar](300) NULL
    , [PublisherType] [nvarchar](300) NULL
    , [PublisherName] [nvarchar](300) NULL
    , [ChargeType] [nvarchar](300) NULL
    , [Frequency] [nvarchar](300) NULL
    , [PricingModel] [nvarchar](300) NULL
    , [AvailabilityZone] [nvarchar](300) NULL
    , [BillingAccountId] [nvarchar](300) NULL
    , [BillingAccountName] [nvarchar](300) NULL
    , [BillingCurrencyCode] [nvarchar](20) NULL
    , [BillingPeriodStartDate] [date] NULL
    , [BillingPeriodEndDate] [date] NULL
    , [BillingProfileId] [nvarchar](100) NULL
    , [BillingProfileName] [nvarchar](300) NULL
    , [InvoiceSectionId] [nvarchar](300) NULL
    , [IsAzureCreditEligible] [nvarchar](10) NULL
    , [PartNumber] [nvarchar](50) NULL
    , [PayGPrice] [nvarchar](100) NULL
    , [PlanName] [nvarchar](300) NULL
    , [ServiceFamily] [nvarchar](300) NULL
    , [CostAllocationRuleName] [nvarchar](300) NULL
    ) ON [monthRangePS] ([Date]);

    CREATE CLUSTERED INDEX [cdi_' + @TableName + '] ON [costmanagement].' + QUOTENAME(@TableName) + ' ([Date]);

    GRANT INSERT ON [costmanagement].' + QUOTENAME(@TableName) + ' TO [CostManagementDataLoader];
    GRANT SELECT ON [costmanagement].' + QUOTENAME(@TableName) + ' TO [CostManagementDataLoader];
    GRANT DELETE ON [costmanagement].' + QUOTENAME(@TableName) + ' TO [CostManagementDataLoader];
    GRANT ALTER ON [costmanagement].' + QUOTENAME(@TableName) + ' TO [CostManagementDataLoader];
    GRANT SELECT ON [costmanagement].' + QUOTENAME(@TableName) + ' TO [CostManagementDataReader];
    '
    --print @DynamicSQL
    EXEC sp_executesql @DynamicSQL;

END
GO
GRANT EXECUTE ON [costmanagement].[CreateTempStageTable] TO [CostManagementDataLoader]
GO
