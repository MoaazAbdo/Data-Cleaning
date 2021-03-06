/****** Script for SelectTopNRows command from SSMS  ******/
-- 1- Remaining URLS
--;With cte as ( Select Distinct SourceURL FROM [DigiKeyProject5].[dbo].[RSComponents] )
--Select a.loc from SiteMaps.dbo.RS_Sitemap a left join cte on a.loc = cte.SourceURL where cte.SourceURL is null

--------------------------- truncate tables------------------

--Truncate table [DigiKeyProject5].[dbo].[RSComponents]


-------------------------------------------------

-- 2- Updates and Normalizing
USe DigiKeyProject5
Update [DigiKeyProject5].[dbo].[RSComponents] set  StockFlag = 'Discontinued product' Where  StockFlag like '%Discontinued product%' 
Update [DigiKeyProject5].[dbo].[RSComponents] set  StockFlag = '' Where  StockFlag like 'MYMEMORY%'
Update [DigiKeyProject5].[dbo].[RSComponents] set  packagingName = '' Where  packagingName like 'MYMEMORY%'
Update [DigiKeyProject5].[dbo].[RSComponents] set  SKU = Null, Price = Null, priceBreak = Null where pricebreak = 0
update d set  StockFlag =REPLACE(StockFlag, CHAR(10), '') from [DigiKeyProject5].[dbo].[RSComponents] d Where StockFlag Like '%' + CHAR(10) + '%'
update d set  StockFlag =REPLACE(StockFlag, CHAR(10), '') from [DigiKeyProject5].[dbo].[RSComponents] d Where packagingName Like '%' + CHAR(10) + '%'
Delete from [DigiKeyProject5].[dbo].[RSComponents]  where partnumber ='' or Len(partnumber) =1
Delete from [DigiKeyProject5].[dbo].[RSComponents]  where price is null and StockFlag <> 'Discontinued product' 
Delete from [DigiKeyProject5].[dbo].[RSComponents]  Where partnumber like '%E+1%'
Delete from [DigiKeyProject5].[dbo].[RSComponents]  Where  pricebreak is null
Delete from [DigiKeyProject5].[dbo].[RSComponents]  Where  pricebreak=0

;With cte as ( Select *, Row_Number () Over ( Partition by Partnumber , MFR, SKU,Pricebreak order by CAST(extractiondate AS DATE) DESC ) RN from [DigiKeyProject5].[dbo].[RSComponents] )
Delete from cte where RN > 1

--------------- Option 1

--;WITH CTE_Rank AS (
--SELECT [partNumber],[mfr],'GBP'[Currency],[SourceURL],[sku],convert(varchar, Cast([extractionDate] as Date),101)[extractionDate],[leadTime],[moq],PackagingName,
--Case when PackagingName like '%BAG%' then 'BAG'  when PackagingName like '%BOX%' then 'BOX'  when PackagingName like '%LOT%' then 'LOT'
-- when PackagingName like '%PACK%' then 'PACK'  when PackagingName like '%Reel%' then 'Reel'  when PackagingName like '%Tape%' then 'Tape'
-- when PackagingName like '%TRAY%' then 'TRAY'  when PackagingName like '%TUBE%' then 'TUBE' Else '' End as PackLU
--,[stock],[StockFlag][StockStatus],[priceBreak],[price],
--[pricebreak_Ranc] = 'pricebreak'+ CAST(DENSE_RANK() OVER (PARTITION BY [PartNumber],[Mfr],[SKU] ORDER BY [pricebreak] ) AS VARCHAR(10))
--,[price_Ranc] = 'price'+ CAST(DENSE_RANK() OVER (PARTITION BY [PartNumber],[Mfr],[SKU] ORDER BY [pricebreak] ) AS VARCHAR(10))
--FROM [DigiKeyProject5].[dbo].[RSComponents]
--)

--,cte as ( SELECT [partNumber],[mfr],[Currency],[SourceURL],[sku],[extractionDate],[leadTime],[moq],PackagingName,PackLU, [stock],[StockStatus]
--, Pricebreak1 = MAX(Pricebreak1) , [price1] = MAX([price1])
--, Pricebreak2 = MAX(Pricebreak2) , [price2] = MAX([price2])
--, Pricebreak3 = MAX(Pricebreak3) , [price3] = MAX([price3])
--, Pricebreak4 = MAX(Pricebreak4) , [price4] = MAX([price4])
--, Pricebreak5 = MAX(Pricebreak5) , [price5] = MAX([price5])
--, Pricebreak6 = MAX(Pricebreak6) , [price6] = MAX([price6])
--, Pricebreak7 = MAX(Pricebreak7) , [price7] = MAX([price7])
--, Pricebreak8 = MAX(Pricebreak8) , [price8] = MAX([price8])
--, Pricebreak9 = MAX(Pricebreak9) , [price9] = MAX([price9]) 
--FROM CTE_Rank AS R
--PIVOT(MAX([pricebreak]) FOR [pricebreak_Ranc] IN ([Pricebreak1], [Pricebreak2],[Pricebreak3],[Pricebreak4], [Pricebreak5],[Pricebreak6],[Pricebreak7], [Pricebreak8],[Pricebreak9])) AS DayOfMonthName
--PIVOT(MAX([price]) FOR [price_Ranc] IN ([price1], [price2],[price3],[price4], [price5],[price6],[price7], [price8],[price9])) AS TargetPercentName
--GROUP BY [partNumber],[mfr],[Currency],[SourceURL],[sku],[extractionDate],[leadTime],[moq],PackagingName,PackLU,[stock],[StockStatus]
--)

