-- schema patch v6.1 various table
-- 20230216

-- Regions Table
drop table if EXISTS [costmanagement].[Regions]
CREATE TABLE [costmanagement].[Regions] (
    [displayName] nvarchar(25)
    , [geographyGroup] nvarchar(20) NULL
    , [id] nvarchar(100)
    , [latitude] Decimal(8,6) NULL
    , [longitude] Decimal(9,6) NULL
    , [name] nvarchar(25) NULL
    , [pairedRegion] nvarchar(25) NULL
    , [physicalLocation] nvarchar(35) NULL
    , [regionCategory] nvarchar(15) NULL
    , [regionalDisplayName] nvarchar(50) NULL
    , [regionType] nvarchar(10) NULL
    , [subscriptionId] nvarchar(300) NULL
);
GO

grant insert on costmanagement.Regions to CostManagementDataLoader
grant select on costmanagement.Regions to CostManagementDataLoader
grant delete on costmanagement.Regions to CostManagementDataLoader
grant alter on costmanagement.Regions to CostManagementDataLoader

grant select on costmanagement.Regions to CostManagementDataReader



-- Advisor Table
drop table if EXISTS [costmanagement].[Advisor]
CREATE TABLE [costmanagement].[Advisor] (
    [assessmentKey] nvarchar(50) NULL
    , [Category] nvarchar(30)
    , [id] nvarchar(350)
    , [Impact] nvarchar(20)
    , [Impacted Resource Name] nvarchar(100)
    , [Impacted Resource Type] nvarchar(100)
    , [Last Updated] Date
    , [name] nvarchar(50)
    , [recommendationTypeId] nvarchar(50)
    , [resourceId] nvarchar(2000)
    , [score] Decimal(3,2) NULL
    , [Short Description - Problem] nvarchar(300)
    , [Short Description - Solution] nvarchar(300)
    , [source] nvarchar(350) NULL
    , [subscriptionId] nvarchar(300)
    , [type] nvarchar(50)
);
GO

grant insert on costmanagement.Advisor to CostManagementDataLoader
grant select on costmanagement.Advisor to CostManagementDataLoader
grant delete on costmanagement.Advisor to CostManagementDataLoader
grant alter on costmanagement.Advisor to CostManagementDataLoader

grant select on costmanagement.Advisor to CostManagementDataReader

-- Reservation Transactions
drop table if EXISTS [costmanagement].[Reservation Transactions]
CREATE TABLE [costmanagement].[Reservation Transactions] (
    [accountName] nvarchar(100)
    , [accountOwnerEmail] nvarchar(100)
    , [amount] Decimal(12,3)
    , [armSkuName] nvarchar(100)
    , [billingFrequency] nvarchar(50)
    , [costCenter] nvarchar(100)
    , [currency] nvarchar(20)
    , [currentEnrollment] nvarchar(50)
    , [departmentName] nvarchar(100)
    , [description] nvarchar(150)
    , [eventDate] Date
    , [eventType] nvarchar(10)
    , [id] nvarchar(200)
    , [name] nvarchar(50)
    , [purchasingEnrollment] nvarchar(50)
    , [purchasingSubscriptionGuid] nvarchar(50)
    , [purchasingSubscriptionName] nvarchar(300)
    , [quantity] int
    , [region] nvarchar(25)
    , [reservationOrderId] nvarchar(50)
    , [reservationOrderName] nvarchar(50)
    , [tags] nvarchar(300)
    , [term] nvarchar(10)
    , [type] nvarchar(50)
);
GO

grant insert on [costmanagement].[Reservation Transactions] to CostManagementDataLoader
grant select on [costmanagement].[Reservation Transactions] to CostManagementDataLoader
grant delete on [costmanagement].[Reservation Transactions] to CostManagementDataLoader
grant alter on [costmanagement].[Reservation Transactions] to CostManagementDataLoader

grant select on [costmanagement].[Reservation Transactions] to CostManagementDataReader


-- ISF Data
ALTER TABLE  [costmanagement].[ISFData] ALTER COLUMN [Ratio] Decimal(14,10)

