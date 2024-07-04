SELECT --TOP 5000 --7284
C.CodUsoDestino, 
c.Estado,
C.dato_col1 as 'Perfil',
C.dato_col2,
C.dato_col3 as 'Fecha visita',
C.dato_col4 as 'Contacto Informante',
C.dato_col5 as 'Corresponde VC',
C.dato_col6 as 'Tipo VC',
C.dato_col7 AS 'Residentes',
C.dato_col8 as 'Residentes Habituales',
C.dato_col9 as 'Cantidad Máxima Residentes',
C.dato_col11 as 'Nombre Colectiva',
C.dato_col12 as 'Nombre Informante',
C.dato_col13 as 'Teléfono Informante',
C.dato_col14 as 'Correo Informante',
C.dato_col15 as 'Tipo Levantamiento',
C.dato_col16 as 'Existe VP',
C.dato_col17 as 'Observaciones',
C.dato_col18 as 'Fecha Formulario',
C.dato_col19,
C.dato_col20,
ISNULL(DIR.ID_Colectiva,'SIN ID') AS ID_VC,

GEO3.NOMBRE AS REGIÓN,

GEO.Nombre AS COMUNA,


DIR.NombreVia AS CALLE,
DIR.NumeroDomiciliario AS NRO,

dato_col11 AS   NOMBRE_VC,

QR.CodigoAcceso AS CODIGO,

dato_col8 AS RESIDENTES_HABITUALES,

 ISNULL(INC_SIN.CANTIDAD,0) AS 'Incompleto sin RPH'

,ISNULL(INC_CON.CANTIDAD,0) AS 'Incompleto con RPH'

,ISNULL(COMP.CANTIDAD,0) AS 'Completo'

,ISNULL(TOT_RES.CANTIDAD,0) AS 'Total Residentes'
--,INC_con.nombre, INC_con.sexo,INC_con.edad, INC_con.PER_ESTADO_PERSONA, INC_con.PER_ESTADO_PERSONA_RPH
FROM GES_ASIGNACION_COLECTIVAS  C

LEFT JOIN
(
 SELECT 
 ROW_NUMBER() OVER(PARTITION BY CodUsoDestino ORDER BY RES.Reslev_guid  DESC, LEN(CodigoAcceso),FechaSincronizacion desc) AS Row#,
 CodUsoDestino, CodigoAcceso, FechaSincronizacion, LEN(CodigoAcceso) AS LARGO--, *
 ,RES.Reslev_guid
 FROM GES_INTEGRACION_QR_SUSO  A
 LEFT join CUESTIONARIOS_CPV_2023..GES_RESUMEN_LEVANTAMIENTO RES ON RES.Reslev_guid LIKE A.CodigoAcceso+'%' AND RES.Reslev_tipo_levantamiento = 3

) 
QR ON QR.CodUsoDestino = C.CodUsoDestino AND QR.Row# =1 

LEFT JOIN
(
 SELECT CodUsoDestino, NombreVia, NumeroDomiciliario, CodAlc, MANZENT, CUT, ID_Colectiva
 FROM GES_DIRECCION 
)
DIR ON DIR.CodUsoDestino = C.CodUsoDestino

LEFT JOIN sgcpv..GLO_GEOGRAFIA GEO ON DIR.CUT = GEO.Codigo
LEFT JOIN SGCPV..GLO_GEOGRAFIA GEO2 ON GEO2.IdGeografia = GEO.Padre 
LEFT JOIN SGCPV..GLO_GEOGRAFIA GEO3 ON GEO3.IdGeografia = GEO2.Padre 


LEFT JOIN
(
 --SELECT  COUNT(1) AS CANTIDAD, SUSO.CodigoAcceso,SUSO.InterviewerId AS CODUSODESTINO,FechaSincronizacion FROM CUESTIONARIOS_CPV_2023..GES_CAWI_VC_DATOS_PERSONA  PER 
 -- INNER JOIN GES_INTEGRACION_QR_SUSO SUSO ON PER.PK_VIVIENDA_CAWI_VC  LIKE SUSO.CodigoAcceso+'%'   
 --WHERE (PER_ESTADO_PERSONA IS NULL OR PER_ESTADO_PERSONA = 0) and (PER_ESTADO_PERSONA_RPH IS NULL OR PER_ESTADO_PERSONA_RPH = 0)
 --GROUP BY SUSO.CodigoAcceso,SUSO.InterviewerId,FechaSincronizacion

 SELECT  COUNT(1) AS CANTIDAD, SUSO.CodigoAcceso,SUSO.InterviewerId AS CODUSODESTINO,FechaSincronizacion FROM CUESTIONARIOS_CPV_2023..GES_CAWI_VC_DATOS_PERSONA  PER 
	  INNER JOIN GES_INTEGRACION_QR_SUSO SUSO ON PER.PK_VIVIENDA_CAWI_VC  LIKE SUSO.CodigoAcceso+'%'   
	  left join GES_ASIGNACION_COLECTIVAS  COL on COL.CodUsoDestino = SUSO.CodUsoDestino and COL.Tipo_Levantamiento = 3
 WHERE (PER_ESTADO_PERSONA IS NULL OR PER_ESTADO_PERSONA = 0) and 
	(((PER_ESTADO_PERSONA_RPH IS NULL OR PER_ESTADO_PERSONA_RPH = 0) and COL.dato_col6<>3)
	OR
		(COL.dato_col6=3 AND per.sexo is null and per.edad is null)
	)
 GROUP BY SUSO.CodigoAcceso,SUSO.InterviewerId,FechaSincronizacion

)
INC_SIN ON  INC_SIN.CODUSODESTINO = C.CodUsoDestino AND INC_SIN.CodigoAcceso = QR.CodigoAcceso

