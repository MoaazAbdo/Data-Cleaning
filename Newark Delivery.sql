/****************************** RAW Data Normalization ***************************/

--Truncate table [Delivery].[dbo].[Newark_RAWDATA]




alter table [Delivery].[dbo].[Newark_RAWDATA] alter column moq int

;With cte as ( SELECT * , Row_Number() Over ( Partition by [partNumber],[mfr],[priceBreak] order by cast([extractionDate] as date) desc ) RN
  FROM [Delivery].[dbo].[Newark_RAWDATA])
 delete from cte where RN > 1

  select distinct [StockFlag] from [Delivery].[dbo].[Newark_RAWDATA]

  select distinct [partNumber],[mfr],sku,[StockFlag] into [Delivery].[dbo].[Newark_BackOrder]
  from [Delivery].[dbo].[Newark_RAWDATA] where [StockFlag] like '%back Order%'

 

--1- updating StockFlag column ----

      update [Delivery].[dbo].[Newark_RAWDATA]
      set [StockFlag]=''


	/************************* updating packaging column according to DK breaks ***************************/

	    --alter table [Delivery].[dbo].[Newark_RAWDATA] 
	    --add NonalphaPart varchar(255),ZCompanyName varchar(255)

	    Update [Delivery].[dbo].[Newark_RAWDATA]
        Set NonalphaPart = [dbo].[fnRemovePatternFromString]([partNumber]) 
        ,ZCompanyName = b.ZCompany
        FROM [Delivery].[dbo].[Newark_RAWDATA] a
        Inner Join [Lookup].[dbo].[DKMouserComapnies] b on a.mfr = b.GivenMan

	    select distinct a.NonalphaPart,a.Zcompany,a.Price_Break_1 
        into [Delivery].[dbo].Helper2
        from [DigiKeyProject5].[dbo].[DKfeed] a
        inner join [Delivery].[dbo].[Newark_RAWDATA] b
        on a.NonAlphaPart=b.NonalphaPart and a.Zcompany=b.ZCompanyName
        where a.Packaging in ('TR','TAPE_BOX')

	    --alter table [Delivery].[dbo].[Newark_RAWDATA] 
	    --add DK_Reel int

        update a
        set DK_Reel=b.Price_Break_1
        from [Delivery].[dbo].[Newark_RAWDATA] a
        inner join [Delivery].[dbo].Helper2 b
        on a.NonalphaPart=b.NonalphaPart and a.ZCompanyName=b.Zcompany

		select  * from [Delivery].[dbo].[Newark_RAWDATA]
		--where partNumber='ABM8-14.7456MHZ-D1X-T'
        where [priceBreak]>=[DK_Reel]

		update [Delivery].[dbo].[Newark_RAWDATA]
	    set [packagingName]='Reel'
	    where [priceBreak]>=[DK_Reel]

			/*************************************** Cleansing Data *************************************/

	   select * from [Delivery].[dbo].[Newark_RAWDATA] where [priceBreak]=0
	
	   delete from [Delivery].[dbo].[Newark_RAWDATA] where [priceBreak]=0

	   select * from [Delivery].[dbo].[Newark_RAWDATA] where [price]=''

	   select * from [Delivery].[dbo].[Newark_RAWDATA] where [priceBreak]=''

	   select * from [Delivery].[dbo].[Newark_RAWDATA] where [priceBreak] is null

	   	/******** Updating data into another table to update PackLU and stock status columns ********/


	    ;With cte as ( Select [partNumber],[mfr],[sku],[partNumber_URL][BuyNow]
        ,Case when [packagingName] like 'Reel%' then 'Full Reel' else '' end as [packagingName]
        ,[SourceName],[StockFlag],[distributorType],[extractionDate]
        ,[leadTime],[moq],[pricesPerBreaks currencyRation][Ratio],[pricesPerBreaks originalCurrency][Currency],[StockFlag][StockStatus]
        ,Case when [packagingName] like '%Reel%' then 'Full Reel' else '' end as [PackLU]
        ,[stock],[price],[priceBreak],Row_Number() Over ( Partition by  [partNumber],[mfr],[priceBreak] Order by [partNumber],[mfr],[priceBreak],[partNumber_URL],[extractionDate],[moq] desc )RN
         FROM [Delivery].[dbo].[Newark_RAWDATA] )

        select * Into [Delivery].[dbo].[Newark1] from cte  where rn = 1

			/***********************************     Pivotting Data    *************************************/

			truncate table [Delivery].[dbo].[Farnell2]

			  update [Delivery].[dbo].[Newark1]
              set [price]=replace([price],'$','')
              where [price] like '$%'

	     update [Delivery].[dbo].[Newark1]
         set [price]=replace([price],'Web only price                 \t\t$','')
         where [price] like 'Web only price                 \t\t$%'

		 alter table [Delivery].[dbo].[Newark1]
		 alter column [price] real

		 select * from [Delivery].[dbo].[Newark1] where [price]=0

		 select distinct [price] from [Delivery].[dbo].[Newark1] order by [price] desc--asc --desc --asc



	    ;WITH CTE_Rank AS (
        SELECT [partNumber],[mfr],[Currency],[sku],[extractionDate],[leadTime],[moq],PackagingName,PackLU,[stock],[priceBreak],[price],
        [pricebreak_Ranc] = 'pricebreak'+ CAST(DENSE_RANK() OVER (PARTITION BY [PartNumber],[Mfr],[packagingName],[extractionDate],[moq] ORDER BY [pricebreak] ) AS VARCHAR(10))
       ,[price_Ranc] = 'price'+ CAST(DENSE_RANK() OVER (PARTITION BY [PartNumber],[Mfr],[packagingName],[extractionDate],[moq] ORDER BY [pricebreak] ) AS VARCHAR(10))
        FROM [Delivery].[dbo].[Newark1]
        --where [partNumber]='10127816-04LF'
		)

        Insert Into [Delivery].[dbo].[Farnell2] ( [partNumber],[mfr],[Currency],[sku],[extractionDate],[leadTime],[moq],[PackagingName],[PackLU]
       ,[stock],[Pricebreak1],[price1],[Pricebreak2],[price2],[Pricebreak3],[price3],[Pricebreak4]
       ,[price4],[Pricebreak5],[price5],[Pricebreak6],[price6],[Pricebreak7],[price7],[Pricebreak8],[price8]
       ,[Pricebreak9],[price9] )
        SELECT [partNumber],[mfr],[Currency],[sku],[extractionDate],[leadTime],[moq],PackagingName,PackLU, [stock]
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
       GROUP BY [partNumber],[mfr],[Currency],[sku],[extractionDate],[leadTime],[moq],PackagingName,PackLU,[stock]


	     select * from [Delivery].[dbo].[Farnell2] where mfr ='' 
	   --delete from [Delivery].[dbo].[Farnell2] where mfr =''


	         Update [Delivery].[dbo].[Farnell2] Set NonalphaPart = [dbo].[fnRemovePatternFromString]([partNumber])

       Update [Delivery].[dbo].[Farnell2]
       Set ZCompanyName = b.ZCompany
       FROM [Delivery].[dbo].[Farnell2] a
       Inner Join [Lookup].[dbo].[DKMouserComapnies] b on a.mfr = b.GivenMan
       Where ZCompanyName is Null or ZCompanyName=''

	   select  /*distinct*/ mfr from [Delivery].[dbo].[Farnell2] where ZCompanyName is null or ZCompanyName=''

	   update [Delivery].[dbo].[Farnell2] set ZCompanyName=mfr where ZCompanyName is null or ZCompanyName=''

	   --delete  from [Delivery].[dbo].[Farnell2] where ZCompanyName is null or ZCompanyName=''

	   	   SELECT b.[Packaging],convert(varchar, Cast(a.[extractionDate] as Date),101) [Last Update Date],b.[Manufacturer] [Vendor (PC)],'USD' [Currency Dimension]
      ,b.[Manufacturer_Part_Number] [Manufacturer Part Number],CONCAT(b.[Digikey_Part_Number],' - ',b.[Manufacturer_Part_Number]) [Part Class],
       b.[Digikey_Part_Number][DK_Part_Number],a.[stock] [Competitor QTY],a.[Pricebreak1] [Competitor Break 1],a.[price1] [Competitor Pricing 1] ,
       a.[Pricebreak2] [Competitor Break 2],a.[price2] [Competitor Pricing 2],a.[Pricebreak3] [Competitor Break 3],a.[price3] [Competitor Pricing 3],
       a.[Pricebreak4] [Competitor Break 4],a.[price4] [Competitor Pricing 4],a.[Pricebreak5] [Competitor Break 5],a.[price5] [Competitor Pricing 5],
       a.[Pricebreak6] [Competitor Break 6],a.[price6] [Competitor Pricing 6],a.[Pricebreak7] [Competitor Break 7],a.[price7] [Competitor Pricing 7],
       a.[Pricebreak8] [Competitor Break 8],a.[price8] [Competitor Pricing 8],a.[Pricebreak9] [Competitor Break 9],[price9] [Competitor Pricing 9],
       Case When b.Digikey_Part_Number is Null then 'Competitor Only' Else 'Common' End as Comment,
       a.[partNumber] [Competitor Manufacturer Part Number],a.[mfr] [Competitor Manufacturer],a.sku[Competitor SKU],a.[PackagingName] [Competitor Packaging],
       Null [Competitor Lead time],a.MOQ [Competitor MOQ],a.StockStatus [Stock Status],'https://www.newark.com/'[Site]
       Into FinalDelivery.dbo.Newark_US_USD_20210902
       FROM [Delivery].[dbo].[Farnell2] a Left Join [DigiKeyProject5].[dbo].[DKFeed] b
       On a.NonalphaPart = b.NonalphaPart and a.ZCompanyName = b.Zcompany and a.PackLU = b.PackLU

	   alter table FinalDelivery.dbo.Newark_US_USD_20210902 add  On_Order_1 varchar(50), Expected_Date_1 varchar(50) , On_Order_2 varchar(50) , Expected_Date_2 varchar(50) ,[Total_On_Order] varchar(50)

	   update FinalDelivery.dbo.Newark_US_USD_20210902 
	   set [Stock Status]='On Order'
	   from FinalDelivery.dbo.Newark_US_USD_20210902  a
	   inner join [Delivery].[dbo].[Newark_BackOrder] b
	   on a.[Competitor SKU]=b.sku

	   -- export parts that have on order dates to excel to normalize  ( by below query ) then truncate table [Delivery].[dbo].[Newark_Backorder_Normalized] and import the new normalized data again

	   SELECT [partNumber]
             ,[mfr]
             ,[sku]
             ,[StockFlag]
      FROM [Delivery].[dbo].[Newark_BackOrder]
      where [StockFlag] not in ('Available for back order','Available for back order.')


	  --delete from  [Delivery].[dbo].[Newark_BackOrder]
	  --where [StockFlag] in ('Available for back order','Available for back order.')

	   truncate table [Delivery].[dbo].[Newark_Backorder_Normalized]
	  -- import the new data to the above table


	  --update [Delivery].[dbo].[Newark_BackOrder]
	  --set [StockFlag]=replace([StockFlag],'Available for back order. More stock available week commencing ','')

	  -- update [Delivery].[dbo].[Newark_BackOrder]
	  --set [StockFlag]=replace([StockFlag],'Available for back order.Awaiting Delivery by','')

	  --update [Delivery].[dbo].[Newark_BackOrder]
	  --set [StockFlag]=replace([StockFlag],' ','')
	  --where [StockFlag] like '% '
       ------------

	   update FinalDelivery.dbo.Newark_US_USD_20210902
	   set Expected_Date_1=b.[StockFlag]
	   from FinalDelivery.dbo.Newark_US_USD_20210902 a
	   inner join [Delivery].[dbo].[Newark_Backorder_Normalized] b
	   on a.[Competitor SKU]=b.[sku]



  INSERT INTO FinalDelivery.dbo.Newark_US_USD_20210902
  SELECT a.[Packaging],'08/05/2021' [Last Update Date],a.[Vendor (PC)],a.[Currency Dimension],a.[Manufacturer Part Number],a.[Part Class],a.[DK_Part_Number],a.[Competitor QTY]
      ,a.[Competitor Break 1],a.[Competitor Pricing 1],a.[Competitor Break 2],a.[Competitor Pricing 2],a.[Competitor Break 3],a.[Competitor Pricing 3],a.[Competitor Break 4],a.[Competitor Pricing 4]
      ,a.[Competitor Break 5],a.[Competitor Pricing 5],a.[Competitor Break 6],a.[Competitor Pricing 6],a.[Competitor Break 7],a.[Competitor Pricing 7],a.[Competitor Break 8],a.[Competitor Pricing 8]
      ,a.[Competitor Break 9],a.[Competitor Pricing 9],a.[Comment],a.[Competitor Manufacturer Part Number],a.[Competitor Manufacturer],a.[Competitor SKU],a.[Competitor Packaging]
      ,a.[Competitor Lead time],a.[Competitor MOQ],a.[Stock Status],a.[Site],null On_Order_1,null Expected_Date_1,null On_Order_2,null Expected_Date_2,null[Total_On_Order]
  FROM FinalDelivery.dbo.Newark_US_USD_20210805 a
  Left Join FinalDelivery.dbo.Newark_US_USD_20210902 b On a.[Competitor Manufacturer Part Number] = b.[Competitor Manufacturer Part Number] -- and [dbo].[fnRemovePatternFromString](a.[Competitor Manufacturer]) = [dbo].[fnRemovePatternFromString](b.[Competitor Manufacturer])
  Where b.[Competitor Manufacturer] Is Null


     ;With Checkers as ( SELECT * , Row_Number() Over ( Partition by [Part Class] order by [Part Class] ) RN 
     FROM FinalDelivery.dbo.Newark_US_USD_20210902
     Where [Part Class] <> ' - ')
     delete from Checkers where  RN > 1      

	 /* updating [Last Update column] */

	 select count(*) , [Last Update Date] FROM [FinalDelivery].[dbo].Newark_US_USD_20210902 group by [Last Update Date]

	   ;with cte as (SELECT [Last Update Date],Row_Number () Over ( Order by [Competitor Manufacturer Part Number]) RN from 
    [FinalDelivery].[dbo].Newark_US_USD_20210902 )
    update cte
    set [Last Update Date]='08/09/2021' 
    where [Last Update Date]='08/05/2021' and RN BETWEEN 1700000 AND 2600000; 


	--update  [FinalDelivery].[dbo].Newark_US_USD_20210603 
	--set [Last Update Date]='05/06/2021'
	--where [Last Update Date] in ('05/03/2021','05/04/2021','05/05/2021')






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
       FROM FinalDelivery.dbo.Newark_US_USD_20210902