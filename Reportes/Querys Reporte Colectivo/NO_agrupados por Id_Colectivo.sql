


SELECT 	GEO3.Nombre as Región,
	GEO.nombre AS Comuna,  
	MANZANA AS MANZANA,
	Direccion as Dirección,
	CASE 
		WHEN (SELECT TOP 1 LEN(CODUSODESTINO) FROM SGCPV..GES_DIRECCION where ID_Colectiva IS NOT NULL AND LEFT(ID_COLECTIVA,CHARINDEX('_',ID_Colectiva)-1) = PIV.ID_Colectiva)<=10 THEN 'Precarga'
		else 'Aparición'
	END AS Fuente,
	CONVERT(VARCHAR,CAST(ASI.dato_col3 AS DATE),105) as Fecha_Carga,
--	ISNULL((select NombreVC from @ltable where idTPCV = ASI.dato_col6),'') as Tipo_de_VC,
	ISNULL((select Nombre from [SGCPV].[dbo].[GLO_TIPO_VIVIENDA_COLECTIVA] where IdTipoVIvienda = cast(ASI.dato_col6 as int)),'') as Tipo_de_VC,
	ASI.dato_col11 AS Nombre_VC,
	ASI.dato_col12 as Encargado_VC,
	ASI.dato_col13 as Telefono_informante, 
	ASI.dato_col14 as correo_informante,
	CASE 
		WHEN ASI.dato_col1=33 THEN 'Operador'
		WHEN ASI.dato_col1=34 THEN 'Gestor de VC'
		ELSE ''
	END AS Perfil_Asignado,
	TBL_VC.Nombre,
	ISNULL(TL.Nombre,'') as Modalidad_Recolección_VC,
	ASI.dato_col17 as Observación,
	--DIR.CodUsoDestino,
	ISNULL((SELECT [Folio] FROM [SGCPV].[dbo].[GES_ASIGNACION_VIVCOLECTIVA_PAPEL] where IdTipoAsignacion = 12 AND Activo=1 and CodUsoDestino= '0' ),'') AS FOLIO,
	--CONVERT(VARCHAR,QR.FechaRegistroVinCod,105) AS FECHA_ENVIO_CLAVE,
	--CONVERT(VARCHAR,QR.FechaRegistroVinCod,105) AS FECHA_VINCULACION,
	CONVERT(VARCHAR,CAST(ASI.dato_col18 AS DATE),105) AS FECHA_INICIADO_LLENADO,
	--ISNULL(EST.ESTADO_VC,'') AS ESTADO_VC,
	isnull(ASI.dato_col8,0) as Cantidad_Residentes_habituales_VC,

	EST.cuestionarios_completos AS CANTIDAD_CUESTIONARIO_COMPLETOS,
	Case When EST.cuestionarios_completos = 0 or isnull(ASI.dato_col8,0)=0 Then Case When EST.cuestionarios_completos > 0 AND isnull(ASI.dato_col8,0)=0 Then 100 Else 0 End Else CAST(((cast(EST.cuestionarios_completos as Decimal(10,2)) / cast(isnull(ASI.dato_col8,0)as Decimal(10,2)))  * 100) AS Decimal(10,2)) End as '% CUESTIONARIO_COMPLETOS',

	EST.cuestionarios_parciales,
	Case When EST.cuestionarios_parciales = 0 or isnull(ASI.dato_col8,0)=0 Then Case When EST.cuestionarios_parciales > 0 AND isnull(ASI.dato_col8,0)=0 Then 100 Else 0 End Else CAST(((cast(EST.cuestionarios_parciales as Decimal(10,2)) / cast(isnull(ASI.dato_col8,0)as Decimal(10,2)))  * 100) AS Decimal(10,2)) End as '% CANTIDAD_CUESTIONARIO_PARCIALES',

	EST.cuestionarios_iniciados,
	Case When EST.cuestionarios_iniciados = 0 or isnull(ASI.dato_col8,0)=0 Then Case When EST.cuestionarios_iniciados > 0 AND isnull(ASI.dato_col8,0)=0 Then 100 Else 0 End Else CAST(((cast(EST.cuestionarios_iniciados as Decimal(10,2)) / cast(isnull(ASI.dato_col8,0)as Decimal(10,2)))  * 100) AS Decimal(10,2)) End as '% CANTIDAD_CUESTIONARIO_INICIADOS',

	EST.cuestionarios_no_iniciados,
	Case When EST.cuestionarios_no_iniciados= 0 or isnull(ASI.dato_col8,0)=0 Then Case When EST.cuestionarios_no_iniciados > 0 AND isnull(ASI.dato_col8,0)=0 Then 100 Else 0 End Else CAST(((cast(EST.cuestionarios_no_iniciados as Decimal(10,2)) / cast(isnull(ASI.dato_col8,0)as Decimal(10,2)))  * 100) AS Decimal(10,2)) End as '% CANTIDAD_CUESTIONARIO_NO_INICIADOS',

	EST.PERSONAS_CENSADAS,
	Case When EST.PERSONAS_CENSADAS = 0 or isnull(asi.dato_col8,0)=0 Then Case When EST.PERSONAS_CENSADAS > 0 AND isnull(ASI.dato_col8,0)=0 Then 100 Else 0 End Else CAST(((cast(EST.PERSONAS_CENSADAS as Decimal(10,2)) / cast(isnull(ASI.dato_col8,0)as Decimal(10,2)))  * 100) AS Decimal(10,2)) End as '% PERSONAS_CENSADAS',



