
  /* Get number of Records*/
  Select count(*) From [FinalDelivery].[dbo].[Mouser_US_USD_20210916]

  SELECT Comment, count (Comment)
  FROM [FinalDelivery].[dbo].[Mouser_US_USD_20210916]
  Group by Comment

  /* Get number of Distinct Parts*/
  Select count(*) from (
  Select distinct [Competitor Manufacturer Part Number], [Competitor Manufacturer]
  From [FinalDelivery].[dbo].[Mouser_US_USD_20210916]) as TheCount

  Select count(*) from (
  Select distinct [Competitor Manufacturer Part Number], [Competitor Manufacturer]
  From [FinalDelivery].[dbo].[Mouser_US_USD_20210916]
  Where Comment = 'Common') as TheCount

  Select count(*) from (
  Select distinct [Competitor Manufacturer Part Number], [Competitor Manufacturer]
  From [FinalDelivery].[dbo].[Mouser_US_USD_20210916]
  Where Comment = 'Mouser Only') as TheCount
  /* Mouser Only */
  Select count(*) from (
  Select distinct [Competitor Manufacturer Part Number], [Competitor Manufacturer]
  From [FinalDelivery].[dbo].[Mouser_US_USD_20210916]
  Where Comment = 'Mouser Packaging Only') as TheCount

  /** Total Prices & Qty */

  Select round(Sum([Competitor Pricing 1]), 0) as PricesSum
  From [FinalDelivery].[dbo].[Mouser_US_USD_20210916]
  
  Select Sum(cast([Competitor QTY] as bigint)) as PricesSum
  From [FinalDelivery].[dbo].[Mouser_US_USD_20210916]









  /********************************************************   ***********************************/


  
  /* Get number of Records*/
  Select count(*) From [Delivery].[dbo].[Mouser_EU_EUR_20210916]

  SELECT Comment, count (Comment)
  FROM [Delivery].[dbo].[Mouser_EU_EUR_20210916]
  Group by Comment

  /* Get number of Distinct Parts*/
  Select count(*) from (
  Select distinct [Competitor Manufacturer Part Number], [Competitor Manufacturer]
  From [Delivery].[dbo].[Mouser_EU_EUR_20210916]) as TheCount

  Select count(*) from (
  Select distinct [Competitor Manufacturer Part Number], [Competitor Manufacturer]
  From [Delivery].[dbo].[Mouser_EU_EUR_20210916]
  Where Comment = 'Common') as TheCount

  Select count(*) from (
  Select distinct [Competitor Manufacturer Part Number], [Competitor Manufacturer]
  From [Delivery].[dbo].[Mouser_EU_EUR_20210916]
  Where Comment = 'Mouser Only') as TheCount
  /* Mouser Only */
  Select count(*) from (
  Select distinct [Competitor Manufacturer Part Number], [Competitor Manufacturer]
  From [Delivery].[dbo].[Mouser_EU_EUR_20210916]
  Where Comment = 'Mouser Packaging Only') as TheCount

  /** Total Prices & Qty */

  Select round(Sum([Competitor Pricing 1]), 0) as PricesSum
  From [Delivery].[dbo].[Mouser_EU_EUR_20210916]
  
  Select Sum(cast([Competitor QTY] as bigint)) as PricesSum
  From [Delivery].[dbo].[Mouser_EU_EUR_20210916]




