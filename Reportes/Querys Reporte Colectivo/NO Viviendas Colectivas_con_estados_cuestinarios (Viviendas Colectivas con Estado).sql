SELECT C.CodUsoDestino, 
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
ISNULL((SELECT ID_Colectiva  FROM GES_DIRECCION WHERE CodUsoDestino = C.CodUsoDestino ),'SIN ID') AS ID_VC,
ISNULL((SELECT Nombre FROM GLO_GEOGRAFIA WHERE Codigo  =(SELECT M.CodRegion FROM GES_MANZANAS M WHERE M.Manzent = (SELECT MANZENT  FROM GES_DIRECCION WHERE CodUsoDestino = C.CodUsoDestino )
 AND CodAlc =(SELECT CodAlc  FROM GES_DIRECCION WHERE CodUsoDestino = C.CodUsoDestino )
) AND IdGeografiaNivel = 1),'SIN REGIÓN')AS REGIÓN,
ISNULL((SELECT UPPER(Nombre)  FROM GLO_GEOGRAFIA WHERE Codigo =(SELECT CUT  FROM GES_DIRECCION WHERE CodUsoDestino = C.CodUsoDestino ) AND IdGeografiaNivel = 3),'SIN COMUNA') AS COMUNA,
(SELECT NombreVia  FROM GES_DIRECCION WHERE CodUsoDestino = C.CodUsoDestino ) AS CALLE,
(SELECT NumeroDomiciliario  FROM GES_DIRECCION WHERE CodUsoDestino = C.CodUsoDestino ) AS NRO,
dato_col11 AS   NOMBRE_VC,
(SELECT TOP 1 CodigoAcceso  FROM GES_INTEGRACION_QR_SUSO  WHERE CodUsoDestino = C.CodUsoDestino order by FechaSincronizacion desc) AS CODIGO,
dato_col8 AS RESIDENTES_HABITUALES,
(SELECT COUNT(1) FROM CUESTIONARIOS_CPV_2023..GES_CAWI_VC_DATOS_PERSONA  
WHERE 
 --SUBSTRING(PK_VIVIENDA_CAWI_VC, 1, 5) = (SELECT TOP 1 CodigoAcceso  FROM GES_INTEGRACION_QR_SUSO  WHERE CodUsoDestino = C.CodUsoDestino order by FechaSincronizacion desc) AND (PER_ESTADO_PERSONA IS NULL OR PER_ESTADO_PERSONA = 0) and (PER_ESTADO_PERSONA_RPH IS NULL OR PER_ESTADO_PERSONA_RPH = 0)
 PK_VIVIENDA_CAWI_VC like (SELECT TOP 1 CodigoAcceso+'%'  FROM GES_INTEGRACION_QR_SUSO  WHERE CodUsoDestino =  C.CodUsoDestino order by FechaSincronizacion desc) AND (PER_ESTADO_PERSONA IS NULL OR PER_ESTADO_PERSONA = 0) and (PER_ESTADO_PERSONA_RPH IS NULL OR PER_ESTADO_PERSONA_RPH = 0)
)AS 'Incompleto sin RPH',
(SELECT COUNT(1) FROM CUESTIONARIOS_CPV_2023..GES_CAWI_VC_DATOS_PERSONA  
WHERE 
 --SUBSTRING(PK_VIVIENDA_CAWI_VC, 1, 5) = (SELECT TOP 1 CodigoAcceso  FROM GES_INTEGRACION_QR_SUSO  WHERE CodUsoDestino = C.CodUsoDestino order by FechaSincronizacion desc) AND ((PER_ESTADO_PERSONA IS NULL OR PER_ESTADO_PERSONA = 0) and PER_ESTADO_PERSONA_RPH = 1)
 PK_VIVIENDA_CAWI_VC like (SELECT TOP 1 CodigoAcceso+'%'  FROM GES_INTEGRACION_QR_SUSO  WHERE CodUsoDestino =  C.CodUsoDestino order by FechaSincronizacion desc) AND ((PER_ESTADO_PERSONA IS NULL OR PER_ESTADO_PERSONA = 0) and PER_ESTADO_PERSONA_RPH = 1)
)AS 'Incompleto con RPH',
(SELECT COUNT(1) FROM CUESTIONARIOS_CPV_2023..GES_CAWI_VC_DATOS_PERSONA  
WHERE 
-- SUBSTRING(PK_VIVIENDA_CAWI_VC, 1, 5) = (SELECT TOP 1 CodigoAcceso  FROM GES_INTEGRACION_QR_SUSO  WHERE CodUsoDestino = C.CodUsoDestino order by FechaSincronizacion desc) AND PER_ESTADO_PERSONA = 1
  PK_VIVIENDA_CAWI_VC like (SELECT TOP 1 CodigoAcceso+'%'  FROM GES_INTEGRACION_QR_SUSO  WHERE CodUsoDestino =  C.CodUsoDestino order by FechaSincronizacion desc) AND PER_ESTADO_PERSONA = 1
)AS 'Completo',
(SELECT COUNT(1) FROM CUESTIONARIOS_CPV_2023..GES_CAWI_VC_DATOS_PERSONA  
WHERE 
-- SUBSTRING(PK_VIVIENDA_CAWI_VC, 1, 5) = (SELECT TOP 1 CodigoAcceso  FROM GES_INTEGRACION_QR_SUSO  WHERE CodUsoDestino = C.CodUsoDestino order by FechaSincronizacion desc) --AND (PER_ESTADO_PERSONA = 1  or PER_ESTADO_PERSONA_RPH = 1)
 PK_VIVIENDA_CAWI_VC like (SELECT TOP 1 CodigoAcceso+'%'  FROM GES_INTEGRACION_QR_SUSO  WHERE CodUsoDestino =  C.CodUsoDestino order by FechaSincronizacion desc) 
)AS 'Total Residentes'
FROM GES_ASIGNACION_COLECTIVAS  C
WHERE Tipo_Levantamiento in (1,2,3)
--and c.CodUsoDestino = '5000425'