DECLARE @FECHA AS DATE 
DECLARE @FECHAAC AS DATE
SET @FECHA= (SELECT CAST(DATEADD(DAY, -7, GETDATE()) as date))
SET @FECHAAC= (SELECT CAST(GETDATE() as date))

SELECT Region as 'Region'
	,Comuna as 'Comuna'
	,NOMBRE AS 'Local Censal'
	,Bloque_horario AS 'Bloque Horario'
	,Lunes as 'Lunes'
	,Martes as 'Martes'
	,Miercoles as 'Miércoles'	
	,Jueves as 'Jueves'	
	,Viernes as 'Viernes'	
	,Sabado as 'Sábado '	
	,Domingo as 'Domingo' 
		FROM (
		SELECT Region, GLO_COM.Comuna, TBL.IdUnidadTerritorial
			,ISNULL(UPPER(GLO_GEO.NOMBRE),TBL.IdUnidadTerritorial) AS NOMBRE
			,Bloque_horario
			,Case When Horario1 = 0 or Dia01=0 Then Case When Horario1 > 0 AND Dia01=0 Then 100 Else 0 End Else CAST((Horario1 / Dia01)  AS Decimal(10,2)) End as 'lunes'
			,Case When Horario2 = 0 or Dia02=0 Then Case When Horario2 > 0 AND Dia02=0 Then 100 Else 0 End Else CAST((Horario2 / Dia02)  AS Decimal(10,2)) End as 'Martes'	
			,Case When Horario3 = 0 or Dia03=0 Then Case When Horario3 > 0 AND Dia03=0 Then 100 Else 0 End Else CAST((Horario3 / Dia03)  AS Decimal(10,2)) End as 'Miercoles'	
			,Case When Horario4 = 0 or Dia04=0 Then Case When Horario4 > 0 AND Dia04=0 Then 100 Else 0 End Else CAST((Horario4 / Dia04)  AS Decimal(10,2)) End as 'Jueves'	
			,Case When Horario5 = 0 or Dia05=0 Then Case When Horario5 > 0 AND Dia05=0 Then 100 Else 0 End Else CAST((Horario5 / Dia05)  AS Decimal(10,2)) End as 'Viernes'	
			,Case When Horario6 = 0 or Dia06=0 Then Case When Horario6 > 0 AND Dia06=0 Then 100 Else 0 End Else CAST((Horario6 / Dia06)  AS Decimal(10,2)) End as 'Sabado'	
			,Case When Horario7 = 0 or Dia07=0 Then Case When Horario7 > 0 AND Dia07=0 Then 100 Else 0 End Else CAST((Horario7 / Dia07)  AS Decimal(10,2)) End as 'Domingo'
		 FROM (SELECT IdLocalCensal AS IdUnidadTerritorial, CodigoRegion, CodigoComuna FROM [REPORTES_EXP_2023].[dbo].[TBL_DIRECCION_ASIGNADA] WITH (NOLOCK)
		 GROUP BY IdLocalCensal, CodigoRegion, CodigoComuna) TBL
		LEFT JOIN
			(SELECT IDUNICOLOCALCENSAL AS IdUnidadTerritorial,NOMBRE FROM SGCPV.dbo.GES_AREA_LEVANTAMIENTO WITH (NOLOCK) WHERE NOT IDUNICOLOCALCENSAL  IS NULL)
			GLO_GEO ON TBL.IdUnidadTerritorial=CONVERT(VARCHAR(100),GLO_GEO.IdUnidadTerritorial) 			
		LEFT JOIN
			(SELECT CODIGO AS CodigoRegion, NOMBRE as Region FROM  SGCPV.dbo.GLO_GEOGRAFIA WITH (NOLOCK) WHERE IdGeografiaNivel=1)
			GLO_REG ON TBL.CodigoRegion=CONVERT(VARCHAR(100),GLO_REG.CodigoRegion) 
		LEFT JOIN
			(SELECT CODIGO AS CodigoComuna, NOMBRE as Comuna FROM  SGCPV.dbo.GLO_GEOGRAFIA WITH (NOLOCK) WHERE IdGeografiaNivel=3)
			GLO_COM ON TBL.CodigoComuna=CONVERT(VARCHAR(100),GLO_COM.CodigoComuna)
	LEFT JOIN
	(
		/*Bloque horario: 09:00 a 10:59:59*/
		SELECT TBL.IdUnidadTerritorial
			,ISNULL(Bloque_horario,'Bloque horario: 09:00 a 10:59') AS 'Bloque_horario'
			,ISNULL(Horario1,0) as Horario1
			,ISNULL(Horario2,0) as Horario2
			,ISNULL(Horario3,0) as Horario3
			,ISNULL(Horario4,0) as Horario4
			,ISNULL(Horario5,0) as Horario5
			,ISNULL(Horario6,0) as Horario6
			,ISNULL(Horario7,0) as Horario7 
			,CAST(ISNULL(Col01,0) AS DECIMAL(10,2)) as Dia01
			,CAST(ISNULL(Col02,0) AS DECIMAL(10,2)) as Dia02
			,CAST(ISNULL(Col03,0) AS DECIMAL(10,2)) as Dia03
			,CAST(ISNULL(Col04,0) AS DECIMAL(10,2)) as Dia04
			,CAST(ISNULL(Col05,0) AS DECIMAL(10,2)) as Dia05
			,CAST(ISNULL(Col06,0) AS DECIMAL(10,2)) as Dia06
			,CAST(ISNULL(Col07,0) AS DECIMAL(10,2)) as Dia07 
		FROM (SELECT IdLocalCensal AS IdUnidadTerritorial FROM [REPORTES_EXP_2023].[dbo].[TBL_DIRECCION_ASIGNADA] WITH (NOLOCK)
		GROUP BY IdLocalCensal) TBL
		LEFT JOIN 
		(SELECT IdLocalCensal  AS IdUnidadTerritorial
				,'Bloque horario: 09:00 a 10:59' AS 'Bloque_horario'
				,SUM(Horario1) as Horario1
				,SUM(Horario2) as Horario2
				,SUM(Horario3) as Horario3
				,SUM(Horario4) as Horario4
				,SUM(Horario5) as Horario5
				,SUM(Horario6) as Horario6
				,SUM(Horario7) as Horario7 
				FROM (				
					SELECT 
					IdLocalCensal
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =1 And try_convert(time,FechaHoraVisitaCensista) BETWEEN '09:00' AND '10:59:59' Then 1 Else 0 End as Horario1
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =2 And try_convert(time,FechaHoraVisitaCensista) BETWEEN '09:00' AND '10:59:59' Then 1 Else 0 End as Horario2
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =3 And try_convert(time,FechaHoraVisitaCensista) BETWEEN '09:00' AND '10:59:59' Then 1 Else 0 End as Horario3
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =4 And try_convert(time,FechaHoraVisitaCensista) BETWEEN '09:00' AND '10:59:59' Then 1 Else 0 End as Horario4
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =5 And try_convert(time,FechaHoraVisitaCensista) BETWEEN '09:00' AND '10:59:59' Then 1 Else 0 End as Horario5
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =6 And try_convert(time,FechaHoraVisitaCensista) BETWEEN '09:00' AND '10:59:59' Then 1 Else 0 End as Horario6
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =7 And try_convert(time,FechaHoraVisitaCensista) BETWEEN '09:00' AND '10:59:59' Then 1 Else 0 End as Horario7
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA WITH (NOLOCK) WHERE FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC  
							and tipo_operativo=2 and (IdEstadoDelCuestionario in (3,4) or IdOcupacionVivienda=2) ) B GROUP BY IdLocalCensal ) TBL_00
				ON TBL.IdUnidadTerritorial=TBL_00.IdUnidadTerritorial 
				 LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col01) as Col01 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col01 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 1 AND TRY_CONVERT(time,fec_hr_ind) BETWEEN '09:00' AND '10:59:59'
				 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO) 
				 B GROUP BY IdUnidadTerritorial)
				TBL_01 ON TBL.IdUnidadTerritorial=TBL_01.IdUnidadTerritorial
				LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col02) as Col02 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col02 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 2 AND TRY_CONVERT(time,fec_hr_ind) BETWEEN '09:00' AND '10:59:59'
					 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO) 
				 B GROUP BY IdUnidadTerritorial)
				TBL_02 ON TBL.IdUnidadTerritorial=TBL_02.IdUnidadTerritorial
				LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col03) as Col03 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col03 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 3 AND TRY_CONVERT(time,fec_hr_ind) BETWEEN '09:00' AND '10:59:59' 
					 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO) 
				B GROUP BY IdUnidadTerritorial)
				TBL_03 ON TBL.IdUnidadTerritorial=TBL_03.IdUnidadTerritorial
				LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col04) as Col04 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col04 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 4 AND TRY_CONVERT(time,fec_hr_ind) BETWEEN '09:00' AND '10:59:59'
					 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO) 
				B GROUP BY IdUnidadTerritorial)
				TBL_04 ON TBL.IdUnidadTerritorial=TBL_04.IdUnidadTerritorial
				LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col05) as Col05 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col05 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 5 AND TRY_CONVERT(time,fec_hr_ind) BETWEEN '09:00' AND '10:59:59'
					 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO)
				 B GROUP BY IdUnidadTerritorial)
				TBL_05 ON TBL.IdUnidadTerritorial=TBL_05.IdUnidadTerritorial
				LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col06) as Col06 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col06 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 6 AND TRY_CONVERT(time,fec_hr_ind) BETWEEN '09:00' AND '10:59:59'
					 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO)
				B GROUP BY IdUnidadTerritorial)
				TBL_06 ON TBL.IdUnidadTerritorial=TBL_06.IdUnidadTerritorial
				LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col07) as Col07 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col07 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 7 AND TRY_CONVERT(time,fec_hr_ind) BETWEEN '09:00' AND '10:59:59'
					 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO) 
				B GROUP BY IdUnidadTerritorial)
				TBL_07 ON TBL.IdUnidadTerritorial=TBL_07.IdUnidadTerritorial
		UNION ALL
		/*Bloque horario: 11:00 a 12:59:59*/
		SELECT TBL.IdUnidadTerritorial
			,ISNULL(Bloque_horario,'Bloque horario: 11:00 a 12:59') AS 'Bloque horario'
			,ISNULL(Horario1,0) as Horario1
			,ISNULL(Horario2,0) as Horario2
			,ISNULL(Horario3,0) as Horario3
			,ISNULL(Horario4,0) as Horario4
			,ISNULL(Horario5,0) as Horario5
			,ISNULL(Horario6,0) as Horario6
			,ISNULL(Horario7,0) as Horario7 
			,CAST(ISNULL(Col01,0) AS DECIMAL(10,2)) as Dia01
			,CAST(ISNULL(Col02,0) AS DECIMAL(10,2)) as Dia02
			,CAST(ISNULL(Col03,0) AS DECIMAL(10,2)) as Dia03
			,CAST(ISNULL(Col04,0) AS DECIMAL(10,2)) as Dia04
			,CAST(ISNULL(Col05,0) AS DECIMAL(10,2)) as Dia05
			,CAST(ISNULL(Col06,0) AS DECIMAL(10,2)) as Dia06
			,CAST(ISNULL(Col07,0) AS DECIMAL(10,2)) as Dia07
		FROM (SELECT IdLocalCensal AS IdUnidadTerritorial FROM [REPORTES_EXP_2023].[dbo].[TBL_DIRECCION_ASIGNADA] WITH (NOLOCK)
		GROUP BY IdLocalCensal ) TBL
		LEFT JOIN 
		(SELECT IdLocalCensal  AS IdUnidadTerritorial
				,'Bloque horario: 11:00 a 12:59' AS 'Bloque_horario'
				,SUM(Horario1) as Horario1
				,SUM(Horario2) as Horario2
				,SUM(Horario3) as Horario3
				,SUM(Horario4) as Horario4
				,SUM(Horario5) as Horario5
				,SUM(Horario6) as Horario6
				,SUM(Horario7) as Horario7
				FROM (				
					SELECT 
					IdLocalCensal
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =1 And try_convert(time,FechaHoraVisitaCensista) BETWEEN '11:00' AND '12:59:59' Then 1 Else 0 End as Horario1
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =2 And try_convert(time,FechaHoraVisitaCensista) BETWEEN '11:00' AND '12:59:59' Then 1 Else 0 End as Horario2
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =3 And try_convert(time,FechaHoraVisitaCensista) BETWEEN '11:00' AND '12:59:59' Then 1 Else 0 End as Horario3
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =4 And try_convert(time,FechaHoraVisitaCensista) BETWEEN '11:00' AND '12:59:59' Then 1 Else 0 End as Horario4
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =5 And try_convert(time,FechaHoraVisitaCensista) BETWEEN '11:00' AND '12:59:59' Then 1 Else 0 End as Horario5
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =6 And try_convert(time,FechaHoraVisitaCensista) BETWEEN '11:00' AND '12:59:59' Then 1 Else 0 End as Horario6
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =7 And try_convert(time,FechaHoraVisitaCensista) BETWEEN '11:00' AND '12:59:59' Then 1 Else 0 End as Horario7
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA WITH (NOLOCK) WHERE FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC  
					and tipo_operativo=2 and (IdEstadoDelCuestionario in (3,4) or IdOcupacionVivienda=2) ) B GROUP BY IdLocalCensal ) TBL_00
				ON TBL.IdUnidadTerritorial=TBL_00.IdUnidadTerritorial 
				 LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col01) as Col01 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col01 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 1 AND TRY_CONVERT(time,fec_hr_ind) BETWEEN '11:00' AND '12:59:59'
				 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO) 
				 B GROUP BY IdUnidadTerritorial)
				TBL_01 ON TBL.IdUnidadTerritorial=TBL_01.IdUnidadTerritorial
				LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col02) as Col02 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col02 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 2 AND TRY_CONVERT(time,fec_hr_ind) BETWEEN '11:00' AND '12:59:59'
					 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO) 
				 B GROUP BY IdUnidadTerritorial)
				TBL_02 ON TBL.IdUnidadTerritorial=TBL_02.IdUnidadTerritorial
				LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col03) as Col03 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col03 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 3 AND TRY_CONVERT(time,fec_hr_ind) BETWEEN '11:00' AND '12:59:59' 
					 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO) 
				B GROUP BY IdUnidadTerritorial)
				TBL_03 ON TBL.IdUnidadTerritorial=TBL_03.IdUnidadTerritorial
				LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col04) as Col04 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col04 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 4 AND TRY_CONVERT(time,fec_hr_ind) BETWEEN '11:00' AND '12:59:59'
					 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO) 
				B GROUP BY IdUnidadTerritorial)
				TBL_04 ON TBL.IdUnidadTerritorial=TBL_04.IdUnidadTerritorial
				LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col05) as Col05 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col05 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 5 AND TRY_CONVERT(time,fec_hr_ind) BETWEEN '11:00' AND '12:59:59'
					 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO)
				 B GROUP BY IdUnidadTerritorial)
				TBL_05 ON TBL.IdUnidadTerritorial=TBL_05.IdUnidadTerritorial
				LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col06) as Col06 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col06 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 6 AND TRY_CONVERT(time,fec_hr_ind) BETWEEN '11:00' AND '12:59:59'
					 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO)
				B GROUP BY IdUnidadTerritorial)
				TBL_06 ON TBL.IdUnidadTerritorial=TBL_06.IdUnidadTerritorial
				LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col07) as Col07 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col07 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 7 AND TRY_CONVERT(time,fec_hr_ind) BETWEEN '11:00' AND '12:59:59'
					 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO) 
				B GROUP BY IdUnidadTerritorial)
				TBL_07 ON TBL.IdUnidadTerritorial=TBL_07.IdUnidadTerritorial

		UNION ALL
		/*Bloque horario: 13:00 a 14:59:59*/
		SELECT TBL.IdUnidadTerritorial
			,ISNULL(Bloque_horario,'Bloque horario: 13:00 a 14:59') AS 'Bloque horario'
			,ISNULL(Horario1,0) as Horario1
			,ISNULL(Horario2,0) as Horario2
			,ISNULL(Horario3,0) as Horario3
			,ISNULL(Horario4,0) as Horario4
			,ISNULL(Horario5,0) as Horario5
			,ISNULL(Horario6,0) as Horario6
			,ISNULL(Horario7,0) as Horario7 
			,CAST(ISNULL(Col01,0) AS DECIMAL(10,2)) as Dia01
			,CAST(ISNULL(Col02,0) AS DECIMAL(10,2)) as Dia02
			,CAST(ISNULL(Col03,0) AS DECIMAL(10,2)) as Dia03
			,CAST(ISNULL(Col04,0) AS DECIMAL(10,2)) as Dia04
			,CAST(ISNULL(Col05,0) AS DECIMAL(10,2)) as Dia05
			,CAST(ISNULL(Col06,0) AS DECIMAL(10,2)) as Dia06
			,CAST(ISNULL(Col07,0) AS DECIMAL(10,2)) as Dia07		
		FROM (SELECT IdLocalCensal AS IdUnidadTerritorial FROM [REPORTES_EXP_2023].[dbo].[TBL_DIRECCION_ASIGNADA] WITH (NOLOCK)
		GROUP BY IdLocalCensal ) TBL
		LEFT JOIN 
		(SELECT IdLocalCensal  AS IdUnidadTerritorial
				,'Bloque horario: 13:00 a 14:59' AS 'Bloque_horario'
				,SUM(Horario1) as Horario1
				,SUM(Horario2) as Horario2
				,SUM(Horario3) as Horario3
				,SUM(Horario4) as Horario4
				,SUM(Horario5) as Horario5
				,SUM(Horario6) as Horario6
				,SUM(Horario7) as Horario7 FROM (				
					SELECT 
					IdLocalCensal
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =1 And try_convert(time,FechaHoraVisitaCensista) BETWEEN '13:00' AND '14:59:59' Then 1 Else 0 End as Horario1
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =2 And try_convert(time,FechaHoraVisitaCensista) BETWEEN '13:00' AND '14:59:59' Then 1 Else 0 End as Horario2
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =3 And try_convert(time,FechaHoraVisitaCensista) BETWEEN '13:00' AND '14:59:59' Then 1 Else 0 End as Horario3
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =4 And try_convert(time,FechaHoraVisitaCensista) BETWEEN '13:00' AND '14:59:59' Then 1 Else 0 End as Horario4
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =5 And try_convert(time,FechaHoraVisitaCensista) BETWEEN '13:00' AND '14:59:59' Then 1 Else 0 End as Horario5
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =6 And try_convert(time,FechaHoraVisitaCensista) BETWEEN '13:00' AND '14:59:59' Then 1 Else 0 End as Horario6
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =7 And try_convert(time,FechaHoraVisitaCensista) BETWEEN '13:00' AND '14:59:59' Then 1 Else 0 End as Horario7
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA WITH (NOLOCK) WHERE FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC  
					and tipo_operativo=2 and (IdEstadoDelCuestionario in (3,4) or IdOcupacionVivienda=2) ) B GROUP BY IdLocalCensal ) TBL_00
				ON TBL.IdUnidadTerritorial=TBL_00.IdUnidadTerritorial 
				 LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col01) as Col01 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col01 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 1 AND TRY_CONVERT(time,fec_hr_ind) BETWEEN '13:00' AND '14:59:59'
				 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO) 
				 B GROUP BY IdUnidadTerritorial)
				TBL_01 ON TBL.IdUnidadTerritorial=TBL_01.IdUnidadTerritorial
				LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col02) as Col02 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col02 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 2 AND TRY_CONVERT(time,fec_hr_ind) BETWEEN '13:00' AND '14:59:59'
					 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO) 
				 B GROUP BY IdUnidadTerritorial)
				TBL_02 ON TBL.IdUnidadTerritorial=TBL_02.IdUnidadTerritorial
				LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col03) as Col03 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col03 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 3 AND TRY_CONVERT(time,fec_hr_ind) BETWEEN '13:00' AND '14:59:59' 
					 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO) 
				B GROUP BY IdUnidadTerritorial)
				TBL_03 ON TBL.IdUnidadTerritorial=TBL_03.IdUnidadTerritorial
				LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col04) as Col04 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col04 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 4 AND TRY_CONVERT(time,fec_hr_ind) BETWEEN '13:00' AND '14:59:59'
					 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO) 
				B GROUP BY IdUnidadTerritorial)
				TBL_04 ON TBL.IdUnidadTerritorial=TBL_04.IdUnidadTerritorial
				LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col05) as Col05 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col05 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 5 AND TRY_CONVERT(time,fec_hr_ind) BETWEEN '13:00' AND '14:59:59'
					 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO)
				 B GROUP BY IdUnidadTerritorial)
				TBL_05 ON TBL.IdUnidadTerritorial=TBL_05.IdUnidadTerritorial
				LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col06) as Col06 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col06 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 6 AND TRY_CONVERT(time,fec_hr_ind) BETWEEN '13:00' AND '14:59:59'
					 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO)
				B GROUP BY IdUnidadTerritorial)
				TBL_06 ON TBL.IdUnidadTerritorial=TBL_06.IdUnidadTerritorial
				LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col07) as Col07 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col07 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 7 AND TRY_CONVERT(time,fec_hr_ind) BETWEEN '13:00' AND '14:59:59'
					 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO) 
				B GROUP BY IdUnidadTerritorial)
				TBL_07 ON TBL.IdUnidadTerritorial=TBL_07.IdUnidadTerritorial

		UNION ALL
		/*Bloque horario: 15:00 a 16:59:59*/
		SELECT TBL.IdUnidadTerritorial
			,ISNULL(Bloque_horario,'Bloque horario: 15:00 a 16:59') AS 'Bloque horario'
			,ISNULL(Horario1,0) as Horario1
			,ISNULL(Horario2,0) as Horario2
			,ISNULL(Horario3,0) as Horario3
			,ISNULL(Horario4,0) as Horario4
			,ISNULL(Horario5,0) as Horario5
			,ISNULL(Horario6,0) as Horario6
			,ISNULL(Horario7,0) as Horario7 
			,CAST(ISNULL(Col01,0) AS DECIMAL(10,2)) as Dia01
			,CAST(ISNULL(Col02,0) AS DECIMAL(10,2)) as Dia02
			,CAST(ISNULL(Col03,0) AS DECIMAL(10,2)) as Dia03
			,CAST(ISNULL(Col04,0) AS DECIMAL(10,2)) as Dia04
			,CAST(ISNULL(Col05,0) AS DECIMAL(10,2)) as Dia05
			,CAST(ISNULL(Col06,0) AS DECIMAL(10,2)) as Dia06
			,CAST(ISNULL(Col07,0) AS DECIMAL(10,2)) as Dia07		
		FROM (SELECT IdLocalCensal AS IdUnidadTerritorial  FROM [REPORTES_EXP_2023].[dbo].[TBL_DIRECCION_ASIGNADA] WITH (NOLOCK)
		GROUP BY IdLocalCensal) TBL
		LEFT JOIN 
		(SELECT IdLocalCensal  AS IdUnidadTerritorial
				,'Bloque horario: 15:00 a 16:59' AS 'Bloque_horario'
				,SUM(Horario1) as Horario1
				,SUM(Horario2) as Horario2
				,SUM(Horario3) as Horario3
				,SUM(Horario4) as Horario4
				,SUM(Horario5) as Horario5
				,SUM(Horario6) as Horario6
				,SUM(Horario7) as Horario7 FROM (				
					SELECT 
					IdLocalCensal
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =1 And try_convert(time,FechaHoraVisitaCensista) BETWEEN '15:00' AND '16:59:59' Then 1 Else 0 End as Horario1
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =2 And try_convert(time,FechaHoraVisitaCensista) BETWEEN '15:00' AND '16:59:59' Then 1 Else 0 End as Horario2
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =3 And try_convert(time,FechaHoraVisitaCensista) BETWEEN '15:00' AND '16:59:59' Then 1 Else 0 End as Horario3
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =4 And try_convert(time,FechaHoraVisitaCensista) BETWEEN '15:00' AND '16:59:59' Then 1 Else 0 End as Horario4
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =5 And try_convert(time,FechaHoraVisitaCensista) BETWEEN '15:00' AND '16:59:59' Then 1 Else 0 End as Horario5
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =6 And try_convert(time,FechaHoraVisitaCensista) BETWEEN '15:00' AND '16:59:59' Then 1 Else 0 End as Horario6
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =7 And try_convert(time,FechaHoraVisitaCensista) BETWEEN '15:00' AND '16:59:59' Then 1 Else 0 End as Horario7
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA WITH (NOLOCK) WHERE FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC  
					and tipo_operativo=2 and (IdEstadoDelCuestionario in (3,4) or IdOcupacionVivienda=2) ) B GROUP BY IdLocalCensal ) TBL_00
				ON TBL.IdUnidadTerritorial=TBL_00.IdUnidadTerritorial 
				 LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col01) as Col01 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col01 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 1 AND TRY_CONVERT(time,fec_hr_ind) BETWEEN '15:00' AND '16:59:59'
				 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO) 
				 B GROUP BY IdUnidadTerritorial)
				TBL_01 ON TBL.IdUnidadTerritorial=TBL_01.IdUnidadTerritorial
				LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col02) as Col02 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col02 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 2 AND TRY_CONVERT(time,fec_hr_ind) BETWEEN '15:00' AND '16:59:59'
					 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO) 
				 B GROUP BY IdUnidadTerritorial)
				TBL_02 ON TBL.IdUnidadTerritorial=TBL_02.IdUnidadTerritorial
				LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col03) as Col03 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col03 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 3 AND TRY_CONVERT(time,fec_hr_ind) BETWEEN '15:00' AND '16:59:59' 
					 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO) 
				B GROUP BY IdUnidadTerritorial)
				TBL_03 ON TBL.IdUnidadTerritorial=TBL_03.IdUnidadTerritorial
				LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col04) as Col04 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col04 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 4 AND TRY_CONVERT(time,fec_hr_ind) BETWEEN '15:00' AND '16:59:59'
					 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO) 
				B GROUP BY IdUnidadTerritorial)
				TBL_04 ON TBL.IdUnidadTerritorial=TBL_04.IdUnidadTerritorial
				LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col05) as Col05 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col05 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 5 AND TRY_CONVERT(time,fec_hr_ind) BETWEEN '15:00' AND '16:59:59'
					 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO)
				 B GROUP BY IdUnidadTerritorial)
				TBL_05 ON TBL.IdUnidadTerritorial=TBL_05.IdUnidadTerritorial
				LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col06) as Col06 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col06 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 6 AND TRY_CONVERT(time,fec_hr_ind) BETWEEN '15:00' AND '16:59:59'
					 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO)
				B GROUP BY IdUnidadTerritorial)
				TBL_06 ON TBL.IdUnidadTerritorial=TBL_06.IdUnidadTerritorial
				LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col07) as Col07 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col07 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 7 AND TRY_CONVERT(time,fec_hr_ind) BETWEEN '15:00' AND '16:59:59'
					 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO) 
				B GROUP BY IdUnidadTerritorial)
				TBL_07 ON TBL.IdUnidadTerritorial=TBL_07.IdUnidadTerritorial
		UNION ALL
		/*Bloque horario: 17:00 a 18:59:59*/
		SELECT TBL.IdUnidadTerritorial
			,ISNULL(Bloque_horario,'Bloque horario: 17:00 a 18:59') AS 'Bloque horario'
			,ISNULL(Horario1,0) as Horario1
			,ISNULL(Horario2,0) as Horario2
			,ISNULL(Horario3,0) as Horario3
			,ISNULL(Horario4,0) as Horario4
			,ISNULL(Horario5,0) as Horario5
			,ISNULL(Horario6,0) as Horario6
			,ISNULL(Horario7,0) as Horario7 
			,CAST(ISNULL(Col01,0) AS DECIMAL(10,2)) as Dia01
			,CAST(ISNULL(Col02,0) AS DECIMAL(10,2)) as Dia02
			,CAST(ISNULL(Col03,0) AS DECIMAL(10,2)) as Dia03
			,CAST(ISNULL(Col04,0) AS DECIMAL(10,2)) as Dia04
			,CAST(ISNULL(Col05,0) AS DECIMAL(10,2)) as Dia05
			,CAST(ISNULL(Col06,0) AS DECIMAL(10,2)) as Dia06
			,CAST(ISNULL(Col07,0) AS DECIMAL(10,2)) as Dia07	
		FROM (SELECT IdLocalCensal AS IdUnidadTerritorial FROM [REPORTES_EXP_2023].[dbo].[TBL_DIRECCION_ASIGNADA] WITH (NOLOCK)
		GROUP BY IdLocalCensal) TBL
		LEFT JOIN 
		(SELECT IdLocalCensal  AS IdUnidadTerritorial
				,'Bloque horario: 17:00 a 18:59' AS 'Bloque_horario'
				,SUM(Horario1) as Horario1
				,SUM(Horario2) as Horario2
				,SUM(Horario3) as Horario3
				,SUM(Horario4) as Horario4
				,SUM(Horario5) as Horario5
				,SUM(Horario6) as Horario6
				,SUM(Horario7) as Horario7 FROM (				
					SELECT 
					IdLocalCensal
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =1 And try_convert(time,FechaHoraVisitaCensista) BETWEEN '17:00' AND '18:59:59' Then 1 Else 0 End as Horario1
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =2 And try_convert(time,FechaHoraVisitaCensista) BETWEEN '17:00' AND '18:59:59' Then 1 Else 0 End as Horario2
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =3 And try_convert(time,FechaHoraVisitaCensista) BETWEEN '17:00' AND '18:59:59' Then 1 Else 0 End as Horario3
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =4 And try_convert(time,FechaHoraVisitaCensista) BETWEEN '17:00' AND '18:59:59' Then 1 Else 0 End as Horario4
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =5 And try_convert(time,FechaHoraVisitaCensista) BETWEEN '17:00' AND '18:59:59' Then 1 Else 0 End as Horario5
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =6 And try_convert(time,FechaHoraVisitaCensista) BETWEEN '17:00' AND '18:59:59' Then 1 Else 0 End as Horario6
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =7 And try_convert(time,FechaHoraVisitaCensista) BETWEEN '17:00' AND '18:59:59' Then 1 Else 0 End as Horario7
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA WITH (NOLOCK) WHERE FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC  
					and tipo_operativo=2 and (IdEstadoDelCuestionario in (3,4) or IdOcupacionVivienda=2) ) B GROUP BY IdLocalCensal ) TBL_00
				ON TBL.IdUnidadTerritorial=TBL_00.IdUnidadTerritorial 
				 LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col01) as Col01 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col01 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 1 AND TRY_CONVERT(time,fec_hr_ind) BETWEEN '17:00' AND '18:59:59'
				 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO) 
				 B GROUP BY IdUnidadTerritorial)
				TBL_01 ON TBL.IdUnidadTerritorial=TBL_01.IdUnidadTerritorial
				LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col02) as Col02 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col02 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 2 AND TRY_CONVERT(time,fec_hr_ind) BETWEEN '17:00' AND '18:59:59'
					 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO) 
				 B GROUP BY IdUnidadTerritorial)
				TBL_02 ON TBL.IdUnidadTerritorial=TBL_02.IdUnidadTerritorial
				LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col03) as Col03 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col03 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 3 AND TRY_CONVERT(time,fec_hr_ind) BETWEEN '17:00' AND '18:59:59' 
					 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO) 
				B GROUP BY IdUnidadTerritorial)
				TBL_03 ON TBL.IdUnidadTerritorial=TBL_03.IdUnidadTerritorial
				LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col04) as Col04 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col04 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 4 AND TRY_CONVERT(time,fec_hr_ind) BETWEEN '17:00' AND '18:59:59'
					 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO) 
				B GROUP BY IdUnidadTerritorial)
				TBL_04 ON TBL.IdUnidadTerritorial=TBL_04.IdUnidadTerritorial
				LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col05) as Col05 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col05 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 5 AND TRY_CONVERT(time,fec_hr_ind) BETWEEN '17:00' AND '18:59:59'
					 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO)
				 B GROUP BY IdUnidadTerritorial)
				TBL_05 ON TBL.IdUnidadTerritorial=TBL_05.IdUnidadTerritorial
				LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col06) as Col06 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col06 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 6 AND TRY_CONVERT(time,fec_hr_ind) BETWEEN '17:00' AND '18:59:59'
					 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO)
				B GROUP BY IdUnidadTerritorial)
				TBL_06 ON TBL.IdUnidadTerritorial=TBL_06.IdUnidadTerritorial
				LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col07) as Col07 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col07 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 7 AND TRY_CONVERT(time,fec_hr_ind) BETWEEN '17:00' AND '18:59:59'
					 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO) 
				B GROUP BY IdUnidadTerritorial)
				TBL_07 ON TBL.IdUnidadTerritorial=TBL_07.IdUnidadTerritorial
		UNION ALL
		/*Bloque horario: 19:00 a 20:59:59*/
		SELECT TBL.IdUnidadTerritorial
			,ISNULL(Bloque_horario,'Bloque horario: 19:00 a 20:59') AS 'Bloque horario'
			,ISNULL(Horario1,0) as Horario1
			,ISNULL(Horario2,0) as Horario2
			,ISNULL(Horario3,0) as Horario3
			,ISNULL(Horario4,0) as Horario4
			,ISNULL(Horario5,0) as Horario5
			,ISNULL(Horario6,0) as Horario6
			,ISNULL(Horario7,0) as Horario7 
			,CAST(ISNULL(Col01,0) AS DECIMAL(10,2)) as Dia01
			,CAST(ISNULL(Col02,0) AS DECIMAL(10,2)) as Dia02
			,CAST(ISNULL(Col03,0) AS DECIMAL(10,2)) as Dia03
			,CAST(ISNULL(Col04,0) AS DECIMAL(10,2)) as Dia04
			,CAST(ISNULL(Col05,0) AS DECIMAL(10,2)) as Dia05
			,CAST(ISNULL(Col06,0) AS DECIMAL(10,2)) as Dia06
			,CAST(ISNULL(Col07,0) AS DECIMAL(10,2)) as Dia07		
		FROM (SELECT IdLocalCensal AS IdUnidadTerritorial FROM [REPORTES_EXP_2023].[dbo].[TBL_DIRECCION_ASIGNADA] WITH (NOLOCK)
		GROUP BY IdLocalCensal) TBL
		LEFT JOIN 
		(SELECT IdLocalCensal  AS IdUnidadTerritorial
				,'Bloque horario: 19:00 a 20:59' AS 'Bloque_horario'
				,SUM(Horario1) as Horario1
				,SUM(Horario2) as Horario2
				,SUM(Horario3) as Horario3
				,SUM(Horario4) as Horario4
				,SUM(Horario5) as Horario5
				,SUM(Horario6) as Horario6
				,SUM(Horario7) as Horario7 FROM (				
					SELECT 
					IdLocalCensal
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =1 And try_convert(time,FechaHoraVisitaCensista) BETWEEN '19:00' AND '20:59:59' Then 1 Else 0 End as Horario1
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =2 And try_convert(time,FechaHoraVisitaCensista) BETWEEN '19:00' AND '20:59:59' Then 1 Else 0 End as Horario2
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =3 And try_convert(time,FechaHoraVisitaCensista) BETWEEN '19:00' AND '20:59:59' Then 1 Else 0 End as Horario3
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =4 And try_convert(time,FechaHoraVisitaCensista) BETWEEN '19:00' AND '20:59:59' Then 1 Else 0 End as Horario4
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =5 And try_convert(time,FechaHoraVisitaCensista) BETWEEN '19:00' AND '20:59:59' Then 1 Else 0 End as Horario5
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =6 And try_convert(time,FechaHoraVisitaCensista) BETWEEN '19:00' AND '20:59:59' Then 1 Else 0 End as Horario6
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =7 And try_convert(time,FechaHoraVisitaCensista) BETWEEN '19:00' AND '20:59:59' Then 1 Else 0 End as Horario7
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA WITH (NOLOCK) WHERE FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC  
					and tipo_operativo=2 and (IdEstadoDelCuestionario in (3,4) or IdOcupacionVivienda=2) ) B GROUP BY IdLocalCensal )TBL_00
				ON TBL.IdUnidadTerritorial=TBL_00.IdUnidadTerritorial 
				 LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col01) as Col01 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col01 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 1 AND TRY_CONVERT(time,fec_hr_ind) BETWEEN '19:00' AND '20:59:59'
				 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO) 
				 B GROUP BY IdUnidadTerritorial)
				TBL_01 ON TBL.IdUnidadTerritorial=TBL_01.IdUnidadTerritorial
				LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col02) as Col02 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col02 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 2 AND TRY_CONVERT(time,fec_hr_ind) BETWEEN '19:00' AND '20:59:59'
					 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO) 
				 B GROUP BY IdUnidadTerritorial)
				TBL_02 ON TBL.IdUnidadTerritorial=TBL_02.IdUnidadTerritorial
				LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col03) as Col03 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col03 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 3 AND TRY_CONVERT(time,fec_hr_ind) BETWEEN '19:00' AND '20:59:59' 
					 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO) 
				B GROUP BY IdUnidadTerritorial)
				TBL_03 ON TBL.IdUnidadTerritorial=TBL_03.IdUnidadTerritorial
				LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col04) as Col04 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col04 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 4 AND TRY_CONVERT(time,fec_hr_ind) BETWEEN '19:00' AND '20:59:59'
					 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO) 
				B GROUP BY IdUnidadTerritorial)
				TBL_04 ON TBL.IdUnidadTerritorial=TBL_04.IdUnidadTerritorial
				LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col05) as Col05 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col05 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 5 AND TRY_CONVERT(time,fec_hr_ind) BETWEEN '19:00' AND '20:59:59'
					 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO)
				 B GROUP BY IdUnidadTerritorial)
				TBL_05 ON TBL.IdUnidadTerritorial=TBL_05.IdUnidadTerritorial
				LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col06) as Col06 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col06 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 6 AND TRY_CONVERT(time,fec_hr_ind) BETWEEN '19:00' AND '20:59:59'
					 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO)
				B GROUP BY IdUnidadTerritorial)
				TBL_06 ON TBL.IdUnidadTerritorial=TBL_06.IdUnidadTerritorial
				LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col07) as Col07 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col07 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 7 AND TRY_CONVERT(time,fec_hr_ind) BETWEEN '19:00' AND '20:59:59'
					 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO) 
				B GROUP BY IdUnidadTerritorial)
				TBL_07 ON TBL.IdUnidadTerritorial=TBL_07.IdUnidadTerritorial
		UNION ALL
		/*Bloque horario: 21:00 a 22:59:59*/
		SELECT TBL.IdUnidadTerritorial
			,ISNULL(Bloque_horario,'Bloque horario: 21:00 a 22:59') AS 'Bloque horario'
			,ISNULL(Horario1,0) as Horario1
			,ISNULL(Horario2,0) as Horario2
			,ISNULL(Horario3,0) as Horario3
			,ISNULL(Horario4,0) as Horario4
			,ISNULL(Horario5,0) as Horario5
			,ISNULL(Horario6,0) as Horario6
			,ISNULL(Horario7,0) as Horario7 
			,CAST(ISNULL(Col01,0) AS DECIMAL(10,2)) as Dia01
			,CAST(ISNULL(Col02,0) AS DECIMAL(10,2)) as Dia02
			,CAST(ISNULL(Col03,0) AS DECIMAL(10,2)) as Dia03
			,CAST(ISNULL(Col04,0) AS DECIMAL(10,2)) as Dia04
			,CAST(ISNULL(Col05,0) AS DECIMAL(10,2)) as Dia05
			,CAST(ISNULL(Col06,0) AS DECIMAL(10,2)) as Dia06
			,CAST(ISNULL(Col07,0) AS DECIMAL(10,2)) as Dia07		
		FROM (SELECT IdLocalCensal AS IdUnidadTerritorial FROM [REPORTES_EXP_2023].[dbo].[TBL_DIRECCION_ASIGNADA] WITH (NOLOCK)
		GROUP BY IdLocalCensal) TBL
		LEFT JOIN 
		(SELECT IdLocalCensal  AS IdUnidadTerritorial
				,'Bloque horario: 21:00 a 22:59' AS 'Bloque_horario'
				,SUM(Horario1) as Horario1
				,SUM(Horario2) as Horario2
				,SUM(Horario3) as Horario3
				,SUM(Horario4) as Horario4
				,SUM(Horario5) as Horario5
				,SUM(Horario6) as Horario6
				,SUM(Horario7) as Horario7 FROM (				
					SELECT 
					IdLocalCensal
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =1 And try_convert(time,FechaHoraVisitaCensista) BETWEEN '21:00' AND '22:59:59' Then 1 Else 0 End as Horario1
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =2 And try_convert(time,FechaHoraVisitaCensista) BETWEEN '21:00' AND '22:59:59' Then 1 Else 0 End as Horario2
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =3 And try_convert(time,FechaHoraVisitaCensista) BETWEEN '21:00' AND '22:59:59' Then 1 Else 0 End as Horario3
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =4 And try_convert(time,FechaHoraVisitaCensista) BETWEEN '21:00' AND '22:59:59' Then 1 Else 0 End as Horario4
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =5 And try_convert(time,FechaHoraVisitaCensista) BETWEEN '21:00' AND '22:59:59' Then 1 Else 0 End as Horario5
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =6 And try_convert(time,FechaHoraVisitaCensista) BETWEEN '21:00' AND '22:59:59' Then 1 Else 0 End as Horario6
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =7 And try_convert(time,FechaHoraVisitaCensista) BETWEEN '21:00' AND '22:59:59' Then 1 Else 0 End as Horario7
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA WITH (NOLOCK) WHERE FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC  
					and tipo_operativo=2 and (IdEstadoDelCuestionario in (3,4) or IdOcupacionVivienda=2) ) B GROUP BY IdLocalCensal ) TBL_00
				ON TBL.IdUnidadTerritorial=TBL_00.IdUnidadTerritorial 
				 LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col01) as Col01 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col01 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 1 AND TRY_CONVERT(time,fec_hr_ind) BETWEEN '21:00' AND '22:59:59'
				 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO) 
				 B GROUP BY IdUnidadTerritorial)
				TBL_01 ON TBL.IdUnidadTerritorial=TBL_01.IdUnidadTerritorial
				LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col02) as Col02 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col02 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 2 AND TRY_CONVERT(time,fec_hr_ind) BETWEEN '21:00' AND '22:59:59'
					 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO) 
				 B GROUP BY IdUnidadTerritorial)
				TBL_02 ON TBL.IdUnidadTerritorial=TBL_02.IdUnidadTerritorial
				LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col03) as Col03 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col03 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 3 AND TRY_CONVERT(time,fec_hr_ind) BETWEEN '21:00' AND '22:59:59' 
					 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO) 
				B GROUP BY IdUnidadTerritorial)
				TBL_03 ON TBL.IdUnidadTerritorial=TBL_03.IdUnidadTerritorial
				LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col04) as Col04 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col04 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 4 AND TRY_CONVERT(time,fec_hr_ind) BETWEEN '21:00' AND '22:59:59'
					 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO) 
				B GROUP BY IdUnidadTerritorial)
				TBL_04 ON TBL.IdUnidadTerritorial=TBL_04.IdUnidadTerritorial
				LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col05) as Col05 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col05 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 5 AND TRY_CONVERT(time,fec_hr_ind) BETWEEN '21:00' AND '22:59:59'
					 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO)
				 B GROUP BY IdUnidadTerritorial)
				TBL_05 ON TBL.IdUnidadTerritorial=TBL_05.IdUnidadTerritorial
				LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col06) as Col06 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col06 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 6 AND TRY_CONVERT(time,fec_hr_ind) BETWEEN '21:00' AND '22:59:59'
					 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO)
				B GROUP BY IdUnidadTerritorial)
				TBL_06 ON TBL.IdUnidadTerritorial=TBL_06.IdUnidadTerritorial
				LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col07) as Col07 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col07 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 7 AND TRY_CONVERT(time,fec_hr_ind) BETWEEN '21:00' AND '22:59:59'
					 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO) 
				B GROUP BY IdUnidadTerritorial)
				TBL_07 ON TBL.IdUnidadTerritorial=TBL_07.IdUnidadTerritorial
		UNION ALL
		/*Bloque horario: Fuera de Horario*/
		SELECT TBL.IdUnidadTerritorial
			,ISNULL(Bloque_horario,'Bloque horario: Fuera de Horario') AS 'Bloque horario'
			,ISNULL(Horario1,0) as Horario1
			,ISNULL(Horario2,0) as Horario2
			,ISNULL(Horario3,0) as Horario3
			,ISNULL(Horario4,0) as Horario4
			,ISNULL(Horario5,0) as Horario5
			,ISNULL(Horario6,0) as Horario6
			,ISNULL(Horario7,0) as Horario7 
			,CAST(ISNULL(Col01,0) AS DECIMAL(10,2)) as Dia01
			,CAST(ISNULL(Col02,0) AS DECIMAL(10,2)) as Dia02
			,CAST(ISNULL(Col03,0) AS DECIMAL(10,2)) as Dia03
			,CAST(ISNULL(Col04,0) AS DECIMAL(10,2)) as Dia04
			,CAST(ISNULL(Col05,0) AS DECIMAL(10,2)) as Dia05
			,CAST(ISNULL(Col06,0) AS DECIMAL(10,2)) as Dia06
			,CAST(ISNULL(Col07,0) AS DECIMAL(10,2)) as Dia07		
		FROM (SELECT IdLocalCensal AS IdUnidadTerritorial FROM [REPORTES_EXP_2023].[dbo].[TBL_DIRECCION_ASIGNADA] WITH (NOLOCK)
		GROUP BY IdLocalCensal) TBL
		LEFT JOIN 
		(SELECT IdLocalCensal  AS IdUnidadTerritorial
				,'Bloque horario: Fuera de Horario' AS 'Bloque_horario'
				,SUM(Horario1) as Horario1
				,SUM(Horario2) as Horario2
				,SUM(Horario3) as Horario3
				,SUM(Horario4) as Horario4
				,SUM(Horario5) as Horario5
				,SUM(Horario6) as Horario6
				,SUM(Horario7) as Horario7 FROM (				
					SELECT 
					IdLocalCensal
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =1 And (try_convert(time,FechaHoraVisitaCensista) BETWEEN '23:00' AND '23:59:59' OR try_convert(time,FechaHoraVisitaCensista) BETWEEN '00:00' AND '08:59:59') Then 1 Else 0 End as Horario1
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =2 And (try_convert(time,FechaHoraVisitaCensista) BETWEEN '23:00' AND '23:59:59' OR try_convert(time,FechaHoraVisitaCensista) BETWEEN '00:00' AND '08:59:59') Then 1 Else 0 End as Horario2
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =3 And (try_convert(time,FechaHoraVisitaCensista) BETWEEN '23:00' AND '23:59:59' OR try_convert(time,FechaHoraVisitaCensista) BETWEEN '00:00' AND '08:59:59') Then 1 Else 0 End as Horario3
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =4 And (try_convert(time,FechaHoraVisitaCensista) BETWEEN '23:00' AND '23:59:59' OR try_convert(time,FechaHoraVisitaCensista) BETWEEN '00:00' AND '08:59:59') Then 1 Else 0 End as Horario4
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =5 And (try_convert(time,FechaHoraVisitaCensista) BETWEEN '23:00' AND '23:59:59' OR try_convert(time,FechaHoraVisitaCensista) BETWEEN '00:00' AND '08:59:59') Then 1 Else 0 End as Horario5
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =6 And (try_convert(time,FechaHoraVisitaCensista) BETWEEN '23:00' AND '23:59:59' OR try_convert(time,FechaHoraVisitaCensista) BETWEEN '00:00' AND '08:59:59') Then 1 Else 0 End as Horario6
					,Case When DATEPART(dw,TRY_CONVERT(datetime,FechaHoraVisitaCensista))  =7 And (try_convert(time,FechaHoraVisitaCensista) BETWEEN '23:00' AND '23:59:59' OR try_convert(time,FechaHoraVisitaCensista) BETWEEN '00:00' AND '08:59:59') Then 1 Else 0 End as Horario7
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA WITH (NOLOCK) WHERE FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC  
					and tipo_operativo=2 and (IdEstadoDelCuestionario in (3,4) or IdOcupacionVivienda=2) ) B GROUP BY IdLocalCensal ) TBL_00
				ON TBL.IdUnidadTerritorial=TBL_00.IdUnidadTerritorial 
				 LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col01) as Col01 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col01 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 1 AND (TRY_CONVERT(time,fec_hr_ind) BETWEEN '23:00' AND '23:59:59' OR TRY_CONVERT(time,fec_hr_ind) BETWEEN '00:00' AND '08:59:59')
				 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO) 
				 B GROUP BY IdUnidadTerritorial)
				TBL_01 ON TBL.IdUnidadTerritorial=TBL_01.IdUnidadTerritorial
				LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col02) as Col02 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col02 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 2 AND (TRY_CONVERT(time,fec_hr_ind) BETWEEN '23:00' AND '23:59:59' OR TRY_CONVERT(time,fec_hr_ind) BETWEEN '00:00' AND '08:59:59')
					 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO) 
				 B GROUP BY IdUnidadTerritorial)
				TBL_02 ON TBL.IdUnidadTerritorial=TBL_02.IdUnidadTerritorial
				LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col03) as Col03 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col03 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 3 AND (TRY_CONVERT(time,fec_hr_ind) BETWEEN '23:00' AND '23:59:59' OR TRY_CONVERT(time,fec_hr_ind) BETWEEN '00:00' AND '08:59:59')
					 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO) 
				B GROUP BY IdUnidadTerritorial)
				TBL_03 ON TBL.IdUnidadTerritorial=TBL_03.IdUnidadTerritorial
				LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col04) as Col04 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col04 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 4 AND (TRY_CONVERT(time,fec_hr_ind) BETWEEN '23:00' AND '23:59:59' OR TRY_CONVERT(time,fec_hr_ind) BETWEEN '00:00' AND '08:59:59')
					 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO) 
				B GROUP BY IdUnidadTerritorial)
				TBL_04 ON TBL.IdUnidadTerritorial=TBL_04.IdUnidadTerritorial
				LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col05) as Col05 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col05 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 5 AND (TRY_CONVERT(time,fec_hr_ind) BETWEEN '23:00' AND '23:59:59' OR TRY_CONVERT(time,fec_hr_ind) BETWEEN '00:00' AND '08:59:59')
					 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO)
				 B GROUP BY IdUnidadTerritorial)
				TBL_05 ON TBL.IdUnidadTerritorial=TBL_05.IdUnidadTerritorial
				LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col06) as Col06 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col06 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 6 AND (TRY_CONVERT(time,fec_hr_ind) BETWEEN '23:00' AND '23:59:59' OR TRY_CONVERT(time,fec_hr_ind) BETWEEN '00:00' AND '08:59:59')
					 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO)
				B GROUP BY IdUnidadTerritorial)
				TBL_06 ON TBL.IdUnidadTerritorial=TBL_06.IdUnidadTerritorial
				LEFT JOIN 
				(SELECT IdUnidadTerritorial, SUM(Col07) as Col07 FROM 
					(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO,COUNT(DISTINCT(fec_hr_ind)) as Col07 FROM (
					SELECT IdLocalCensal,GU.IDUSUARIO,RESPONSIBLE,(TRY_CONVERT(DATE,fec_hr_ind)) AS fec_hr_ind
					FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
					LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
					LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
					WHERE 1=1 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL AND NOT CodUsoDestino IS NULL 
					AND DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 7 AND (TRY_CONVERT(time,fec_hr_ind) BETWEEN '23:00' AND '23:59:59' OR TRY_CONVERT(time,fec_hr_ind) BETWEEN '00:00' AND '08:59:59')
					 And FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC ) A GROUP BY IdLocalCensal,IDUSUARIO) 
				B GROUP BY IdUnidadTerritorial)
				TBL_07 ON TBL.IdUnidadTerritorial=TBL_07.IdUnidadTerritorial
)
	 A ON TBL.IdUnidadTerritorial=A.IdUnidadTerritorial 
	 ) B 