-- TaggedResources Table
drop table if EXISTS [costmanagement].[TaggedResources]
CREATE TABLE [costmanagement].[TaggedResources](
    [InvoiceSectionName] [nvarchar](300) NULL,
    [AccountName] [nvarchar](300) NULL,
    [AccountOwnerId] [nvarchar](300) NULL,
    [SubscriptionId] [nvarchar](300) NULL,
    [SubscriptionName] [nvarchar](300) NULL,
    [ResourceGroup] [nvarchar](300) NULL,
    [ResourceLocation] [nvarchar](300) NULL,
    [Date] [date] NULL,
    [ProductName] [nvarchar](300) NULL,
    [MeterCategory] [nvarchar](300) NULL,
    [MeterSubCategory] [nvarchar](300) NULL,
    [MeterId] [nvarchar](300) NULL,
    [MeterName] [nvarchar](300) NULL,
    [MeterRegion] [nvarchar](300) NULL,
    [UnitOfMeasure] [nvarchar](300) NULL,
    [Quantity] [decimal](38, 20) NULL,
    [EffectivePrice] [decimal](28, 20) NULL,
    [CostInBillingCurrency] [decimal](28, 20) NULL,
    [CostCenter] [nvarchar](300) NULL,
    [ConsumedService] [nvarchar](300) NULL,
    [ResourceIdCount] [int] NULL,
    [HasTag] [int] NULL,
    [CompliantTagResourceCount] [int] NULL,
    [OfferId] [nvarchar](300) NULL,
    [ServiceInfo1] [nvarchar](300) NULL,
    [ServiceInfo2] [nvarchar](300) NULL,
    [ResourceNameCount] [int] NULL,
    [ReservationId] [nvarchar](300) NULL,
    [ReservationName] [nvarchar](300) NULL,
    [UnitPrice] [smallmoney] NULL,
    [ProductOrderId] [nvarchar](300) NULL,
    [ProductOrderName] [nvarchar](300) NULL,
    [Term] [nvarchar](300) NULL,
    [PublisherType] [nvarchar](300) NULL,
    [PublisherName] [nvarchar](300) NULL,
    [ChargeType] [nvarchar](300) NULL,
    [Frequency] [nvarchar](300) NULL,
    [PricingModel] [nvarchar](300) NULL,
    [AvailabilityZone] [nvarchar](300) NULL,
    [BillingAccountId] [nvarchar](300) NULL,
    [BillingAccountName] [nvarchar](300) NULL,
    [BillingCurrencyCode] [nvarchar](20) NULL,
    [BillingPeriodStartDate] [date] NULL,
    [BillingPeriodEndDate] [date] NULL,
    [BillingProfileId] [nvarchar](100) NULL,
    [BillingProfileName] [nvarchar](300) NULL,
    [InvoiceSectionId] [nvarchar](300) NULL,
    [IsAzureCreditEligible] [nvarchar](10) NULL,
    [PartNumber] [nvarchar](50) NULL,
    [PayGPrice] [smallmoney] NULL,
    [PlanName] [nvarchar](300) NULL,
    [ServiceFamily] [nvarchar](300) NULL,
    [CostAllocationRuleName] [nvarchar](300) NULL
) ON [monthRangePS] ([Date])
GO
CREATE CLUSTERED COLUMNSTORE INDEX [cci_TaggedResources] ON [costmanagement].[TaggedResources] WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0) ON [monthRangePS] ([Date])
GO

grant insert on costmanagement.TaggedResources to CostManagementDataLoader
grant select on costmanagement.TaggedResources to CostManagementDataLoader
grant delete on costmanagement.TaggedResources to CostManagementDataLoader
grant alter on costmanagement.TaggedResources to CostManagementDataLoader
grant select on costmanagement.TaggedResources to CostManagementDataReader

GO

drop procedure if EXISTS costmanagement.UpdateTaggedResources
GO

create procedure costmanagement.UpdateTaggedResources
    @DateRangeStart date
  , @DateRangeEnd date
  , @target_tag [nvarchar](300)