--PIV.*, --VIV.cod_uso_destino, 
--VIV.cant_per--, VIV.cant_rph_sexo_edad,VIV.cant_per_complete
PIV.ID_COLECTIVA,
--ASI.ID_COLECTIVA,
asi.Tipo_Levantamiento,
PIV.CUT
,asi.Row#
FROM (
	(select top 100  LEFT(PIV.ID_COLECTIVA,CHARINDEX('_',PIV.ID_Colectiva)-1) AS ID_COLECTIVA--, ID_Colectiva 
		,PIV.CUT
		,PIV.UBICACIONGEOGRAFICA AS MANZANA
		,(concat(PIV.NombreVia,' ',PIV.NumeroDomiciliario)) as Direccion 
		FROM SGCPV..GES_DIRECCION PIV
	where PIV.ID_Colectiva IS NOT NULL
	--AND LEFT(PIV.ID_COLECTIVA,CHARINDEX('_',PIV.ID_Colectiva)-1) in ('APC10424','MATRIZ2649')
	GROUP BY LEFT(PIV.ID_COLECTIVA,CHARINDEX('_',PIV.ID_Colectiva)-1), PIV.CUT, PIV.UBICACIONGEOGRAFICA, PIV.NombreVia, PIV.NumeroDomiciliario
	) PIV

	-- OBTENEMOS LA CANTIDAD PERSONAS CENSADA
	LEFT JOIN
		(
		SELECT --VIV.cod_uso_destino,
		LEFT(DIR.ID_COLECTIVA,CHARINDEX('_',DIR.ID_Colectiva)-1) AS ID_COLECTIVA, SUM(VIV.cant_per) AS cant_per--, VIV.cant_rph_sexo_edad, VIV.cant_per_complete
		FROM SGCPV..GES_DIRECCION DIR WITH (NOLOCK)
		LEFT JOIN   PROCESAMIENTOCPV_2023..VIVIENDA VIV WITH (NOLOCK) ON VIV.cod_uso_destino = DIR.CodUsoDestino  
		WHERE DIR.ID_Colectiva IS NOT NULL AND VIV.cod_uso_destino IS NOT NULL
	--	AND LEFT(DIR.ID_COLECTIVA,CHARINDEX('_',DIR.ID_Colectiva)-1) = 'APC10424'  --'MATRIZ2649'
		GROUP BY LEFT(DIR.ID_COLECTIVA,CHARINDEX('_',DIR.ID_Colectiva)-1)
		)
	VIV ON PIV.ID_Colectiva = VIV.ID_COLECTIVA

	LEFT JOIN sgcpv..GLO_GEOGRAFIA GEO ON PIV.CUT = GEO.Codigo
	LEFT JOIN SGCPV..GLO_GEOGRAFIA GEO2 ON GEO2.IdGeografia = GEO.Padre 
	LEFT JOIN SGCPV..GLO_GEOGRAFIA GEO3 ON GEO3.IdGeografia = GEO2.Padre 

	-- obtenemos valores de asignacion colectiva
	left join 
		(
--		SELECT LEFT(ID_COLECTIVA,CHARINDEX('_',ID_Colectiva)-1) AS ID_COLECTIVO, DATO_COL1, DATO_COL3, DATO_COL6, DATO_COL8, DATO_COL11, DATO_COL12, DATO_COL13, DATO_COL14, dato_col17,
--			CONVERT(VARCHAR(10),CAST(dato_col18 AS DATE),105) AS dato_col18, Tipo_Levantamiento 
--		FROM SGCPV..GES_ASIGNACION_COLECTIVAS ASI
--			INNER JOIN SGCPV..GES_DIRECCION DIR ON ASI.CodUsoDestino = DIR.CodUsoDestino
----		WHERE LEFT(ID_COLECTIVA,CHARINDEX('_',ID_Colectiva)-1) = 'APC10424'
--		GROUP BY LEFT(ID_COLECTIVA,CHARINDEX('_',ID_Colectiva)-1), DATO_COL1, DATO_COL3, DATO_COL6, DATO_COL8, DATO_COL11, DATO_COL12, DATO_COL13, DATO_COL14, dato_col17, 
--			CONVERT(VARCHAR(10),CAST(dato_col18 AS DATE),105), Tipo_Levantamiento  
--		ORDER BY dato_col18 DESC
		
--		SELECT TOP 1 LEFT(ID_COLECTIVA,CHARINDEX('_',ID_Colectiva)-1) AS ID_COLECTIVA, DATO_COL1, DATO_COL3, DATO_COL6, DATO_COL8, DATO_COL11, DATO_COL12, DATO_COL13, DATO_COL14, dato_col17,
--			CONVERT(VARCHAR(10),CAST(dato_col18 AS DATE),105) AS dato_col18, 
--			Tipo_Levantamiento 
--		FROM SGCPV..GES_ASIGNACION_COLECTIVAS ASI
--			INNER JOIN SGCPV..GES_DIRECCION DIR ON ASI.CodUsoDestino = DIR.CodUsoDestino
----		WHERE LEFT(ID_COLECTIVA,CHARINDEX('_',ID_Colectiva)-1) = 'APC10424'
--		ORDER BY Tipo_Levantamiento DESC, dato_col18 DESC


	SELECT 
		ROW_NUMBER() OVER(PARTITION BY LEFT(dir.ID_COLECTIVA,CHARINDEX('_',dir.ID_Colectiva)-1) ORDER BY DATo_col18 desc) AS Row#,
		LEFT(dir.ID_COLECTIVA,CHARINDEX('_',dir.ID_Colectiva)-1) AS ID_COLECTIVA, -- cast(dato_col18 as datetime)
		 DATO_COL1, DATO_COL3, DATO_COL6, DATO_COL8, DATO_COL11, DATO_COL12, DATO_COL13, DATO_COL14, dato_col17,
			dato_col18
			,Tipo_Levantamiento 
		FROM SGCPV..GES_ASIGNACION_COLECTIVAS ASI
			INNER JOIN SGCPV..GES_DIRECCION DIR ON ASI.CodUsoDestino = DIR.CodUsoDestino
		--and dato_col18 = (
		--		SELECT max(dato_col18)
		--	FROM SGCPV..GES_ASIGNACION_COLECTIVAS ASI2
		--		INNER JOIN SGCPV..GES_DIRECCION DIR2 ON ASI2.CodUsoDestino = DIR2.CodUsoDestino 
		--	where  LEFT(dir2.ID_COLECTIVA,CHARINDEX('_',dir2.ID_Colectiva)-1) = LEFT(dir.ID_COLECTIVA,CHARINDEX('_',dir.ID_Colectiva)-1)
		--)
		where (ASI.dato_col1 = 34 OR (ASI.dato_col1 = 33 AND NOT EXISTS (SELECT AC.CODUSODESTINO FROM SGCPV..GES_ASIGNACION_COLECTIVAS AC WHERE AC.DATO_COL1 = 34 AND AC.CODUSODESTINO = ASI.CODUSODESTINO)))
	) 
	ASI ON LTRIM(RTRIM(PIV.ID_COLECTIVA)) = ASI.ID_COLECTIVA and asi.Row# = 1

	)

	LEFT JOIN
	(
		SELECT TOP 1 Nombre,ASI.IdTipoAsignacion, LEFT(ID_COLECTIVA,CHARINDEX('_',ID_Colectiva)-1) AS ID_COLECTIVO FROM SGCPV..GES_USUARIO USU 
			INNER JOIN SGCPV..GES_ASIGNACIONES ASI ON USU.IDUSUARIO = ASI.IDASIGNACIONA 
			INNER JOIN SGCPV..GES_DIRECCION DIR ON ASI.IdAsignacionDe = DIR.CodUsoDestino
	--	WHERE --ASI.IdTipoAsignacion = CAST(dato_col1 AS int)-15 AND 
--		WHERE LEFT(ID_COLECTIVA,CHARINDEX('_',ID_Colectiva)-1) = 'APC13624'
		GROUP BY Nombre,ASI.IdTipoAsignacion, LEFT(ID_COLECTIVA,CHARINDEX('_',ID_Colectiva)-1)
		ORDER BY ASI.IdTipoAsignacion DESC
	)
	TBL_VC ON PIV.ID_COLECTIVA = TBL_VC.ID_COLECTIVO AND TBL_VC.IdTipoAsignacion = CAST(ASI.dato_col1 AS int)-15

	LEFT JOIN SGCPV..GLO_TIPO_LEVANTAMIENTO TL ON TL.IdTipoLevantamiento = asi.Tipo_Levantamiento  

