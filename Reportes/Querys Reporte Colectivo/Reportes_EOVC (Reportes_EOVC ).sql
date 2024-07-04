

select 
	GEO3.Nombre as Región,
	GEO.nombre AS Comuna,  
	MANZANA AS MANZANA,
	Direccion as Dirección,
	CASE 
		WHEN (SELECT TOP 1 LEN(DIR.CODUSODESTINO) FROM SGCPV..GES_DIRECCION dir
				inner join SGCPV..GES_ASIGNACION_COLECTIVAS col on col.CodUsoDestino = dir.CodUsoDestino
				where ID_Colectiva is null and dir.tipo_operativo = 3
				and col.Tipo_Levantamiento in (1,2,3)
				AND DIR.cut+'-'+col.dato_col11 = piv.ID_COLECTIVO)<=10 THEN 'Precarga'
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
--	ASI.dato_col1,
	ISNULL(TL.Nombre,'') as Modalidad_Recolección_VC,
	ASI.dato_col17 as Observación,
	ISNULL((SELECT [Folio] FROM [SGCPV].[dbo].[GES_ASIGNACION_VIVCOLECTIVA_PAPEL] where IdTipoAsignacion = 12 AND Activo=1 and CodUsoDestino= '0' ),'') AS FOLIO,
	ISNULL(CONVERT(VARCHAR,QR.FechaRegistroVinCod,105),'') AS FECHA_ENVIO_CLAVE,
	ISNULL(CONVERT(VARCHAR,QR.FechaRegistroVinCod,105),'') AS FECHA_VINCULACION,

	CONVERT(VARCHAR,CAST(ASI.dato_col18 AS DATE),105) AS FECHA_INICIADO_LLENADO,
	isnull(ASI.dato_col8,0) as Cantidad_Residentes_habituales_VC,

	ISNULL(EST.ESTADO_VC,'') AS ESTADO_VC,

	ISNULL(EST.cuestionarios_completos,0) AS CANTIDAD_CUESTIONARIO_COMPLETOS,
	ISNULL(Case When EST.cuestionarios_completos = 0 or isnull(ASI.dato_col8,0)=0 Then Case When EST.cuestionarios_completos > 0 AND isnull(ASI.dato_col8,0)=0 Then 100 Else 0 End Else CAST(((cast(EST.cuestionarios_completos as Decimal(10,2)) / cast(isnull(ASI.dato_col8,0)as Decimal(10,2)))  * 100) AS Decimal(10,2)) End,0) as '% CUESTIONARIO_COMPLETOS',

	ISNULL(EST.cuestionarios_parciales,0) AS cuestionarios_parciales,
	ISNULL(Case When EST.cuestionarios_parciales = 0 or isnull(ASI.dato_col8,0)=0 Then Case When EST.cuestionarios_parciales > 0 AND isnull(ASI.dato_col8,0)=0 Then 100 Else 0 End Else CAST(((cast(EST.cuestionarios_parciales as Decimal(10,2)) / cast(isnull(ASI.dato_col8,0)as Decimal(10,2)))  * 100) AS Decimal(10,2)) End,0) as '% CANTIDAD_CUESTIONARIO_PARCIALES',

	ISNULL(EST.cuestionarios_iniciados,0) AS cuestionarios_iniciados,
	ISNULL(Case When EST.cuestionarios_iniciados = 0 or isnull(ASI.dato_col8,0)=0 Then Case When EST.cuestionarios_iniciados > 0 AND isnull(ASI.dato_col8,0)=0 Then 100 Else 0 End Else CAST(((cast(EST.cuestionarios_iniciados as Decimal(10,2)) / cast(isnull(ASI.dato_col8,0)as Decimal(10,2)))  * 100) AS Decimal(10,2)) End,0) as '% CANTIDAD_CUESTIONARIO_INICIADOS',

	ISNULL(EST.cuestionarios_no_iniciados,0) AS cuestionarios_no_iniciados,
	ISNULL(Case When EST.cuestionarios_no_iniciados= 0 or isnull(ASI.dato_col8,0)=0 Then Case When EST.cuestionarios_no_iniciados > 0 AND isnull(ASI.dato_col8,0)=0 Then 100 Else 0 End Else CAST(((cast(EST.cuestionarios_no_iniciados as Decimal(10,2)) / cast(isnull(ASI.dato_col8,0)as Decimal(10,2)))  * 100) AS Decimal(10,2)) End,0) as '% CANTIDAD_CUESTIONARIO_NO_INICIADOS',

	ISNULL(EST.PERSONAS_CENSADAS,0) AS PERSONAS_CENSADAS,
	ISNULL(Case When EST.PERSONAS_CENSADAS = 0 or isnull(asi.dato_col8,0)=0 Then Case When EST.PERSONAS_CENSADAS > 0 AND isnull(ASI.dato_col8,0)=0 Then 100 Else 0 End Else CAST(((cast(EST.PERSONAS_CENSADAS as Decimal(10,2)) / cast(isnull(ASI.dato_col8,0)as Decimal(10,2)))  * 100) AS Decimal(10,2)) End,0) as '% PERSONAS_CENSADAS',
	
	IDVC.ID_VC AS ID_VC,