--,cte2 as ( Select *, Row_Number () Over ( Partition by Partnumber , MFR order by extractiondate ) RN from cte )

--Select * from cte2 where partnumber in ( Select partnumber from cte2 where RN > 1)



/***************************** On Order Normalizing ***********************/

  select distinct [StockFlag] FROM [DigiKeyProject5].[dbo].[RSComponents]

  update [DigiKeyProject5].[dbo].[RSComponents]
  set [StockFlag] =replace([StockFlag],'Voraussichtlich ab','Expected')
  where [StockFlag] like 'Voraussichtlich%'

   update [DigiKeyProject5].[dbo].[RSComponents]
  set [StockFlag] =replace([StockFlag],' verfÃ¼gbar. ','')
  where [StockFlag] like 'Expected%'

  update [DigiKeyProject5].[dbo].[RSComponents]
  set [StockFlag]=''
  where [StockFlag] not like 'Expected%'

    update [DigiKeyProject5].[dbo].[RSComponents]
  set [StockFlag] =''
  where [StockFlag] like 'Expected to be available from%'

----- Option 2

;WITH CTE_Rank AS (
SELECT [partNumber],[mfr],'EUR'[Currency],[SourceURL],[sku],convert(varchar, Cast([extractionDate] as Date),101)[extractionDate],[leadTime],[moq],PackagingName
,case when packagingName like '%Price Each%' then 'Price Each' else 'Other' End as PricingOption ,[stock],[StockFlag][StockStatus],[priceBreak],[price],
[pricebreak_Ranc] = 'pricebreak'+ CAST(DENSE_RANK() OVER (PARTITION BY [dbo].[fnRemovePatternFromString]([partNumber]),[Mfr],sku,SourceURL,case when packagingName like '%Price Each%' then 'Price Each' else 'Other' End
 ORDER BY [pricebreak] ) AS VARCHAR(10)),[price_Ranc] = 'price'+ CAST(DENSE_RANK() OVER (PARTITION BY [dbo].[fnRemovePatternFromString]([partNumber]),[Mfr],sku,SourceURL,case when packagingName like '%Price Each%' then 'Price Each' else 'Other' End ORDER BY [pricebreak] ) AS VARCHAR(10))
FROM [DigiKeyProject5].[dbo].[RSComponents]
)

,cte as ( SELECT [partNumber],[mfr],[Currency],PricingOption, MAX(extractiondate)extractiondate, MAX(stock) Stock, Min(MOQ)MOQ, MAX(PackagingName)PackagingName, Max(SKU)SKU, MAX(StockStatus) Stock_FLag
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
GROUP BY [partNumber],[mfr],sku,[Currency],PricingOption
)

,cte2 as ( Select *, Row_Number () Over ( Partition by Partnumber , MFR,sku order by PricingOption desc ) RN from cte )

Select Cast('' as varchar(255)) NonAlphaPart, Cast('' as varchar(255)) Zcompany , *  into DigiKeyproject5.dbo.RS_Final5
from cte2 where rn = 1 


--- 4- Updating final1_RS
Update a
Set [NonAlphaPart] = [dbo].[fnRemovePatternFromString](a.partnumber)
, Zcompany = b.zcompany
from [DigiKeyProject5].[dbo].[RS_Final5] a
Inner Join Lookup.dbo.DKMouserComapnies b on a.mfr = b.GivenMan


select distinct mfr from [DigiKeyProject5].[dbo].[RS_Final5] where Zcompany is null or Zcompany=''

update [DigiKeyProject5].[dbo].[RS_Final5] set Zcompany=mfr where Zcompany is null or Zcompany=''


Update [DigiKeyProject5].[dbo].[RS_Final5] 
Set Zcompany = 'Brad' where MFR = 'Brad'

;With cte as ( SELECT * ,Row_Number () Over ( Partition by nonalphapart, zcompany,sku order by PricingOption DESC, Stock DESC ) RN1
From [DigiKeyProject5].[dbo].[RS_Final5] )

