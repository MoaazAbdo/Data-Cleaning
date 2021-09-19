/******************************************* Mouser New Module data ************************************/

-- Truncate table [DigiKeyProject5].[dbo].[MouserUS_Update]

--alter table [DigiKeyProject5].[dbo].[MouserUS_Update] add Max_OrderedQTY int

select count(*) from (select distinct partNumber,mfr from [DigiKeyProject5].[dbo].[MouserUS_Update_Distinct] ) a

 -- ;With cte as ( SELECT * , Row_Number() Over ( Partition by [partNumber],[mfr],[priceBreak] order by cast([extractionDate] as date) desc ) RN
 -- FROM [DigiKeyProject5].[dbo].[MouserUS_Update_Distinct] with(nolock) )
 --select * into [DigiKeyProject5].[dbo].[MouserUS_Update_New]
 --from cte where RN=1

 drop index FDB1 on [DigiKeyProject5].[dbo].[MouserUS_Update]
 drop index FDB2 on [DigiKeyProject5].[dbo].[MouserUS_Update]

create nonclustered index FDB1 on [DigiKeyProject5].[dbo].[MouserUS_Update] ([partNumber],[mfr],[priceBreak])
create nonclustered index FDB2 on [DigiKeyProject5].[dbo].[MouserUS_Update] ([extractionDate])
--create nonclustered index FDB3 on [DigiKeyProject5].[dbo].[MouserUS_Update_Distinct] ([priceBreak])


SELECT * , Row_Number() Over ( Partition by [partNumber],[mfr],[priceBreak] order by [extractionDate]  desc ) RN
into [DigiKeyProject5].dbo.[MouserUS_Update_New]
FROM [DigiKeyProject5].[dbo].[MouserUS_Update]


create nonclustered index FDB3 on [DigiKeyProject5].[dbo].[MouserUS_Update_New] (RN)

select * into [DigiKeyProject5].[dbo].[MouserUS_Update_Distinct]
from [DigiKeyProject5].[dbo].[MouserUS_Update_New] 
where RN=1

--;With cte as ( SELECT * , Row_Number() Over ( Partition by [partNumber],[mfr],[priceBreak] order by cast([extractionDate] as date) desc ) RN
--  FROM [DigiKeyProject5].[dbo].[MouserUS_Update_Distinct] )
-- delete from cte where RN > 1

-- select * into [DigiKeyProject5].[dbo].[Mouser_New_Module_Copy]
-- from [DigiKeyProject5].[dbo].[MouserUS_Update_Distinct]

--1-- Updating BuyNow column to use as SourceURL column in old module data

    --update [DigiKeyProject5].[dbo].[Mouser_New_Module]
    --set [BuyNow]=replace([BuyNow],'/ProductDetail/','https://www.mouser.com/ProductDetail/')

--2-- Updating StockFlag column -------------------------------------
   
    update [DigiKeyProject5].[dbo].[MouserUS_Update_Distinct]
	set [StockFlag]='Instock'
	where [StockFlag] like '%In Stock%'

    update [DigiKeyProject5].[dbo].[MouserUS_Update_Distinct]
	set [StockFlag]='Non-Stocked'
	where [StockFlag] like '%Non-Stocked%'

	delete from [DigiKeyProject5].[dbo].[MouserUS_Update_Distinct]
	where [StockFlag] like'%Not Available%'
	 
    update [DigiKeyProject5].[dbo].[MouserUS_Update_Distinct]
	set [stock]=[dbo].[udf_GetNumeric]([StockFlag])
	where [StockFlag] like '%Stock Available%'

	 update [DigiKeyProject5].[dbo].[MouserUS_Update_Distinct]
	set [stock]=[dbo].[udf_GetNumeric]([StockFlag])
	where [StockFlag] like '%On Order%'

	--select distinct 
	--partNumber,mfr from [DigiKeyProject5].[dbo].[MouserUS_Update_Distinct]
	--where [StockFlag] like '%Stock Available%'

	update [DigiKeyProject5].[dbo].[MouserUS_Update_Distinct]
	set [StockFlag]='Factory Stock'
	where [StockFlag] like '%Stock Available%'

    update [DigiKeyProject5].[dbo].[MouserUS_Update_Distinct]
	set [StockFlag]='On Order'
	where [StockFlag] like '%On Order%'

	update [DigiKeyProject5].[dbo].[MouserUS_Update_Distinct]
	set [StockFlag]='Instock'
	where [StockFlag]='' and [priceBreak]<>0

	Delete from [DigiKeyProject5].[dbo].[MouserUS_Update_Distinct]
	where [StockFlag]='' and [priceBreak]=0

	update [DigiKeyProject5].[dbo].[MouserUS_Update_Distinct]
	set [StockFlag]='Factory Drop Ship'
	where [StockFlag] like '%Factory Drop Ship%'

	update [DigiKeyProject5].[dbo].[MouserUS_Update_Distinct]
	set [StockFlag]='ZeroStock'
	where [StockFlag] not in ('Factory Drop Ship','Instock','Non-Stocked','Factory Stock','On Order')


    select distinct [StockFlag] from [DigiKeyProject5].[dbo].[MouserUS_Update_Distinct]

	--delete from [DigiKeyProject5].[dbo].[Mouser_New_Module] where [StockFlag] ='Factory Stock'

