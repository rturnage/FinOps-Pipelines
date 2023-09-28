/*******************************
Update Target table from Staging
********************************/

-- USE CostManagementDev
-- USE CostManagementQA
-- USE CostManagementDemo

DROP PROCEDURE IF EXISTS [costmanagement].[UpdateTargetFromStaging]
GO
CREATE PROCEDURE [costmanagement].[UpdateTargetFromStaging]
(
    @StagingTableName sysname,
    @TargetTableName sysname
)
WITH EXECUTE AS OWNER
AS
BEGIN

    DECLARE @DateRangeStart date
    DECLARE @DateRangeEnd date

    DECLARE @DynamicSQL nvarchar(max);
    SET @DynamicSQL = N'
    SELECT
        @maxDate = MAX([Date])
        , @minDate = MIN([Date])
    FROM
        [costmanagement].' + QUOTENAME(@StagingTableName)

    PRINT @DynamicSQL
    EXEC sp_executesql @DynamicSQL, N'@maxDate date OUTPUT, @minDate date OUTPUT', @maxDate=@DateRangeEnd OUTPUT, @minDate=@DateRangeStart OUTPUT;

    -- TODO: Try swapping Partitions
    SET @DynamicSQL = N'
    DELETE FROM [costmanagement]' + QUOTENAME(@TargetTableName) + '
    WHERE [Date] >= @DateRangeStart
         AND [Date] <= @DateRangeEnd;'

    EXEC sp_executesql @DynamicSQL;

    SET @DynamicSQL = N'
    INSERT INTO [costmanagement]' + QUOTENAME(@TargetTableName) + '
    (
        [InvoiceSectionName]
        , [AccountName]
        , [AccountOwnerId]
        , [SubscriptionId]
        , [SubscriptionName]
        , [ResourceGroup]
        , [ResourceLocation]
        , [Date]
        , [ProductName]
        , [MeterCategory]
        , [MeterSubCategory]
        , [MeterId]
        , [MeterName]
        , [MeterRegion]
        , [UnitOfMeasure]
        , [Quantity]
        , [EffectivePrice]
        , [CostInBillingCurrency]
        , [CostCenter]
        , [ConsumedService]
        , [ResourceId]
        , [Tags]
        , [OfferId]
        , [AdditionalInfo]
        , [ServiceInfo1]
        , [ServiceInfo2]
        , [ResourceName]
        , [ReservationId]
        , [ReservationName]
        , [UnitPrice]
        , [ProductOrderId]
        , [ProductOrderName]
        , [Term]
        , [PublisherType]
        , [PublisherName]
        , [ChargeType]
        , [Frequency]
        , [PricingModel]
        , [AvailabilityZone]
        , [BillingAccountId]
        , [BillingAccountName]
        , [BillingCurrencyCode]
        , [BillingPeriodStartDate]
        , [BillingPeriodEndDate]
        , [BillingProfileId]
        , [BillingProfileName]
        , [InvoiceSectionId]
        , [IsAzureCreditEligible]
        , [PartNumber]
        , [PayGPrice]
        , [PlanName]
        , [ServiceFamily]
        , [CostAllocationRuleName]
    )
    SELECT
        [Staging].[InvoiceSectionName]
        , [Staging].[AccountName]
        , [Staging].[AccountOwnerId]
        , [Staging].[SubscriptionId]
        , [Staging].[SubscriptionName]
        , [Staging].[ResourceGroup]
        , [Staging].[ResourceLocation]
        , [Staging].[Date]
        , [Staging].[ProductName]
        , [Staging].[MeterCategory]
        , [Staging].[MeterSubCategory]
        , [Staging].[MeterId]
        , [Staging].[MeterName]
        , [Staging].[MeterRegion]
        , [Staging].[UnitOfMeasure]
        , [Staging].[Quantity]
        , [Staging].[EffectivePrice]
        , [Staging].[CostInBillingCurrency]
        , [Staging].[CostCenter]
        , [Staging].[ConsumedService]
        , [Staging].[ResourceId]
        , [Staging].[Tags]
        , [Staging].[OfferId]
        , [Staging].[AdditionalInfo]
        , [Staging].[ServiceInfo1]
        , [Staging].[ServiceInfo2]
        , [Staging].[ResourceName]
        , [Staging].[ReservationId]
        , [Staging].[ReservationName]
        , [Staging].[UnitPrice]
        , [Staging].[ProductOrderId]
        , [Staging].[ProductOrderName]
        , [Staging].[Term]
        , [Staging].[PublisherType]
        , [Staging].[PublisherName]
        , [Staging].[ChargeType]
        , [Staging].[Frequency]
        , [Staging].[PricingModel]
        , [Staging].[AvailabilityZone]
        , [Staging].[BillingAccountId]
        , [Staging].[BillingAccountName]
        , [Staging].[BillingCurrencyCode]
        , [Staging].[BillingPeriodStartDate]
        , [Staging].[BillingPeriodEndDate]
        , [Staging].[BillingProfileId]
        , [Staging].[BillingProfileName]
        , [Staging].[InvoiceSectionId]
        , [Staging].[IsAzureCreditEligible]
        , [Staging].[PartNumber]
        , [Staging].[PayGPrice]
        , [Staging].[PlanName]
        , [Staging].[ServiceFamily]
        , [Staging].[CostAllocationRuleName]
    FROM
        [costmanagement].' + QUOTENAME(@StagingTableName) + ' as Staging;'

    EXEC sp_executesql @DynamicSQL;

END
GO
GRANT EXECUTE ON [costmanagement].[UpdateTargetFromStaging] TO [CostManagementDataLoader]
GO
