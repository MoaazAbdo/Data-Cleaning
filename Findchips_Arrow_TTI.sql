
-- 1- Normalizing & Removing duplicates Step

--truncate table [DigiKeyProject5].[dbo].[ArrowTTI]


;With cte as ( Select [partNumber],[mfr],[sku],[SourceURL]
,Case when [packagingName] like '%Reel%' then 'Full Reel' else '' end as [packagingName]
,[SourceName],[distributorType],[extractionDate]
,[moq],[pricesPerBreaks currencyRatio][Ratio],[pricesPerBreaks originalCurrency][Currency]
,[stock],[price],[priceBreak],Row_Number() Over ( Partition by  [partNumber],[mfr],[priceBreak] Order by [partNumber],[mfr],[priceBreak],[SourceURL], cast([extractionDate] as date) desc )RN
FROM [DigiKeyProject5].[dbo].[ArrowTTI]
where [SourceName] ='Arrow Electronics'
)
select * into [Delivery].[dbo].Arrow
from cte where rn = 1

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> /* Old Export From Oraby */

/*;With cte as ( Select [partNumber],[mfr],[sku],[SourceURL]
,Case when [packagingName] like '%Reel%' then 'Full Reel' else '' end as [packagingName]
,[SourceName],[distributorType],[extractionDate]
,[moq],[pricesPerBreaks currencyRatio][Ratio],[pricesPerBreaks originalCurrency][Currency]
,[stock] ,[pricesPerBreaks pricesList 0 priceBreak]priceBreak0,[pricesPerBreaks pricesList 0 price] price0
,[pricesPerBreaks pricesList 1 priceBreak] priceBreak1
,[pricesPerBreaks pricesList 1 price] price1
      ,[pricesPerBreaks pricesList 2 priceBreak] priceBreak2
      ,[pricesPerBreaks pricesList 2 price] price2
      ,[pricesPerBreaks pricesList 3 priceBreak] priceBreak3
      ,[pricesPerBreaks pricesList 3 price] price3
      ,[pricesPerBreaks pricesList 4 priceBreak] priceBreak4
      ,[pricesPerBreaks pricesList 4 price] price4
      ,[pricesPerBreaks pricesList 5 priceBreak] priceBreak5
      ,[pricesPerBreaks pricesList 5 price] price5
      ,[pricesPerBreaks pricesList 6 priceBreak] priceBreak6
      ,[pricesPerBreaks pricesList 6 price] price6
      ,[pricesPerBreaks pricesList 7 priceBreak] priceBreak7
      ,[pricesPerBreaks pricesList 7 price] price7
      ,[pricesPerBreaks pricesList 8 priceBreak] priceBreak8
      ,[pricesPerBreaks pricesList 8 price] price8
      ,[pricesPerBreaks pricesList 9 priceBreak] priceBreak9
      ,[pricesPerBreaks pricesList 9 price] price9
      ,[pricesPerBreaks pricesList 10 priceBreak] priceBreak10
      ,[pricesPerBreaks pricesList 10 price] price10
      ,[pricesPerBreaks pricesList 11 priceBreak] priceBreak11
      ,[pricesPerBreaks pricesList 11 price] price11
      ,[pricesPerBreaks pricesList 12 priceBreak] priceBreak12
      ,[pricesPerBreaks pricesList 12 price] price12 
	  ,Row_Number() Over ( Partition by  [partNumber],[pricesPerBreaks pricesList 0 priceBreak],[pricesPerBreaks pricesList 1 priceBreak],[pricesPerBreaks pricesList 2 priceBreak],[pricesPerBreaks pricesList 3 priceBreak],[pricesPerBreaks pricesList 4 priceBreak],[pricesPerBreaks pricesList 5 priceBreak],[pricesPerBreaks pricesList 6 priceBreak],[pricesPerBreaks pricesList 7 priceBreak],[pricesPerBreaks pricesList 8 priceBreak],[pricesPerBreaks pricesList 9 priceBreak],[pricesPerBreaks pricesList 10 priceBreak],[pricesPerBreaks pricesList 11 priceBreak],[pricesPerBreaks pricesList 12 priceBreak],[mfr]
	   Order by [partNumber],[pricesPerBreaks pricesList 0 priceBreak],[pricesPerBreaks pricesList 1 priceBreak],[pricesPerBreaks pricesList 2 priceBreak],[pricesPerBreaks pricesList 3 priceBreak],[pricesPerBreaks pricesList 4 priceBreak],[pricesPerBreaks pricesList 5 priceBreak],[pricesPerBreaks pricesList 6 priceBreak],[pricesPerBreaks pricesList 7 priceBreak],[pricesPerBreaks pricesList 8 priceBreak],[pricesPerBreaks pricesList 9 priceBreak],[pricesPerBreaks pricesList 10 priceBreak],[pricesPerBreaks pricesList 11 priceBreak],[pricesPerBreaks pricesList 12 priceBreak],[mfr],[SourceURL],[extractionDate] DESC )RN
FROM [FindChips].[dbo].[aggregator_FC]
)

Select * into [FindChips].[dbo].FindChips4 from cte where rn = 1   */


