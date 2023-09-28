/********************************************************************
*
* v2 Schema - Used by the ADF processes that call the Billing APIs
* v3 Schema - Used by the ADF processes that call the Azure Consumption APIs
* v4 Schema - Removed creation of users from this script
* v5 Schema - Create PowerBI Report user
* v6 Schema - Add Summary Tables for Actual and Amortized cost.
*/


DROP VIEW IF EXISTS [costmanagement].[RegionSummaryDate]
DROP VIEW IF EXISTS [costmanagement].[ActualCostSummaryView]
DROP TABLE IF EXISTS [costmanagement].[ISFData]
DROP TABLE IF EXISTS [costmanagement].[AmortizedCost]
DROP TABLE IF EXISTS [costmanagement].[AmortizedCostSummary]
DROP TABLE IF EXISTS [costmanagement].[ActualCost]
DROP TABLE IF EXISTS [costmanagement].[ActualCostSummary]
DROP TABLE IF EXISTS [costmanagement].[ReservationDetails]
DROP TABLE IF EXISTS [costmanagement].[AmortizedCostSummaryDate];
DROP PROCEDURE IF EXISTS [costmanagement].[ReorganiseActualCostIndex]
DROP PROCEDURE IF EXISTS [costmanagement].[ReorganiseAmortizedCostIndex]
DROP PROCEDURE IF EXISTS [costmanagement].[ReorganiseReservationDetailsIndex]
DROP PROCEDURE IF EXISTS [costmanagement].[addMonthPartitions]
DROP PROCEDURE IF EXISTS [costmanagement].[BuildSummaryTables]
DROP PROCEDURE IF EXISTS [costmanagement].[DeleteAmortizedCostDataForDateRange]
DROP PROCEDURE IF EXISTS [costmanagement].[DeleteActualCostDataForDateRange]
DROP PROCEDURE IF EXISTS [costmanagement].[UpdateActualCostSummaryTable]
DROP PROCEDURE IF EXISTS [costmanagement].[UpdateAmortizedCostSummaryTable]

IF( EXISTS( SELECT * FROM sys.partition_schemes WHERE name = 'monthRangePS' ) )
BEGIN
 DROP PARTITION SCHEME monthRangePS;
END

IF( EXISTS( SELECT * FROM sys.partition_functions WHERE name = 'monthRangePF' ) )
BEGIN
 DROP PARTITION FUNCTION monthRangePF;
END


DROP USER IF EXISTS [$(DATAFACTORYMSI)];

DROP ROLE IF EXISTS CostManagementDataLoader
create role CostManagementDataLoader

DROP ROLE IF EXISTS CostManagementDataReader
create role CostManagementDataReader