Delete from cte where RN1 > 1

-- 5 - Generating the report

SELECT b.[Packaging],convert(varchar, Cast(a.[extractionDate] as Date),101) [Last Update Date],b.[Manufacturer] [Vendor (PC)],'EUR' [Currency Dimension]
,b.[Manufacturer_Part_Number] [Manufacturer Part Number],CONCAT(b.[Digikey_Part_Number],' - ',b.[Manufacturer_Part_Number]) [Part Class],
b.[Digikey_Part_Number][DK_Part_Number],a.[stock] [Competitor QTY],b.Price_Break_1[DK Break 1],b.Price_1[DK Price1],a.Pricebreak1 [Competitor Break 1],a.price1 [Competitor Pricing 1] ,
a.Pricebreak2 [Competitor Break 2],a.price2 [Competitor Pricing 2],a.Pricebreak3 [Competitor Break 3],a.price3 [Competitor Pricing 3],
a.Pricebreak4 [Competitor Break 4],a.price4 [Competitor Pricing 4],a.Pricebreak5 [Competitor Break 5],a.price5 [Competitor Pricing 5],
a.Pricebreak6 [Competitor Break 6],a.price6 [Competitor Pricing 6],a.Pricebreak7 [Competitor Break 7],a.price7 [Competitor Pricing 7],
a.Pricebreak8 [Competitor Break 8],a.price8 [Competitor Pricing 8],a.Pricebreak9 [Competitor Break 9],price9 [Competitor Pricing 9],
Case When b.Digikey_Part_Number is Null then 'RS Part Only' Else 'Common' End as Comment,
a.[partNumber] [Competitor Manufacturer Part Number],a.[mfr] [Competitor Manufacturer],a.[sku][Competitor SKU],a.[PackagingName] [Competitor Packaging],
NULL [Competitor Lead time],a.MOQ [Competitor MOQ],a.[Stock_FLag][Stock Status],'https://de.rs-online.com/web/'[Site]
Into FinalDelivery.dbo.RS_DE_EUR_20210826
FROM [DigiKeyProject5].[dbo].[RS_Final5] a Left Join [DigiKeyProject5].[dbo].[DKFeed] b
On a.NonalphaPart = b.NonalphaPart and a.ZCompany = b.Zcompany 

------------------------ eaton issue ------------------------------

 update FinalDelivery.dbo.RS_DE_EUR_20210826
  set [Competitor Manufacturer Part Number]=REPLACE([Competitor Manufacturer Part Number], '|', '}')
  where [Competitor Manufacturer Part Number] like '%|%'
 
 --------------------------- LineFeed Issue ---------------------------

 --select [Part Class] from FinalDelivery.dbo.RS_DE_EUR_20201126
 --where [Part Class]<>' - '
 --order by [Part Class] asc


 --update FinalDelivery.dbo.RS_DE_EUR_20201001
 -- set [DK_Part_Number] =REPLACE([DK_Part_Number], '      ', ''),[Part Class]=REPLACE([Part Class], '      ', '')


  /***************************** Normalization ****************************************/

   update [FinalDelivery].[dbo].RS_DE_EUR_20210826
  set [Competitor Packaging]=''
  where [Competitor Packaging] like 'MYMEMORY WARNING:%'

     update [FinalDelivery].[dbo].RS_DE_EUR_20210826
  set [Stock Status]=''
  where [Stock Status] like 'MYMEMORY WARNING:%'

  alter table [FinalDelivery].[dbo].RS_DE_EUR_20210826 alter column [DK Price1] float

  select * from [FinalDelivery].[dbo].RS_DE_EUR_20210826
  where [Competitor Break 1]<>[DK Break 1]

    select *  FROM [FinalDelivery].[dbo].RS_DE_EUR_20210826
  where [Competitor Pricing 1] > 10*[DK Price1] and [DK Price1]<>'0' and [Competitor Break 1]=[DK Break 1]

  delete  FROM [FinalDelivery].[dbo].RS_DE_EUR_20210826
  where [Competitor Pricing 1] > 10*[DK Price1] and [DK Price1]<>'0' and [Competitor Break 1]=[DK Break 1]



  /************ updating on order columns ***************/

    select distinct [partNumber],[mfr],[Stock_FLag] into [DigiKeyProject5].[dbo].[RS_Final_OnOrder]
  FROM [DigiKeyProject5].[dbo].[RS_Final5]
  where [Stock_FLag] like 'Expected%'


     update [FinalDelivery].[dbo].RS_DE_EUR_20210826
  set [Stock Status]='On Order'
  where [Stock Status] like 'Expected%'

  update [FinalDelivery].[dbo].RS_DE_EUR_20210826
  set [Stock Status]=''
  where [Stock Status]<>'On Order'

  alter table [FinalDelivery].[dbo].RS_DE_EUR_20210826
  add  [On_Order_1] int
      ,[Expected_Date_1] varchar(255)
      ,[On_Order_2] int
      ,[Expected_Date_2] varchar(255)
      ,[Total_On_Order] int

	    update [DigiKeyProject5].[dbo].[RS_Final_OnOrder]
  set [Stock_FLag]=replace([Stock_FLag],'Expected ','')

   update [DigiKeyProject5].[dbo].[RS_Final_OnOrder]
  set [Stock_FLag]=replace([Stock_FLag],' ','')

     update [DigiKeyProject5].[dbo].[RS_Final_OnOrder]
  set [Stock_FLag]=replace([Stock_FLag],'.','/')

  alter table [DigiKeyProject5].[dbo].[RS_Final_OnOrder] add Expected_Date_Correct varchar(50)

  update [DigiKeyProject5].[dbo].[RS_Final_OnOrder]
  set Expected_Date_Correct=convert(varchar(50),convert(DATETIME, [Stock_FLag], 105), 101)

  select * from [DigiKeyProject5].[dbo].[RS_Final_OnOrder]


    update a
  set [Expected_Date_1]=b.Expected_Date_Correct
  from [FinalDelivery].[dbo].RS_DE_EUR_20210826 a
  inner join [DigiKeyProject5].[dbo].[RS_Final_OnOrder] b 
  on a.[Competitor Manufacturer Part Number]=b.[partNumber] 
  and a.[Competitor Manufacturer]=b.[mfr] and a.[Stock Status]='On Order'

   select count(*),[Last Update Date] FROM [FinalDelivery].[dbo].RS_DE_EUR_20210826 group by [Last Update Date]

  INSERT INTO [FinalDelivery].[dbo].RS_DE_EUR_20210826
