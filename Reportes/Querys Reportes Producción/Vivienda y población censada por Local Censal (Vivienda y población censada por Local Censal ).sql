	DECLARE @startDate DATE = '2024-06-01';

	--DECLARE @endDate DATE = GETDATE();

	DECLARE @endDate DATE =  DATEADD(DAY, -1, GETDATE());

	DECLARE @dates NVARCHAR(MAX);
	DECLARE @columnA NVARCHAR(MAX);
	 DECLARE @columnB NVARCHAR(MAX);
	 DECLARE @columnC NVARCHAR(MAX);
	 DECLARE @columnD NVARCHAR(MAX);
	WITH DateRange AS (

		SELECT @startDate AS DateValue

		UNION ALL

		SELECT DATEADD(DAY, 1, DateValue)

		FROM DateRange

		WHERE DateValue < @endDate

	)
 
	SELECT @dates = COALESCE(@dates + ', ', '') + '[' + CONVERT(VARCHAR, DateValue, 105) + ']'
	,@columnA= COALESCE(@columnA + ', ', '') + 'ISNULL(TBL_CON.[' + CONVERT(VARCHAR, DateValue, 105) + '],0) AS [' + CONVERT(VARCHAR, DateValue, 105) + '_V]'
	,@columnB= COALESCE(@columnB + ', ', '') + 'ISNULL(TBL_PER.[' + CONVERT(VARCHAR, DateValue, 105) + '],0) AS [' + CONVERT(VARCHAR, DateValue, 105) + '_P]'
	,@columnC= COALESCE(@columnC + ', ', '') + '[' + CONVERT(VARCHAR, DateValue, 105) + '_V],[' + CONVERT(VARCHAR, DateValue, 105) + '_P]'

	FROM DateRange

	OPTION (MAXRECURSION 0);
 
	exec('SELECT Region as ''Región''
		,Comuna as ''Comuna''
		,IdUnidadTerritorial AS ''Código Local Censal''
		,(select nombre from sgcpv..ges_area_levantamiento  WITH (NOLOCK) where idunicolocalcensal = IdUnidadTerritorial) as ''Nombre Local Censal''
		,' + @columnC + '
	FROM (

	SELECT Region, GLO_COM.Comuna, TBL.IdUnidadTerritorial
				,' + @columnA + '
				,' +  @columnB + '

	FROM (SELECT IdLocalCensal AS IdUnidadTerritorial, CodigoRegion, CodigoComuna FROM [REPORTES_EXP_2023].[dbo].[TBL_DIRECCION_ASIGNADA] WITH (NOLOCK)
	GROUP BY IdLocalCensal, CodigoRegion, CodigoComuna) TBL
	LEFT JOIN
				(SELECT CODIGO AS CodigoRegion, NOMBRE as Region FROM  SGCPV.dbo.GLO_GEOGRAFIA WITH (NOLOCK) WHERE IdGeografiaNivel=1)
				GLO_REG ON TBL.CodigoRegion=CONVERT(VARCHAR(100),GLO_REG.CodigoRegion) 
			LEFT JOIN
				(SELECT CODIGO AS CodigoComuna, NOMBRE as Comuna FROM  SGCPV.dbo.GLO_GEOGRAFIA WITH (NOLOCK) WHERE IdGeografiaNivel=3)
				GLO_COM ON TBL.CodigoComuna=CONVERT(VARCHAR(100),GLO_COM.CodigoComuna)
	LEFT JOIN
	(SELECT IdLocalCensal  AS IdUnidadTerritorial FROM TBL_DIRECCION_ASIGNADA WITH (NOLOCK) WHERE tipo_operativo=2
	group by IdLocalCensal) 
	TBL_01 ON  TBL.IdUnidadTerritorial=TBL_01.IdUnidadTerritorial
	--LEFT JOIN 
	--SGCPV.DBO.GES_USUARIO GUC 
	--ON TBL_01.IdCensista=GUC.IDUSUARIO
	LEFT JOIN 
	(
	SELECT IdLocalCensal  AS IdUnidadTerritorial,
		   ' + @dates + '
	FROM (
	SELECT IdLocalCensal,Fecha FROM (
		SELECT IdLocalCensal,fechahoravisitare AS Fecha
		FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
		WHERE tipo_operativo=2 and (IdEstadoDelCuestionario IN (3,4)) and cant_per > 0--  or IdOcupacionVivienda=2)
		) A WHERE fecha >= ''2024-03-09'' AND fecha <= GETDATE()
	) AS TBL_PVT
	PIVOT (
		COUNT(Fecha)
		FOR Fecha IN (' + @dates + ')
	) AS PivotTable
	) TBL_CON ON TBL_01.IdUnidadTerritorial=TBL_CON.IdUnidadTerritorial
	LEFT JOIN 
	(
	SELECT IdLocalCensal  AS IdUnidadTerritorial,
		   ' + @dates + '
	FROM (
	SELECT IdLocalCensal,Fecha,cant_per FROM (
		SELECT IdLocalCensal,fechahoravisitare AS Fecha,isnull(cant_per,0) as cant_per
		FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
		WHERE tipo_operativo=2 and (IdEstadoDelCuestionario IN (3,4))--  or IdOcupacionVivienda=2)
		) B WHERE fecha >= ''2024-03-09'' AND fecha <= GETDATE()
	) AS TBL_PVT2
	PIVOT (
		sum(cant_per)
		FOR Fecha IN (' + @dates + ')
	) AS PivotTable2
	) TBL_PER ON  TBL_01.IdUnidadTerritorial=TBL_PER.IdUnidadTerritorial
	) A order by IdUnidadTerritorial')
