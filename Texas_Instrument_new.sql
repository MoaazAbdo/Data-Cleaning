/****** Script for SelectTopNRows command from SSMS  ******/


--truncate table [DigiKeyProject5].[dbo].[Texas_Instrument_OLD]

-- first Normalizing values on original Table columns partNumber and sku --
    
	update [DigiKeyProject5].[dbo].[Texas_Instrument_OLD]
	set partNumber=replace([partNumber],' ACTIVE',''),sku=replace([sku],' ACTIVE','')

	update [DigiKeyProject5].[dbo].[Texas_Instrument_OLD]
	set partNumber=replace([partNumber],' NOT RECOMMENDED FOR NEW DESIGNS',''),sku=replace([sku],' NOT RECOMMENDED FOR NEW DESIGNS','')

	update [DigiKeyProject5].[dbo].[Texas_Instrument_OLD]
	set partNumber=replace([partNumber],' LAST TIME BUY',''),sku=replace([sku],' LAST TIME BUY','')

   

USe DigiKeyProject5
Go

;WITH CTE_Rank AS (
SELECT [partNumber],[mfr],[Currency],[SourceURL],[sku],[extractionDate],[moq],Concat('Packaging QTY : ',Replace(Replace([packagingName],'â€‚',' '),'|',' & Carrier :'))[packagingName],
[stock],[stockFlag],[priceBreak],[price],Row_Number() Over ( Partition by [partNumber],[mfr] Order by [partNumber],[mfr] desc ) RN,
[pricebreak_Ranc] = 'pricebreak'+ CAST(DENSE_RANK() OVER (PARTITION BY [PartNumber],[Mfr],[packagingName] ORDER BY [pricebreak] ) AS VARCHAR(10))
,[price_Ranc] = 'price'+ CAST(DENSE_RANK() OVER (PARTITION BY [PartNumber],[Mfr],[packagingName] ORDER BY [pricebreak] ) AS VARCHAR(10))
FROM DigiKeyProject5.[dbo].[Texas_Instrument_OLD]
)

,cte as ( SELECT [partNumber],[mfr],[Currency],[SourceURL],[sku],[extractionDate],[moq],PackagingName,[stock],[stockFlag]
, Pricebreak1 = MAX(Pricebreak1) , [price1] = MAX([price1])
, Pricebreak2 = MAX(Pricebreak2) , [price2] = MAX([price2])
, Pricebreak3 = MAX(Pricebreak3) , [price3] = MAX([price3])
, Pricebreak4 = MAX(Pricebreak4) , [price4] = MAX([price4])
, Pricebreak5 = MAX(Pricebreak5) , [price5] = MAX([price5])
, Pricebreak6 = MAX(Pricebreak6) , [price6] = MAX([price6])
, Pricebreak7 = MAX(Pricebreak7) , [price7] = MAX([price7])
, Pricebreak8 = MAX(Pricebreak8) , [price8] = MAX([price8])
, Pricebreak9 = MAX(Pricebreak9) , [price9] = MAX([price9]) 
FROM CTE_Rank AS R
PIVOT(MAX([pricebreak]) FOR [pricebreak_Ranc] IN ([Pricebreak1], [Pricebreak2],[Pricebreak3],[Pricebreak4], [Pricebreak5],[Pricebreak6],[Pricebreak7], [Pricebreak8],[Pricebreak9])) AS DayOfMonthName
PIVOT(MAX([price]) FOR [price_Ranc] IN ([price1], [price2],[price3],[price4], [price5],[price6],[price7], [price8],[price9])) AS TargetPercentName
GROUP BY [partNumber],[mfr],[Currency],[SourceURL],[sku],[extractionDate],[moq],PackagingName,[stock],[stockFlag] )

, DK as ( Select * from [DigiKeyProject5].[dbo].[DKFeed] where Manufacturer = 'TEXAS INSTRUMENTS' )