--3-- Updating stock to zero where [StockFlag] is zerostock -------

    update [DigiKeyProject5].[dbo].[MouserUS_Update_Distinct]
	set [stock]='0'
	where [StockFlag]='ZeroStock'

--4-- Updating Lead Time column --------------------------------------
    
    update [DigiKeyProject5].[dbo].[MouserUS_Update_Distinct]
	set [leadTime]=replace([leadTime],'\n','')
	where [leadTime] like '%Non-Stocked Lead-Time%'

	update [DigiKeyProject5].[dbo].[MouserUS_Update_Distinct]
	set [leadTime]=replace([leadTime],'Non-Stocked Lead-Time','')
	where [leadTime] like '%Non-Stocked Lead-Time%'

	update [DigiKeyProject5].[dbo].[MouserUS_Update_Distinct]
	set [leadTime]=''
	where [leadTime] like '%Stock%'

	update [DigiKeyProject5].[dbo].[MouserUS_Update_Distinct]
	set [leadTime]=replace([leadTime],'\n','')

	update [DigiKeyProject5].[dbo].[MouserUS_Update_Distinct]
	set [leadTime]=replace([leadTime],'Lead-Time','')

	update [DigiKeyProject5].[dbo].[MouserUS_Update_Distinct]
	set [leadTime]=replace([leadTime],'Alternative Packaging','')

	update [DigiKeyProject5].[dbo].[MouserUS_Update_Distinct]
	set [leadTime]=replace([leadTime],'More Info Available','')

	select distinct [leadTime] from [DigiKeyProject5].[dbo].[MouserUS_Update_Distinct]