LEFT JOIN
(
--SELECT  COUNT(1) AS CANTIDAD , nombre,sexo,edad, PER_ESTADO_PERSONA, PER_ESTADO_PERSONA_RPH ,SUSO.CodigoAcceso,SUSO.InterviewerId AS CODUSODESTINO,FechaSincronizacion FROM CUESTIONARIOS_CPV_2023..GES_CAWI_VC_DATOS_PERSONA  PER 
-- INNER JOIN GES_INTEGRACION_QR_SUSO SUSO ON PER.PK_VIVIENDA_CAWI_VC  LIKE SUSO.CodigoAcceso+'%'   
-- WHERE ((PER_ESTADO_PERSONA IS NULL OR PER_ESTADO_PERSONA = 0) and PER_ESTADO_PERSONA_RPH = 1)
-- GROUP BY  nombre,sexo,edad, PER_ESTADO_PERSONA, PER_ESTADO_PERSONA_RPH, SUSO.CodigoAcceso,SUSO.InterviewerId,FechaSincronizacion

SELECT  COUNT(1) AS CANTIDAD, 
	SUSO.CodigoAcceso, SUSO.InterviewerId AS CODUSODESTINO, FechaSincronizacion 
 FROM CUESTIONARIOS_CPV_2023..GES_CAWI_VC_DATOS_PERSONA  PER 
  INNER JOIN GES_INTEGRACION_QR_SUSO SUSO ON PER.PK_VIVIENDA_CAWI_VC  LIKE SUSO.CodigoAcceso+'%'   
  left join GES_ASIGNACION_COLECTIVAS  COL on COL.CodUsoDestino = SUSO.CodUsoDestino and COL.Tipo_Levantamiento = 3
 WHERE (PER_ESTADO_PERSONA IS NULL OR PER_ESTADO_PERSONA = 0) and 
		(((PER_ESTADO_PERSONA_RPH IS not NULL OR PER_ESTADO_PERSONA_RPH <> 0) and COL.dato_col6<>3)
		OR
		(COL.dato_col6=3 AND per.sexo is not null and per.edad is not null)
		)
  GROUP BY SUSO.CodigoAcceso, SUSO.InterviewerId, FechaSincronizacion

)
INC_CON ON  INC_CON.CODUSODESTINO = C.CodUsoDestino AND INC_CON.CodigoAcceso = QR.CodigoAcceso

LEFT JOIN 
(
 SELECT  COUNT(1) AS CANTIDAD,SUSO.CodigoAcceso,SUSO.InterviewerId AS CODUSODESTINO,FechaSincronizacion FROM CUESTIONARIOS_CPV_2023..GES_CAWI_VC_DATOS_PERSONA  PER 
 INNER JOIN GES_INTEGRACION_QR_SUSO SUSO ON PER.PK_VIVIENDA_CAWI_VC  LIKE SUSO.CodigoAcceso+'%'   
 WHERE PER_ESTADO_PERSONA = 1
 GROUP BY SUSO.CodigoAcceso,SUSO.InterviewerId,FechaSincronizacion

)
COMP ON  COMP.CODUSODESTINO = C.CodUsoDestino AND COMP.CodigoAcceso = QR.CodigoAcceso

LEFT JOIN
(
 SELECT  COUNT(1) AS CANTIDAD,SUSO.CodigoAcceso,SUSO.InterviewerId AS CODUSODESTINO,FechaSincronizacion FROM CUESTIONARIOS_CPV_2023..GES_CAWI_VC_DATOS_PERSONA  PER 
 INNER JOIN GES_INTEGRACION_QR_SUSO SUSO ON PER.PK_VIVIENDA_CAWI_VC  LIKE SUSO.CodigoAcceso+'%'   --   'sm-k4%'
 GROUP BY SUSO.CodigoAcceso,SUSO.InterviewerId,FechaSincronizacion
)
TOT_RES ON  TOT_RES.CODUSODESTINO = C.CodUsoDestino AND TOT_RES.CodigoAcceso = QR.CodigoAcceso


WHERE Tipo_Levantamiento in (3)
-- and c.CodUsoDestino = '5015327'

