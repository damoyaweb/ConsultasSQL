USE [BDI]
GO

/****** Object:  UserDefinedFunction [dbo].[fn_NacionalizacionLineas]    Script Date: 15/09/2021 10:26:55 a. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create function [dbo].[fn_NacionalizacionLineas] (
 @DocEntry INT
,@ObjType NVARCHAR(20)
)
RETURNS TABLE
AS
RETURN(
SELECT solicitudesLinea.DocEntry
	,solicitudesLinea.ObjType
	,solicitudesLinea.LineNum
	,solicitudesLinea.ItemCode
	,solicitudesLinea.Dscription
	,solicitudesLinea.Quantity
	,solicitudesLinea.WhsCode
	,'' AS almacenDestino
	,COALESCE(solicitudesLinea.U_Comentariosl, '') AS predistribucion
	,(((COALESCE(precio.AvgPrice, 0.0) * impuestos.Rate) / 100) + COALESCE(precio.AvgPrice, 0.0)) + COALESCE(articulos.U_GW_ICO, 0, 0) AS precio
	,COALESCE(solicitudesLinea.PriceBefDi, 0.0) AS precioSinDescuento
	,COALESCE(solicitudesLinea.U_VnCadena, 0, 0) AS precioCliente
	,COALESCE(solicitudesLinea.DiscPrcnt, 0, 0) AS descuentr
	,COALESCE(articulos.U_GW_ICO, 0, 0) AS icoGws
	,COALESCE(solicitudesLinea.U_VIcoCadena, 0, 0) AS icoCliente
	,solicitudesLinea.Project
	,solicitudesLinea.U_GW_Salida
	,solicitudesLinea.TaxCode AS impuesto
FROM [GlobalWine].dbo.DRF1 solicitudesLinea
INNER JOIN GlobalWine.dbo.OITM articulos ON solicitudesLinea.itemcode = articulos.ItemCode
INNER JOIN GlobalWine.dbo.OSTC impuestos ON articulos.taxcodear = impuestos.Code
INNER JOIN GlobalWine.dbo.ODRF solicitud ON solicitudesLinea.DocEntry = solicitud.DocEntry
LEFT OUTER JOIN GlobalWine.dbo.OITW precio ON solicitudesLinea.ItemCode = precio.ItemCode
	AND solicitudesLinea.WhsCode = precio.WhsCode
WHERE solicitudesLinea.DocEntry = @DocEntry
	AND solicitudesLinea.ObjType = @ObjType
)
GO