CREATE PARTITION FUNCTION monthRangePF (date)
    AS RANGE Right FOR VALUES (
        '2014-01-01'
        ,'2014-02-01'
        ,'2014-03-01'
        ,'2014-04-01'
        ,'2014-05-01'
        ,'2014-06-01'
        ,'2014-07-01'
        ,'2014-08-01'
        ,'2014-09-01'
        ,'2014-10-01'
        ,'2014-11-01'
        ,'2014-12-01'
        ,'2015-01-01'
        ,'2015-02-01'
        ,'2015-03-01'
        ,'2015-04-01'
        ,'2015-05-01'
        ,'2015-06-01'
        ,'2015-07-01'
        ,'2015-08-01'
        ,'2015-09-01'
        ,'2015-10-01'
        ,'2015-11-01'
        ,'2015-12-01'
        ,'2016-01-01'
        ,'2016-02-01'
        ,'2016-03-01'
        ,'2016-04-01'
        ,'2016-05-01'
        ,'2016-06-01'
        ,'2016-07-01'
        ,'2016-08-01'
        ,'2016-09-01'
        ,'2016-10-01'
        ,'2016-11-01'
        ,'2016-12-01'
        ,'2017-01-01'
        ,'2017-02-01'
        ,'2017-03-01'
        ,'2017-04-01'
        ,'2017-05-01'
        ,'2017-06-01'
        ,'2017-07-01'
        ,'2017-08-01'
        ,'2017-09-01'
        ,'2017-10-01'
        ,'2017-11-01'
        ,'2017-12-01'
        ,'2018-01-01'
        ,'2018-02-01'
        ,'2018-03-01'
        ,'2018-04-01'
        ,'2018-05-01'
        ,'2018-06-01'
        ,'2018-07-01'
        ,'2018-08-01'
        ,'2018-09-01'
        ,'2018-10-01'
        ,'2018-11-01'
        ,'2018-12-01'
        ,'2019-01-01'
        ,'2019-02-01'
        ,'2019-03-01'
        ,'2019-04-01'
        ,'2019-05-01'
        ,'2019-06-01'
        ,'2019-07-01'
        ,'2019-08-01'
        ,'2019-09-01'
        ,'2019-10-01'
        ,'2019-11-01'
        ,'2019-12-01'
        ,'2020-01-01'
        ,'2020-02-01'
        ,'2020-03-01'
        ,'2020-04-01'
        ,'2020-05-01'
        ,'2020-06-01'
        ,'2020-07-01'
        ,'2020-08-01'
        ,'2020-09-01'
        ,'2020-10-01'
        ,'2020-11-01'
        ,'2020-12-01'
        ,'2021-01-01'
        ,'2021-02-01'
        ,'2021-03-01'
        ,'2021-04-01'
        ,'2021-05-01'
        ,'2021-06-01'
        ,'2021-07-01'
        ,'2021-08-01'
        ,'2021-09-01'
        ,'2021-10-01'
        ,'2021-11-01'
        ,'2021-12-01'
        ,'2022-01-01'
        ,'2022-02-01'
        ,'2022-03-01'
        ,'2022-04-01'
        ,'2022-05-01'
        ,'2022-06-01'
        ,'2022-07-01'
        ,'2022-08-01'
        ,'2022-09-01'
        ,'2022-10-01'
        ,'2022-11-01'
        ,'2022-12-01'
        ,'2023-01-01'
        ,'2023-02-01'
    ) ;
GO

CREATE PARTITION SCHEME monthRangePS
    AS PARTITION monthRangePF
    ALL TO ('PRIMARY') ;
GO

DROP SCHEMA IF EXISTS costmanagement
go
create schema costmanagement
go

CREATE TABLE [costmanagement].[ISFData](
	[InstanceSizeFlexibilityGroup] [nvarchar](200) NULL,
	[ArmSkuName] [nvarchar](50) NULL,
	[Ratio] decimal (14,10) NULL,
) ON [PRIMARY]
GO

CREATE TABLE [costmanagement].[ActualCost](
	[InvoiceSectionName] [nvarchar](300) NULL,
	[AccountName] [nvarchar](300) NULL,
	[AccountOwnerId] [nvarchar](300) NULL,
	[SubscriptionId] [nvarchar](300) NULL,
	[SubscriptionName] [nvarchar](300) NULL,
	[ResourceGroup] [nvarchar](300) NULL,
	[ResourceLocation] [nvarchar](300) NULL,
	[Date] Date NULL,
	[ProductName] [nvarchar](300) NULL,
	[MeterCategory] [nvarchar](300) NULL,
	[MeterSubCategory] [nvarchar](300) NULL,
	[MeterId] [nvarchar](300) NULL,
	[MeterName] [nvarchar](300) NULL,
	[MeterRegion] [nvarchar](300) NULL,
	[UnitOfMeasure] [nvarchar](300) NULL,
	[Quantity] decimal (28,20) NULL,
	[EffectivePrice] decimal (28,20) NULL,
	[CostInBillingCurrency] decimal (28,20) NULL,
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
	[UnitPrice] decimal (28,20) NULL,
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
	[BillingPeriodStartDate] date NULL,
	[BillingPeriodEndDate] date NULL,
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
CREATE CLUSTERED COLUMNSTORE INDEX [cci_ActualCost] ON [costmanagement].[ActualCost] WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0) ON [monthRangePS] ([Date])
GO

CREATE TABLE [costmanagement].[ActualCostSummary](
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
	[Tags] [nvarchar](4000) NULL,
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
CREATE CLUSTERED COLUMNSTORE INDEX [cci_ActualCostSummary] ON [costmanagement].[ActualCostSummary] WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0) ON [monthRangePS] ([Date])
GO

