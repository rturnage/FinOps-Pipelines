DECLARE @test_rg [nvarchar](300)
SET @test_rg = 'test1234'

DROP TABLE IF EXISTS [costmanagement].[ActualCostSummary];

SELECT
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
    , [CostCenter]
    , [ConsumedService]
    -- ,Min([EffectivePrice]) as [EffectivePriceMin]
    -- ,Max([EffectivePrice]) as [EffectivePriceMax]
    -- ,Avg([EffectivePrice]) as [EffectivePriceAve]
    , [Tags]
    , [OfferId]
    , [ServiceInfo1]
    -- ,Count([ResourceId]) as ResourceIdCount
    , [ServiceInfo2]
    , [ReservationId]
    , [ReservationName]
    -- ,[AdditionalInfo]
    , [ProductOrderId]
    , [ProductOrderName]
    -- ,Count([ResourceName]) as ResourceNameCount
    , [Term]
    , [PublisherType]
    , [PublisherName]
    , [ChargeType]
    -- ,Avg([UnitPrice]) as [UnitPrice]
    -- ,Sum([UnitPrice]) as UnitPriceSum
    -- ,Min([UnitPrice]) as UnitPriceMin
    -- ,Max([UnitPrice]) as UnitPriceMax
    -- ,AVG([UnitPrice]) as UnitPriceAvg
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
    , [PlanName]
    , [ServiceFamily]
    , [CostAllocationRuleName]
    , Sum([Quantity]) AS [Quantity]
    , Avg([EffectivePrice]) AS [EffectivePrice]
    , Sum([CostInBillingCurrency]) AS [CostInBillingCurrency]
    , Count(DISTINCT [ResourceId]) AS ResourceIdCount
    , Count(DISTINCT [ResourceName]) AS ResourceNameCount
    , CONVERT(smallmoney, [UnitPrice]) AS [UnitPrice]
    , CONVERT(smallmoney, [PayGPrice]) AS [PayGPrice]
INTO [costmanagement].[ActualCostSummary]
FROM [costmanagement].[ActualCost]
--   WHERE [ResourceGroup] = @test_rg
GROUP BY
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
    , [CostCenter]
    , [ConsumedService]
    , [Tags]
    , [OfferId]
    -- ,[AdditionalInfo]
    , [ServiceInfo1]
    , [ServiceInfo2]
    , [ReservationId]
    , [ReservationName]
    , CONVERT(smallmoney, [UnitPrice])
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
    , CONVERT(smallmoney, [PayGPrice])
    , [PlanName]
    , [ServiceFamily]
    , [CostAllocationRuleName]


GRANT SELECT ON Costmanagement.ActualCostSummary TO CostManagementDataReader

EXEC Sp_Spaceused '[costmanagement].[ActualCost]';
EXEC Sp_Spaceused '[costmanagement].[ActualCostSummary]';

SELECT Count(*) FROM [costmanagement].[ActualCost];
SELECT Count(*) FROM [costmanagement].[ActualCostSummary];