SELECT b.[Packaging],convert(varchar, Cast(a.[extractionDate] as Date),101) [Last Update Date],b.[Manufacturer] [Vendor (PC)],'USD' [Currency Dimension]
,b.[Manufacturer_Part_Number] [Manufacturer Part Number],CONCAT(b.[Digikey_Part_Number],' - ',b.[Manufacturer_Part_Number]) [Part Class],
b.[Digikey_Part_Number][DK_Part_Number],a.[stock] [Competitor QTY],a.Pricebreak1 [Competitor Break 1],a.price1 [Competitor Pricing 1] ,
a.Pricebreak2 [Competitor Break 2],a.price2 [Competitor Pricing 2],a.Pricebreak3 [Competitor Break 3],a.price3 [Competitor Pricing 3],
a.Pricebreak4 [Competitor Break 4],a.price4 [Competitor Pricing 4],a.Pricebreak5 [Competitor Break 5],a.price5 [Competitor Pricing 5],
a.Pricebreak6 [Competitor Break 6],a.price6 [Competitor Pricing 6],a.Pricebreak7 [Competitor Break 7],a.price7 [Competitor Pricing 7],
a.Pricebreak8 [Competitor Break 8],a.price8 [Competitor Pricing 8],a.Pricebreak9 [Competitor Break 9],price9 [Competitor Pricing 9],
Case When b.Digikey_Part_Number is Null then 'Competitor Only' Else 'Common' End as Comment,
a.[partNumber] [Competitor Manufacturer Part Number],a.[mfr] [Competitor Manufacturer],a.[sku][Competitor SKU],a.[PackagingName] [Competitor Packaging],
'NULL' [Competitor Lead time], 'NULL' [Competitor MOQ],a.[stockFlag][Stock Status] Into FinalDelivery.dbo.Texas_Instruments_US_USD_20210826
FROM cte a Left Join DK b
On a.Partnumber = b.Manufacturer_Part_Number


;With cte as ( SELECT * ,Row_Number() Over( Partition by [Part Class],[Competitor Manufacturer Part Number], [Competitor Manufacturer] Order by [Part Class] ) RN
FROM FinalDelivery.dbo.Texas_Instruments_US_USD_20210826 )

delete from cte where RN > 1 


-- ;With Checkers as ( SELECT * , Row_Number() Over ( Partition by [Part Class] order by [Part Class] ) RN 
--  FROM FinalDelivery.dbo.Texas_Instruments_US_USD_20210624
--  Where [Part Class] <> ' - ')
--delete from Checkers where RN > 1


select * from FinalDelivery.dbo.Texas_Instruments_US_USD_20210826 where [Competitor Break 1]=0

-- delete from FinalDelivery.dbo.Texas_Instruments_US_USD_20210826 where [Competitor Break 1]=0


  --update [FinalDelivery].[dbo].Texas_Instruments_US_USD_20210225
  --set [Competitor Pricing 1]=[Stock Status]
  --where [Competitor Break 1]=0

    select distinct [Stock Status] FROM [FinalDelivery].[dbo].Texas_Instruments_US_USD_20210826 where [Competitor Break 1]<>0

	select count(*),[Stock Status] FROM [FinalDelivery].[dbo].Texas_Instruments_US_USD_20210826 group by [Stock Status]

	update [FinalDelivery].[dbo].Texas_Instruments_US_USD_20210826
	set [Stock Status]=replace([Stock Status],'New - æœ‰å¯ç”¨å®šåˆ¶å·å¸¦','')



	
	 -- update [FinalDelivery].[dbo].Texas_Instruments_US_USD_20210422
  --set [Stock Status]='In stock'
  --where [Competitor Break 1]=0

  -- update [FinalDelivery].[dbo].Texas_Instruments_US_USD_20210225
  --set [Competitor Break 1]='1'
  --where [Competitor Break 1]=0


  --delete from [FinalDelivery].[dbo].Texas_Instruments_US_USD_20210527
  --where [Competitor Pricing 1]=''


  select * from [FinalDelivery].[dbo].Texas_Instruments_US_USD_20210826
  where [Competitor Pricing 1] like '% %'

  --update [FinalDelivery].[dbo].Texas_Instruments_US_USD_20210325
  --set [Competitor Pricing 1]=replace([Competitor Pricing 1],' ','')
  --where [Competitor Pricing 1] like '% %'

  alter table [FinalDelivery].[dbo].Texas_Instruments_US_USD_20210826 alter column [Competitor Pricing 1] float


  select count(*), [Last Update Date] from [FinalDelivery].[dbo].Texas_Instruments_US_USD_20210826 group by [Last Update Date]


    INSERT INTO [FinalDelivery].[dbo].Texas_Instruments_US_USD_20210826
