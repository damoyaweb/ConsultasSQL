CREATE PROCEDURE MigrarNacionalizaciones
AS
BEGIN TRY
	DECLARE @fechaProximaConsulta DATETIME = GETDATE()

	IF OBJECT_ID('tempdb..#integraciones') IS NOT NULL
	BEGIN
		DROP TABLE #integraciones
	END

	SELECT CAST(a.fechaUltimaConsulta AS DATE) AS fechaUltimaConsulta
	INTO #integraciones
	FROM Integraciones a
	WHERE codigoIntegracion = 'NACIONALIZACION'

	IF OBJECT_ID('tempdb..#ordenesBase') IS NOT NULL
	BEGIN
		DROP TABLE #ordenesBase
	END

	SELECT CAST(a.keySolicitud AS NVARCHAR(50)) AS keySolicitud
		,CAST(a.nombreSerie AS NVARCHAR(20)) AS nombreSerie
		,CAST(a.documento AS NVARCHAR(20)) AS documento
		,a.DocNum
		,CAST(a.ordenCompra AS NVARCHAR(20)) AS ordenCompra
		,CAST(a.codigoEmpresa AS NVARCHAR(10)) AS codigoEmpresa
		,a.idTiposSolicitud
		,a.idTipoServicio
		,a.terceroCodigoSap
		,a.terceroNit
		,CAST(a.terceroRazonSocial AS NVARCHAR(100)) AS terceroRazonSocial
		,a.nombreGrupo
		,CAST(a.nombreDireccion AS NVARCHAR(100)) AS nombreDireccion
		,a.codigoDane
		,CAST(a.direccion AS NVARCHAR(100)) AS direccion
		,a.idOoperadorLogistico
		,a.feMi
		,a.feMa
		,CAST(a.hoMi AS TIME) AS hoMi
		,CAST(a.hoMa AS TIME) AS hoMa
		,a.CreateDate
		,a.DocDate
		,a.DocDueDate
		,a.generarListaDocumentosDigitales
		,CASE 
			WHEN a.terceroNit = '222222225'
				AND a.nombreSerie NOT LIKE ('%SAL%')
				THEN 'AUTORIZAR_CONTADO'
			ELSE 'MIGRADO_SAP'
			END AS [status]
		,CASE 
			WHEN c.id IS NOT NULL
				THEN 1
			ELSE 0
			END AS existe
		,GETDATE() AS dateMigradoSap
		,a.docEntry
		,a.objType
		,a.series
		,a.noPedidoExterno
		,a.comments
		,a.observRegreso
		,a.SlpName
		,CASE 
			WHEN a.GroupCode = 102
				THEN 0
			ELSE a.DocTotal
			END AS DocTotal
		,a.DocTotal AS TotalOrdenDespacho
		,a.cedi
	INTO #ordenesBase
	FROM dbo.Vista_IntencionNacionalizacion a
	INNER JOIN #integraciones b
		ON a.CreateDate >= b.fechaUltimaConsulta
	LEFT JOIN dbo.Solicitudes c
		ON a.keySolicitud = c.keySolicitud

	IF OBJECT_ID('tempdb..#id') IS NOT NULL
	BEGIN
		DROP TABLE #id
	END

	SELECT FLOOR(RAND() * (99 * 9) + 1) AS id
	INTO #id

	--LIMPIEZA DE DATOS
	IF OBJECT_ID('tempdb..#errores_direcciones_multiples') IS NOT NULL
	BEGIN
		DROP TABLE #errores_direcciones_multiples
	END;

	WITH cte_00
	AS (
		SELECT keySolicitud
			,COUNT(DISTINCT direccion) AS duplicado
		FROM #ordenesBase
		GROUP BY keySolicitud
		HAVING COUNT(DISTINCT direccion) > 1
		)
	SELECT (
			SELECT *
			FROM #id
			) AS idSolicitud
		,b.keySolicitud
		,'SAP_BDI' AS integracion
		,b.keySolicitud AS idExterno
		,205 AS idCausal
		,b.documento AS arg0
		,b.ordenCompra AS arg1
		,b.direccion AS arg2
		,GETDATE() AS fechaCreacion
		,GETDATE() AS fechaModificacion
	INTO #errores_direcciones_multiples
	FROM cte_00 a
	INNER JOIN #ordenesBase b
		ON a.keySolicitud = b.keySolicitud

	DELETE a
	FROM #ordenesBase a
	INNER JOIN #errores_direcciones_multiples b
		ON b.keySolicitud = a.keySolicitud

	IF OBJECT_ID('tempdb..#solicitudes') IS NOT NULL
	BEGIN
		DROP TABLE #solicitudes
	END

	SELECT DISTINCT CAST(NULL AS INT) AS id
		,keySolicitud
		,nombreSerie
		,documento
		,ordenCompra
		,codigoEmpresa
		,idTiposSolicitud
		,idTipoServicio
		,terceroCodigoSap
		,terceroNit
		,terceroRazonSocial
		,nombreGrupo
		,nombreDireccion
		,codigoDane
		,direccion
		,idOoperadorLogistico
		,feMi
		,feMa
		,hoMi
		,hoMa
		,generarListaDocumentosDigitales
		,STATUS
		,a.DocTotal
		,existe
		,dateMigradoSap
		,SlpName
		,a.comments
	INTO #solicitudes
	FROM #ordenesBase a

	IF OBJECT_ID('tempdb..#ordenes_multiples') IS NOT NULL
	BEGIN
		DROP TABLE #ordenes_multiples
	END

	SELECT (
			SELECT *
			FROM #id
			) AS idSolicitud
		,'SAP_BDI' AS Integracion
		,keySolicitud AS idExterno
		,205 AS idCausal
		,keySolicitud
		,documento
		,COUNT(*) AS duplicado
		,terceroNit
		,terceroRazonSocial
		,GETDATE() AS fechaCreacion
		,GETDATE() AS fechaModificacion
	INTO #ordenes_multiples
	FROM #solicitudes
	GROUP BY keySolicitud
		,documento
		,terceroNit
		,terceroRazonSocial
	HAVING COUNT(*) > 1

	IF OBJECT_ID('tempdb..#ordenesBaseDespacho') IS NOT NULL
	BEGIN
		DROP TABLE #ordenesBaseDespacho
	END

	SELECT CAST(a.DocNum AS NVARCHAR(50)) AS keyOrden
		,a.keySolicitud
		,CAST(a.objType AS NVARCHAR(50)) AS objType
		,a.docEntry
		,CAST(a.series AS INT) AS series
		,a.nombreSerie AS seriesName
		,CAST(a.documento AS NVARCHAR(20)) AS DocNum
		,CAST(a.noPedidoExterno AS NVARCHAR(100)) AS noPedidoExterno
		,a.comments
		,a.DocDate
		,a.CreateDate
		,CAST(a.observRegreso AS NVARCHAR(200)) AS observRegreso
		,a.existe
		,a.TotalOrdenDespacho
		,a.cedi
	INTO #ordenesBaseDespacho
	FROM #ordenesBase a

	-- LIMPIAR ORDENES REPETIDAS
	DELETE a
	FROM #solicitudes a
	INNER JOIN #ordenes_multiples b
		ON b.keySolicitud = a.keySolicitud

	IF OBJECT_ID('tempdb..#lineas') IS NOT NULL
	BEGIN
		DROP TABLE #lineas
	END

	SELECT a.keySolicitud
		,ROW_NUMBER() OVER (
			PARTITION BY a.keySolicitud ORDER BY a.keySolicitud
			) - 1 AS LineNum
		,0 AS subLineNum
		,CAST(b.ItemCode AS NVARCHAR(10)) AS ItemCode
		,CAST(b.dscription AS NVARCHAR(200)) AS descripcion
		,CAST(b.quantity AS INT) AS cantidad
		,CAST(NULL AS INT) AS cantidadAsignada
		,CAST(NULL AS INT) AS cantidadNoAsignada
		,b.whsCode AS almacen
		,b.almacenDestino
		,CAST(b.predistribucion AS NVARCHAR(200)) AS predistribucion
		,b.precio AS precioEmpresa
		,b.precioSinDescuento
		,b.precioCliente
		,b.icoGws AS icoEmpresa
		,b.icoCliente
		,b.descuento
		,keyOrden
		,CAST(lineNum AS VARCHAR(100)) AS keyLineNum
		,b.Project AS proyecto
		,b.U_GW_Salida
		,b.impuesto
	INTO #lineas
	FROM #ordenesBaseDespacho a
	CROSS APPLY dbo.ft_SolicitudesDespachoLIneas(a.docEntry, a.objType) b
	WHERE a.existe = 0

	DECLARE @t AS TABLE (
		keySolicitud NVARCHAR(50)
		,id INT
		)

	BEGIN TRANSACTION

	INSERT INTO dbo.Solicitudes (
		keySolicitud
		,nombreSerie
		,documento
		,ordenCompra
		,codigoEmpresa
		,idTiposSolicitud
		,idTipoServicio
		,codigoDane
		,direccion
		,terceroCodigoSap
		,terceroNit
		,terceroRazonSocial
		,nombreGrupo
		,nombreDireccion
		,idOoperadorLogistico
		,feMi
		,feMa
		,hoMi
		,hoMa
		,generarListaDocumentosDigitales
		,[status]
		,valorTotal
		,dateMigradoSap
		,icoPrecio
		,ejecutivo
		,actualizar
		,comentarios
		,actDias
		,reprocesar
		)
	OUTPUT inserted.keySolicitud
		,inserted.id
	INTO @t(keySolicitud, Id)
	SELECT --top 1
		keySolicitud
		,nombreSerie
		,documento
		,ordenCompra
		,codigoEmpresa
		,idTiposSolicitud
		,idTipoServicio
		,codigoDane
		,direccion
		,terceroCodigoSap
		,terceroNit
		,terceroRazonSocial
		,nombreGrupo
		,nombreDireccion
		,idOoperadorLogistico
		,feMi
		,feMa
		,hoMi
		,hoMa
		,generarListaDocumentosDigitales
		,[status]
		,a.DocTotal
		,dateMigradoSap
		,0
		,SlpName
		,1
		,a.comments
		,0
		,0
	FROM #solicitudes a
	WHERE a.existe = 0

	--commit tran rollback
	UPDATE #solicitudes
	SET #solicitudes.id = b.id
	FROM #solicitudes
	INNER JOIN @t b
		ON b.keySolicitud = #solicitudes.keySolicitud

	INSERT INTO dbo.OrdenesDespacho (
		idSolicitud
		,keyOrden
		,keySolicitud
		,objType
		,docEntry
		,series
		,seriesName
		,docNum
		,noPedidoExterno
		,comments
		,docDate
		,createDate
		,observRegreso
		,valorTotal
		,cedi
		)
	SELECT a.id AS idSolicitud
		,keyOrden
		,b.keySolicitud
		,b.objType
		,b.docEntry
		,b.series
		,b.seriesName
		,b.DocNum
		,b.noPedidoExterno
		,b.comments
		,b.DocDate
		,b.CreateDate
		,b.observRegreso
		,b.TotalOrdenDespacho
		,b.cedi
	FROM #solicitudes a
	INNER JOIN #ordenesBaseDespacho b
		ON a.keySolicitud = b.keySolicitud
	WHERE a.existe = 0

	INSERT INTO dbo.SolicitudesLineas (
		idSolicitud
		,keySolicitud
		,lineNum
		,subLineNum
		,itemCode
		,descripcion
		,cantidad
		,cantidadAsignada
		,cantidadNoAsignada
		,almacen
		,almacenDestino
		,predistribucion
		,precioEmpresa
		,precioCliente
		,precioSinDescuento
		,icoEmpresa
		,icoCliente
		,valorDeSap
		,descuento
		,keyOrden
		,keyLineNum
		,proyecto
		,codSalida
		,actualizar
		,impuesto
		)
	SELECT a.id AS idSolicitud
		,b.keySolicitud
		,b.LineNum
		,b.subLineNum
		,b.ItemCode
		,b.descripcion
		,b.cantidad
		,b.cantidadAsignada
		,b.cantidadNoAsignada
		,b.almacen
		,b.almacenDestino
		,b.predistribucion
		,b.precioEmpresa
		,b.precioCliente
		,b.precioSinDescuento
		,b.icoEmpresa
		,b.icoCliente
		,b.precioEmpresa AS valorDeSap
		,b.descuento
		,b.keyOrden
		,b.keyLineNum
		,b.proyecto
		,b.U_GW_Salida
		,1
		,b.impuesto
	FROM #solicitudes a
	INNER JOIN #lineas b
		ON a.keySolicitud = b.keySolicitud

	IF NOT EXISTS (
			SELECT 1
			FROM SolicitudesErrores a
			INNER JOIN #errores_direcciones_multiples b
				ON a.arg0 = b.arg0
			)
	BEGIN
		INSERT INTO SolicitudesErrores (
			idSolicitud
			,integracion
			,idExterno
			,idCausal
			,arg0
			,arg1
			,arg2
			,fechaCreacion
			,fechaModificacion
			)
		SELECT a.idSolicitud
			,a.integracion
			,idExterno
			,a.idCausal
			,a.arg0
			,a.arg1
			,a.arg2
			,a.fechaCreacion
			,a.fechaModificacion
		FROM #errores_direcciones_multiples a
	END

	IF NOT EXISTS (
			SELECT 1
			FROM SolicitudesErrores a
			INNER JOIN #ordenes_multiples b
				ON a.arg0 = b.documento
			)
	BEGIN
		INSERT INTO SolicitudesErrores (
			idSolicitud
			,integracion
			,idExterno
			,idCausal
			,arg0
			,arg1
			,arg2
			,fechaCreacion
			,fechaModificacion
			)
		SELECT idSolicitud
			,Integracion
			,idExterno
			,idCausal
			,documento AS arg0
			,terceroNit AS arg1
			,terceroRazonSocial AS arg2
			,fechaCreacion
			,fechaModificacion
		FROM #ordenes_multiples
	END

	--ACTUALIZA CAUSALES EN LOS PEDIDOS DE SAP
	UPDATE b
	SET b.U_CausalNod = a.U_CausalNod
	FROM actualizarCausalSap a
	INNER JOIN globalwine.dbo.RDR1 b
		ON a.DocEntry = b.DocEntry
			AND a.LineNum = b.Linenum
	INNER JOIN #integraciones c
		ON a.DocDate >= c.fechaUltimaConsulta

	UPDATE a
	SET a.fechaUltimaConsulta = @fechaProximaConsulta
	FROM Integraciones a
	WHERE codigoIntegracion = 'DESPACHOS'

	COMMIT TRANSACTION
END TRY

BEGIN CATCH
	IF (@@TRANCOUNT > 0)
	BEGIN
		ROLLBACK TRANSACTION
	END;

	THROW
END CATCH
