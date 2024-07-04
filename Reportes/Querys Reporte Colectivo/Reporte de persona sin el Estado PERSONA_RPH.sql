SELECT  --top 10000 
--	COUNT(1),
	PER.NPER AS NUMEROPERSONA,
	per.nombre AS NOMBRE,
	per.sexo AS SEXO,
	per.edad AS EDAD,
	per.censado as CENSADO,
	SUSO.CodigoAcceso AS CODIGOACCESO,
	SUSO.InterviewerId AS CODUSODESTINO,
	FechaSincronizacion AS FECHASINCRONIZACION,
	PER_ESTADO_PERSONA, 
	PER_ESTADO_PERSONA_RPH, 
	dato_col6 as TIPO_VC
	--	,case
	--	when (PER_ESTADO_PERSONA_RPH <> 1 or PER_ESTADO_PERSONA_RPH is null)  AND COL.dato_col6<>3 and (PER_ESTADO_PERSONA = 0 or PER_ESTADO_PERSONA is null)  then 1
	--	when ((PER_ESTADO_PERSONA_RPH IS NULL OR PER_ESTADO_PERSONA_RPH = 0) AND COL.dato_col6=3 AND per.sexo is null and per.edad is null and (PER_ESTADO_PERSONA = 0 or PER_ESTADO_PERSONA is null) ) then 2
	--	else 0
	--end as situacion 
	FROM CUESTIONARIOS_CPV_2023..GES_CAWI_VC_DATOS_PERSONA  PER 
	INNER JOIN GES_INTEGRACION_QR_SUSO SUSO ON PER.PK_VIVIENDA_CAWI_VC  LIKE SUSO.CodigoAcceso+'%'   
 	LEFT JOIN GES_ASIGNACION_COLECTIVAS  COL on COL.CodUsoDestino = SUSO.CodUsoDestino and COL.Tipo_Levantamiento = 3

 WHERE 
		(
		(PER_ESTADO_PERSONA_RPH <> 1 or PER_ESTADO_PERSONA_RPH is null)  AND COL.dato_col6<>3 and (PER_ESTADO_PERSONA = 0 or PER_ESTADO_PERSONA is null)
		OR
		((PER_ESTADO_PERSONA_RPH IS NULL OR PER_ESTADO_PERSONA_RPH = 0) AND COL.dato_col6=3 AND per.sexo is null and per.edad is null and (PER_ESTADO_PERSONA = 0 or PER_ESTADO_PERSONA is null) )
		)
 --GROUP BY per.nombre,per.sexo, per.edad,	SUSO.CodigoAcceso,SUSO.InterviewerId ,FechaSincronizacion, PER_ESTADO_PERSONA, PER_ESTADO_PERSONA_RPH, dato_col6 
-- dato_col6= 3   => milirtar
ORDER BY per.nombre, PER.NPER