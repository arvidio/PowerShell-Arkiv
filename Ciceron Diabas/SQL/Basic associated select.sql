/****** Associerade dokument med diarienummer  ******/
SELECT --[assoc_id]
      [dok_id]
      --,[assoc_typ]
      ,[assoc_data]
      --,[assoc_fritext]
      --,[mod_dat]
      --,[usrsign_reg]
      --,[dok_ref]
  FROM [jvp].[dbo].[d_assoc_dok]
  ORDER BY assoc_data