with execute as owner
as
BEGIN

    -- Delete Previous Data
    delete from [costmanagement].[TaggedResources]
    where Date >= @DateRangeStart
          and Date <= @DateRangeEnd

    ;WITH WT AS (
    Select [InvoiceSectionName]
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
            , Sum([Quantity])                  as [Quantity]
            , Avg([EffectivePrice])            as [EffectivePrice]
            , Sum([CostInBillingCurrency])     as [CostInBillingCurrency]
            , [CostCenter]
            , [ConsumedService]
            , Count(Distinct [ResourceId])     as ResourceIdCount
            , (case when charindex(@target_tag, [Tags],0) > 0 then 1 else 0 end) as HasTag
            , Sum(case when charindex(@target_tag, [Tags],0) > 0 then 1 else 0 end) as CompliantTagResourceCount
            , [OfferId]
            , [ServiceInfo1]
            , [ServiceInfo2]
            , Count(Distinct [ResourceName])   as ResourceNameCount
            , [ReservationId]
            , [ReservationName]
            , CONVERT(SMALLMONEY, [UnitPrice]) as [UnitPrice]
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
            , CONVERT(SMALLMONEY, [PayGPrice]) as [PayGPrice]
            , [PlanName]
            , [ServiceFamily]
            , [CostAllocationRuleName]
        FROM [costmanagement].[ActualCost]
        WHERE [costmanagement].[ActualCost].[Date] >= @DateRangeStart
            and [costmanagement].[ActualCost].[Date] <= @DateRangeEnd
        Group By [InvoiceSectionName]
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
            , [ServiceInfo1]
            , [ServiceInfo2]
            , [ReservationId]
            , [ReservationName]
            , CONVERT(SMALLMONEY, [UnitPrice])
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
            , CONVERT(SMALLMONEY, [PayGPrice])
            , [PlanName]
            , [ServiceFamily]
            , [CostAllocationRuleName]
    )
    Insert INTO [costmanagement].[TaggedResources]
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
            , ResourceIdCount
            , HasTag
            , CompliantTagResourceCount
            , [OfferId]
            , [ServiceInfo1]
            , [ServiceInfo2]
            , ResourceNameCount
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
    Select
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
            , Sum([Quantity])                  as [Quantity]
            , Avg([EffectivePrice])            as [EffectivePrice]
            , Sum([CostInBillingCurrency])     as [CostInBillingCurrency]
            , [CostCenter]
            , [ConsumedService]
            , Sum(ResourceIdCount)             as ResourceIdCount
            , HasTag
            , Sum(CompliantTagResourceCount)  as CompliantTagResourceCount
            , [OfferId]
            , [ServiceInfo1]
            , [ServiceInfo2]
            , Sum([ResourceNameCount])              as ResourceNameCount
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
        FROM WT
        Group By [InvoiceSectionName]
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
            , HasTag
            , [OfferId]
            , [ServiceInfo1]
            , [ServiceInfo2]
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

end
GO

grant execute on costmanagement.UpdateTaggedResources to CostManagementDataLoader