---------------------------------------- Pivotting the Requested Columns 

;WITH CTE_Rank AS (
SELECT  [partNumber],[mfr],[SourceName],[Currency],[sku],PackagingName,[stock],[priceBreak],[price],
[pricebreak_Ranc] = 'pricebreak'+ CAST(DENSE_RANK() OVER (PARTITION BY [PartNumber],[Mfr],[packagingName],[stock],sku ORDER BY [pricebreak] ) AS varchar(10))
,[price_Ranc] = 'price'+ CAST(DENSE_RANK() OVER (PARTITION BY [PartNumber],[Mfr],[packagingName],[stock],sku ORDER BY [pricebreak] ) AS varchar(10))
FROM [Delivery].[dbo].Arrow
--where [partNumber]='NMC0805NPO220J100TRPF'

)
SELECT [partNumber],[mfr],[SourceName],[Currency],[sku],PackagingName, [stock]
, Pricebreak1 = MAX(Pricebreak1) , [price1] = MAX([price1])
, Pricebreak2 = MAX(Pricebreak2) , [price2] = MAX([price2])
, Pricebreak3 = MAX(Pricebreak3) , [price3] = MAX([price3])
, Pricebreak4 = MAX(Pricebreak4) , [price4] = MAX([price4])
, Pricebreak5 = MAX(Pricebreak5) , [price5] = MAX([price5])
, Pricebreak6 = MAX(Pricebreak6) , [price6] = MAX([price6])
, Pricebreak7 = MAX(Pricebreak7) , [price7] = MAX([price7])
, Pricebreak8 = MAX(Pricebreak8) , [price8] = MAX([price8])
, Pricebreak9 = MAX(Pricebreak9) , [price9] = MAX([price9]) 
Into [Delivery].[dbo].[Arrow_Delivery]
 FROM CTE_Rank AS R
PIVOT(MAX([pricebreak]) FOR [pricebreak_Ranc] IN ([Pricebreak1], [Pricebreak2],[Pricebreak3],[Pricebreak4], [Pricebreak5],[Pricebreak6],[Pricebreak7], [Pricebreak8],[Pricebreak9])) AS DayOfMonthName
PIVOT(MAX([price]) FOR [price_Ranc] IN ([price1], [price2],[price3],[price4], [price5],[price6],[price7], [price8],[price9])) AS TargetPercentName
GROUP BY [partNumber],[mfr],[SourceName],[Currency],[sku],PackagingName,[stock]

--------------------------------- cleansing---------------------------------------------

select * from [Delivery].[dbo].[Arrow_Delivery] where [Pricebreak1] = 0 and [Pricebreak2] is not null
--delete from [Delivery].[dbo].[Arrow_Delivery]  where partNumber in ('FSA1156P6X','RB66P06C28G')  'MS3106A16-10SY'
delete from [Delivery].[dbo].[Arrow_Delivery] where [Pricebreak1] = 0
select * from [Delivery].[dbo].[Arrow_Delivery] where mfr =''
delete from [Delivery].[dbo].[Arrow_Delivery] where mfr =''



--------------------------------- Updating Non-Alpha Parts -----------------------------

alter table [Delivery].[dbo].[Arrow_Delivery] add NonalphaPart nvarchar(500)

Update [Delivery].[dbo].[Arrow_Delivery] Set NonalphaPart = [dbo].[fnRemovePatternFromString]([partNumber])

alter table [Delivery].[dbo].[Arrow_Delivery] add ZCompanyName nvarchar(500)

