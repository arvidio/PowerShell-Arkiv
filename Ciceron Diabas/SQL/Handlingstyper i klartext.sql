/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [atgard_typ]
      ,[atgard_typ_text]
  FROM [jvp].[dbo].[atgard_typ_old]
  --Finns förmodligen fler saker i atgard_typ_fast i nyare databaser