CREATE TABLE [costmanagement].[AmortizedCost](
	[InvoiceSectionName] [nvarchar](300) NULL,
	[AccountName] [nvarchar](300) NULL,
	[AccountOwnerId] [nvarchar](300) NULL,
	[SubscriptionId] [nvarchar](300) NULL,
	[SubscriptionName] [nvarchar](300) NULL,
	[ResourceGroup] [nvarchar](300) NULL,
	[ResourceLocation] [nvarchar](300) NULL,
	[Date] date NULL,
	[ProductName] [nvarchar](300) NULL,
	[MeterCategory] [nvarchar](300) NULL,
	[MeterSubCategory] [nvarchar](300) NULL,
	[MeterId] [nvarchar](300) NULL,
	[MeterName] [nvarchar](300) NULL,
	[MeterRegion] [nvarchar](300) NULL,
	[UnitOfMeasure] [nvarchar](300) NULL,
	[Quantity] decimal (28,20) NULL,
	[EffectivePrice] decimal (28,20) NULL,
	[CostInBillingCurrency] decimal (28,20) NULL,
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
	[UnitPrice] decimal (28,20) NULL,
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
	[BillingPeriodStartDate] date NULL,
	[BillingPeriodEndDate] date NULL,
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
CREATE CLUSTERED COLUMNSTORE INDEX [cci_AmortizedCost] ON [costmanagement].[AmortizedCost] WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0) ON [monthRangePS] ([Date])
GO

CREATE TABLE [costmanagement].[AmortizedCostSummary](
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
	[Tags] [nvarchar](4000) NULL,
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
CREATE CLUSTERED COLUMNSTORE INDEX [cci_AmortizedCostSummary] ON [costmanagement].[AmortizedCostSummary] WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0) ON [monthRangePS] ([Date])
GO

Create View [costmanagement].[RegionSummaryDate] as
SELECT sum([CostInBillingCurrency]) as Cost
      ,[ResourceLocation]
      ,[Date]
  FROM [costmanagement].[ActualCost]
  GROUP BY
      [ResourceLocation]
      ,[Date]

GO

Create View [costmanagement].[ActualCostSummaryView] as
SELECT [AccountName]
      ,[SubscriptionName]
      ,[ResourceGroup]
      ,[Date]
     -- ,[MeterCategory]
     -- ,[MeterName]
      ,sum([CostInBillingCurrency]) as Cost
FROM  [costmanagement].[ActualCost]
Group by
       [AccountName]
      ,[SubscriptionName]
      ,[ResourceGroup]
      ,[Date]
     -- ,[MeterCategory]
     -- ,[MeterName]

GO

CREATE TABLE [costmanagement].[ReservationDetails](
	[InstanceFlexibilityGroup] [nvarchar](300) NULL,
	[InstanceFlexibilityRatio] [nvarchar](300) NULL,
	[InstanceId] [nvarchar](2000) NULL,
	[Kind] [nvarchar](300) NULL,
	[ReservationId] [nvarchar](300) NULL,
	[ReservationOrderId] [nvarchar](300) NULL,
	[ReservedHours] decimal (28,10) NULL,
	[SkuName] [nvarchar](300) NULL,
	[TotalReservedQuantity] decimal (28,10) NULL,
	[UsageDate] [nvarchar](30) NULL,
	[UsedHours] decimal (28,10) NULL
) ON [PRIMARY]
GO


CREATE CLUSTERED COLUMNSTORE INDEX [cci_ReservationDetails] ON [costmanagement].[ReservationDetails] WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0) ON [PRIMARY]
GO


