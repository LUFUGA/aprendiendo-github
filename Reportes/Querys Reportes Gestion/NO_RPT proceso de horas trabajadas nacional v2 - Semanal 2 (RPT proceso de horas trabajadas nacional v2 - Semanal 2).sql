DECLARE @FECHA AS DATE 
DECLARE @FECHAAC AS DATE
SET @FECHA= (SELECT CAST(DATEADD(DAY, -7, GETDATE()) as date))
SET @FECHAAC= (SELECT CAST(GETDATE() as date))

SELECT Region as 'Region'
	,Comuna as 'Comuna'
	,NOMBRE AS 'Local Censal'
	,Coordinador as 'Coordinador(a)'
	,RutCensista as 'Rut censista'
	,NombreCensista as 'Nombre censista'
	--,PERFIL as 'Perfil'
	,DIAS AS 'Días trabajados efectivos'
	,MINIMO  as 'Mínimo'
	,MAXIMO  as 'Máximo'
	,TOTAL  as 'Total semanal'
	,Horario1 as 'Bloque horario: 09:00 a 10:59'
	,Horario2 as 'Bloque horario: 11:00 a 12:59'
	,Horario3 as 'Bloque horario: 13:00 a 14:59'
	,Horario4 as 'Bloque horario: 15:00 a 16:59'
	,Horario5 as 'Bloque horario: 17:00 a 18:59'
	,Horario6 as 'Bloque horario: 19:00 a 20:59'
	,Horario7 as 'Bloque horario: 21:00 a 22:59'
	,Horario8 as 'Bloque horario: Fuera de horario'
	FROM (
		SELECT Region, GLO_COM.Comuna, TBL.IdUnidadTerritorial
		,ISNULL(UPPER(GLO_GEO.NOMBRE),TBL.IdUnidadTerritorial) AS NOMBRE
		,ISNULL(UPPER(GUCO.NOMBRE),'') as 'Coordinador'
		,ISNULL(UPPER(GUC.RUT),'')  as 'RutCensista'
		,ISNULL(UPPER(GUC.NOMBRE),'')  as 'NombreCensista'
		,1 as 'PERFIL'
		,ISNULL(col03,0) AS 'DIAS'
		,ISNULL(MINIMO,0)  as 'MINIMO'
		,ISNULL(MAXIMO,0)  as 'MAXIMO'
		,ISNULL(TOTAL,0)  as 'TOTAL'
		,ISNULL(Horario1,0) as Horario1
		,ISNULL(Horario2,0) as Horario2
		,ISNULL(Horario3,0) as Horario3
		,ISNULL(Horario4,0) as Horario4
		,ISNULL(Horario5,0) as Horario5
		,ISNULL(Horario6,0) as Horario6
		,ISNULL(Horario7,0) as Horario7
		,ISNULL(Horario8,0) as Horario8
		 FROM (SELECT IdLocalCensal AS IdUnidadTerritorial, CodigoRegion, CodigoComuna FROM [REPORTES_EXP_2023].[dbo].[TBL_DIRECCION_ASIGNADA] WITH (NOLOCK)
		 GROUP BY IdLocalCensal, CodigoRegion, CodigoComuna ) TBL
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
		(SELECT IdLocalCensal  AS IdUnidadTerritorial ,IdCoordinadorGrupo,IdCensista FROM TBL_DIRECCION_ASIGNADA WITH (NOLOCK) WHERE 1=1 and tipo_operativo=2
		group by IdLocalCensal,IdCoordinadorGrupo,IdCensista) 
		TBL_01 ON  TBL.IdUnidadTerritorial=TBL_01.IdUnidadTerritorial
		LEFT JOIN 
		SGCPV.DBO.GES_USUARIO GUC WITH (NOLOCK)
		ON TBL_01.IdCensista=GUC.IDUSUARIO
		LEFT JOIN SGCPV.DBO.GES_USUARIO GUCO WITH (NOLOCK)
		ON TBL_01.IdCoordinadorGrupo=GUCO.IDUSUARIO
		LEFT JOIN 
		(SELECT IdLocalCensal AS IdUnidadTerritorial,IDUSUARIO as IdCensista,COUNT( DISTINCT(fec_hr_ind)) as Col03 FROM (
			SELECT IdLocalCensal,GU.IDUSUARIO,TRY_CONVERT(DATE, fec_hr_ind) AS fec_hr_ind
			FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
			LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
			LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
			WHERE 1=1 and tipo_operativo=2 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL  AND NOT CodUsoDestino IS NULL 
			AND FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC
		)A GROUP BY IdLocalCensal,IDUSUARIO) 
		TBL_03 ON TBL_01.IdCensista=TBL_03.IdCensista and TBL.IdUnidadTerritorial=TBL_03.IdUnidadTerritorial
		LEFT JOIN 
		(
		SELECT IdLocalCensal as IdUnidadTerritorial,IdUsuario
		,Sum(Dia1Bloque01+Dia1Bloque02+Dia2Bloque01+Dia2Bloque02+Dia3Bloque01+Dia3Bloque02+Dia4Bloque01+Dia4Bloque02
		+Dia5Bloque01+Dia5Bloque02+Dia6Bloque01+Dia6Bloque02+Dia7Bloque01+Dia7Bloque02) as 'Horario1'
		,Sum(Dia1Bloque03+Dia1Bloque04+Dia2Bloque03+Dia2Bloque04+Dia3Bloque03+Dia3Bloque04+Dia4Bloque03+Dia4Bloque04
		+Dia5Bloque03+Dia5Bloque04+Dia6Bloque03+Dia6Bloque04+Dia7Bloque03+Dia7Bloque04) as 'Horario2'
		,Sum(Dia1Bloque05+Dia1Bloque06+Dia2Bloque05+Dia2Bloque06+Dia3Bloque05+Dia3Bloque06+Dia4Bloque05+Dia4Bloque06
		+Dia5Bloque05+Dia5Bloque06+Dia6Bloque05+Dia6Bloque06+Dia7Bloque05+Dia7Bloque06) as 'Horario3'
		,Sum(Dia1Bloque07+Dia1Bloque08+Dia2Bloque07+Dia2Bloque08+Dia3Bloque07+Dia3Bloque08+Dia4Bloque07+Dia4Bloque08
		+Dia5Bloque07+Dia5Bloque08+Dia6Bloque07+Dia6Bloque08+Dia7Bloque07+Dia7Bloque08) as 'Horario4'
		,Sum(Dia1Bloque09+Dia1Bloque10+Dia2Bloque09+Dia2Bloque10+Dia3Bloque09+Dia3Bloque10+Dia4Bloque09+Dia4Bloque10
		+Dia5Bloque09+Dia5Bloque10+Dia6Bloque09+Dia6Bloque10+Dia7Bloque09+Dia7Bloque10) as 'Horario5'
		,Sum(Dia1Bloque11+Dia1Bloque12+Dia2Bloque11+Dia2Bloque12+Dia3Bloque11+Dia3Bloque12+Dia4Bloque11+Dia4Bloque12
		+Dia5Bloque11+Dia5Bloque12+Dia6Bloque11+Dia6Bloque12+Dia7Bloque11+Dia7Bloque12) as 'Horario6'
		,Sum(Dia1Bloque13+Dia1Bloque14+Dia2Bloque13+Dia2Bloque14+Dia3Bloque13+Dia3Bloque14+Dia4Bloque13+Dia4Bloque14
		+Dia5Bloque13+Dia5Bloque14+Dia6Bloque13+Dia6Bloque14+Dia7Bloque13+Dia7Bloque14) as 'Horario7'
		,Sum(Dia1Bloque15+Dia1Bloque16+Dia1Bloque17+Dia1Bloque18+Dia1Bloque19+Dia1Bloque20+Dia1Bloque21+Dia1Bloque22+Dia1Bloque23+Dia1Bloque24
		+Dia2Bloque15+Dia2Bloque16+Dia2Bloque17+Dia2Bloque18+Dia2Bloque19+Dia2Bloque20+Dia2Bloque21+Dia2Bloque22+Dia2Bloque23+Dia2Bloque24
		+Dia3Bloque15+Dia3Bloque16+Dia3Bloque17+Dia3Bloque18+Dia3Bloque19+Dia3Bloque20+Dia3Bloque21+Dia3Bloque22+Dia3Bloque23+Dia3Bloque24
		+Dia4Bloque15+Dia4Bloque16+Dia4Bloque17+Dia4Bloque18+Dia4Bloque19+Dia4Bloque20+Dia4Bloque21+Dia4Bloque22+Dia4Bloque23+Dia4Bloque24
		+Dia5Bloque15+Dia5Bloque16+Dia5Bloque17+Dia5Bloque18+Dia5Bloque19+Dia5Bloque20+Dia5Bloque21+Dia5Bloque22+Dia5Bloque23+Dia5Bloque24
		+Dia6Bloque15+Dia6Bloque16+Dia6Bloque17+Dia6Bloque18+Dia6Bloque19+Dia6Bloque20+Dia6Bloque21+Dia6Bloque22+Dia6Bloque23+Dia6Bloque24
		+Dia7Bloque15+Dia7Bloque16+Dia7Bloque17+Dia7Bloque18+Dia7Bloque19+Dia7Bloque20+Dia7Bloque21+Dia7Bloque22+Dia7Bloque23+Dia7Bloque24) as 'Horario8'
		FROM (
		SELECT IdLocalCensal
			,IdUsuario
			,Semana
			,Case when sum(Dia1Bloque01)>0 Then 1 Else 0 End as Dia1Bloque01
			,Case when sum(Dia1Bloque02)>0 Then 1 Else 0 End as Dia1Bloque02
			,Case when sum(Dia1Bloque03)>0 Then 1 Else 0 End as Dia1Bloque03
			,Case when sum(Dia1Bloque04)>0 Then 1 Else 0 End as Dia1Bloque04
			,Case when sum(Dia1Bloque05)>0 Then 1 Else 0 End as Dia1Bloque05
			,Case when sum(Dia1Bloque06)>0 Then 1 Else 0 End as Dia1Bloque06
			,Case when sum(Dia1Bloque07)>0 Then 1 Else 0 End as Dia1Bloque07
			,Case when sum(Dia1Bloque08)>0 Then 1 Else 0 End as Dia1Bloque08
			,Case when sum(Dia1Bloque09)>0 Then 1 Else 0 End as Dia1Bloque09
			,Case when sum(Dia1Bloque10)>0 Then 1 Else 0 End as Dia1Bloque10
			,Case when sum(Dia1Bloque11)>0 Then 1 Else 0 End as Dia1Bloque11
			,Case when sum(Dia1Bloque12)>0 Then 1 Else 0 End as Dia1Bloque12
			,Case when sum(Dia1Bloque13)>0 Then 1 Else 0 End as Dia1Bloque13
			,Case when sum(Dia1Bloque14)>0 Then 1 Else 0 End as Dia1Bloque14
			,Case when sum(Dia1Bloque15)>0 Then 1 Else 0 End as Dia1Bloque15
			,Case when sum(Dia1Bloque16)>0 Then 1 Else 0 End as Dia1Bloque16
			,Case When sum(Dia1Bloque17)>0 Then 1 Else 0 End as Dia1Bloque17
			,Case When sum(Dia1Bloque18)>0 Then 1 Else 0 End as Dia1Bloque18
			,Case When sum(Dia1Bloque19)>0 Then 1 Else 0 End as Dia1Bloque19
			,Case When sum(Dia1Bloque20)>0 Then 1 Else 0 End as Dia1Bloque20
			,Case When sum(Dia1Bloque21)>0 Then 1 Else 0 End as Dia1Bloque21
			,Case When sum(Dia1Bloque22)>0 Then 1 Else 0 End as Dia1Bloque22
			,Case When sum(Dia1Bloque23)>0 Then 1 Else 0 End as Dia1Bloque23
			,Case When sum(Dia1Bloque24)>0 Then 1 Else 0 End as Dia1Bloque24
			/*Martes*/
			,Case When sum(Dia2Bloque01)>0 Then 1 Else 0 End as Dia2Bloque01
			,Case When sum(Dia2Bloque02)>0 Then 1 Else 0 End as Dia2Bloque02
			,Case When sum(Dia2Bloque03)>0 Then 1 Else 0 End as Dia2Bloque03
			,Case When sum(Dia2Bloque04)>0 Then 1 Else 0 End as Dia2Bloque04
			,Case When sum(Dia2Bloque05)>0 Then 1 Else 0 End as Dia2Bloque05
			,Case When sum(Dia2Bloque06)>0 Then 1 Else 0 End as Dia2Bloque06
			,Case When sum(Dia2Bloque07)>0 Then 1 Else 0 End as Dia2Bloque07
			,Case When sum(Dia2Bloque08)>0 Then 1 Else 0 End as Dia2Bloque08
			,Case When sum(Dia2Bloque09)>0 Then 1 Else 0 End as Dia2Bloque09
			,Case When sum(Dia2Bloque10)>0 Then 1 Else 0 End as Dia2Bloque10
			,Case When sum(Dia2Bloque11)>0 Then 1 Else 0 End as Dia2Bloque11
			,Case When sum(Dia2Bloque12)>0 Then 1 Else 0 End as Dia2Bloque12
			,Case When sum(Dia2Bloque13)>0 Then 1 Else 0 End as Dia2Bloque13
			,Case When sum(Dia2Bloque14)>0 Then 1 Else 0 End as Dia2Bloque14
			,Case When sum(Dia2Bloque15)>0 Then 1 Else 0 End as Dia2Bloque15
			,Case When sum(Dia2Bloque16)>0 Then 1 Else 0 End as Dia2Bloque16
			,Case When sum(Dia2Bloque17)>0 Then 1 Else 0 End as Dia2Bloque17
			,Case When sum(Dia2Bloque18)>0 Then 1 Else 0 End as Dia2Bloque18
			,Case When sum(Dia2Bloque19)>0 Then 1 Else 0 End as Dia2Bloque19
			,Case When sum(Dia2Bloque20)>0 Then 1 Else 0 End as Dia2Bloque20
			,Case When sum(Dia2Bloque21)>0 Then 1 Else 0 End as Dia2Bloque21
			,Case When sum(Dia2Bloque22)>0 Then 1 Else 0 End as Dia2Bloque22
			,Case When sum(Dia2Bloque23)>0 Then 1 Else 0 End as Dia2Bloque23
			,Case When sum(Dia2Bloque24)>0 Then 1 Else 0 End as Dia2Bloque24
			/*Miercoles*/
			,Case When sum(Dia3Bloque01)>0 Then 1 Else 0 End as Dia3Bloque01
			,Case When sum(Dia3Bloque02)>0 Then 1 Else 0 End as Dia3Bloque02
			,Case When sum(Dia3Bloque03)>0 Then 1 Else 0 End as Dia3Bloque03
			,Case When sum(Dia3Bloque04)>0 Then 1 Else 0 End as Dia3Bloque04
			,Case When sum(Dia3Bloque05)>0 Then 1 Else 0 End as Dia3Bloque05
			,Case When sum(Dia3Bloque06)>0 Then 1 Else 0 End as Dia3Bloque06
			,Case When sum(Dia3Bloque07)>0 Then 1 Else 0 End as Dia3Bloque07
			,Case When sum(Dia3Bloque08)>0 Then 1 Else 0 End as Dia3Bloque08
			,Case When sum(Dia3Bloque09)>0 Then 1 Else 0 End as Dia3Bloque09
			,Case When sum(Dia3Bloque10)>0 Then 1 Else 0 End as Dia3Bloque10
			,Case When sum(Dia3Bloque11)>0 Then 1 Else 0 End as Dia3Bloque11
			,Case When sum(Dia3Bloque12)>0 Then 1 Else 0 End as Dia3Bloque12
			,Case When sum(Dia3Bloque13)>0 Then 1 Else 0 End as Dia3Bloque13
			,Case When sum(Dia3Bloque14)>0 Then 1 Else 0 End as Dia3Bloque14
			,Case When sum(Dia3Bloque15)>0 Then 1 Else 0 End as Dia3Bloque15
			,Case When sum(Dia3Bloque16)>0 Then 1 Else 0 End as Dia3Bloque16
			,Case When sum(Dia3Bloque17)>0 Then 1 Else 0 End as Dia3Bloque17
			,Case When sum(Dia3Bloque18)>0 Then 1 Else 0 End as Dia3Bloque18
			,Case When sum(Dia3Bloque19)>0 Then 1 Else 0 End as Dia3Bloque19
			,Case When sum(Dia3Bloque20)>0 Then 1 Else 0 End as Dia3Bloque20
			,Case When sum(Dia3Bloque21)>0 Then 1 Else 0 End as Dia3Bloque21
			,Case When sum(Dia3Bloque22)>0 Then 1 Else 0 End as Dia3Bloque22
			,Case When sum(Dia3Bloque23)>0 Then 1 Else 0 End as Dia3Bloque23
			,Case When sum(Dia3Bloque24)>0 Then 1 Else 0 End as Dia3Bloque24
			/*Jueves*/
			,Case When sum(Dia4Bloque01)>0 Then 1 Else 0 End as Dia4Bloque01
			,Case When sum(Dia4Bloque02)>0 Then 1 Else 0 End as Dia4Bloque02
			,Case When sum(Dia4Bloque03)>0 Then 1 Else 0 End as Dia4Bloque03
			,Case When sum(Dia4Bloque04)>0 Then 1 Else 0 End as Dia4Bloque04
			,Case When sum(Dia4Bloque05)>0 Then 1 Else 0 End as Dia4Bloque05
			,Case When sum(Dia4Bloque06)>0 Then 1 Else 0 End as Dia4Bloque06
			,Case When sum(Dia4Bloque07)>0 Then 1 Else 0 End as Dia4Bloque07
			,Case When sum(Dia4Bloque08)>0 Then 1 Else 0 End as Dia4Bloque08
			,Case When sum(Dia4Bloque09)>0 Then 1 Else 0 End as Dia4Bloque09
			,Case When sum(Dia4Bloque10)>0 Then 1 Else 0 End as Dia4Bloque10
			,Case When sum(Dia4Bloque11)>0 Then 1 Else 0 End as Dia4Bloque11
			,Case When sum(Dia4Bloque12)>0 Then 1 Else 0 End as Dia4Bloque12
			,Case When sum(Dia4Bloque13)>0 Then 1 Else 0 End as Dia4Bloque13
			,Case When sum(Dia4Bloque14)>0 Then 1 Else 0 End as Dia4Bloque14
			,Case When sum(Dia4Bloque15)>0 Then 1 Else 0 End as Dia4Bloque15
			,Case When sum(Dia4Bloque16)>0 Then 1 Else 0 End as Dia4Bloque16
			,Case When sum(Dia4Bloque17)>0 Then 1 Else 0 End as Dia4Bloque17
			,Case When sum(Dia4Bloque18)>0 Then 1 Else 0 End as Dia4Bloque18
			,Case When sum(Dia4Bloque19)>0 Then 1 Else 0 End as Dia4Bloque19
			,Case When sum(Dia4Bloque20)>0 Then 1 Else 0 End as Dia4Bloque20
			,Case When sum(Dia4Bloque21)>0 Then 1 Else 0 End as Dia4Bloque21
			,Case When sum(Dia4Bloque22)>0 Then 1 Else 0 End as Dia4Bloque22
			,Case When sum(Dia4Bloque23)>0 Then 1 Else 0 End as Dia4Bloque23
			,Case When sum(Dia4Bloque24)>0 Then 1 Else 0 End as Dia4Bloque24
			/*Viernes*/
			,Case When sum(Dia5Bloque01)>0 Then 1 Else 0 End as Dia5Bloque01
			,Case When sum(Dia5Bloque02)>0 Then 1 Else 0 End as Dia5Bloque02
			,Case When sum(Dia5Bloque03)>0 Then 1 Else 0 End as Dia5Bloque03
			,Case When sum(Dia5Bloque04)>0 Then 1 Else 0 End as Dia5Bloque04
			,Case When sum(Dia5Bloque05)>0 Then 1 Else 0 End as Dia5Bloque05
			,Case When sum(Dia5Bloque06)>0 Then 1 Else 0 End as Dia5Bloque06
			,Case When sum(Dia5Bloque07)>0 Then 1 Else 0 End as Dia5Bloque07
			,Case When sum(Dia5Bloque08)>0 Then 1 Else 0 End as Dia5Bloque08
			,Case When sum(Dia5Bloque09)>0 Then 1 Else 0 End as Dia5Bloque09
			,Case When sum(Dia5Bloque10)>0 Then 1 Else 0 End as Dia5Bloque10
			,Case When sum(Dia5Bloque11)>0 Then 1 Else 0 End as Dia5Bloque11
			,Case When sum(Dia5Bloque12)>0 Then 1 Else 0 End as Dia5Bloque12
			,Case When sum(Dia5Bloque13)>0 Then 1 Else 0 End as Dia5Bloque13
			,Case When sum(Dia5Bloque14)>0 Then 1 Else 0 End as Dia5Bloque14
			,Case When sum(Dia5Bloque15)>0 Then 1 Else 0 End as Dia5Bloque15
			,Case When sum(Dia5Bloque16)>0 Then 1 Else 0 End as Dia5Bloque16
			,Case When sum(Dia5Bloque17)>0 Then 1 Else 0 End as Dia5Bloque17
			,Case When sum(Dia5Bloque18)>0 Then 1 Else 0 End as Dia5Bloque18
			,Case When sum(Dia5Bloque19)>0 Then 1 Else 0 End as Dia5Bloque19
			,Case When sum(Dia5Bloque20)>0 Then 1 Else 0 End as Dia5Bloque20
			,Case When sum(Dia5Bloque21)>0 Then 1 Else 0 End as Dia5Bloque21
			,Case When sum(Dia5Bloque22)>0 Then 1 Else 0 End as Dia5Bloque22
			,Case When sum(Dia5Bloque23)>0 Then 1 Else 0 End as Dia5Bloque23
			,Case When sum(Dia5Bloque24)>0 Then 1 Else 0 End as Dia5Bloque24
			/*Sabado*/
			,Case When sum(Dia6Bloque01)>0 Then 1 Else 0 End as Dia6Bloque01
			,Case When sum(Dia6Bloque02)>0 Then 1 Else 0 End as Dia6Bloque02
			,Case When sum(Dia6Bloque03)>0 Then 1 Else 0 End as Dia6Bloque03
			,Case When sum(Dia6Bloque04)>0 Then 1 Else 0 End as Dia6Bloque04
			,Case When sum(Dia6Bloque05)>0 Then 1 Else 0 End as Dia6Bloque05
			,Case When sum(Dia6Bloque06)>0 Then 1 Else 0 End as Dia6Bloque06
			,Case When sum(Dia6Bloque07)>0 Then 1 Else 0 End as Dia6Bloque07
			,Case When sum(Dia6Bloque08)>0 Then 1 Else 0 End as Dia6Bloque08
			,Case When sum(Dia6Bloque09)>0 Then 1 Else 0 End as Dia6Bloque09
			,Case When sum(Dia6Bloque10)>0 Then 1 Else 0 End as Dia6Bloque10
			,Case When sum(Dia6Bloque11)>0 Then 1 Else 0 End as Dia6Bloque11
			,Case When sum(Dia6Bloque12)>0 Then 1 Else 0 End as Dia6Bloque12
			,Case When sum(Dia6Bloque13)>0 Then 1 Else 0 End as Dia6Bloque13
			,Case When sum(Dia6Bloque14)>0 Then 1 Else 0 End as Dia6Bloque14
			,Case When sum(Dia6Bloque15)>0 Then 1 Else 0 End as Dia6Bloque15
			,Case When sum(Dia6Bloque16)>0 Then 1 Else 0 End as Dia6Bloque16
			,Case When sum(Dia6Bloque17)>0 Then 1 Else 0 End as Dia6Bloque17
			,Case When sum(Dia6Bloque18)>0 Then 1 Else 0 End as Dia6Bloque18
			,Case When sum(Dia6Bloque19)>0 Then 1 Else 0 End as Dia6Bloque19
			,Case When sum(Dia6Bloque20)>0 Then 1 Else 0 End as Dia6Bloque20
			,Case When sum(Dia6Bloque21)>0 Then 1 Else 0 End as Dia6Bloque21
			,Case When sum(Dia6Bloque22)>0 Then 1 Else 0 End as Dia6Bloque22
			,Case When sum(Dia6Bloque23)>0 Then 1 Else 0 End as Dia6Bloque23
			,Case When sum(Dia6Bloque24)>0 Then 1 Else 0 End as Dia6Bloque24
			/*Domingo*/
			,Case When sum(Dia7Bloque01)>0 Then 1 Else 0 End as Dia7Bloque01
			,Case When sum(Dia7Bloque02)>0 Then 1 Else 0 End as Dia7Bloque02
			,Case When sum(Dia7Bloque03)>0 Then 1 Else 0 End as Dia7Bloque03
			,Case When sum(Dia7Bloque04)>0 Then 1 Else 0 End as Dia7Bloque04
			,Case When sum(Dia7Bloque05)>0 Then 1 Else 0 End as Dia7Bloque05
			,Case When sum(Dia7Bloque06)>0 Then 1 Else 0 End as Dia7Bloque06
			,Case When sum(Dia7Bloque07)>0 Then 1 Else 0 End as Dia7Bloque07
			,Case When sum(Dia7Bloque08)>0 Then 1 Else 0 End as Dia7Bloque08
			,Case When sum(Dia7Bloque09)>0 Then 1 Else 0 End as Dia7Bloque09
			,Case When sum(Dia7Bloque10)>0 Then 1 Else 0 End as Dia7Bloque10
			,Case When sum(Dia7Bloque11)>0 Then 1 Else 0 End as Dia7Bloque11
			,Case When sum(Dia7Bloque12)>0 Then 1 Else 0 End as Dia7Bloque12
			,Case When sum(Dia7Bloque13)>0 Then 1 Else 0 End as Dia7Bloque13
			,Case When sum(Dia7Bloque14)>0 Then 1 Else 0 End as Dia7Bloque14
			,Case When sum(Dia7Bloque15)>0 Then 1 Else 0 End as Dia7Bloque15
			,Case When sum(Dia7Bloque16)>0 Then 1 Else 0 End as Dia7Bloque16
			,Case When sum(Dia7Bloque17)>0 Then 1 Else 0 End as Dia7Bloque17
			,Case When sum(Dia7Bloque18)>0 Then 1 Else 0 End as Dia7Bloque18
			,Case When sum(Dia7Bloque19)>0 Then 1 Else 0 End as Dia7Bloque19
			,Case When sum(Dia7Bloque20)>0 Then 1 Else 0 End as Dia7Bloque20
			,Case When sum(Dia7Bloque21)>0 Then 1 Else 0 End as Dia7Bloque21
			,Case When sum(Dia7Bloque22)>0 Then 1 Else 0 End as Dia7Bloque22
			,Case When sum(Dia7Bloque23)>0 Then 1 Else 0 End as Dia7Bloque23
			,Case When sum(Dia7Bloque24)>0 Then 1 Else 0 End as Dia7Bloque24
		FROM (
SELECT 
			DA.IdLocalCensal
			,GU.IdUsuario
			,DATEPART(WEEK, TRY_CONVERT(datetime,fec_hr_ind)) As Semana
			/*Lunes*/
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 1 And try_convert(time,fec_hr_ind) BETWEEN '09:00' AND '09:59:59' Then 1 Else 0 End as Dia1Bloque01
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 1 And try_convert(time,fec_hr_ind) BETWEEN '10:00' AND '10:59:59' Then 1 Else 0 End as Dia1Bloque02
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 1 And try_convert(time,fec_hr_ind) BETWEEN '11:00' AND '11:59:59' Then 1 Else 0 End as Dia1Bloque03
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 1 And try_convert(time,fec_hr_ind) BETWEEN '12:00' AND '12:59:59' Then 1 Else 0 End as Dia1Bloque04
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 1 And try_convert(time,fec_hr_ind) BETWEEN '13:00' AND '13:59:59' Then 1 Else 0 End as Dia1Bloque05
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 1 And try_convert(time,fec_hr_ind) BETWEEN '14:00' AND '14:59:59' Then 1 Else 0 End as Dia1Bloque06
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 1 And try_convert(time,fec_hr_ind) BETWEEN '15:00' AND '15:59:59' Then 1 Else 0 End as Dia1Bloque07
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 1 And try_convert(time,fec_hr_ind) BETWEEN '16:00' AND '16:59:59' Then 1 Else 0 End as Dia1Bloque08
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 1 And try_convert(time,fec_hr_ind) BETWEEN '17:00' AND '17:59:59' Then 1 Else 0 End as Dia1Bloque09
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 1 And try_convert(time,fec_hr_ind) BETWEEN '18:00' AND '18:59:59' Then 1 Else 0 End as Dia1Bloque10
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 1 And try_convert(time,fec_hr_ind) BETWEEN '19:00' AND '19:59:59' Then 1 Else 0 End as Dia1Bloque11
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 1 And try_convert(time,fec_hr_ind) BETWEEN '20:00' AND '20:59:59' Then 1 Else 0 End as Dia1Bloque12
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 1 And try_convert(time,fec_hr_ind) BETWEEN '21:00' AND '21:59:59' Then 1 Else 0 End as Dia1Bloque13
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 1 And try_convert(time,fec_hr_ind) BETWEEN '22:00' AND '22:59:59' Then 1 Else 0 End as Dia1Bloque14
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 1 And try_convert(time,fec_hr_ind) BETWEEN '23:00' AND '23:59:59' Then 1 Else 0 End as Dia1Bloque15
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 1 And try_convert(time,fec_hr_ind) BETWEEN '00:00' AND '00:59:59' Then 1 Else 0 End as Dia1Bloque16
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 1 And try_convert(time,fec_hr_ind) BETWEEN '01:00' AND '01:59:59' Then 1 Else 0 End as Dia1Bloque17
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 1 And try_convert(time,fec_hr_ind) BETWEEN '02:00' AND '02:59:59' Then 1 Else 0 End as Dia1Bloque18
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 1 And try_convert(time,fec_hr_ind) BETWEEN '03:00' AND '03:59:59' Then 1 Else 0 End as Dia1Bloque19
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 1 And try_convert(time,fec_hr_ind) BETWEEN '04:00' AND '04:59:59' Then 1 Else 0 End as Dia1Bloque20
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 1 And try_convert(time,fec_hr_ind) BETWEEN '05:00' AND '05:59:59' Then 1 Else 0 End as Dia1Bloque21
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 1 And try_convert(time,fec_hr_ind) BETWEEN '06:00' AND '06:59:59' Then 1 Else 0 End as Dia1Bloque22
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 1 And try_convert(time,fec_hr_ind) BETWEEN '07:00' AND '07:59:59' Then 1 Else 0 End as Dia1Bloque23
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 1 And try_convert(time,fec_hr_ind) BETWEEN '08:00' AND '08:59:59' Then 1 Else 0 End as Dia1Bloque24
			/*Martes*/
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 2 And try_convert(time,fec_hr_ind) BETWEEN '09:00' AND '09:59:59' Then 1 Else 0 End as Dia2Bloque01
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 2 And try_convert(time,fec_hr_ind) BETWEEN '10:00' AND '10:59:59' Then 1 Else 0 End as Dia2Bloque02
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 2 And try_convert(time,fec_hr_ind) BETWEEN '11:00' AND '11:59:59' Then 1 Else 0 End as Dia2Bloque03
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 2 And try_convert(time,fec_hr_ind) BETWEEN '12:00' AND '12:59:59' Then 1 Else 0 End as Dia2Bloque04
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 2 And try_convert(time,fec_hr_ind) BETWEEN '13:00' AND '13:59:59' Then 1 Else 0 End as Dia2Bloque05
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 2 And try_convert(time,fec_hr_ind) BETWEEN '14:00' AND '14:59:59' Then 1 Else 0 End as Dia2Bloque06
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 2 And try_convert(time,fec_hr_ind) BETWEEN '15:00' AND '15:59:59' Then 1 Else 0 End as Dia2Bloque07
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 2 And try_convert(time,fec_hr_ind) BETWEEN '16:00' AND '16:59:59' Then 1 Else 0 End as Dia2Bloque08
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 2 And try_convert(time,fec_hr_ind) BETWEEN '17:00' AND '17:59:59' Then 1 Else 0 End as Dia2Bloque09
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 2 And try_convert(time,fec_hr_ind) BETWEEN '18:00' AND '18:59:59' Then 1 Else 0 End as Dia2Bloque10
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 2 And try_convert(time,fec_hr_ind) BETWEEN '19:00' AND '19:59:59' Then 1 Else 0 End as Dia2Bloque11
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 2 And try_convert(time,fec_hr_ind) BETWEEN '20:00' AND '20:59:59' Then 1 Else 0 End as Dia2Bloque12
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 2 And try_convert(time,fec_hr_ind) BETWEEN '21:00' AND '21:59:59' Then 1 Else 0 End as Dia2Bloque13
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 2 And try_convert(time,fec_hr_ind) BETWEEN '22:00' AND '22:59:59' Then 1 Else 0 End as Dia2Bloque14
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 2 And try_convert(time,fec_hr_ind) BETWEEN '23:00' AND '23:59:59' Then 1 Else 0 End as Dia2Bloque15
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 2 And try_convert(time,fec_hr_ind) BETWEEN '00:00' AND '00:59:59' Then 1 Else 0 End as Dia2Bloque16
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 2 And try_convert(time,fec_hr_ind) BETWEEN '01:00' AND '01:59:59' Then 1 Else 0 End as Dia2Bloque17
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 2 And try_convert(time,fec_hr_ind) BETWEEN '02:00' AND '02:59:59' Then 1 Else 0 End as Dia2Bloque18
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 2 And try_convert(time,fec_hr_ind) BETWEEN '03:00' AND '03:59:59' Then 1 Else 0 End as Dia2Bloque19
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 2 And try_convert(time,fec_hr_ind) BETWEEN '04:00' AND '04:59:59' Then 1 Else 0 End as Dia2Bloque20
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 2 And try_convert(time,fec_hr_ind) BETWEEN '05:00' AND '05:59:59' Then 1 Else 0 End as Dia2Bloque21
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 2 And try_convert(time,fec_hr_ind) BETWEEN '06:00' AND '06:59:59' Then 1 Else 0 End as Dia2Bloque22
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 2 And try_convert(time,fec_hr_ind) BETWEEN '07:00' AND '07:59:59' Then 1 Else 0 End as Dia2Bloque23
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 2 And try_convert(time,fec_hr_ind) BETWEEN '08:00' AND '08:59:59' Then 1 Else 0 End as Dia2Bloque24
			/*Miercoles*/
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 3 And try_convert(time,fec_hr_ind) BETWEEN '09:00' AND '09:59:59' Then 1 Else 0 End as Dia3Bloque01
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 3 And try_convert(time,fec_hr_ind) BETWEEN '10:00' AND '10:59:59' Then 1 Else 0 End as Dia3Bloque02
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 3 And try_convert(time,fec_hr_ind) BETWEEN '11:00' AND '11:59:59' Then 1 Else 0 End as Dia3Bloque03
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 3 And try_convert(time,fec_hr_ind) BETWEEN '12:00' AND '12:59:59' Then 1 Else 0 End as Dia3Bloque04
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 3 And try_convert(time,fec_hr_ind) BETWEEN '13:00' AND '13:59:59' Then 1 Else 0 End as Dia3Bloque05
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 3 And try_convert(time,fec_hr_ind) BETWEEN '14:00' AND '14:59:59' Then 1 Else 0 End as Dia3Bloque06
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 3 And try_convert(time,fec_hr_ind) BETWEEN '15:00' AND '15:59:59' Then 1 Else 0 End as Dia3Bloque07
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 3 And try_convert(time,fec_hr_ind) BETWEEN '16:00' AND '16:59:59' Then 1 Else 0 End as Dia3Bloque08
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 3 And try_convert(time,fec_hr_ind) BETWEEN '17:00' AND '17:59:59' Then 1 Else 0 End as Dia3Bloque09
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 3 And try_convert(time,fec_hr_ind) BETWEEN '18:00' AND '18:59:59' Then 1 Else 0 End as Dia3Bloque10
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 3 And try_convert(time,fec_hr_ind) BETWEEN '19:00' AND '19:59:59' Then 1 Else 0 End as Dia3Bloque11
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 3 And try_convert(time,fec_hr_ind) BETWEEN '20:00' AND '20:59:59' Then 1 Else 0 End as Dia3Bloque12
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 3 And try_convert(time,fec_hr_ind) BETWEEN '21:00' AND '21:59:59' Then 1 Else 0 End as Dia3Bloque13
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 3 And try_convert(time,fec_hr_ind) BETWEEN '22:00' AND '22:59:59' Then 1 Else 0 End as Dia3Bloque14
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 3 And try_convert(time,fec_hr_ind) BETWEEN '23:00' AND '23:59:59' Then 1 Else 0 End as Dia3Bloque15
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 3 And try_convert(time,fec_hr_ind) BETWEEN '00:00' AND '00:59:59' Then 1 Else 0 End as Dia3Bloque16
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 3 And try_convert(time,fec_hr_ind) BETWEEN '01:00' AND '01:59:59' Then 1 Else 0 End as Dia3Bloque17
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 3 And try_convert(time,fec_hr_ind) BETWEEN '02:00' AND '02:59:59' Then 1 Else 0 End as Dia3Bloque18
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 3 And try_convert(time,fec_hr_ind) BETWEEN '03:00' AND '03:59:59' Then 1 Else 0 End as Dia3Bloque19
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 3 And try_convert(time,fec_hr_ind) BETWEEN '04:00' AND '04:59:59' Then 1 Else 0 End as Dia3Bloque20
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 3 And try_convert(time,fec_hr_ind) BETWEEN '05:00' AND '05:59:59' Then 1 Else 0 End as Dia3Bloque21
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 3 And try_convert(time,fec_hr_ind) BETWEEN '06:00' AND '06:59:59' Then 1 Else 0 End as Dia3Bloque22
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 3 And try_convert(time,fec_hr_ind) BETWEEN '07:00' AND '07:59:59' Then 1 Else 0 End as Dia3Bloque23
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 3 And try_convert(time,fec_hr_ind) BETWEEN '08:00' AND '08:59:59' Then 1 Else 0 End as Dia3Bloque24
			/*Jueves*/
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 4 And try_convert(time,fec_hr_ind) BETWEEN '09:00' AND '09:59:59' Then 1 Else 0 End as Dia4Bloque01
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 4 And try_convert(time,fec_hr_ind) BETWEEN '10:00' AND '10:59:59' Then 1 Else 0 End as Dia4Bloque02
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 4 And try_convert(time,fec_hr_ind) BETWEEN '11:00' AND '11:59:59' Then 1 Else 0 End as Dia4Bloque03
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 4 And try_convert(time,fec_hr_ind) BETWEEN '12:00' AND '12:59:59' Then 1 Else 0 End as Dia4Bloque04
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 4 And try_convert(time,fec_hr_ind) BETWEEN '13:00' AND '13:59:59' Then 1 Else 0 End as Dia4Bloque05
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 4 And try_convert(time,fec_hr_ind) BETWEEN '14:00' AND '14:59:59' Then 1 Else 0 End as Dia4Bloque06
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 4 And try_convert(time,fec_hr_ind) BETWEEN '15:00' AND '15:59:59' Then 1 Else 0 End as Dia4Bloque07
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 4 And try_convert(time,fec_hr_ind) BETWEEN '16:00' AND '16:59:59' Then 1 Else 0 End as Dia4Bloque08
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 4 And try_convert(time,fec_hr_ind) BETWEEN '17:00' AND '17:59:59' Then 1 Else 0 End as Dia4Bloque09
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 4 And try_convert(time,fec_hr_ind) BETWEEN '18:00' AND '18:59:59' Then 1 Else 0 End as Dia4Bloque10
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 4 And try_convert(time,fec_hr_ind) BETWEEN '19:00' AND '19:59:59' Then 1 Else 0 End as Dia4Bloque11
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 4 And try_convert(time,fec_hr_ind) BETWEEN '20:00' AND '20:59:59' Then 1 Else 0 End as Dia4Bloque12
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 4 And try_convert(time,fec_hr_ind) BETWEEN '21:00' AND '21:59:59' Then 1 Else 0 End as Dia4Bloque13
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 4 And try_convert(time,fec_hr_ind) BETWEEN '22:00' AND '22:59:59' Then 1 Else 0 End as Dia4Bloque14
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 4 And try_convert(time,fec_hr_ind) BETWEEN '23:00' AND '23:59:59' Then 1 Else 0 End as Dia4Bloque15
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 4 And try_convert(time,fec_hr_ind) BETWEEN '00:00' AND '00:59:59' Then 1 Else 0 End as Dia4Bloque16
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 4 And try_convert(time,fec_hr_ind) BETWEEN '01:00' AND '01:59:59' Then 1 Else 0 End as Dia4Bloque17
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 4 And try_convert(time,fec_hr_ind) BETWEEN '02:00' AND '02:59:59' Then 1 Else 0 End as Dia4Bloque18
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 4 And try_convert(time,fec_hr_ind) BETWEEN '03:00' AND '03:59:59' Then 1 Else 0 End as Dia4Bloque19
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 4 And try_convert(time,fec_hr_ind) BETWEEN '04:00' AND '04:59:59' Then 1 Else 0 End as Dia4Bloque20
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 4 And try_convert(time,fec_hr_ind) BETWEEN '05:00' AND '05:59:59' Then 1 Else 0 End as Dia4Bloque21
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 4 And try_convert(time,fec_hr_ind) BETWEEN '06:00' AND '06:59:59' Then 1 Else 0 End as Dia4Bloque22
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 4 And try_convert(time,fec_hr_ind) BETWEEN '07:00' AND '07:59:59' Then 1 Else 0 End as Dia4Bloque23
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 4 And try_convert(time,fec_hr_ind) BETWEEN '08:00' AND '08:59:59' Then 1 Else 0 End as Dia4Bloque24
			/*Viernes*/
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 5 And try_convert(time,fec_hr_ind) BETWEEN '09:00' AND '09:59:59' Then 1 Else 0 End as Dia5Bloque01
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 5 And try_convert(time,fec_hr_ind) BETWEEN '10:00' AND '10:59:59' Then 1 Else 0 End as Dia5Bloque02
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 5 And try_convert(time,fec_hr_ind) BETWEEN '11:00' AND '11:59:59' Then 1 Else 0 End as Dia5Bloque03
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 5 And try_convert(time,fec_hr_ind) BETWEEN '12:00' AND '12:59:59' Then 1 Else 0 End as Dia5Bloque04
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 5 And try_convert(time,fec_hr_ind) BETWEEN '13:00' AND '13:59:59' Then 1 Else 0 End as Dia5Bloque05
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 5 And try_convert(time,fec_hr_ind) BETWEEN '14:00' AND '14:59:59' Then 1 Else 0 End as Dia5Bloque06
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 5 And try_convert(time,fec_hr_ind) BETWEEN '15:00' AND '15:59:59' Then 1 Else 0 End as Dia5Bloque07
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 5 And try_convert(time,fec_hr_ind) BETWEEN '16:00' AND '16:59:59' Then 1 Else 0 End as Dia5Bloque08
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 5 And try_convert(time,fec_hr_ind) BETWEEN '17:00' AND '17:59:59' Then 1 Else 0 End as Dia5Bloque09
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 5 And try_convert(time,fec_hr_ind) BETWEEN '18:00' AND '18:59:59' Then 1 Else 0 End as Dia5Bloque10
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 5 And try_convert(time,fec_hr_ind) BETWEEN '19:00' AND '19:59:59' Then 1 Else 0 End as Dia5Bloque11
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 5 And try_convert(time,fec_hr_ind) BETWEEN '20:00' AND '20:59:59' Then 1 Else 0 End as Dia5Bloque12
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 5 And try_convert(time,fec_hr_ind) BETWEEN '21:00' AND '21:59:59' Then 1 Else 0 End as Dia5Bloque13
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 5 And try_convert(time,fec_hr_ind) BETWEEN '22:00' AND '22:59:59' Then 1 Else 0 End as Dia5Bloque14
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 5 And try_convert(time,fec_hr_ind) BETWEEN '23:00' AND '23:59:59' Then 1 Else 0 End as Dia5Bloque15
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 5 And try_convert(time,fec_hr_ind) BETWEEN '00:00' AND '00:59:59' Then 1 Else 0 End as Dia5Bloque16
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 5 And try_convert(time,fec_hr_ind) BETWEEN '01:00' AND '01:59:59' Then 1 Else 0 End as Dia5Bloque17
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 5 And try_convert(time,fec_hr_ind) BETWEEN '02:00' AND '02:59:59' Then 1 Else 0 End as Dia5Bloque18
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 5 And try_convert(time,fec_hr_ind) BETWEEN '03:00' AND '03:59:59' Then 1 Else 0 End as Dia5Bloque19
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 5 And try_convert(time,fec_hr_ind) BETWEEN '04:00' AND '04:59:59' Then 1 Else 0 End as Dia5Bloque20
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 5 And try_convert(time,fec_hr_ind) BETWEEN '05:00' AND '05:59:59' Then 1 Else 0 End as Dia5Bloque21
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 5 And try_convert(time,fec_hr_ind) BETWEEN '06:00' AND '06:59:59' Then 1 Else 0 End as Dia5Bloque22
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 5 And try_convert(time,fec_hr_ind) BETWEEN '07:00' AND '07:59:59' Then 1 Else 0 End as Dia5Bloque23
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 5 And try_convert(time,fec_hr_ind) BETWEEN '08:00' AND '08:59:59' Then 1 Else 0 End as Dia5Bloque24
			/*Sabado*/
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 6 And try_convert(time,fec_hr_ind) BETWEEN '09:00' AND '09:59:59' Then 1 Else 0 End as Dia6Bloque01
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 6 And try_convert(time,fec_hr_ind) BETWEEN '10:00' AND '10:59:59' Then 1 Else 0 End as Dia6Bloque02
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 6 And try_convert(time,fec_hr_ind) BETWEEN '11:00' AND '11:59:59' Then 1 Else 0 End as Dia6Bloque03
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 6 And try_convert(time,fec_hr_ind) BETWEEN '12:00' AND '12:59:59' Then 1 Else 0 End as Dia6Bloque04
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 6 And try_convert(time,fec_hr_ind) BETWEEN '13:00' AND '13:59:59' Then 1 Else 0 End as Dia6Bloque05
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 6 And try_convert(time,fec_hr_ind) BETWEEN '14:00' AND '14:59:59' Then 1 Else 0 End as Dia6Bloque06
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 6 And try_convert(time,fec_hr_ind) BETWEEN '15:00' AND '15:59:59' Then 1 Else 0 End as Dia6Bloque07
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 6 And try_convert(time,fec_hr_ind) BETWEEN '16:00' AND '16:59:59' Then 1 Else 0 End as Dia6Bloque08
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 6 And try_convert(time,fec_hr_ind) BETWEEN '17:00' AND '17:59:59' Then 1 Else 0 End as Dia6Bloque09
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 6 And try_convert(time,fec_hr_ind) BETWEEN '18:00' AND '18:59:59' Then 1 Else 0 End as Dia6Bloque10
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 6 And try_convert(time,fec_hr_ind) BETWEEN '19:00' AND '19:59:59' Then 1 Else 0 End as Dia6Bloque11
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 6 And try_convert(time,fec_hr_ind) BETWEEN '20:00' AND '20:59:59' Then 1 Else 0 End as Dia6Bloque12
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 6 And try_convert(time,fec_hr_ind) BETWEEN '21:00' AND '21:59:59' Then 1 Else 0 End as Dia6Bloque13
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 6 And try_convert(time,fec_hr_ind) BETWEEN '22:00' AND '22:59:59' Then 1 Else 0 End as Dia6Bloque14
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 6 And try_convert(time,fec_hr_ind) BETWEEN '23:00' AND '23:59:59' Then 1 Else 0 End as Dia6Bloque15
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 6 And try_convert(time,fec_hr_ind) BETWEEN '00:00' AND '00:59:59' Then 1 Else 0 End as Dia6Bloque16
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 6 And try_convert(time,fec_hr_ind) BETWEEN '01:00' AND '01:59:59' Then 1 Else 0 End as Dia6Bloque17
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 6 And try_convert(time,fec_hr_ind) BETWEEN '02:00' AND '02:59:59' Then 1 Else 0 End as Dia6Bloque18
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 6 And try_convert(time,fec_hr_ind) BETWEEN '03:00' AND '03:59:59' Then 1 Else 0 End as Dia6Bloque19
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 6 And try_convert(time,fec_hr_ind) BETWEEN '04:00' AND '04:59:59' Then 1 Else 0 End as Dia6Bloque20
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 6 And try_convert(time,fec_hr_ind) BETWEEN '05:00' AND '05:59:59' Then 1 Else 0 End as Dia6Bloque21
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 6 And try_convert(time,fec_hr_ind) BETWEEN '06:00' AND '06:59:59' Then 1 Else 0 End as Dia6Bloque22
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 6 And try_convert(time,fec_hr_ind) BETWEEN '07:00' AND '07:59:59' Then 1 Else 0 End as Dia6Bloque23
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 6 And try_convert(time,fec_hr_ind) BETWEEN '08:00' AND '08:59:59' Then 1 Else 0 End as Dia6Bloque24
			/*Domingo*/
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 7 And try_convert(time,fec_hr_ind) BETWEEN '09:00' AND '09:59:59' Then 1 Else 0 End as Dia7Bloque01
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 7 And try_convert(time,fec_hr_ind) BETWEEN '10:00' AND '10:59:59' Then 1 Else 0 End as Dia7Bloque02
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 7 And try_convert(time,fec_hr_ind) BETWEEN '11:00' AND '11:59:59' Then 1 Else 0 End as Dia7Bloque03
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 7 And try_convert(time,fec_hr_ind) BETWEEN '12:00' AND '12:59:59' Then 1 Else 0 End as Dia7Bloque04
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 7 And try_convert(time,fec_hr_ind) BETWEEN '13:00' AND '13:59:59' Then 1 Else 0 End as Dia7Bloque05
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 7 And try_convert(time,fec_hr_ind) BETWEEN '14:00' AND '14:59:59' Then 1 Else 0 End as Dia7Bloque06
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 7 And try_convert(time,fec_hr_ind) BETWEEN '15:00' AND '15:59:59' Then 1 Else 0 End as Dia7Bloque07
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 7 And try_convert(time,fec_hr_ind) BETWEEN '16:00' AND '16:59:59' Then 1 Else 0 End as Dia7Bloque08
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 7 And try_convert(time,fec_hr_ind) BETWEEN '17:00' AND '17:59:59' Then 1 Else 0 End as Dia7Bloque09
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 7 And try_convert(time,fec_hr_ind) BETWEEN '18:00' AND '18:59:59' Then 1 Else 0 End as Dia7Bloque10
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 7 And try_convert(time,fec_hr_ind) BETWEEN '19:00' AND '19:59:59' Then 1 Else 0 End as Dia7Bloque11
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 7 And try_convert(time,fec_hr_ind) BETWEEN '20:00' AND '20:59:59' Then 1 Else 0 End as Dia7Bloque12
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 7 And try_convert(time,fec_hr_ind) BETWEEN '21:00' AND '21:59:59' Then 1 Else 0 End as Dia7Bloque13
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 7 And try_convert(time,fec_hr_ind) BETWEEN '22:00' AND '22:59:59' Then 1 Else 0 End as Dia7Bloque14
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 7 And try_convert(time,fec_hr_ind) BETWEEN '23:00' AND '23:59:59' Then 1 Else 0 End as Dia7Bloque15
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 7 And try_convert(time,fec_hr_ind) BETWEEN '00:00' AND '00:59:59' Then 1 Else 0 End as Dia7Bloque16
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 7 And try_convert(time,fec_hr_ind) BETWEEN '01:00' AND '01:59:59' Then 1 Else 0 End as Dia7Bloque17
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 7 And try_convert(time,fec_hr_ind) BETWEEN '02:00' AND '02:59:59' Then 1 Else 0 End as Dia7Bloque18
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 7 And try_convert(time,fec_hr_ind) BETWEEN '03:00' AND '03:59:59' Then 1 Else 0 End as Dia7Bloque19
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 7 And try_convert(time,fec_hr_ind) BETWEEN '04:00' AND '04:59:59' Then 1 Else 0 End as Dia7Bloque20
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 7 And try_convert(time,fec_hr_ind) BETWEEN '05:00' AND '05:59:59' Then 1 Else 0 End as Dia7Bloque21
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 7 And try_convert(time,fec_hr_ind) BETWEEN '06:00' AND '06:59:59' Then 1 Else 0 End as Dia7Bloque22
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 7 And try_convert(time,fec_hr_ind) BETWEEN '07:00' AND '07:59:59' Then 1 Else 0 End as Dia7Bloque23
			,Case When DATEPART(dw,TRY_CONVERT(datetime,fec_hr_ind)) = 7 And try_convert(time,fec_hr_ind) BETWEEN '08:00' AND '08:59:59' Then 1 Else 0 End as Dia7Bloque24
		
		
		FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
		LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
		LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
		WHERE 1=1 and tipo_operativo=2 AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL  AND NOT CodUsoDestino IS NULL 
		AND FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC
		)A GROUP BY IdLocalCensal,IDUSUARIO,Semana) B GROUP BY IdLocalCensal,IDUSUARIO)
		TBL_04 ON TBL_01.IdCensista=TBL_04.IdUsuario And TBL_01.IdUnidadTerritorial=TBL_04.IdUnidadTerritorial
		LEFT JOIN SGCPV.DBO.GES_ATRIBUTO_USUARIO GAU WITH (NOLOCK) ON  TBL_01.IdCensista=GAU.IDUSUARIO AND GAU.IdPerfil = 7
		LEFT JOIN
		(SELECT IdLocalCensal as IdUnidadTerritorial,IdUsuario,MIN(Horas) AS MINIMO,MAX(Horas) AS MAXIMO,SUM(Horas) TOTAL FROM (
			SELECT IdLocalCensal,IdUsuario, Dia, COUNT(1) Horas FROM (
				SELECT IdLocalCensal,GU.IdUsuario,DATEPART(HOUR, TRY_CONVERT(datetime,fec_hr_ind)) AS Hora,(TRY_CONVERT(DATE,fec_hr_ind)) AS Dia,COUNT(*) AS Cantidad
				FROM REPORTES_EXP_2023.DBO.TBL_DIRECCION_ASIGNADA DA WITH (NOLOCK) 
				LEFT JOIN SGCPV.DBO.GES_USUARIO GU WITH (NOLOCK) ON DA.IdCensista=GU.IdUsuario
				LEFT JOIN PROCESAMIENTOCPV_2023..HOJA_RUTA HR WITH (NOLOCK) ON HR.cod_uso_destino=DA.CodUsoDestino
				WHERE 1=1 and tipo_operativo=2 AND fec_hr_ind <> '-99' AND NOT RESPONSIBLE IS NULL AND NOT COD_USO_DESTINO IS NULL  AND NOT CodUsoDestino IS NULL
				AND FechaHoraVisitaRe BETWEEN @FECHA AND @FECHAAC AND cast(hoja_ruta_fecha as date) BETWEEN @FECHA AND @FECHAAC				
				GROUP BY IdLocalCensal,GU.IdUsuario,DATEPART(HOUR, TRY_CONVERT(datetime,fec_hr_ind)), (TRY_CONVERT(DATE,fec_hr_ind))
				) A GROUP BY IdLocalCensal,IdUsuario,DIA) B GROUP BY IdLocalCensal,IdUsuario)
		TBL_05 ON TBL_01.IdCensista=TBL_05.IdUsuario And TBL_01.IdUnidadTerritorial=TBL_05.IdUnidadTerritorial
		/*WHERE GAU.IdPerfil=7*/ ) A