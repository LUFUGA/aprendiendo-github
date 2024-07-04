select 
asi.IdAsignacionDe AS ARC
,(select nombre from SGCPV..GES_USUARIO where IdUsuario = asi.IdAsignacionA) as Nombre_CG
,(select Rut from SGCPV..GES_USUARIO where IdUsuario = asi.IdAsignacionA) as Rut_CG
,asi.IdAsignacionA AS ID_USUARIO
from SGCPV..GES_ASIGNACIONES asi 
where asi.IdTipoAsignacion = 16 group by IdAsignacionDe, IdAsignacionA


SELECT 
(select nombre from SGCPV..GES_USUARIO where IdUsuario = asi.IdAsignacionA) as Nombre_CG
,ASI.IdAsignacionA AS ID_USUARIO
,COUNT(IdAsignacionDe) AS CANTIDAD_CENSISTAS
FROM SGCPV..GES_ASIGNACIONES ASI WHERE ASI.IdTipoAsignacion = 10 GROUP BY ASI.IdAsignacionA