-- last 30 days Actual Cost
DROP TABLE if EXISTS [costmanagement].[ActualCost_Last_30_days]
CREATE TABLE [costmanagement].[ActualCost_Last_30_days](
	[InvoiceSectionName] [nvarchar](300) NULL,
	[AccountName] [nvarchar](300) NULL,
	[AccountOwnerId] [nvarchar](300) NULL,
	[SubscriptionId] [nvarchar](300) NULL,
	[SubscriptionName] [nvarchar](300) NULL,
	[ResourceGroup] [nvarchar](300) NULL,
	[ResourceLocation] [nvarchar](300) NULL,
	[Date] [date] NULL,
	[ProductName] [nvarchar](300) NULL,
	[MeterCategory] [nvarchar](300) NULL,
	[MeterSubCategory] [nvarchar](300) NULL,
	[MeterId] [nvarchar](300) NULL,
	[MeterName] [nvarchar](300) NULL,
	[MeterRegion] [nvarchar](300) NULL,
	[UnitOfMeasure] [nvarchar](300) NULL,
	[Quantity] [decimal](28, 20) NULL,
	[EffectivePrice] [decimal](28, 20) NULL,
	[CostInBillingCurrency] [decimal](28, 20) NULL,
	[CostCenter] [nvarchar](300) NULL,
	[ConsumedService] [nvarchar](300) NULL,
	[ResourceId] [nvarchar](2000) NULL,
	[Tags] [nvarchar](4000) NULL,
	[OfferId] [nvarchar](300) NULL,
	[AdditionalInfo] [nvarchar](4000) NULL,
	[ServiceInfo1] [nvarchar](300) NULL,
	[ServiceInfo2] [nvarchar](300) NULL,
	[ResourceName] [nvarchar](300) NULL,
	[ReservationId] [nvarchar](300) NULL,
	[ReservationName] [nvarchar](300) NULL,
	[UnitPrice] [decimal](28, 20) NULL,
	[ProductOrderId] [nvarchar](300) NULL,
	[ProductOrderName] [nvarchar](300) NULL,
	[Term] [nvarchar](300) NULL,
	[PublisherType] [nvarchar](300) NULL,
	[PublisherName] [nvarchar](300) NULL,
	[ChargeType] [nvarchar](300) NULL,
	[Frequency] [nvarchar](300) NULL,
	[PricingModel] [nvarchar](300) NULL,
	[AvailabilityZone] [nvarchar](300) NULL,
	[BillingAccountId] [nvarchar](300) NULL,
	[BillingAccountName] [nvarchar](300) NULL,
	[BillingCurrencyCode] [nvarchar](20) NULL,
	[BillingPeriodStartDate] [date] NULL,
	[BillingPeriodEndDate] [date] NULL,
	[BillingProfileId] [nvarchar](100) NULL,
	[BillingProfileName] [nvarchar](300) NULL,
	[InvoiceSectionId] [nvarchar](300) NULL,
	[IsAzureCreditEligible] [nvarchar](10) NULL,
	[PartNumber] [nvarchar](50) NULL,
	[PayGPrice] [nvarchar](100) NULL,
	[PlanName] [nvarchar](300) NULL,
	[ServiceFamily] [nvarchar](300) NULL,
	[CostAllocationRuleName] [nvarchar](300) NULL
) ON [monthRangePS] ([Date])
GO
CREATE CLUSTERED COLUMNSTORE INDEX [cci_ActualCost_Last_30_days] ON [costmanagement].[ActualCost_Last_30_days] WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0) ON [monthRangePS] ([Date])
GO

grant insert on costmanagement.ActualCost_Last_30_days to CostManagementDataLoader
grant select on costmanagement.ActualCost_Last_30_days to CostManagementDataLoader
grant delete on costmanagement.ActualCost_Last_30_days to CostManagementDataLoader
grant alter on costmanagement.ActualCost_Last_30_days to CostManagementDataLoader
grant select on costmanagement.ActualCost_Last_30_days to CostManagementDataReader

GO

drop procedure if EXISTS costmanagement.UpdateActualCost_Last_30_days
GO
create procedure costmanagement.UpdateActualCost_Last_30_days
    @DateRangeStart date
  , @DateRangeEnd date
with execute as owner
as
BEGIN

    -- Delete Previous Data
    delete from [costmanagement].[ActualCost_Last_30_days]
    where Date >= @DateRangeStart
          and Date <= @DateRangeEnd

    Insert INTO [costmanagement].[ActualCost_Last_30_days]
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
    Select
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
        FROM ActualCost
        WHERE [costmanagement].[ActualCost].[Date] >= @DateRangeStart
            and [costmanagement].[ActualCost].[Date] <= @DateRangeEnd
end
GO

grant execute on costmanagement.UpdateActualCost_Last_30_days to CostManagementDataLoader
GO