create procedure costmanagement.BuildSummaryTables
with execute as owner
as
BEGIN

    drop table if EXISTS [costmanagement].[AmortizedCostSummaryDate];

    SELECT isnull([AccountName],'') [AccountName]
        ,isnull([SubscriptionName],'') [SubscriptionName]
        ,isnull([ResourceGroup],'') [ResourceGroup]
        ,isnull([Date],'')[Date]
        ,isnull([MeterCategory],'') [MeterCategory]
        ,isnull([MeterName],'') [MeterName]
        ,sum([CostInBillingCurrency]) as Cost
    INTO  [costmanagement].[AmortizedCostSummaryDate]
    FROM  [costmanagement].[AmortizedCost]
    Group by
        isnull([AccountName],'')
        ,isnull([SubscriptionName],'')
        ,isnull([ResourceGroup],'')
        ,isnull([Date],'')
        ,isnull([MeterCategory],'')
        ,isnull([MeterName],'');

    CREATE CLUSTERED COLUMNSTORE INDEX [cci_AmortizedCostSummaryDate] ON [costmanagement].[AmortizedCostSummaryDate] WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0) ON [PRIMARY];


    grant insert on costmanagement.AmortizedCostSummaryDate to CostManagementDataLoader
    grant select on costmanagement.AmortizedCostSummaryDate to CostManagementDataLoader
    grant delete on costmanagement.AmortizedCostSummaryDate to CostManagementDataLoader
    grant alter on costmanagement.AmortizedCostSummaryDate to CostManagementDataLoader

    grant select on costmanagement.AmortizedCostSummaryDate to CostManagementDataReader

end
GO

exec costmanagement.BuildSummaryTables

go

create procedure costmanagement.UpdateActualCostSummaryTable
    @DateRangeStart date
  , @DateRangeEnd date
with execute as owner
as
begin

    -- Delete Previous Data
    delete from [costmanagement].[ActualCostSummary]
    where Date >= @DateRangeStart
          and Date <= @DateRangeEnd

    -- Select Latest Data
    Insert INTO [costmanagement].[ActualCostSummary]
    (
        InvoiceSectionName
      , AccountName
      , AccountOwnerId
      , SubscriptionId
      , SubscriptionName
      , ResourceGroup
      , ResourceLocation
      , Date
      , ProductName
      , MeterCategory
      , MeterSubCategory
      , MeterId
      , MeterName
      , MeterRegion
      , UnitOfMeasure
      , Quantity
      , EffectivePrice
      , CostInBillingCurrency
      , CostCenter
      , ConsumedService
      , ResourceIdCount
      , Tags
      , OfferId
      , ServiceInfo1
      , ServiceInfo2
      , ResourceNameCount
      , ReservationId
      , ReservationName
      , UnitPrice
      , ProductOrderId
      , ProductOrderName
      , Term
      , PublisherType
      , PublisherName
      , ChargeType
      , Frequency
      , PricingModel
      , AvailabilityZone
      , BillingAccountId
      , BillingAccountName
      , BillingCurrencyCode
      , BillingPeriodStartDate
      , BillingPeriodEndDate
      , BillingProfileId
      , BillingProfileName
      , InvoiceSectionId
      , IsAzureCreditEligible
      , PartNumber
      , PayGPrice
      , PlanName
      , ServiceFamily
      , CostAllocationRuleName
    )
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
         , [Tags]
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



    -- update index
    ALTER INDEX [cci_ActualCostSummary]
    on [costmanagement].[ActualCostSummary]
    REORGANIZE
    with (COMPRESS_ALL_ROW_GROUPS = ON)

end
GO