Update [Delivery].[dbo].[Arrow_Delivery]
Set ZCompanyName = b.ZCompany
FROM [Delivery].[dbo].[Arrow_Delivery] a
Inner Join [Lookup].[dbo].[DKMouserComapnies] b on a.mfr = b.GivenMan
Where ZCompanyName is Null

Select    mfr from [Delivery].[dbo].[Arrow_Delivery] where ZCompanyName='' or ZCompanyName is Null
--delete  from [Delivery].[dbo].[Arrow_Delivery] where ZCompanyName='' or ZCompanyName is Null
update [Delivery].[dbo].[Arrow_Delivery]  set ZCompanyName=mfr where ZCompanyName='' or ZCompanyName is Null

--------- Creating PartLUK table to recoginze the mapping between both findchips & Digi-Key-------------

--SELECT Distinct a.[partNumber] [MouserPN],a.[mfr] [MouserManufacturer],b.[Manufacturer] [DKManufacturer],b.[Manufacturer_Part_Number] [DKPN]
--into [FindChips].[dbo].Final1  FROM [Delivery].[dbo].[TTI_Delivery] a Left Join [DigiKeyProject5].[dbo].DKFeed b
--On a.NonalphaPart = b.NonalphaPart and a.ZCompanyName = b.Zcompany
----------------------------------------------------------------------------------------------

select * from [Delivery].[dbo].[Arrow_Delivery]
where [partNumber] like '% .'

update [Delivery].[dbo].[Arrow_Delivery] 
set [partNumber]=replace([partNumber],' .','')
where [partNumber] like '% .'

alter table [Delivery].[dbo].[Arrow_Delivery] add [extractionDate] varchar(500) , MOQ int


 update [Delivery].[dbo].[Arrow_Delivery]
 set [extractionDate]=b.[extractionDate] ,  MOQ=b.MOQ
 from [Delivery].[dbo].[Arrow_Delivery] a
 inner join [Delivery].[dbo].[Arrow] b on a.partNumber=b.partNumber and a.mfr=b.mfr

------------------------------ Generating the Final Report ------------------------------------

SELECT b.[Packaging],convert(varchar, Cast(a.[extractionDate] as Date),101) [Last Update Date],b.[Manufacturer] [Vendor (PC)],'USD' [Currency Dimension]
,b.[Manufacturer_Part_Number] [Manufacturer Part Number],CONCAT(b.[Digikey_Part_Number],' - ',b.[Manufacturer_Part_Number]) [Part Class],
b.[Digikey_Part_Number][DK_Part_Number],a.[stock] [Competitor QTY],a.[Pricebreak1] [Competitor Break 1],a.[price1] [Competitor Pricing 1] ,
a.[Pricebreak2] [Competitor Break 2],a.[price2] [Competitor Pricing 2],a.[Pricebreak3] [Competitor Break 3],a.[price3] [Competitor Pricing 3],
a.[Pricebreak4] [Competitor Break 4],a.[price4] [Competitor Pricing 4],a.[Pricebreak5] [Competitor Break 5],a.[price5] [Competitor Pricing 5],
a.[Pricebreak6] [Competitor Break 6],a.[price6] [Competitor Pricing 6],a.[Pricebreak7] [Competitor Break 7],a.[price7] [Competitor Pricing 7],
a.[Pricebreak8] [Competitor Break 8],a.[price8] [Competitor Pricing 8],a.[Pricebreak9] [Competitor Break 9],[price9] [Competitor Pricing 9],
Case When b.Digikey_Part_Number is Null then 'Competitor Only' Else 'Common' End as Comment,
a.[partNumber] [Competitor Manufacturer Part Number],a.[mfr] [Competitor Manufacturer],a.sku [Competitor SKU],a.[PackagingName] [Competitor Packaging],
 Null [Competitor Lead time],a.MOQ [Competitor MOQ],Null [Stock Status],'https://www.arrow.com/'[Site]
Into FinalDelivery.dbo.Arrow_US_USD_20210909
FROM [Delivery].[dbo].[Arrow_Delivery] a Left Join [DigiKeyProject5].[dbo].[DKFeed] b with (nolock) 
On a.NonalphaPart = b.NonalphaPart and a.ZCompanyName = b.Zcompany
--where a.SourceName='Newark element14'
--where a.SourceName='Arrow Electronics'
--where a.SourceName='Farnell element14'
--where a.SourceName='Texas Instruments'
--where a.SourceName='TTI'
--'https://www.arrow.com/'
/************************ Appending missing data from last delivery ***************************/