SELECT a.[Packaging],'08/15/2021' [Last Update Date],a.[Vendor (PC)],a.[Currency Dimension],a.[Manufacturer Part Number],a.[Part Class],a.[DK_Part_Number],a.[Competitor QTY],a.[DK Break 1],a.[DK Price1]
      ,a.[Competitor Break 1],a.[Competitor Pricing 1],a.[Competitor Break 2],a.[Competitor Pricing 2],a.[Competitor Break 3],a.[Competitor Pricing 3],a.[Competitor Break 4],a.[Competitor Pricing 4]
      ,a.[Competitor Break 5],a.[Competitor Pricing 5],a.[Competitor Break 6],a.[Competitor Pricing 6],a.[Competitor Break 7],a.[Competitor Pricing 7],a.[Competitor Break 8],a.[Competitor Pricing 8]
      ,a.[Competitor Break 9],a.[Competitor Pricing 9],a.[Comment],a.[Competitor Manufacturer Part Number],a.[Competitor Manufacturer],a.[Competitor SKU],a.[Competitor Packaging]
      ,a.[Competitor Lead time],a.[Competitor MOQ],a.[Stock Status],a.[Site],a.[On_Order_1],a.Expected_Date_1,a.On_Order_2,a.Expected_Date_2,a.Total_On_Order
  FROM [FinalDelivery].[dbo].RS_DE_EUR_20210715 a
  Left Join [FinalDelivery].[dbo].RS_DE_EUR_20210826 b On a.[Competitor Manufacturer Part Number] = b.[Competitor Manufacturer Part Number] -- and [dbo].[fnRemovePatternFromString](a.[Competitor Manufacturer]) = [dbo].[fnRemovePatternFromString](b.[Competitor Manufacturer])
  Where b.[Competitor Manufacturer] Is Null


  select distinct [Stock Status] FROM [FinalDelivery].[dbo].RS_DE_EUR_20210826

  ---------------------------- Part class duplication issue ----------------------------------------


  ;With Checkers as ( SELECT * , Row_Number() Over ( Partition by [Part Class] order by [Competitor Pricing 1] asc) RN 
FROM FinalDelivery.dbo.RS_DE_EUR_20210826
Where [Part Class] <> ' - ')
delete from Checkers where RN > 1 

 /***************** updating Packaging column ****************/

 update FinalDelivery.dbo.RS_DE_EUR_20210826
 set [Competitor Packaging]=''

---------- Final : Export data into csv | delimiter without any text qualifiers

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
	  ,[Site]
	  ,0 [FACTORY_STOCK]
	  ,[On_Order_1]
      ,[Expected_Date_1]
      ,[On_Order_2]
      ,[Expected_Date_2]
      ,[Total_On_Order]
	  ,null [Lifecycle_Status]
  FROM FinalDelivery.dbo.RS_DE_EUR_20210826
