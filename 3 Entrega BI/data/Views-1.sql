--Las ganancias mensuales de cada canal de venta.
--Se entiende por ganancias al total de las ventas, menos el total de las
--compras, menos los costos de transacción totales aplicados asociados los
--medios de pagos utilizados en las mismas.

ALTER VIEW vw_ganancias_mensuales_canal_venta (CANAL_VENTA, ANIOMES ,GANANCIA_MENSUAL_TOTAL)
AS

SELECT
	CANAL_VENTA_ID,
	convert(varchar(7), VENTA_FECHA, 126) AS ANIOMES,
	SUM(VENTA_TOTAL - COMPRA_TOTAL - MEDIO_PAGO_COSTO) AS GANANCIA_MENSUAL_TOTAL

FROM [sale_worson].canal_venta
JOIN [sale_worson].venta ON VENTA_CANAL = CANAL_VENTA_ID
JOIN [sale_worson].medio_pago ON VENTA_MEDIO_PAGO = MEDIO_PAGO_ID
JOIN [sale_worson].venta_detalle ON VENTA_CODIGO = VD_VENTA
JOIN [sale_worson].producto_variante ON VD_PV = PV_CODIGO
JOIN [sale_worson].compra_detalle ON PV_CODIGO = CD_PV
JOIN [sale_worson].compra ON CD_COMPRA = COMPRA_NUMERO

GROUP BY convert(varchar(7), VENTA_FECHA, 126), CANAL_VENTA_ID


-- SELECT SUM(ISNULL(M.VENTA_TOTAL,0) - ISNULL(M.COMPRA_TOTAL,0) - ISNULL(M.VENTA_MEDIO_PAGO_COSTO,0)) AS total FROM [gd_esquema].[Maestra] M
-- WHERE convert(varchar(7), M.COMPRA_FECHA, 126) = convert(varchar(7), M.VENTA_FECHA, 126)
-- GROUP BY M.VENTA_CANAL, convert(varchar(7), M.VENTA_FECHA, 126)
