DECLARE @startDate DATE = '2024-03-09';
--DECLARE @endDate DATE = GETDATE();
DECLARE @endDate DATE =  DATEADD(DAY, -1, GETDATE());
DECLARE @dates NVARCHAR(MAX);

WITH DateRange AS (
    SELECT @startDate AS DateValue
    UNION ALL
    SELECT DATEADD(DAY, 1, DateValue)
    FROM DateRange
    WHERE DateValue < @endDate
)

SELECT @dates = COALESCE(@dates + ', ', '') + '[' + CONVERT(VARCHAR, DateValue, 105) + ']'
FROM DateRange
OPTION (MAXRECURSION 0);

exec('SELECT Region as ''Region''
	,Comuna as ''Comuna''
	,IdUnidadTerritorial AS ''CODIGO LOCAL CENSAL''
	,RUT As ''RUT Censista''
	,Censista As ''Nombre Censista''
	,' + @dates + '
FROM (
SELECT Region, GLO_COM.Comuna, TBL.IdUnidadTerritorial
			,ISNULL(GUC.RUT,'''') as RUT
			,ISNULL(UPPER(GUC.NOMBRE),'''') as Censista
			,' + @dates + '
FROM (SELECT IdLocalCensal AS IdUnidadTerritorial, CodigoRegion, CodigoComuna FROM [REPORTES_EXP_2023].[dbo].[TBL_DIRECCION_ASIGNADA] WITH (NOLOCK)
GROUP BY IdLocalCensal, CodigoRegion, CodigoComuna) TBL
LEFT JOIN
			(SELECT CODIGO AS CodigoRegion, NOMBRE as Region FROM  SGCPV.dbo.GLO_GEOGRAFIA WITH (NOLOCK) WHERE IdGeografiaNivel=1)
			GLO_REG ON TBL.CodigoRegion=CONVERT(VARCHAR(100),GLO_REG.CodigoRegion) 
		LEFT JOIN
			(SELECT CODIGO AS CodigoComuna, NOMBRE as Comuna FROM  SGCPV.dbo.GLO_GEOGRAFIA WITH (NOLOCK) WHERE IdGeografiaNivel=3)
			GLO_COM ON TBL.CodigoComuna=CONVERT(VARCHAR(100),GLO_COM.CodigoComuna)
LEFT JOIN
(SELECT IdLocalCensal  AS IdUnidadTerritorial ,IdCensista FROM TBL_DIRECCION_ASIGNADA WITH (NOLOCK) WHERE tipo_operativo=2
group by IdLocalCensal,IdCensista) 
TBL_01 ON  TBL.IdUnidadTerritorial=TBL_01.IdUnidadTerritorial
LEFT JOIN 
SGCPV.DBO.GES_USUARIO GUC 
ON TBL_01.IdCensista=GUC.IDUSUARIO
LEFT JOIN 
(
SELECT IdLocalCensal  AS IdUnidadTerritorial,IdCensista,
       ' + @dates + '
FROM (
SELECT IdLocalCensal,IDUSUARIO as IdCensista,Fecha FROM (
    SELECT IdLocalCensal,GU.IDUSUARIO,TRY_CONVERT(DATE, fec_hr_ind) AS Fecha
	FROM PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) 
	LEFT JOIN REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
	LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON HR.RESPONSIBLE=GU.RUT
	WHERE tipo_operativo=2 And NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL  AND NOT CodUsoDestino IS NULL 
	) A WHERE fecha >= ''2024-03-09'' AND fecha <= GETDATE()
) AS TBL_PVT
PIVOT (
    COUNT(Fecha)
    FOR Fecha IN (' + @dates + ')
) AS PivotTable
) TBL_CON ON TBL_01.IdCensista=TBL_CON.IdCensista AND TBL_01.IdUnidadTerritorial=TBL_CON.IdUnidadTerritorial
) A order by IdUnidadTerritorial, RUT')