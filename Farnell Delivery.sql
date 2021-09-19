
-- Truncate table [Delivery].[dbo].[Farnell_Export]

              /********************** Data Normalization ******************/

	--1- Translating not translated values in StockFlag column:

	    update [Delivery].[dbo].[Farnell_Export]
	    set [StockFlag]='In Stock'
	    where [StockFlag] like '%Lager%'

	    update [Delivery].[dbo].[Farnell_Export]
	    set [StockFlag]='Available with reorder'
	    where [StockFlag] like '%Nachbestellung lieferbar%'

	--2- Normalize values in stockflag column to accepted values :

	    update [Delivery].[dbo].[Farnell_Export]
		set  [StockFlag]='In Stock'
		where [StockFlag] like '%Stock%'

		update [Delivery].[dbo].[Farnell_Export]
		set  [StockFlag]='Non-Stocked'
		where [StockFlag]<>'In Stock'

	--3- translating not translated valus in packagingName column :

	 --   update [Delivery].[dbo].[Farnell_Export]
	 --   set [packagingName]=replace([packagingName],'Rolle à 									','Roll of ')
	 --   where [packagingName] like 'Rolle à 									%' 

		--update [Delivery].[dbo].[Farnell_Export]
	 --   set [packagingName]=replace([packagingName],'Rolle at','Roll of')
	 --   where [packagingName] like 'Rolle at%' 
	
  --  	update [Delivery].[dbo].[Farnell_Export]
	 --   set [packagingName]=replace([packagingName],'Fuß','foot')
	 --   where [packagingName] like '%Fuß%' 

		--update [Delivery].[dbo].[Farnell_Export]
	 --   set [packagingName]=replace([packagingName],'Paar','pair')
	 --   where [packagingName] like '%Paar%'

		--update [Delivery].[dbo].[Farnell_Export]
	 --   set [packagingName]=replace([packagingName],'Satz','sentence')
	 --   where [packagingName] like '%Satz%'

		--update [Delivery].[dbo].[Farnell_Export]
	 --   set [packagingName]=replace([packagingName],'Bogen à 									','sheet of ')
	 --   where [packagingName] like '%Bogen à 									%'

		--update [Delivery].[dbo].[Farnell_Export]
	 --   set [packagingName]=replace([packagingName],'Bogen at','Sheet of')
	 --   where [packagingName] like '%Bogen at%'

		--update [Delivery].[dbo].[Farnell_Export]
	 --   set [packagingName]=replace([packagingName],'Packing at','Pack of')
	 --   where [packagingName] like '%Packing at%'

		--update [Delivery].[dbo].[Farnell_Export]
	 --   set [packagingName]=replace([packagingName],'Packing at','Pack of')
	 --   where [packagingName] like '%Packing at%'

		--update [Delivery].[dbo].[Farnell_Export]
	 --   set [packagingName]=replace([packagingName],'Packung à 									','Pack of ')
	 --   where [packagingName] like '%Packung à 									%'

		--update [Delivery].[dbo].[Farnell_Export]
	 --   set [packagingName]=replace([packagingName],'Rolle in','Roll of')
	 --   where [packagingName] like 'Rolle in%' 

		--update [Delivery].[dbo].[Farnell_Export]
	 --   set [packagingName]=replace([packagingName],'Rolle to','Roll of')
	 --   where [packagingName] like 'Rolle to%' 

		--update [Delivery].[dbo].[Farnell_Export]
	 --   set [packagingName]=replace([packagingName],'Stück','piece')
	 --   where [packagingName] like 'Stück%' 

		--update [Delivery].[dbo].[Farnell_Export]
	 --   set [packagingName]=replace([packagingName],'piece (gegurtet auf Rolle - ganze Rolle)','Piece (taped on roll - whole roll)')
	 --   where [packagingName] like 'piece (gegurtet auf Rolle - ganze Rolle)%' 

		--update [Delivery].[dbo].[Farnell_Export]
	 --   set [packagingName]=replace([packagingName],'piece (Gurtabschnitt)','Piece (strap section)')
	 --   where [packagingName] like 'piece (Gurtabschnitt)%' 

		--update [Delivery].[dbo].[Farnell_Export]
	 --   set [packagingName]=replace([packagingName],'piece (Lieferung in einem Waffle-Tray)','Piece (delivery in a waffle tray)')
	 --   where [packagingName] like 'piece (Lieferung in einem Waffle-Tray)%' 

  --      update [Delivery].[dbo].[Farnell_Export]
	 --   set [packagingName]=replace([packagingName],'Stange (Tube) à 									','Rod (tube) of ')
	 --   where [packagingName] like 'Stange (Tube) à 									%'

		--update [Delivery].[dbo].[Farnell_Export]
	 --   set [packagingName]=replace([packagingName],'Stange (Tube) at ','Rod (tube) of ')
	 --   where [packagingName] like 'Stange (Tube) at %'


	/************************* updating packaging column according to DK breaks ***************************/

	    --alter table [Delivery].[dbo].[Farnell_Export] 
	    --add NonalphaPart varchar(255),ZCompanyName varchar(255)

	    Update [Delivery].[dbo].[Farnell_Export]
        Set NonalphaPart = [dbo].[fnRemovePatternFromString]([partNumber]) 
        ,ZCompanyName = b.ZCompany
        FROM [Delivery].[dbo].[Farnell_Export] a
        Inner Join [Lookup].[dbo].[DKMouserComapnies] b with (nolock) on a.mfr = b.GivenMan

	    select distinct a.NonalphaPart,a.Zcompany,a.Price_Break_1 
        into [Delivery].[dbo].Helper2
        from [DigiKeyProject5].[dbo].[DKfeed] a with (nolock)
        inner join [Delivery].[dbo].[Farnell_Export] b
        on a.NonAlphaPart=b.NonalphaPart and a.Zcompany=b.ZCompanyName
        where a.Packaging in ('TR','TAPE_BOX')

	    --alter table [Delivery].[dbo].[Farnell_Export] 
	    --add DK_Reel int

        update a
        set DK_Reel=b.Price_Break_1
        from [Delivery].[dbo].[Farnell_Export] a
        inner join [Delivery].[dbo].Helper2 b
        on a.NonalphaPart=b.NonalphaPart and a.ZCompanyName=b.Zcompany

		select  * from [Delivery].[dbo].[Farnell_Export]
        where [priceBreak]>=[DK_Reel]

		update [Delivery].[dbo].[Farnell_Export]
	    set [packagingName]='Reel'
	    where [priceBreak]>=[DK_Reel]

	/*************************************** Cleansing Data *************************************/

	   select * from [Delivery].[dbo].[Farnell_Export] where [priceBreak]=0
	
	   delete from [Delivery].[dbo].[Farnell_Export] where [priceBreak]=0

	   select * from [Delivery].[dbo].[Farnell_Export] where [priceBreak]=''


	/******** Updating data into another table to update PackLU and stock status columns ********/


	    ;With cte as ( Select [partNumber],[mfr],[sku],[partNumber_URL][BuyNow]
        ,Case when [packagingName] like 'Reel%' then 'Full Reel' else '' end as [packagingName]
        ,[SourceName],[StockFlag],[distributorType],[extractionDate]
        ,[leadTime],[moq],[pricesPerBreaks currencyRation][Ratio],[pricesPerBreaks originalCurrency][Currency],[StockFlag][StockStatus]
        ,Case when [packagingName] like '%Reel%' then 'Full Reel' else '' end as [PackLU]
        ,[stock],[price],[priceBreak],Row_Number() Over ( Partition by  [partNumber],[mfr],[priceBreak] Order by [partNumber],[mfr],[priceBreak],[partNumber_URL],[extractionDate],[moq] desc )RN
         FROM [Delivery].[dbo].[Farnell_Export] )

        select * Into [Delivery].[dbo].[Farnell1] from cte  where rn = 1


	/***********************************     Pivotting Data    *************************************/
	    
		Truncate table [Delivery].[dbo].[Farnell2]


	    ;WITH CTE_Rank AS (
        SELECT [partNumber],[mfr],[Currency],[sku],[extractionDate],[leadTime],[moq],PackagingName,PackLU,[stock],[priceBreak],[price],
        [pricebreak_Ranc] = 'pricebreak'+ CAST(DENSE_RANK() OVER (PARTITION BY [PartNumber],[Mfr],[packagingName],[extractionDate],[moq] ORDER BY [pricebreak] ) AS VARCHAR(10))
       ,[price_Ranc] = 'price'+ CAST(DENSE_RANK() OVER (PARTITION BY [PartNumber],[Mfr],[packagingName],[extractionDate],[moq] ORDER BY [pricebreak] ) AS VARCHAR(10))
        FROM [Delivery].[dbo].[Farnell1]
       -- where [partNumber]='031-70541-12G'
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


	/************************* updating Stock Status column ************************/

	   update [Delivery].[dbo].[Farnell2]
       set [StockStatus]= case when [stock]=0 then 'Non-Stocked' else 'In Stock' end 


	/***************** updating table with nonalphapart and Zcompany*****************/

	   select * from [Delivery].[dbo].[Farnell2] where mfr ='' 
	   --delete from [Delivery].[dbo].[Farnell2] where mfr =''

	   --alter table [Delivery].[dbo].[Farnell2]  add NonalphaPart varchar(255), ZCompanyName varchar(255)

       Update [Delivery].[dbo].[Farnell2] Set NonalphaPart = [dbo].[fnRemovePatternFromString]([partNumber])

       Update [Delivery].[dbo].[Farnell2]
       Set ZCompanyName = b.ZCompany
       FROM [Delivery].[dbo].[Farnell2] a
       Inner Join [Lookup].[dbo].[DKMouserComapnies] b on a.mfr = b.GivenMan
       Where ZCompanyName is Null or ZCompanyName=''

	   select distinct mfr from [Delivery].[dbo].[Farnell2] where ZCompanyName is null or ZCompanyName=''

	   update [Delivery].[dbo].[Farnell2] set ZCompanyName=mfr where ZCompanyName is null or ZCompanyName=''

	   --SELECT Distinct a.[partNumber] [Farnell_PN],a.[mfr] [Farnell_Manufacturer],b.[Manufacturer] [DKManufacturer],b.[Manufacturer_Part_Number] [DKPN]
    --   into Delivery.[dbo].farnell3  FROM [Delivery].[dbo].[Farnell2] a Left Join [DigiKeyProject5].[dbo].DKFeed b
    --   On a.NonalphaPart = b.NonalphaPart and a.ZCompanyName = b.Zcompany

	/***************************** updating Data in delivery Table ****************************/

	   SELECT b.[Packaging],convert(varchar, Cast(a.[extractionDate] as Date),101) [Last Update Date],b.[Manufacturer] [Vendor (PC)],'EUR' [Currency Dimension]
      ,b.[Manufacturer_Part_Number] [Manufacturer Part Number],CONCAT(b.[Digikey_Part_Number],' - ',b.[Manufacturer_Part_Number]) [Part Class],
       b.[Digikey_Part_Number][DK_Part_Number],a.[stock] [Competitor QTY],a.[Pricebreak1] [Competitor Break 1],a.[price1] [Competitor Pricing 1] ,
       a.[Pricebreak2] [Competitor Break 2],a.[price2] [Competitor Pricing 2],a.[Pricebreak3] [Competitor Break 3],a.[price3] [Competitor Pricing 3],
       a.[Pricebreak4] [Competitor Break 4],a.[price4] [Competitor Pricing 4],a.[Pricebreak5] [Competitor Break 5],a.[price5] [Competitor Pricing 5],
       a.[Pricebreak6] [Competitor Break 6],a.[price6] [Competitor Pricing 6],a.[Pricebreak7] [Competitor Break 7],a.[price7] [Competitor Pricing 7],
       a.[Pricebreak8] [Competitor Break 8],a.[price8] [Competitor Pricing 8],a.[Pricebreak9] [Competitor Break 9],[price9] [Competitor Pricing 9],
       Case When b.Digikey_Part_Number is Null then 'Competitor Only' Else 'Common' End as Comment,
       a.[partNumber] [Competitor Manufacturer Part Number],a.[mfr] [Competitor Manufacturer],a.sku[Competitor SKU],a.[PackagingName] [Competitor Packaging],
       Null [Competitor Lead time],a.MOQ [Competitor MOQ],a.StockStatus [Stock Status],'https://de.farnell.com/'[Site]
       Into FinalDelivery.dbo.Farnell_DE_EUR_20210916
       FROM [Delivery].[dbo].[Farnell2] a Left Join [DigiKeyProject5].[dbo].[DKFeed] b
       On a.NonalphaPart = b.NonalphaPart and a.ZCompanyName = b.Zcompany and a.PackLU = b.PackLU


    /********************************** Append Missing Data **************************************/
	select count(*), [Last Update Date] from FinalDelivery.dbo.Farnell_DE_EUR_20210916 group by [Last Update Date]


	INSERT INTO FinalDelivery.dbo.Farnell_DE_EUR_20210916
    SELECT a.[Packaging],'08/31/2021' [Last Update Date],a.[Vendor (PC)],a.[Currency Dimension],a.[Manufacturer Part Number],a.[Part Class],a.[DK_Part_Number],a.[Competitor QTY]
      ,a.[Competitor Break 1],a.[Competitor Pricing 1],a.[Competitor Break 2],a.[Competitor Pricing 2],a.[Competitor Break 3],a.[Competitor Pricing 3],a.[Competitor Break 4],a.[Competitor Pricing 4]
      ,a.[Competitor Break 5],a.[Competitor Pricing 5],a.[Competitor Break 6],a.[Competitor Pricing 6],a.[Competitor Break 7],a.[Competitor Pricing 7],a.[Competitor Break 8],a.[Competitor Pricing 8]
      ,a.[Competitor Break 9],a.[Competitor Pricing 9],a.[Comment],a.[Competitor Manufacturer Part Number],a.[Competitor Manufacturer],a.[Competitor SKU],a.[Competitor Packaging]
      ,a.[Competitor Lead time],a.[Competitor MOQ],a.[Stock Status],a.[Site]
    FROM FinalDelivery.dbo.Farnell_DE_EUR_20210819 a
    Left Join FinalDelivery.dbo.Farnell_DE_EUR_20210916 b On a.[Competitor Manufacturer Part Number] = b.[Competitor Manufacturer Part Number] -- and [dbo].[fnRemovePatternFromString](a.[Competitor Manufacturer]) = [dbo].[fnRemovePatternFromString](b.[Competitor Manufacturer])
     Where b.[Competitor Manufacturer] Is Null 

	 	 
	 /*********************** removing Duplicates from Part Class column *************************/
	 
	   ;With Checkers as ( SELECT * , Row_Number() Over ( Partition by [Part Class] order by [Part Class] ) RN 
        FROM FinalDelivery.dbo.Farnell_DE_EUR_20210916
        Where [Part Class] <> ' - ')
        delete from Checkers where RN > 1      


		/************ update [Last Update Date] column if needed ************/

		  ;with cte as (SELECT [Last Update Date],Row_Number () Over ( Order by [Competitor Manufacturer Part Number]) RN 
       from [FinalDelivery].[dbo].Farnell_DE_EUR_20210715)
       update cte
       set [Last Update Date]='05/04/2021' 
       WHERE [Last Update Date]='05/02/2021'  and RN BETWEEN 180000 AND 380000; 


	/************************************* Exporting Data ****************************************/

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
	   ,null [On_Order_1]
       ,null [Expected_Date_1]
       ,null [On_Order_2]
       ,null [Expected_Date_2]
       ,null [Total_On_Order]
	   ,null [Lifecycle_Status]
       FROM FinalDelivery.dbo.Farnell_DE_EUR_20210916