--5-- deleting where pricebreak is zero -----------------------------

    Delete from [DigiKeyProject5].[dbo].[MouserUS_Update_Distinct]
	where [priceBreak]=0

	delete from [DigiKeyProject5].[dbo].[MouserUS_Update_Distinct]
	where [priceBreak]=''

	-------------- Updating Original table ( wrong packaging with PriceBreaks --------------

	 update [DigiKeyProject5].[dbo].[MouserUS_Update_Distinct]
     set Reel=replace(Reel,',','')


     update [DigiKeyProject5].[dbo].[MouserUS_Update_Distinct]
     set [packagingName]='Reel'
     where [priceBreak]>=[Reel] and [packagingName]<>'Reel' and [Reel]<>''

     update [DigiKeyProject5].[dbo].[MouserUS_Update_Distinct]
     set [packagingName]=''
     where [priceBreak]<[Reel] and [packagingName]='Reel'

  -----------------------------------------------------------------------------------------------

  --------------- Updating original table with two columns to help mapping with DK Breaks --------

     update [DigiKeyProject5].[dbo].[MouserUS_Update_Distinct]
     set [packagingName]='Cut Tape'
     where [packagingName]<>'Reel'

	 --select count(distinct [packagingName])[#Packaging_options],[partNumber],[mfr]  FROM [DigiKeyProject5].[dbo].[Mouser_New_Module] 
  --   group by [partNumber],[mfr]

     select count(distinct [packagingName])[#Packaging_options],[partNumber],[mfr]  into [Delivery].[dbo].Helper11
     FROM [DigiKeyProject5].[dbo].[MouserUS_Update_Distinct] 
     group by [partNumber],[mfr]

	 --alter table [DigiKeyProject5].[dbo].[MouserUS_Update_Distinct] 
	 --add [#Packaging_options] int

     update a
     set [#Packaging_options]=b.[#Packaging_options]
     from [DigiKeyProject5].[dbo].[MouserUS_Update_Distinct] a
     inner join [Delivery].[dbo].Helper11 b
     on a.partNumber=b.partNumber and a.mfr=b.mfr

	 --alter table [DigiKeyProject5].[dbo].[MouserUS_Update_Distinct] 
	 --add NonalphaPart varchar(255),ZCompanyName varchar(255)

	 Update [DigiKeyProject5].[dbo].[MouserUS_Update_Distinct] 
     Set NonalphaPart = [dbo].[fnRemovePatternFromString]([partNumber]) 
     ,ZCompanyName = b.ZCompany
     FROM [DigiKeyProject5].[dbo].[MouserUS_Update_Distinct] a
     Inner Join [Lookup].[dbo].[NewDKMouserCompanies] b on a.mfr = b.Given

	 select distinct a.NonalphaPart,a.Zcompany,a.Price_Break_1 
     into [Delivery].[dbo].Helper2
     from [DigiKeyProject5].[dbo].[DKfeed] a
     inner join [DigiKeyProject5].[dbo].[MouserUS_Update_Distinct] b
     on a.NonAlphaPart=b.NonalphaPart and a.Zcompany=b.ZCompanyName
     where a.Packaging in ('TR','TAPE_BOX')

	 --alter table [DigiKeyProject5].[dbo].[MouserUS_Update_Distinct] 
	 --add DK_Reel int

     update a
     set DK_Reel=b.Price_Break_1
     from [DigiKeyProject5].[dbo].[MouserUS_Update_Distinct] a
     inner join [Delivery].[dbo].Helper2 b
     on a.NonalphaPart=b.NonalphaPart and a.ZCompanyName=b.Zcompany

	 --select  * from [DigiKeyProject5].[dbo].[Mouser_New_Module]
  --   where [priceBreak]>=[DK_Reel] and [packagingName]='Cut Tape' and [#Packaging_options]='1'
                                   
     --select distinct [partNumber],mfr into [Delivery].[dbo].helper3 from [DigiKeyProject5].[dbo].[Mouser_New_Module]
     --where [priceBreak]=[DK_Reel] and [packagingName]='Cut Tape' and [#Packaging_options]='1'

	 update [DigiKeyProject5].[dbo].[MouserUS_Update_Distinct]
	 set [packagingName]='Reel'
	 where [priceBreak]>=[DK_Reel] and [packagingName]='Cut Tape' and [#Packaging_options]='1'

--6- Updating data in table [Delivery].[dbo].[Mouser_US1] ------------
  
    truncate table [Delivery].[dbo].[Mouser_US1]
    
	 ;With cte as ( Select [partNumber],[mfr],[sku],[BuyNow]
,Case when [packagingName] like 'Reel%' then 'Full Reel' else '' end as [packagingName]
,[SourceName],[StockFlag],[distributorType],[extractionDate]
,[leadTime],[moq],[pricesPerBreaks currencyRatio][Ratio],[pricesPerBreaks originalCurrency][Currency]
,Case When [StockFlag]='Instock' then 'Instock' when [StockFlag]='ZeroStock' then 'ZeroStock' Else [StockFlag] End as [StockStatus]
,Case when [packagingName] like '%Reel%' then 'Full Reel' else '' end as [PackLU]
,[stock],[price],[priceBreak],Row_Number() Over ( Partition by  [partNumber],[mfr],[priceBreak] Order by [partNumber],[mfr],[priceBreak],[BuyNow],[extractionDate],[SourceURL],[moq] desc )RN
FROM [DigiKeyProject5].[dbo].[MouserUS_Update_Distinct]
--where [partNumber]='1641R-101K'
)

Insert Into [Delivery].[dbo].[Mouser_US1]
select *from cte  where rn = 1


  ----------------------- deleting wrong extracted parts from [Mouser_US1] table before pivotting data ---------------

  select distinct [sku],[priceBreak][TR_Break] into [Delivery].[dbo].[Mouser_US2]
  FROM [Delivery].[dbo].[Mouser_US1]
  where [packagingName]='Full Reel'
  
 

   select distinct [sku],[priceBreak][CT_Break] into [Delivery].[dbo].[Mouser_US3]
  FROM [Delivery].[dbo].[Mouser_US1]
  where [packagingName]=''

  alter table [Delivery].[dbo].[Mouser_US2]
  add [CT_Break] int 

 
  update a 
  set [CT_Break]=b.[CT_Break]
  from [Delivery].[dbo].[Mouser_US2] a
  inner join [Delivery].[dbo].[Mouser_US3] b 
  on a.sku=b.sku

  select * from [Delivery].[dbo].[Mouser_US2]
  where [CT_Break]>[TR_Break]

  select distinct sku into [Delivery].[dbo].[Mouser_US4] 
  from [Delivery].[dbo].[Mouser_US2]
  where [CT_Break]>[TR_Break]

  delete a 
  from [Delivery].[dbo].[Mouser_US1] a
  inner join [Delivery].[dbo].[Mouser_US4] b
  on a.sku=b.sku

  ----------------------------------- Pivotting Data ------------------------------------------------

  Truncate Table [Delivery].[dbo].[US_Delivery1]

  ;WITH CTE_Rank AS (
SELECT [partNumber],[mfr],[Currency],[sku],[extractionDate],[leadTime],[moq],PackagingName,PackLU,[stock],[StockStatus],[priceBreak],[price],
[pricebreak_Ranc] = 'pricebreak'+ CAST(DENSE_RANK() OVER (PARTITION BY [PartNumber],[Mfr],[packagingName],[extractionDate],[moq] ORDER BY [pricebreak] ) AS VARCHAR(10))
,[price_Ranc] = 'price'+ CAST(DENSE_RANK() OVER (PARTITION BY [PartNumber],[Mfr],[packagingName],[extractionDate],[moq] ORDER BY [pricebreak] ) AS VARCHAR(10))
FROM [Delivery].[dbo].[Mouser_US1]
--where [partNumber]='08051A221JAT2A'
)

Insert Into [Delivery].[dbo].[US_Delivery1] ( [partNumber],[mfr],[Currency],[sku],[extractionDate],[leadTime],[moq],[PackagingName],[PackLU]
,[stock],[StockStatus],[Pricebreak1],[price1],[Pricebreak2],[price2],[Pricebreak3],[price3],[Pricebreak4]
,[price4],[Pricebreak5],[price5],[Pricebreak6],[price6],[Pricebreak7],[price7],[Pricebreak8],[price8]
,[Pricebreak9],[price9] )
SELECT [partNumber],[mfr],[Currency],[sku],[extractionDate],[leadTime],[moq],PackagingName,PackLU, [stock],[StockStatus]
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
GROUP BY [partNumber],[mfr],[Currency],[sku],[extractionDate],[leadTime],[moq],PackagingName,PackLU,[stock],[StockStatus]

  -------------------- Deletind wrong extracted parts after pivotting ---------------

    select distinct  [partNumber],[mfr] into [Delivery].[dbo].[US_Delivery2] 
  from [Delivery].[dbo].[US_Delivery1]
  where [Pricebreak1] is null

  delete a
  from [Delivery].[dbo].[US_Delivery1] a
  inner join [Delivery].[dbo].[US_Delivery2] b
  on a.partNumber=b.partNumber and a.mfr=b.mfr


  select * from [Delivery].[dbo].[US_Delivery1] where [Pricebreak1] is null and [Pricebreak2] is not null
------------------------------------------------------------------------------------------------

select * from [Delivery].[dbo].[US_Delivery1] where mfr =''

delete from [Delivery].[dbo].[US_Delivery1] where mfr =''


Update [Delivery].[dbo].[US_Delivery1] Set NonalphaPart = [dbo].[fnRemovePatternFromString]([partNumber])

Update [Delivery].[dbo].[US_Delivery1]
Set ZCompanyName = b.ZCompany
FROM [Delivery].[dbo].[US_Delivery1] a
Inner Join [Lookup].[dbo].[NewDKMouserCompanies] b on a.mfr = b.Given
Where ZCompanyName is Null


 select distinct mfr from [Delivery].[dbo].[US_Delivery1] where ZCompanyName is null or ZCompanyName=''

 --update [Delivery].[dbo].[US_Delivery1] set ZCompanyName=mfr where ZCompanyName is null or ZCompanyName=''

--delete from [Delivery].[dbo].[US_Delivery1] where ZCompanyName is null or ZCompanyName=''

/* Creating PartLUK table to recoginze the mapping between both Mouser & Digi-Key */

Insert Into Lookup.dbo.PartLUK_New([MouserPN],[MouserManufacturer],[DKManufacturer],[DKPN])
SELECT Distinct a.[partNumber] [MouserPN],a.[mfr] [MouserManufacturer],b.[Manufacturer] [DKManufacturer],b.[Manufacturer_Part_Number] [DKPN]
FROM [Delivery].[dbo].[US_Delivery1] a Left Join [DigiKeyProject5].[dbo].DKFeed b
On a.NonalphaPart = b.NonalphaPart and a.ZCompanyName = b.Zcompany


/************ Generating Final REport *******************/

SELECT b.[Packaging],convert(varchar, Cast(a.[extractionDate] as Date),101) [Last Update Date],b.[Manufacturer] [Vendor (PC)],'USD' [Currency Dimension]
,b.[Manufacturer_Part_Number] [Manufacturer Part Number],CONCAT(b.[Digikey_Part_Number],' - ',b.[Manufacturer_Part_Number]) [Part Class],
b.[Digikey_Part_Number][DK_Part_Number],a.[stock] [Mouser QTY],a.Pricebreak1 [Mouser Break 1],a.price1 [Mouser Pricing 1] ,
a.Pricebreak2 [Mouser Break 2],a.price2 [Mouser Pricing 2],a.Pricebreak3 [Mouser Break 3],a.price3 [Mouser Pricing 3],
a.Pricebreak4 [Mouser Break 4],a.price4 [Mouser Pricing 4],a.Pricebreak5 [Mouser Break 5],a.price5 [Mouser Pricing 5],
a.Pricebreak6 [Mouser Break 6],a.price6 [Mouser Pricing 6],a.Pricebreak7 [Mouser Break 7],a.price7 [Mouser Pricing 7],
a.Pricebreak8 [Mouser Break 8],a.price8 [Mouser Pricing 8],a.Pricebreak9 [Mouser Break 9],price9 [Mouser Pricing 9],
Case When b.Digikey_Part_Number is Null then 'Mouser Only' Else 'Common' End as Comment,
a.[partNumber] [Mouser Manufacturer Part Number],a.[mfr] [Mouser Manufacturer],a.[sku][Mouser SKU],a.[PackagingName] [Mouser Packaging],
a.[leadTime] [Mouser Lead time],a.MOQ [Mouser MOQ],a.[StockStatus][Stock Status]
Into FinalDelivery.dbo.Mouser_US_USD_20210916
FROM [Delivery].[dbo].[US_Delivery1] a Left Join [DigiKeyProject5].[dbo].[DKFeed] b
On a.NonalphaPart = b.NonalphaPart and a.ZCompanyName = b.Zcompany and a.PackLU = b.PackLU


Alter table FinalDelivery.dbo.Mouser_US_USD_20210916 Alter column comment varchar(50)

--Select comment,count(1) from FinalDelivery.dbo.Mouser_US_USD_20210527 group by Comment


;with cte as ( Select * from Lookup.dbo.PartLUK_New where DKManufacturer is not Null)
Update a
Set a.Comment = 'Mouser Packaging Only', a.[Vendor (PC)] = b.DKManufacturer, a.[Manufacturer Part Number] = b.DKPN
from FinalDelivery.dbo.Mouser_US_USD_20210916 a inner join cte b
on a.[Mouser Manufacturer Part Number]= b.MouserPN and a.[Mouser Manufacturer] = b.MouserManufacturer
Where a.comment ='Mouser Only'

------------------ Removing parts with not matched pricebreaks from last table -----------------

    alter table [FinalDelivery].[dbo].Mouser_US_USD_20210916
    add DK_Break1 int

	select top 1000 * from [FinalDelivery].[dbo].Mouser_US_USD_20210916

    update [FinalDelivery].[dbo].Mouser_US_USD_20210916
    set DK_Break1=b.Price_Break_1
    from [FinalDelivery].[dbo].Mouser_US_USD_20210916 a
    inner join [DigiKeyProject5].[dbo].[DKfeed] b 
    on a.[Manufacturer Part Number]=b.Manufacturer_Part_Number

	

    --select [Packaging],[Mouser Manufacturer Part Number],[Mouser Manufacturer],DK_Break1,[Mouser Break 1] 
    --from [FinalDelivery].[dbo].Mouser_US_USD_20210408
    --where [Packaging]='CT' and [Mouser Break 1]<>'1' and [Mouser Break 1]>10*DK_Break1


    select distinct [Mouser Manufacturer Part Number],[Mouser Manufacturer] into [Delivery].[dbo].[US_Delivery3]
    from [FinalDelivery].[dbo].Mouser_US_USD_20210916
    where [Packaging]='CT' and [Mouser Break 1]<>'1' and [Mouser Break 1]>10*DK_Break1

    delete a
    from [FinalDelivery].[dbo].Mouser_US_USD_20210916 a
    inner join [Delivery].[dbo].[US_Delivery3] b
    on a.[Mouser Manufacturer Part Number]=b.[Mouser Manufacturer Part Number] and a.[Mouser Manufacturer]=b.[Mouser Manufacturer]


	/****************** Adding [Competitor Factory Stock] column and updating it before appending data *********************/


	alter table FinalDelivery.dbo.Mouser_US_USD_20210916 add [FACTORY_STOCK] int

	update FinalDelivery.dbo.Mouser_US_USD_20210916 
	set [FACTORY_STOCK]=[Mouser QTY] where [Stock Status]='Factory Stock'

	update FinalDelivery.dbo.Mouser_US_USD_20210916  set [FACTORY_STOCK]=0 where [FACTORY_STOCK] is null

	update FinalDelivery.dbo.Mouser_US_USD_20210916 set [Mouser QTY]=0 where [FACTORY_STOCK]<>0



	select * from FinalDelivery.dbo.Mouser_US_USD_20210916 where [Stock Status]='On Order'

	alter table FinalDelivery.dbo.Mouser_US_USD_20210916 add [Total_On_Order] int

	

	update FinalDelivery.dbo.Mouser_US_USD_20210916 
	set [Total_On_Order]=[Mouser QTY] where [Stock Status]='On Order'

	update FinalDelivery.dbo.Mouser_US_USD_20210916  set [Total_On_Order]=0 where [Total_On_Order] is null
	
	update FinalDelivery.dbo.Mouser_US_USD_20210916 set [Mouser QTY]=0 where [Total_On_Order]<>0

	/************************** updating On Order columns ************************/

	select distinct partNumber,mfr,sku,StockFlag,[Onorder 0 Flag],[Onorder 0 stock],[Onorder 1 Flag],[Onorder 1 stock] 
    into [DigiKeyProject5].[dbo].[MouserUS_OnOrder]
    FROM [DigiKeyProject5].[dbo].[MouserUS_Update_Distinct]
    where [StockFlag] like '%On Order%'

    update [DigiKeyProject5].[dbo].[MouserUS_OnOrder] set [Onorder 1 Flag]=replace([Onorder 1 Flag],'Expected ',''),[Onorder 0 Flag]=replace([Onorder 0 Flag],'Expected ','')
    ,[Onorder 0 stock]=replace([Onorder 0 stock],'.',''),[Onorder 1 stock]=replace([Onorder 1 stock],'.','')

    update [DigiKeyProject5].[dbo].[MouserUS_OnOrder] set [Onorder 0 stock]=replace([Onorder 0 stock],',',''),[Onorder 1 stock]=replace([Onorder 1 stock],',','')

	select * from [DigiKeyProject5].[dbo].[MouserUS_OnOrder]

	alter table [FinalDelivery].[dbo].Mouser_US_USD_20210916 add On_Order_1 int , Expected_Date_1 varchar(255),On_Order_2 int , Expected_Date_2 varchar(255)

    update [FinalDelivery].[dbo].Mouser_US_USD_20210916
    set On_Order_1=b.[Onorder 0 stock],On_Order_2=b.[Onorder 1 stock],Expected_Date_1=b.[Onorder 0 Flag],Expected_Date_2=b.[Onorder 1 Flag]
    from [FinalDelivery].[dbo].Mouser_US_USD_20210916 a
    inner join [DigiKeyProject5].[dbo].[MouserUS_OnOrder] b on a.[Mouser SKU]=b.[sku]

	update [FinalDelivery].[dbo].Mouser_US_USD_20210916
	set    On_Order_1=null
	where  On_Order_1=0 or On_Order_1=''

	update [FinalDelivery].[dbo].Mouser_US_USD_20210916
	set    On_Order_2=null
	where  On_Order_2=0 or On_Order_2=''

	update [FinalDelivery].[dbo].Mouser_US_USD_20210916
	set    Expected_Date_1=null
	where  Expected_Date_1=''

	update [FinalDelivery].[dbo].Mouser_US_USD_20210916
	set    Expected_Date_2=null
	where  Expected_Date_2=''


	/********************************** updating Life Cycle Column *********************/

	Alter table [FinalDelivery].[dbo].Mouser_US_USD_20210916 
	add [Lifecycle_Status] varchar(255)

	select distinct partNumber,mfr,lifecycle into [DigiKeyProject5].[dbo].[MouserUS_LifeCycle]
	from [DigiKeyProject5].[dbo].[MouserUS_Update_Distinct]

	--select * 
	--from [DigiKeyProject5].[dbo].[MouserUS_LifeCycle] where lifecycle <> ''

	--with cte as ( select count(lifecycle) TheCount ,mfr,partNumber from [DigiKeyProject5].[dbo].[MouserUS_LifeCycle] group by mfr,partNumber having count(lifecycle)>1 )  -- should be zero rows
	--select * from [DigiKeyProject5].[dbo].[MouserUS_Update_Distinct] b  inner join cte on b.partNumber=cte.partNumber and b.mfr=cte.mfr


	update [FinalDelivery].[dbo].Mouser_US_USD_20210916 
	set [Lifecycle_Status]=b.lifecycle
	from [FinalDelivery].[dbo].Mouser_US_USD_20210916 a
	inner join [DigiKeyProject5].[dbo].[MouserUS_LifeCycle] b
	on a.[Mouser Manufacturer Part Number]=b.partNumber and a.[Mouser Manufacturer]=b.mfr

	--select * from [FinalDelivery].[dbo].Mouser_US_USD_20210325 where [Lifecycle_Status] is null

	--update [FinalDelivery].[dbo].Mouser_US_USD_20210318
	--set  [Lifecycle_Status]='' where [Lifecycle_Status] is null 

	--select count(distinct [Mouser Manufacturer Part Number] ) #DistinctParts , [Lifecycle_Status] from [FinalDelivery].[dbo].Mouser_US_USD_20210218 group by [Lifecycle_Status]

	--select * from [FinalDelivery].[dbo].Mouser_US_USD_20210211 where [Lifecycle_Status] ='Part Number Change'

		/********************************** updating Max QTY Column *********************/

	Alter table [FinalDelivery].[dbo].Mouser_US_USD_20210916 
	add [Max_OrderedQTY] int

	select distinct partNumber,mfr,[Max_OrderedQTY] into [DigiKeyProject5].[dbo].[MouserUS_MaxQTY]
	from [DigiKeyProject5].[dbo].[MouserUS_Update_Distinct]
	where [Max_OrderedQTY]<>0

		update [FinalDelivery].[dbo].Mouser_US_USD_20210916 
	set [Max_OrderedQTY]=b.[Max_OrderedQTY]
	from [FinalDelivery].[dbo].Mouser_US_USD_20210916 a
	inner join [DigiKeyProject5].[dbo].[MouserUS_MaxQTY] b
	on a.[Mouser Manufacturer Part Number]=b.partNumber and a.[Mouser Manufacturer]=b.mfr



	/********** Appending missing data from last delivery *************/

	-- next time replace null  [MouserUS_MaxQTY] with a. [MouserUS_MaxQTY]

	INSERT INTO FinalDelivery.dbo.Mouser_US_USD_20210916
SELECT a.[Packaging],'09/09/2021' [Last Update Date],a.[Vendor (PC)],a.[Currency Dimension],a.[Manufacturer Part Number],a.[Part Class],a.[DK_Part_Number],a.[Competitor QTY]
      ,a.[Competitor Break 1],a.[Competitor Pricing 1],a.[Competitor Break 2],a.[Competitor Pricing 2],a.[Competitor Break 3],a.[Competitor Pricing 3],a.[Competitor Break 4],a.[Competitor Pricing 4]
      ,a.[Competitor Break 5],a.[Competitor Pricing 5],a.[Competitor Break 6],a.[Competitor Pricing 6],a.[Competitor Break 7],a.[Competitor Pricing 7],a.[Competitor Break 8],a.[Competitor Pricing 8]
      ,a.[Competitor Break 9],a.[Competitor Pricing 9],a.[Comment],a.[Competitor Manufacturer Part Number],a.[Competitor Manufacturer],a.[Competitor SKU],a.[Competitor Packaging]
      ,a.[Competitor Lead time],a.[Competitor MOQ],a.[Stock Status],a.DK_Break1,a.[FACTORY_STOCK],a.Total_On_Order,a.On_Order_1,a.Expected_Date_1,a.On_Order_2,a.Expected_Date_2,a.Lifecycle_Status,null [MouserUS_MaxQTY] -- replace
  FROM Delivery.dbo.Mouser_US_USD_20210909 a
  Left Join FinalDelivery.dbo.Mouser_US_USD_20210916 b On a.[Competitor Manufacturer Part Number] = b.[Mouser Manufacturer Part Number] -- and [dbo].[fnRemovePatternFromString](a.[Competitor Manufacturer]) = [dbo].[fnRemovePatternFromString](b.[Competitor Manufacturer])
  Where b.[Mouser Manufacturer] Is Null



    -------checkers--------

  ;With Checkers as ( SELECT * , Row_Number() Over ( Partition by [Part Class] order by [Part Class] ) RN 
  FROM FinalDelivery.dbo.Mouser_US_USD_20210916
  Where [Part Class] <> ' - ')
Delete from Checkers where RN > 1


/******* delete parts with wrong expected on order dates from appended data from last delivery ************/


  select distinct [Expected_Date_1] FROM [FinalDelivery].[dbo].Mouser_US_USD_20210916 where [Last Update Date]='09/09/2021' and [Expected_Date_1] like '%2021'

  delete from [FinalDelivery].[dbo].Mouser_US_USD_20210916 where [Last Update Date]='09/09/2021' and [Expected_Date_1]
   in ('9/6/2021','9/7/2021','9/8/2021','9/9/2021','9/10/2021')


    select distinct [Expected_Date_2] FROM [FinalDelivery].[dbo].Mouser_US_USD_20210916 where [Last Update Date]='09/09/2021' and [Expected_Date_2] like '%2021'

  delete from [FinalDelivery].[dbo].Mouser_US_USD_20210916 where [Last Update Date]='09/09/2021' and [Expected_Date_2]
    in ('9/6/2021','9/7/2021','9/8/2021','9/9/2021','9/10/2021')


/************** updating last update column if needed *************/

--select count(*),[Last Update Date]  from [FinalDelivery].[dbo].Mouser_US_USD_20210708 group by [Last Update Date]

--  ;with cte as (SELECT [Last Update Date],Row_Number () Over ( Order by [Competitor Manufacturer Part Number]) RN 
-- from [FinalDelivery].[dbo].Mouser_US_USD_20210401)
-- update cte
-- set [Last Update Date]='03/26/2021' 
-- WHERE [Last Update Date]='03/25/2021'  and RN BETWEEN 1 AND 3000000; 



 /************** Exporting Data ****************/

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
	  ,'https://www.mouser.com'[Site]
	  ,[FACTORY_STOCK]
	  ,[On_Order_1]
      ,[Expected_Date_1]
      ,[On_Order_2]
      ,[Expected_Date_2]
      ,[Total_On_Order]
	  ,[Lifecycle_Status]
	  ,[Max_OrderedQTY]
  FROM FinalDelivery.dbo.Mouser_US_USD_20210916