-- last 30 days Amortized Cost
DROP TABLE if EXISTS [costmanagement].[AmortizedCost_Last_30_days]
CREATE TABLE [costmanagement].[AmortizedCost_Last_30_days](
	[InvoiceSectionName] [nvarchar](300) NULL,
	[AccountName] [nvarchar](300) NULL,
	[AccountOwnerId] [nvarchar](300) NULL,
	[SubscriptionId] [nvarchar](300) NULL,
	[SubscriptionName] [nvarchar](300) NULL,
	[ResourceGroup] [nvarchar](300) NULL,
	[ResourceLocation] [nvarchar](300) NULL,
	[Date] [date] NULL,
	[ProductName] [nvarchar](300) NULL,
	[MeterCategory] [nvarchar](300) NULL,
	[MeterSubCategory] [nvarchar](300) NULL,
	[MeterId] [nvarchar](300) NULL,
	[MeterName] [nvarchar](300) NULL,
	[MeterRegion] [nvarchar](300) NULL,
	[UnitOfMeasure] [nvarchar](300) NULL,
	[Quantity] [decimal](28, 20) NULL,
	[EffectivePrice] [decimal](28, 20) NULL,
	[CostInBillingCurrency] [decimal](28, 20) NULL,
	[CostCenter] [nvarchar](300) NULL,
	[ConsumedService] [nvarchar](300) NULL,
	[ResourceId] [nvarchar](2000) NULL,
	[Tags] [nvarchar](4000) NULL,
	[OfferId] [nvarchar](300) NULL,
	[AdditionalInfo] [nvarchar](4000) NULL,
	[ServiceInfo1] [nvarchar](300) NULL,
	[ServiceInfo2] [nvarchar](300) NULL,
	[ResourceName] [nvarchar](300) NULL,
	[ReservationId] [nvarchar](300) NULL,
	[ReservationName] [nvarchar](300) NULL,
	[UnitPrice] [decimal](28, 20) NULL,
	[ProductOrderId] [nvarchar](300) NULL,
	[ProductOrderName] [nvarchar](300) NULL,
	[Term] [nvarchar](300) NULL,
	[PublisherType] [nvarchar](300) NULL,
	[PublisherName] [nvarchar](300) NULL,
	[ChargeType] [nvarchar](300) NULL,
	[Frequency] [nvarchar](300) NULL,
	[PricingModel] [nvarchar](300) NULL,
	[AvailabilityZone] [nvarchar](300) NULL,
	[BillingAccountId] [nvarchar](300) NULL,
	[BillingAccountName] [nvarchar](300) NULL,
	[BillingCurrencyCode] [nvarchar](20) NULL,
	[BillingPeriodStartDate] [date] NULL,
	[BillingPeriodEndDate] [date] NULL,
	[BillingProfileId] [nvarchar](100) NULL,
	[BillingProfileName] [nvarchar](300) NULL,
	[InvoiceSectionId] [nvarchar](300) NULL,
	[IsAzureCreditEligible] [nvarchar](10) NULL,
	[PartNumber] [nvarchar](50) NULL,
	[PayGPrice] [nvarchar](100) NULL,
	[PlanName] [nvarchar](300) NULL,
	[ServiceFamily] [nvarchar](300) NULL,
	[CostAllocationRuleName] [nvarchar](300) NULL
) ON [monthRangePS] ([Date])
GO
CREATE CLUSTERED COLUMNSTORE INDEX [cci_AmortizedCost_Last_30_days] ON [costmanagement].[AmortizedCost_Last_30_days] WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0) ON [monthRangePS] ([Date])
GO

grant insert on costmanagement.AmortizedCost_Last_30_days to CostManagementDataLoader
grant select on costmanagement.AmortizedCost_Last_30_days to CostManagementDataLoader
grant delete on costmanagement.AmortizedCost_Last_30_days to CostManagementDataLoader
grant alter on costmanagement.AmortizedCost_Last_30_days to CostManagementDataLoader
grant select on costmanagement.AmortizedCost_Last_30_days to CostManagementDataReader

GO

drop procedure if EXISTS costmanagement.UpdateAmortizedCost_Last_30_days
GO
create procedure costmanagement.UpdateAmortizedCost_Last_30_days
    @DateRangeStart date
  , @DateRangeEnd date
with execute as owner
as
BEGIN

    -- Delete Previous Data
    delete from [costmanagement].[AmortizedCost_Last_30_days]
    where Date >= @DateRangeStart
          and Date <= @DateRangeEnd

    Insert INTO [costmanagement].[AmortizedCost_Last_30_days]
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
    Select
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
        FROM ActualCost
        WHERE [costmanagement].[ActualCost].[Date] >= @DateRangeStart
            and [costmanagement].[ActualCost].[Date] <= @DateRangeEnd
end
GO

grant execute on costmanagement.UpdateAmortizedCost_Last_30_days to CostManagementDataLoader
GO