SELECT a.[Packaging],'08/15/2021' [Last Update Date],a.[Vendor (PC)],a.[Currency Dimension],a.[Manufacturer Part Number],a.[Part Class],a.[DK_Part_Number],a.[Competitor QTY]
      ,a.[Competitor Break 1],a.[Competitor Pricing 1],a.[Competitor Break 2],a.[Competitor Pricing 2],a.[Competitor Break 3],a.[Competitor Pricing 3],a.[Competitor Break 4],a.[Competitor Pricing 4]
      ,a.[Competitor Break 5],a.[Competitor Pricing 5],a.[Competitor Break 6],a.[Competitor Pricing 6],a.[Competitor Break 7],a.[Competitor Pricing 7],a.[Competitor Break 8],a.[Competitor Pricing 8]
      ,a.[Competitor Break 9],a.[Competitor Pricing 9],a.[Comment],a.[Competitor Manufacturer Part Number],a.[Competitor Manufacturer],a.[Competitor SKU],a.[Competitor Packaging]
      ,a.[Competitor Lead time],a.[Competitor MOQ],a.[Stock Status]
  FROM [FinalDelivery].[dbo].Texas_Instruments_US_USD_20210722 a
  Left Join [FinalDelivery].[dbo].Texas_Instruments_US_USD_20210826 b On a.[Competitor Manufacturer Part Number] = b.[Competitor Manufacturer Part Number] -- and [dbo].[fnRemovePatternFromString](a.[Competitor Manufacturer]) = [dbo].[fnRemovePatternFromString](b.[Competitor Manufacturer])
  Where b.[Competitor Manufacturer] Is Null


   ;With Checkers as ( SELECT * , Row_Number() Over ( Partition by [Part Class] order by [Part Class] ) RN 
  FROM FinalDelivery.dbo.Texas_Instruments_US_USD_20210826
  Where [Part Class] <> ' - ')
delete from Checkers where RN > 1


/************************** Export (CSV File with | delimiter without text qualifier)***********************/


SELECT [Packaging]
      ,convert(varchar, Cast([Last Update Date] as Date), 101)[Last Update Date]
      ,[Vendor (PC)]
      ,[Currency Dimension]
      ,[Manufacturer Part Number]
      ,[Part Class]
      ,[DK_Part_Number]
      ,[Competitor QTY]
      ,[Competitor Break 1]
      ,Cast([Competitor Pricing 1] as varchar(10) )[Competitor Pricing 1]
      ,[Competitor Break 2]
      ,Cast([Competitor Pricing 2] as varchar(10) )[Competitor Pricing 2]
      ,[Competitor Break 3]
      ,Cast([Competitor Pricing 3] as varchar(10) )[Competitor Pricing 3]
      ,[Competitor Break 4]
      ,Cast([Competitor Pricing 4] as varchar(10) )[Competitor Pricing 4]
      ,[Competitor Break 5]
      ,Cast([Competitor Pricing 5] as varchar(10) )[Competitor Pricing 5]
      ,[Competitor Break 6]
      ,Cast([Competitor Pricing 6] as varchar(10) )[Competitor Pricing 6]
      ,[Competitor Break 7]
      ,Cast([Competitor Pricing 7] as varchar(10) )[Competitor Pricing 7]
      ,[Competitor Break 8]
      ,Cast([Competitor Pricing 8] as varchar(10) )[Competitor Pricing 8]
      ,[Competitor Break 9]
      ,Cast([Competitor Pricing 9] as varchar(10) )[Competitor Pricing 9]
      ,[Comment]
      ,[Competitor Manufacturer Part Number]
      ,[Competitor Manufacturer]
      ,[Competitor SKU]
      ,[Competitor Packaging]
      ,[Competitor Lead time]
      ,[Competitor MOQ]
      ,[Stock Status]
	  ,'https://www.ti.com/store/ti/en/'[Site]
	  ,0 [FACTORY_STOCK]
	  ,null [On_Order_1]
      ,null [Expected_Date_1]
      ,null [On_Order_2]
      ,null [Expected_Date_2]
      ,null [Total_On_Order]
	  ,null [Lifecycle_Status]
  FROM [FinalDelivery].[dbo].Texas_Instruments_US_USD_20210826