create procedure costmanagement.UpdateAmortizedCostSummaryTable
@DateRangeStart date
,@DateRangeEnd date
with execute as owner
as
begin

    -- Delete Previous Data
    delete from [costmanagement].[AmortizedCostSummary]
    where Date >= @DateRangeStart
          and Date <= @DateRangeEnd

    -- Select Latest Data
    Insert INTO [costmanagement].[AmortizedCostSummary]
    (
        InvoiceSectionName
      , AccountName
      , AccountOwnerId
      , SubscriptionId
      , SubscriptionName
      , ResourceGroup
      , ResourceLocation
      , Date
      , ProductName
      , MeterCategory
      , MeterSubCategory
      , MeterId
      , MeterName
      , MeterRegion
      , UnitOfMeasure
      , Quantity
      , EffectivePrice
      , CostInBillingCurrency
      , CostCenter
      , ConsumedService
      , ResourceIdCount
      , Tags
      , OfferId
      , ServiceInfo1
      , ServiceInfo2
      , ResourceNameCount
      , ReservationId
      , ReservationName
      , UnitPrice
      , ProductOrderId
      , ProductOrderName
      , Term
      , PublisherType
      , PublisherName
      , ChargeType
      , Frequency
      , PricingModel
      , AvailabilityZone
      , BillingAccountId
      , BillingAccountName
      , BillingCurrencyCode
      , BillingPeriodStartDate
      , BillingPeriodEndDate
      , BillingProfileId
      , BillingProfileName
      , InvoiceSectionId
      , IsAzureCreditEligible
      , PartNumber
      , PayGPrice
      , PlanName
      , ServiceFamily
      , CostAllocationRuleName
    )
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
         , [Tags]
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
    FROM [costmanagement].[AmortizedCost]
    WHERE [costmanagement].[AmortizedCost].[Date] >= @DateRangeStart
          and [costmanagement].[AmortizedCost].[Date] <= @DateRangeEnd
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



    -- update index
    ALTER INDEX [cci_AmortizedCostSummary]
    on [costmanagement].[AmortizedCostSummary]
    REORGANIZE
    with (COMPRESS_ALL_ROW_GROUPS = ON)

end
GO

create procedure costmanagement.ReorganiseActualCostIndex as
begin
ALTER INDEX [cci_ActualCost] on [costmanagement].[ActualCost] REORGANIZE with (COMPRESS_ALL_ROW_GROUPS = ON)

end
go

create procedure costmanagement.ReorganiseAmortizedCostIndex as
begin
ALTER INDEX [cci_AmortizedCost] on [costmanagement].[AmortizedCost] REORGANIZE with (COMPRESS_ALL_ROW_GROUPS = ON)

end
go

create procedure costmanagement.ReorganiseReservationDetailsIndex as
begin
ALTER INDEX [cci_ReservationDetails] on [costmanagement].[ReservationDetails] REORGANIZE with (COMPRESS_ALL_ROW_GROUPS = ON)

end
go

create procedure costmanagement.DeleteActualCostDataForDateRange
@DateRangeStart date
,@DateRangeEnd date
as
begin

Delete from [costmanagement].[ActualCost] where Date >=  @DateRangeStart and Date <=@DateRangeEnd

end

go

create procedure costmanagement.DeleteAmortizedCostDataForDateRange
@DateRangeStart date
,@DateRangeEnd date
as
begin

Delete from [costmanagement].[AmortizedCost] where Date >=  @DateRangeStart and Date <=@DateRangeEnd

end

go

create procedure costmanagement.addMonthPartitions
AS
begin

    declare @nextPartitionValue date,
            @currentMaxPartitionValue date,
            @numFuturePartitions int;

    select @currentMaxPartitionValue = cast(max([value]) as date)
    from sys.partition_functions pf
    join sys.partition_range_values prv
        on pf.function_id = prv.function_id
    where pf.name = 'monthRangePF'

    select @numFuturePartitions = datediff(MONTH,GETUTCDATE(),@currentMaxPartitionValue);

    while (@numFuturePartitions < 24)
    BEGIN

        print 'Number of Future Partitions: ' + cast(@numFuturePartitions as varchar(5));

        select @nextPartitionValue = dateadd(month,1,cast(max([value]) as date))
        from sys.partition_functions pf
        join sys.partition_range_values prv
            on pf.function_id = prv.function_id
        where pf.name = 'monthRangePF'

        ALTER PARTITION FUNCTION monthRangePF ()
        SPLIT RANGE (@nextPartitionValue);

        ALTER PARTITION SCHEME monthRangePS
        NEXT USED [Primary]

        print 'New Partition added for: ' + convert(varchar(10), @nextPartitionValue,23 );

        select @currentMaxPartitionValue = cast(max([value]) as date)
        from sys.partition_functions pf
        join sys.partition_range_values prv
            on pf.function_id = prv.function_id
        where pf.name = 'monthRangePF'

        select @numFuturePartitions = datediff(MONTH,GETUTCDATE(),@currentMaxPartitionValue);

    END;

    print 'Current Number of Future Partitions: ' + cast(@numFuturePartitions as varchar(3));

