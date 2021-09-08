--SOLICITUDES = ODRF
--SOLICITUDESLINEAS = DRF1
--SERIES = NNM1
SELECT solicitudes.DocEntry
	,solicitudes.ObjType
	,series.ObjectCode
	,series.SeriesName
	,CAST(CONCAT (
			solicitudes.DocNum
			,solicitudes.DocEntry
			) AS BIGINT) AS DocNum
	,solicitudes.Series
	,solicitudes.U_BKV_UID AS NoPedidoExterno
	,COALESCE(solicitudes.Comments, '') AS Comments
	,CAST(COALESCE(solicitudes.Ref2,'') AS NVARCHAR(20)) AS NumAtCard
	,COALESCE(solicitudesLineas.U_GW_Cliente,'') AS UGwCliente
	,CASE solicitudes.U_TIPO_VENTA
		WHEN '5'
			THEN 'INTENCION DE NACIONALIZACION INVENTARIO'
		WHEN '6'
			THEN 'INTENCION DE NACIONALIZACION OTM'
		END AS TipoServicio
	,CASE solicitudes.U_TIPO_VENTA
		WHEN '5'
			THEN 16
		WHEN '6'
			THEN 17
		END AS IdTipoServicio
	,3 AS IdTiposSolicitud
	,cast(solicitudes.U_GW_Fecha1 AS DATE) AS UGwFecha1
	,cast(solicitudes.U_GW_Fecha2 AS DATE) AS UGwFecha2
	,solicitudes.DocDueDate
	,solicitudes.U_GW_estampilla AS UGwEstampilla
	,solicitudes.U_GW_tornaguia AS UGwTornaguia
	,solicitudes.ShipToCode
	,solicitudes.U_BPCOST AS Address2
	,solicitudes.DocDate
	,solicitudes.CreateDate
	,CAST(solicitudes.U_GW_ObservRegreso AS NVARCHAR(MAX)) AS UGwObservRegreso
	,solicitudes.SlpCode
	,solicitudes.DocTotal
	,COALESCE(solicitudes.U_GW_Novedad, '') AS Cedi
FROM GlobalWine.dbo.ODRF solicitudes
INNER JOIN GlobalWine.dbo.DRF1 solicitudesLineas ON solicitudes.DocEntry = solicitudesLineas.DocEntry
INNER JOIN GlobalWine.dbo.NNM1 series ON series.Series = solicitudes.Series
WHERE solicitudes.CANCELED = 'N'
	AND solicitudes.U_TIPO_VENTA IN ('5', '6')
--AND solicitudes.Ref2 = 'PruebaInteN'
GROUP BY solicitudes.DocEntry
	,solicitudes.ObjType
	,series.ObjectCode
	,series.SeriesName
	,solicitudes.DocNum
	,solicitudes.Series
	,solicitudes.U_BKV_UID
	,solicitudes.Comments
	,solicitudes.Ref2
	,solicitudesLineas.U_GW_Cliente
	,solicitudes.U_TIPO_VENTA
	,solicitudes.U_GW_Fecha1
	,solicitudes.U_GW_Fecha2
	,solicitudes.DocDueDate
	,solicitudes.U_GW_estampilla
	,solicitudes.U_GW_tornaguia
	,solicitudes.ShipToCode
	,solicitudes.U_BPCOST
	,solicitudes.DocDate
	,solicitudes.CreateDate
	,CAST(solicitudes.U_GW_ObservRegreso AS NVARCHAR(MAX))
	,solicitudes.SlpCode
	,solicitudes.DocTotal
	,solicitudes.U_GW_Novedad