alter table FinalDelivery.dbo.Arrow_US_USD_20210909
alter column [Site] varchar(23)

INSERT INTO FinalDelivery.dbo.Arrow_US_USD_20210909
SELECT a.[Packaging],'08/12/2021' [Last Update Date],a.[Vendor (PC)],a.[Currency Dimension],a.[Manufacturer Part Number],a.[Part Class],a.[DK_Part_Number],a.[Competitor QTY]
      ,a.[Competitor Break 1],a.[Competitor Pricing 1],a.[Competitor Break 2],a.[Competitor Pricing 2],a.[Competitor Break 3],a.[Competitor Pricing 3],a.[Competitor Break 4],a.[Competitor Pricing 4]
      ,a.[Competitor Break 5],a.[Competitor Pricing 5],a.[Competitor Break 6],a.[Competitor Pricing 6],a.[Competitor Break 7],a.[Competitor Pricing 7],a.[Competitor Break 8],a.[Competitor Pricing 8]
      ,a.[Competitor Break 9],a.[Competitor Pricing 9],a.[Comment],a.[Competitor Manufacturer Part Number],a.[Competitor Manufacturer],a.[Competitor SKU],a.[Competitor Packaging]
      ,a.[Competitor Lead time],a.[Competitor MOQ],a.[Stock Status],a.[Site]
  FROM FinalDelivery.dbo.Arrow_US_USD_20210812 a
  Left Join FinalDelivery.dbo.Arrow_US_USD_20210909 b On a.[Competitor Manufacturer Part Number] = b.[Competitor Manufacturer Part Number] -- and [dbo].[fnRemovePatternFromString](a.[Competitor Manufacturer]) = [dbo].[fnRemovePatternFromString](b.[Competitor Manufacturer])
  Where b.[Competitor Manufacturer] Is Null

----------------------- part class checking and removing Duplicates --------------------------

;With Checkers as ( SELECT * , Row_Number() Over ( Partition by [Part Class] order by [Part Class] asc   ) RN 
 FROM FinalDelivery.dbo.Arrow_US_USD_20210909
Where [Part Class] <> ' - ')
 delete from Checkers where RN > 1 


----------------------- export as csv | delimiter and none text qualifier -----------------------

SELECT [Packaging]
      ,convert(varchar, Cast([Last Update Date] as Date), 101)[Last Update Date]
      ,[Vendor (PC)]
      ,[Currency Dimension]
      ,[Manufacturer Part Number]
      ,[Part Class]
      ,[DK_Part_Number]
      ,[Competitor QTY]
      ,[Competitor Break 1]
      ,Cast([Competitor Pricing 1] as varchar(20) )[Competitor Pricing 1]
      ,[Competitor Break 2]
      ,Cast([Competitor Pricing 2] as varchar(20) )[Competitor Pricing 2]
      ,[Competitor Break 3]
      ,Cast([Competitor Pricing 3] as varchar(20) )[Competitor Pricing 3]
      ,[Competitor Break 4]
      ,Cast([Competitor Pricing 4] as varchar(20) )[Competitor Pricing 4]
      ,[Competitor Break 5]
      ,Cast([Competitor Pricing 5] as varchar(20) )[Competitor Pricing 5]
      ,[Competitor Break 6]
      ,Cast([Competitor Pricing 6] as varchar(20) )[Competitor Pricing 6]
      ,[Competitor Break 7]
      ,Cast([Competitor Pricing 7] as varchar(20) )[Competitor Pricing 7]
      ,[Competitor Break 8]
      ,Cast([Competitor Pricing 8] as varchar(20) )[Competitor Pricing 8]
      ,[Competitor Break 9]
      ,Cast([Competitor Pricing 9] as varchar(20) )[Competitor Pricing 9]
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
	  ,null [On_Order_1]
      ,null [Expected_Date_1]
      ,null [On_Order_2]
      ,null [Expected_Date_2]
      ,null [Total_On_Order]
	  ,null [Lifecycle_Status]
  FROM [FinalDelivery].[dbo].Arrow_US_USD_20210909

  ----------------------------------------------