--	SUSO.suso_interview_status,
	CASE 
		WHEN SUSO.suso_interview_status = 100 THEN 1
		ELSE 0
	END AS REGISTRO_CERRADO,
	PIV.ID_COLECTIVO
FROM (
	(
		SELECT  REPLACE(DIR.cut+'-'+col.dato_col11+col.dato_col8+DIR.NombreVia+NumeroDomiciliario,' ','') as ID_COLECTIVO 
		FROM SGCPV..GES_DIRECCION dir
			inner join SGCPV..GES_ASIGNACION_COLECTIVAS col on col.CodUsoDestino = dir.CodUsoDestino
		where --ID_Colectiva is null and 
		dir.tipo_operativo = 3
		and col.Tipo_Levantamiento in (1,2,3)
--		and col.dato_col11='ELEAM ALERCE' --'C.P. PUERTO MONTT'
--		AND	REPLACE(dir.cut+'-'+col.dato_col11+col.dato_col8+DIR.NombreVia+NumeroDomiciliario,' ','') = '6101-CASADEREPOSOHERMANOCLAUDIO22CAPITANRAMONFREIRE116' --'10101-RDS-RESIDENCIALASAZALEAS15LOSCEREZOS1285'
--and 	DIR.CUT in (
--			select geo.codigo from sgcpv..GLO_GEOGRAFIA GEO --= GEO.Codigo
--					inner JOIN SGCPV..GLO_GEOGRAFIA GEO2 ON GEO2.IdGeografia = GEO.Padre 
--					inner JOIN SGCPV..GLO_GEOGRAFIA GEO3 ON GEO3.IdGeografia = GEO2.Padre and GEO3.Codigo = 1      -- Filtrar por regiones
--						)
		group by  REPLACE(dir.cut+'-'+col.dato_col11+col.dato_col8+DIR.NombreVia+NumeroDomiciliario,' ','') --, DIR.CUT, ISNULL(DIR.UBICACIONGEOGRAFICA, ''), DIR.NombreVia, DIR.NumeroDomiciliario
	) PIV

	LEFT JOIN
	(
		select 
			ROW_NUMBER() OVER(PARTITION BY REPLACE(DIR.cut+'-'+col.dato_col11+col.dato_col8+DIR.NombreVia+NumeroDomiciliario,' ','') ORDER BY DIR.iddireccion asc) AS Row#,
			REPLACE(DIR.cut+'-'+col.dato_col11+col.dato_col8+DIR.NombreVia+NumeroDomiciliario,' ','') as id_colectivo,
			DIR.UBICACIONGEOGRAFICA AS MANZANA,
			(concat(DIR.NombreVia,' ',DIR.NumeroDomiciliario)) as Direccion ,
			DIR.CUT AS CUT
		FROM SGCPV..GES_DIRECCION dir
			inner join SGCPV..GES_ASIGNACION_COLECTIVAS col on col.CodUsoDestino = dir.CodUsoDestino
		--where DIR.cut+'-'+col.dato_col11+col.dato_col8+DIR.NombreVia+NumeroDomiciliario = '10101-ELEAM ALERCE77VIOLETA PARRA5178'
	)
	DIR ON PIV.ID_COLECTIVO = DIR.id_colectivo AND DIR.Row# = 1


	LEFT JOIN sgcpv..GLO_GEOGRAFIA GEO ON DIR.CUT = GEO.Codigo
	LEFT JOIN SGCPV..GLO_GEOGRAFIA GEO2 ON GEO2.IdGeografia = GEO.Padre 
	LEFT JOIN SGCPV..GLO_GEOGRAFIA GEO3 ON GEO3.IdGeografia = GEO2.Padre 

	LEFT JOIN
	(
		SELECT 
		ROW_NUMBER() OVER(PARTITION BY REPLACE(DIR.cut+'-'+ASI.dato_col11+ASI.dato_col8+DIR.NombreVia+NumeroDomiciliario,' ','') ORDER BY DATo_col18 desc) AS Row#,
		--DIR.cut+'-'+ASI.dato_col11 AS ID_COLECTIVA, 
		REPLACE(DIR.cut+'-'+ASI.dato_col11+ASI.dato_col8+DIR.NombreVia+NumeroDomiciliario,' ','') AS ID_COLECTIVA,
		 DATO_COL1, DATO_COL3, DATO_COL6, DATO_COL8, DATO_COL11, DATO_COL12, DATO_COL13, DATO_COL14, dato_col17,
			dato_col18
			,Tipo_Levantamiento 
		FROM SGCPV..GES_ASIGNACION_COLECTIVAS ASI
			INNER JOIN SGCPV..GES_DIRECCION DIR ON ASI.CodUsoDestino = DIR.CodUsoDestino
		where 
			(ASI.dato_col1 = 34 OR (ASI.dato_col1 = 33 AND NOT EXISTS (SELECT AC.CODUSODESTINO FROM SGCPV..GES_ASIGNACION_COLECTIVAS AC WHERE AC.DATO_COL1 = 34 AND AC.CODUSODESTINO = ASI.CODUSODESTINO)))
			--AND DIR.cut+'-'+ASI.dato_col11 = '10101-C.P. PUERTO MONTT'
	)
	ASI ON PIV.ID_COLECTIVO = ASI.ID_COLECTIVA and asi.Row# = 1

	LEFT JOIN 
	(
		SELECT Nombre,ASI.IdTipoAsignacion,  REPLACE(DIR.cut+'-'+COL.dato_col11+COL.dato_col8+DIR.NombreVia+NumeroDomiciliario,' ','') AS ID_COLECTIVO 
				, ROW_NUMBER() OVER(PARTITION BY  REPLACE(DIR.cut+'-'+COL.dato_col11+COL.dato_col8+DIR.NombreVia+NumeroDomiciliario,' ','') ORDER BY ASI.IdTipoAsignacion desc) AS Row#
		FROM SGCPV..GES_USUARIO USU 
			INNER JOIN SGCPV..GES_ASIGNACIONES ASI ON USU.IDUSUARIO = ASI.IDASIGNACIONA 
			INNER JOIN SGCPV..GES_DIRECCION DIR ON ASI.IdAsignacionDe = DIR.CodUsoDestino
			INNER JOIN SGCPV..GES_ASIGNACION_COLECTIVAS COL ON DIR.CodUsoDestino = COL.CodUsoDestino
--		WHERE DIR.cut+'-'+COL.dato_col11 = '10101-C.P. PUERTO MONTT'
		GROUP BY Nombre,ASI.IdTipoAsignacion, REPLACE(DIR.cut+'-'+COL.dato_col11+COL.dato_col8+DIR.NombreVia+NumeroDomiciliario,' ','')
	)
	TBL_VC ON PIV.ID_COLECTIVO = TBL_VC.ID_COLECTIVO AND TBL_VC.IdTipoAsignacion = CAST(ASI.dato_col1 AS int)-15 and TBL_VC.Row# = 1

	LEFT JOIN SGCPV..GLO_TIPO_LEVANTAMIENTO TL ON TL.IdTipoLevantamiento = asi.Tipo_Levantamiento  


		-- DETERINAR EL ESTADO_VC
	LEFT JOIN
		(
		SELECT ID_COLECTIVA,
		CASE WHEN COL08>=95 THEN 'Censada' ELSE 'No Censada' END AS ESTADO_VC,
		ISNULL(cuestionarios_completos,0) AS cuestionarios_completos,
		ISNULL(cuestionarios_parciales,0) AS cuestionarios_parciales,
		ISNULL(cuestionarios_iniciados,0) AS cuestionarios_iniciados,
		ISNULL(cuestionarios_no_iniciados,0) AS cuestionarios_no_iniciados,
		ISNULL(personas_censadas,0) AS personas_censadas
		FROM 
		(
		select  REPLACE(DIR.cut+'-'+ASI.dato_col11+ASI.dato_col8+DIR.NombreVia+NumeroDomiciliario,' ','') AS ID_COLECTIVA
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
			where 
			(ASI.dato_col1 = 34 OR (ASI.dato_col1 = 33 AND NOT EXISTS (SELECT AC.CODUSODESTINO FROM SGCPV..GES_ASIGNACION_COLECTIVAS AC WHERE AC.DATO_COL1 = 34 AND AC.CODUSODESTINO = ASI.CODUSODESTINO)))
--			AND DIR.cut+'-'+ASI.dato_col11 = '10101-C.P. PUERTO MONTT'
			GROUP BY REPLACE(DIR.cut+'-'+ASI.dato_col11+ASI.dato_col8+DIR.NombreVia+NumeroDomiciliario,' ','')
			,ASI.dato_col8
			) A
		)
		EST ON EST.ID_COLECTIVA = PIV.ID_COLECTIVO


		LEFT JOIN 
		(
			select 
			ROW_NUMBER() OVER(PARTITION BY REPLACE(DIR.cut+'-'+col.dato_col11+col.dato_col8+DIR.NombreVia+NumeroDomiciliario,' ','') ORDER BY DIR.ID_COLECTIVA DESC) AS Row#,
			REPLACE(DIR.cut+'-'+col.dato_col11+col.dato_col8+DIR.NombreVia+NumeroDomiciliario,' ','') as id_colectivo,
			CASE 
				WHEN LEFT(ID_COLECTIVA,CHARINDEX('_',ID_Colectiva)-1) IS NOT NULL THEN LEFT(ID_COLECTIVA,CHARINDEX('_',ID_Colectiva)-1)
				ELSE 'SIN ID'
			END AS ID_VC
			FROM SGCPV..GES_DIRECCION dir
				inner join SGCPV..GES_ASIGNACION_COLECTIVAS col on col.CodUsoDestino = dir.CodUsoDestino
			--where REPLACE(DIR.cut+'-'+col.dato_col11+col.dato_col8+DIR.NombreVia+NumeroDomiciliario,' ','') = '10101-ELEAMALERCE77VIOLETAPARRA5178'
		)
		IDVC ON IDVC.id_colectivo = PIV.ID_COLECTIVO AND IDVC.Row#=1 


		LEFT JOIN
		(
			SELECT 
				ROW_NUMBER() OVER(PARTITION BY REPLACE(DIR.cut+'-'+col.dato_col11+col.dato_col8+DIR.NombreVia+NumeroDomiciliario,' ','') ORDER BY viv.suso_interview_status desc) AS Row#,
				viv.suso_interview_status,  viv.cod_uso_destino, REPLACE(DIR.cut+'-'+col.dato_col11+col.dato_col8+DIR.NombreVia+NumeroDomiciliario,' ','') as ID_COLECTIVO 
			FROM PROCESAMIENTOCPV_2023..VIVIENDA viv
				inner join SGCPV..GES_DIRECCION dir on viv.cod_uso_destino = dir.CodUsoDestino
				inner join SGCPV..GES_ASIGNACION_COLECTIVAS col on col.CodUsoDestino = dir.CodUsoDestino
			where 
--			REPLACE(dir.cut+'-'+col.dato_col11+col.dato_col8+DIR.NombreVia+NumeroDomiciliario,' ','') = '10101-CentroRecreativoCoincide1BUIN583' --'6101-CASADEREPOSOHERMANOCLAUDIO22CAPITANRAMONFREIRE116' --'10101-RDS-RESIDENCIALASAZALEAS15LOSCEREZOS1285'
			suso_interview_status is not null 
		)
		SUSO ON SUSO.ID_COLECTIVO = PIV.ID_COLECTIVO AND SUSO.Row#=1


		LEFT JOIN
		(
			select  TOP 1
				REPLACE(dir.cut+'-'+col.dato_col11+col.dato_col8+DIR.NombreVia+NumeroDomiciliario,' ','')  AS ID_COLECTIVO, CONVERT(VARCHAR(10),CAST(SUSO.FechaRegistroVinCod AS DATE),105) AS FechaRegistroVinCod
			from SGCPV..GES_INTEGRACION_QR_SUSO SUSO
			INNER JOIN SGCPV..GES_DIRECCION DIR ON SUSO.CodUsoDestino = DIR.CodUsoDestino
			inner join SGCPV..GES_ASIGNACION_COLECTIVAS col on col.CodUsoDestino = dir.CodUsoDestino
			where TipoLevantamiento <> 2

		--	AND REPLACE(dir.cut+'-'+col.dato_col11+col.dato_col8+DIR.NombreVia+NumeroDomiciliario,' ','') = '10101-C.P.PUERTOMONTT1729ARGENTINA25' --'6101-CASADEREPOSOHERMANOCLAUDIO22CAPITANRAMONFREIRE116' --'10101-RDS-RESIDENCIALASAZALEAS15LOSCEREZOS1285'
			GROUP BY REPLACE(dir.cut+'-'+col.dato_col11+col.dato_col8+DIR.NombreVia+NumeroDomiciliario,' ',''), CONVERT(VARCHAR(10),CAST(SUSO.FechaRegistroVinCod AS DATE),105)
			ORDER BY CONVERT(VARCHAR(10),CAST(SUSO.FechaRegistroVinCod AS DATE),105) DESC
		)
		QR ON QR.ID_COLECTIVO = PIV.ID_COLECTIVO

	) 