--	LEFT JOIN
--		(
--			select  TOP 1--TOP 100 SUSO.CodUsoDestino,SUSO.CodigoAcceso, 
--				LEFT(ID_COLECTIVA,CHARINDEX('_',ID_Colectiva)-1)  AS ID_COLECTIVO, CONVERT(VARCHAR(10),CAST(SUSO.FechaRegistroVinCod AS DATE),105) AS FechaRegistroVinCod
--			from SGCPV..GES_INTEGRACION_QR_SUSO SUSO
--			INNER JOIN SGCPV..GES_DIRECCION DIR ON SUSO.CodUsoDestino = DIR.CodUsoDestino
--			where TipoLevantamiento <> 2
----			AND LEFT(ID_COLECTIVA,CHARINDEX('_',ID_Colectiva)-1) = 'APC02875'
--			GROUP BY LEFT(ID_COLECTIVA,CHARINDEX('_',ID_Colectiva)-1), CONVERT(VARCHAR(10),CAST(SUSO.FechaRegistroVinCod AS DATE),105)
--			ORDER BY CONVERT(VARCHAR(10),CAST(SUSO.FechaRegistroVinCod AS DATE),105) DESC
--		)
--	QR ON QR.ID_COLECTIVO = PIV.ID_COLECTIVA

	-- DETERINAR EL ESTADO_VC
	LEFT JOIN
		(
		SELECT DISTINCT ID_COLECTIVA,
		CASE WHEN COL08>=95 THEN 'Censada' ELSE 'No Censada' END AS ESTADO_VC,
		cuestionarios_completos,
		cuestionarios_parciales,
		cuestionarios_iniciados,
		cuestionarios_no_iniciados,
		personas_censadas
		FROM 
		(
		select LEFT(ID_COLECTIVA,CHARINDEX('_',ID_Colectiva)-1) AS ID_COLECTIVA
			--,(Case When ISNULL(sum(case when est_cuest_cob in (3,4) then 1 else 0 end),0) = 0 or CAST(ISNULL(TRY_CAST(dato_col8 AS INT),0) AS Decimal(10,2))=0 
			,(Case When ISNULL(sum(case when est_cuest_cob in (3,4) then 1 else 0 end),0) = 0 or CAST(ISNULL(TRY_CAST(asi.dato_col8 AS INT),0) AS Decimal(10,2))=0 
						Then 
							--Case When ISNULL(sum(case when est_cuest_cob in (3,4) then 1 else 0 end),0) > 0 AND CAST(ISNULL(TRY_CAST(dato_col8 AS INT),0) AS Decimal(10,2))=0 
							Case When ISNULL(sum(case when est_cuest_cob in (3,4) then 1 else 0 end),0) > 0 AND CAST(ISNULL(TRY_CAST(asi.dato_col8 AS INT),0) AS Decimal(10,2))=0 
								Then 100 
								Else 0 
							End 
						Else 
							CAST(((ISNULL(sum(
								case when est_cuest_cob in (3,4) 
									then 1 
									else 0 
								--end),0) / CAST(ISNULL(TRY_CAST(dato_col8 AS INT),0) AS Decimal(10,2))) * 100) AS Decimal(10,2)) 
								end),0) / CAST(ISNULL(TRY_CAST(asi.dato_col8 AS INT),0) AS Decimal(10,2))) * 100) AS Decimal(10,2)) 
						End ) as col08,
				COUNT(CASE WHEN PER.est_cuest_cob = 4 THEN 1 END) AS cuestionarios_completos,
				COUNT(CASE WHEN PER.est_cuest_cob = 3 THEN 1 END) AS cuestionarios_parciales,
				COUNT(CASE WHEN PER.est_cuest_cob = 2 THEN 1 END) AS cuestionarios_iniciados,
				COUNT(CASE WHEN PER.est_cuest_cob = 1 THEN 1 END) AS cuestionarios_no_iniciados,
				COUNT(CASE WHEN PER.est_cuest_cob IN (3,4) THEN 1 END) AS personas_censadas
			from [PROCESAMIENTOCPV_2023].[dbo].[PERSONAS] per
			INNER JOIN SGCPV..GES_DIRECCION DIR ON PER.cod_uso_destino = DIR.CodUsoDestino
			INNER JOIN SGCPV..GES_ASIGNACION_COLECTIVAS ASI ON PER.cod_uso_destino = ASI.CodUsoDestino   
																										--and asi.dato_col18 = (
																										--	SELECT max(dato_col18)
																										--FROM SGCPV..GES_ASIGNACION_COLECTIVAS ASI2
																										--	INNER JOIN SGCPV..GES_DIRECCION DIR2 ON ASI2.CodUsoDestino = DIR2.CodUsoDestino 
																										--where  LEFT(dir2.ID_COLECTIVA,CHARINDEX('_',dir2.ID_Colectiva)-1) = LEFT(dir.ID_COLECTIVA,CHARINDEX('_',dir.ID_Colectiva)-1)
																										--	)
--			where  LEFT(ID_COLECTIVA,CHARINDEX('_',ID_Colectiva)-1) = 'APC10424'
			where DIR.ID_COLECTIVA IS NOT NULL  AND (ASI.dato_col1 = 34 OR (ASI.dato_col1 = 33 AND NOT EXISTS (SELECT AC.CODUSODESTINO FROM SGCPV..GES_ASIGNACION_COLECTIVAS AC WHERE AC.DATO_COL1 = 34 AND AC.CODUSODESTINO = ASI.CODUSODESTINO)))
			GROUP BY LEFT(ID_COLECTIVA,CHARINDEX('_',ID_Colectiva)-1)--, PER.nombre
			--, PER.cod_uso_destino
			--, PER.est_cuest_cob
			,ASI.dato_col8
			) A
		)
		EST ON EST.ID_COLECTIVA = PIV.ID_COLECTIVA
	