-- Amortized Budgets
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
DROP TABLE if EXISTS [costmanagement].[AmortizedBudgets]
CREATE TABLE [costmanagement].[AmortizedBudgets](
 [BudgetYear] [int] NULL,
 [MinDate] Date NULL,
 [MaxDate] Date NULL,
 [DaysInYear] [int] NULL,
 [SubscriptionName] [nvarchar](300) NULL,
 [ResourceGroup] [nvarchar](300) NULL,
 [MeterCategory] [nvarchar](300) NULL,
 [MeterSubCategory] [nvarchar](300) NULL,
 [MeterName] [nvarchar](300) NULL,
 [ProductName] [nvarchar](300) NULL,
 [AnnualCost] [decimal](38, 20) NULL,
 [AverageDailyCost] [decimal](38, 20) NULL,
 [AnnualQuantity] [decimal](38, 20) NULL,
 [AverageDailyQuantity] [decimal](38, 20) NULL,
 [EffectivePrice] [decimal](38, 20) NULL
) ON [PRIMARY]
GO

grant insert on costmanagement.AmortizedBudgets to CostManagementDataLoader
grant select on costmanagement.AmortizedBudgets to CostManagementDataLoader
grant delete on costmanagement.AmortizedBudgets to CostManagementDataLoader
grant alter on costmanagement.AmortizedBudgets to CostManagementDataLoader
grant select on costmanagement.AmortizedBudgets to CostManagementDataReader

INSERT INTO [costmanagement].[AmortizedBudgets]
(
    [BudgetYear]
  , [MinDate]
  , [MaxDate]
  , [DaysInYear]
  , [SubscriptionName]
  , [ResourceGroup]
  , [MeterCategory]
  , [MeterSubCategory]
  , [MeterName]
  , [ProductName]
  , [AnnualCost]
  , [AverageDailyCost]
  , [AnnualQuantity]
  , [AverageDailyQuantity]
  , [EffectivePrice]
)
SELECT YEAR(date)                                                                                                    as [BudgetYear]
     , MIN(MIN(date)) over (PARTITION By YEAR(date))                                                                 as [MinDate]
     , MAX(MAX(date)) over (PARTITION By YEAR(date))                                                                 as [MaxDate]
     , DATEDIFF(DAY, MIN(MIN(date)) over (PARTITION By YEAR(date)), MAX(MAX(date)) over (PARTITION By YEAR(date)))   as [DaysInYear]
     , [SubscriptionName]
     , [ResourceGroup]
     , [MeterCategory]
     , [MeterSubCategory]
     , [MeterName]
     , [ProductName]
     , SUM([costmanagement].[amortizedcost].[costinbillingcurrency])                                                 AS [AnnualCost]
     , SUM([costmanagement].[amortizedcost].[costinbillingcurrency])
       / DATEDIFF(DAY, MIN(MIN(date)) over (PARTITION By YEAR(date)), MAX(MAX(date)) over (PARTITION By YEAR(date))) AS [AverageDailyCost]
     , SUM([costmanagement].[amortizedcost].[Quantity])                                                              AS [AnnualQuantity]
     , SUM([costmanagement].[amortizedcost].[Quantity])
       / DATEDIFF(DAY, MIN(MIN(date)) over (PARTITION By YEAR(date)), MAX(MAX(date)) over (PARTITION By YEAR(date))) as [AverageDailyQuantity]
     , AVG([costmanagement].[amortizedcost].[EffectivePrice])                                                        AS [EffectivePrice]
FROM [costmanagement].[AmortizedCost]
Group by year(date)
       , [SubscriptionName]
       , [ResourceGroup]
       , [MeterCategory]
       , [MeterSubCategory]
       , [MeterName]
       , [ProductName]
GO

/**********************************************************************************************
Variance Analysis
***********************************************************************************************/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
DROP TABLE if EXISTS [costmanagement].[AmortizedBudgetVariance]
CREATE TABLE [costmanagement].[AmortizedBudgetVariance](
    [Date] date NULL,
    [SubscriptionName] [nvarchar](300) NULL,
    [ResourceGroup] [nvarchar](300) NULL,
    [MeterCategory] [nvarchar](300) NULL,
    [MeterSubCategory] [nvarchar](300) NULL,
    [MeterName] [nvarchar](300) NULL,
    [ProductName] [nvarchar](300) NULL,
    [BudgetUnitPrice] [decimal](38, 20) NULL,
    [BudgetQuantity] [decimal](38, 20) NULL,
    [Quantity] [decimal](38, 20) NULL,
    [EffectivePrice] [decimal](38, 20) NULL,
    [CostInBillingCurrency] [decimal](38, 20) NULL
) ON [PRIMARY]
GO

