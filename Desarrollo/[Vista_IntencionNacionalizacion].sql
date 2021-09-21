USE [BDI]
GO

/****** Object:  View [dbo].[Vista_IntencionNacionalizacion]    Script Date: 15/09/2021 10:26:26 a. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[Vista_IntencionNacionalizacion]
AS
WITH IntecionBase
AS (
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
		,CAST(COALESCE(solicitudes.Ref2, '') AS NVARCHAR(20)) AS NumAtCard
		,COALESCE(solicitudesLineas.U_GW_Cliente, '') AS UGwCliente
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
	INNER JOIN GlobalWine.dbo.DRF1 solicitudesLineas
		ON solicitudes.DocEntry = solicitudesLineas.DocEntry
	INNER JOIN GlobalWine.dbo.NNM1 series
		ON series.Series = solicitudes.Series
	WHERE solicitudes.CANCELED = 'N'
		AND solicitudes.U_TIPO_VENTA IN (
			'5'
			,'6'
			)
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
	)
	,intencionCompleta
AS (
	SELECT a.DocEntry AS docEntry
		,a.ObjType AS objType
		,a.Series AS series
		,CAST(a.NoPedidoExterno AS VARCHAR(20)) AS noPedidoExterno
		,a.UGwObservRegreso AS observRegreso
		,a.Comments
		,CASE 
			WHEN COALESCE(a.NumAtCard, '') != ''
				THEN a.SeriesName
			WHEN COALESCE(a.NumAtCard, '') = ''
				THEN a.SeriesName
			END AS nombreSerie
		,CASE 
			WHEN COALESCE(a.NumAtCard, '') != ''
				THEN COALESCE(a.NumAtCard, '')
			WHEN COALESCE(a.NumAtCard, '') = ''
				THEN CAST(a.DocNum AS NVARCHAR(20))
			END AS documento
		,a.DocNum
		,coalesce(a.NumAtCard, '') AS ordenCompra
		,'GWS' AS codigoEmpresa
		,a.TipoServicio
		,a.IdTipoServicio
		,a.IdTiposSolicitud
		,a.UGwCliente AS terceroCodigoSap
		,cliente.LicTradNum AS terceroNit
		,REPLACE(COALESCE(dbo.f_string_to_printable_string(cliente.CardName), ''), '"', '''') AS terceroRazonSocial
		,UPPER(COALESCE(grupos.GroupName, '')) AS nombreGrupo
		,COALESCE(dbo.f_string_to_printable_string(a.ShipToCode), '') AS nombreDireccion
		,COALESCE(dbo.f_string_to_printable_string(a.Address2), '') AS direccion
		,1 AS idOoperadorLogistico
		--
		,CASE 
			WHEN a.UGwFecha1 > cast(GETDATE() AS DATE)
				THEN a.UGwFecha1
			WHEN a.UGwEstampilla IS NULL
				THEN GETDATE() + 1
			ELSE cast(GETDATE() + 1 AS DATE)
			END AS feMi
		,CASE 
			WHEN a.UGwFecha2 > cast(GETDATE() AS DATE)
				THEN a.UGwFecha2
			WHEN a.UGwTornaguia IS NULL
				THEN GETDATE() + 1
			ELSE cast(GETDATE() + 1 AS DATE)
			END AS feMa
		,CASE 
			WHEN a.UGwEstampilla > a.UGwTornaguia
				THEN '07:00'
			WHEN a.UGwEstampilla = ''
				THEN '07:00'
			WHEN a.UGwEstampilla IS NULL
				THEN '07:00'
			ELSE CAST(a.UGwEstampilla AS NVARCHAR(5))
			END AS hoMi
		,CASE 
			WHEN a.UGwEstampilla > a.UGwTornaguia
				AND a.UGwEstampilla >= '22:00'
				THEN '23:59'
			WHEN a.UGwEstampilla > a.UGwTornaguia
				THEN '18:00'
			WHEN a.UGwTornaguia = ''
				THEN '18:00'
			WHEN a.UGwTornaguia IS NULL
				THEN '18:00'
			WHEN a.UGwTornaguia = '00:00'
				THEN '18:00'
			WHEN a.UGwTornaguia = '00:00:00.0'
				THEN '18:00'
			ELSE CAST(a.UGwTornaguia AS NVARCHAR(5))
			END AS hoMa
		,a.CreateDate
		,a.DocDate
		,a.DocDueDate
		,0 AS generarListaDocumentosDigitales
		,a.SlpCode
		,cliente.GroupCode
		,a.DocTotal
		,a.cedi
	FROM IntecionBase a
	INNER JOIN GlobalWine.dbo.OCRD cliente
		ON cliente.CardCode = a.UGwCliente
	LEFT JOIN GlobalWine.dbo.OCRG grupos
		ON cliente.GroupCode = grupos.GroupCode
	)
SELECT docEntry
	,objType
	,series
	,COALESCE(CAST(noPedidoExterno AS NVARCHAR(50)), '') AS noPedidoExterno
	,COALESCE(CAST(Comments AS NVARCHAR(200)), '') AS comments
	,COALESCE(observRegreso, '') AS observRegreso
	,CONCAT (
		nombreSerie
		,'_'
		,documento
		) AS keySolicitud
	,nombreSerie
	,documento
	,DocNum
	,ordenCompra
	,codigoEmpresa
	,idTiposSolicitud
	,idTipoServicio
	,terceroCodigoSap
	,terceroNit
	,terceroRazonSocial
	,nombreGrupo
	,nombreDireccion
	,CAST(dbo.f_direccion_to_codigo_dane(direccion, '') AS NVARCHAR(5)) AS codigoDane
	,CAST(direccion AS NVARCHAR(150)) AS direccion
	,CASE 
		WHEN series IN ('396')
			OR b.principal = 0
			THEN 0
		ELSE 1
		END AS idOoperadorLogistico
	,CAST(COALESCE(feMi, a.DocDueDate, '') AS DATE) AS feMi
	,CAST(COALESCE(feMa, a.DocDueDate, '') AS DATE) AS feMa
	,hoMi
	,hoMa
	,CreateDate
	,DocDate
	,DocDueDate
	,generarListaDocumentosDigitales
	,c.SlpName
	,a.GroupCode
	,a.DocTotal
	,a.cedi
FROM intencionCompleta a 
LEFT JOIN OperadoresLogisticos b
	ON a.terceroNit = b.nit
LEFT JOIN GlobalWine.dbo.OSLP c
	ON a.slpCode = c.SlpCode

GO