END
go

-- Alter database permissions needed for alter partition statements
declare @stmt nvarchar(100) ='GRANT ALTER ON DATABASE::['+DB_NAME()+'] TO CostManagementDataLoader;' ;
exec sp_executesql @stmt;

grant insert on costmanagement.ActualCost to CostManagementDataLoader
grant select on costmanagement.ActualCost to CostManagementDataLoader
grant delete on costmanagement.ActualCost to CostManagementDataLoader
grant alter on costmanagement.ActualCost to CostManagementDataLoader

grant insert on costmanagement.ActualCostSummary to CostManagementDataLoader
grant select on costmanagement.ActualCostSummary to CostManagementDataLoader
grant delete on costmanagement.ActualCostSummary to CostManagementDataLoader
grant alter on costmanagement.ActualCostSummary to CostManagementDataLoader

grant insert on costmanagement.AmortizedCost to CostManagementDataLoader
grant select on costmanagement.AmortizedCost to CostManagementDataLoader
grant delete on costmanagement.AmortizedCost to CostManagementDataLoader
grant alter on costmanagement.AmortizedCost to CostManagementDataLoader

grant insert on costmanagement.AmortizedCostSummary to CostManagementDataLoader
grant select on costmanagement.AmortizedCostSummary to CostManagementDataLoader
grant delete on costmanagement.AmortizedCostSummary to CostManagementDataLoader
grant alter on costmanagement.AmortizedCostSummary to CostManagementDataLoader

grant insert on costmanagement.ReservationDetails to CostManagementDataLoader
grant select on costmanagement.ReservationDetails to CostManagementDataLoader
grant delete on costmanagement.ReservationDetails to CostManagementDataLoader
grant alter on costmanagement.ReservationDetails to CostManagementDataLoader

grant insert on [costmanagement].[ISFData] to CostManagementDataLoader
grant select on [costmanagement].[ISFData] to CostManagementDataLoader
grant delete on [costmanagement].[ISFData] to CostManagementDataLoader

grant execute on costmanagement.ReorganiseActualCostIndex to CostManagementDataLoader
grant execute on costmanagement.ReorganiseAmortizedCostIndex to CostManagementDataLoader
grant execute on costmanagement.ReorganiseReservationDetailsIndex to CostManagementDataLoader
grant execute on costmanagement.addMonthPartitions to CostManagementDataLoader
grant execute on costmanagement.DeleteActualCostDataForDateRange to CostManagementDataLoader
grant execute on costmanagement.DeleteAmortizedCostDataForDateRange to CostManagementDataLoader
grant execute on costmanagement.BuildSummaryTables to CostManagementDataLoader
grant execute on costmanagement.UpdateActualCostSummaryTable to CostManagementDataLoader
grant execute on costmanagement.UpdateAmortizedCostSummaryTable to CostManagementDataLoader

grant select on costmanagement.ActualCost to CostManagementDataReader
grant select on costmanagement.ActualCostSummary to CostManagementDataReader
grant select on costmanagement.AmortizedCost to CostManagementDataReader
grant select on costmanagement.AmortizedCostSummary to CostManagementDataReader
grant select on costmanagement.ReservationDetails to CostManagementDataReader
grant select on costmanagement.ISFData to CostManagementDataReader
grant select on costmanagement.AmortizedCostSummaryDate to CostManagementDataReader
grant select on costmanagement.RegionSummaryDate to CostManagementDataReader
grant select on costmanagement.ActualCostSummaryView to CostManagementDataReader

go

-- Create Login, User, and assign Role
Use Master
DROP LOGIN PowerBIReportUser;
CREATE LOGIN PowerBIReportUser WITH PASSWORD = '$(PBI_USER_PASSWORD)'

USE costmanagement;
GO
DROP USER IF EXISTS PowerBIReportUser;
CREATE user PowerBIReportUser for LOGIN PowerBIReportUser WITH DEFAULT_SCHEMA=[costmanagement];

ALTER ROLE CostManagementDataReader ADD MEMBER PowerBIReportUser