grant insert on costmanagement.AmortizedBudgetVariance to CostManagementDataLoader
grant select on costmanagement.AmortizedBudgetVariance to CostManagementDataLoader
grant delete on costmanagement.AmortizedBudgetVariance to CostManagementDataLoader
grant alter on costmanagement.AmortizedBudgetVariance to CostManagementDataLoader
grant select on costmanagement.AmortizedBudgetVariance to CostManagementDataReader

DECLARE @BudgetYear date
SET @BudgetYear = '2022-01-01'

INSERT INTO [costmanagement].[AmortizedBudgetVariance]
(
    [Date]
    , [SubscriptionName]
    , [ResourceGroup]
    , [MeterCategory]
    , [MeterSubCategory]
    , [MeterName]
    , [ProductName]
    , [BudgetUnitPrice]
    , [BudgetQuantity]
    , [Quantity]
    , [EffectivePrice]
    , [CostInBillingCurrency]
)
SELECT c.date
     , c.SubscriptionName
     , c.ResourceGroup
     , c.MeterCategory
     , c.MeterSubCategory
     , c.MeterName
     , c.ProductName
     , ISNULL(b.EffectivePrice, 0) as BudgetUnitPrice
     , ISNULL(b.AverageDailyQuantity, 0) as BudgetQuantity
     , c.Quantity
     , c.EffectivePrice
     , c.CostInBillingCurrency
FROM
(
    SELECT
        CONVERT(NVARCHAR(5), YEAR([AmortizedCost].[date])) as BudgetYear
        , [AmortizedCost].[Date]
        , [AmortizedCost].[SubscriptionName]
        , [AmortizedCost].[ResourceGroup]
        , [AmortizedCost].[MeterCategory]
        , [AmortizedCost].[MeterSubCategory]
        , [AmortizedCost].[MeterName]
        , [AmortizedCost].[ProductName]
        , SUM([AmortizedCost].[Quantity]) AS Quantity
        , AVG([AmortizedCost].[EffectivePrice]) AS EffectivePrice
        , SUM([AmortizedCost].[CostInBillingCurrency]) AS CostInBillingCurrency
    FROM costmanagement.AmortizedCost
    GROUP BY [AmortizedCost].[Date]
        , [AmortizedCost].[SubscriptionName]
        , [AmortizedCost].[ResourceGroup]
        , [AmortizedCost].[MeterCategory]
        , [AmortizedCost].[MeterSubCategory]
        , [AmortizedCost].[MeterName]
        , [AmortizedCost].[ProductName]
) AS c
LEFT JOIN
(
    SELECT
        [AmortizedBudgets].[SubscriptionName]
        , [AmortizedBudgets].[MeterCategory]
        , [AmortizedBudgets].[MeterSubCategory]
        , [AmortizedBudgets].[MeterName]
        , [AmortizedBudgets].[ProductName]
        , SUM([AmortizedBudgets].[AnnualCost]) AS AnnualCost
        , SUM([AmortizedBudgets].[AverageDailyCost]) AS AverageDailyCost
        , SUM([AmortizedBudgets].[AnnualQuantity]) AS AnnualQuantity
        , SUM([AmortizedBudgets].[AverageDailyQuantity]) AS AverageDailyQuantity
        , AVG([AmortizedBudgets].[EffectivePrice]) AS EffectivePrice
    FROM costmanagement.AmortizedBudgets
    WHERE [AmortizedBudgets].[BudgetYear] = year(@BudgetYear)
    Group by
        [AmortizedBudgets].[SubscriptionName]
        , [AmortizedBudgets].[MeterCategory]
        , [AmortizedBudgets].[MeterSubCategory]
        , [AmortizedBudgets].[MeterName]
        , [AmortizedBudgets].[ProductName]
) AS b
ON (
    c.SubscriptionName = b.SubscriptionName
    AND c.MeterCategory = b.MeterCategory
    AND c.MeterSubCategory = b.MeterSubCategory
    AND c.MeterName = b.MeterName
    AND c.ProductName = b.ProductName
)


/*
select * from [costmanagement].[Regions]
select * from [costmanagement].[Advisor]
select * from [costmanagement].[Reservation Transactions]
select * from [costmanagement].[ISFData]

delete from  [costmanagement].[Regions]
delete from  [costmanagement].[Advisor]
delete from [costmanagement].[ISFData]
*/
