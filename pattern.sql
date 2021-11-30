USE [master]
GO
/****** Object:  UserDefinedFunction [dbo].[fnRemovePatternFromString]    Script Date: 11/30/2021 11:12:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec sp_helptext 'fnRemovePatternFromString'

ALTER Function [dbo].[fnRemovePatternFromString](@Temp VarChar(100))

Returns VarChar(max)

AS

Begin



    Declare @KeepValues as varchar(50)

    Set @KeepValues = '%[^a-z0-9+.#:/%]%'

    While PatIndex(@KeepValues, @Temp) > 0

        Set @Temp = Stuff(@Temp, PatIndex(@KeepValues, @Temp), 1, '')



    Return @Temp

End
