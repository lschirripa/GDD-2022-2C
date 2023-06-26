--1. Mostrar el código, razón social de todos los clientes cuyo límite de crédito sea mayor o
--igual a $ 1000 ordenado por código de cliente.

SELECT C.clie_codigo , c.clie_razon_social FROM CLIENTE C
where c.clie_limite_credito >= 1000
ORDER BY c.clie_codigo ASC

-- 2. Mostrar el código, detalle de todos los artículos vendidos en el año 2012 ordenados por
-- cantidad vendida.

SELECT P.prod_codigo, p.prod_detalle, SUM(iff.item_cantidad) AS cant_total_vendida FROM Producto P
JOIN Item_Factura IFF ON iff.item_producto = p.prod_codigo
JOIN Factura F ON f.fact_numero+f.fact_sucursal+f.fact_tipo = iff.item_numero+iff.item_sucursal+iff.item_tipo
WHERE YEAR(F.fact_fecha) = 2012
group by prod_codigo, p.prod_detalle
order by cant_total_vendida DESC

-- 3. Realizar una consulta que muestre código de producto, nombre de producto y el stock
-- total, sin importar en que deposito se encuentre, los datos deben ser ordenados por
-- nombre del artículo de menor a mayor.

SELECT P.prod_codigo, p.prod_detalle, sum(s.stoc_cantidad) AS stoc_total FROM PRODUCTO P
JOIN STOCK S ON s.stoc_producto = p.prod_codigo
GROUP BY P.prod_codigo, p.prod_detalle
ORDER BY prod_detalle ASC

-- 4. Realizar una consulta que muestre para todos los artículos código, detalle y cantidad de
-- artículos que lo componen. Mostrar solo aquellos artículos para los cuales el stock
-- promedio por depósito sea mayor a 100.

SELECT P.prod_codigo,P.prod_detalle,COUNT(c.comp_componente) AS cant_componentes FROM Producto P
LEFT JOIN Composicion C on c.comp_producto=p.prod_codigo
GROUP BY P.prod_detalle, P.prod_codigo
HAVING P.prod_codigo IN (
    SELECT S.stoc_producto
    FROM STOCK S
    GROUP BY S.stoc_producto
    HAVING AVG(S.stoc_cantidad) > 100
    )
ORDER BY cant_componentes DESC


-- 5. Realizar una consulta que muestre código de artículo, detalle y cantidad de egresos de
-- stock que se realizaron para ese artículo en el año 2012 (egresan los productos que
-- fueron vendidos). Mostrar solo aquellos que hayan tenido más egresos que en el 2011.

SELECT iff.item_producto,p.prod_detalle, COUNT(iff.item_producto) AS stoc_vendido_2012 FROM Item_Factura iff
JOIN PRODUCTO P on p.prod_codigo = iff.item_producto
JOIN Factura F ON f.fact_numero+f.fact_sucursal+f.fact_tipo = iff.item_numero+iff.item_sucursal+iff.item_tipo
WHERE YEAR(F.fact_fecha) = 2012
GROUP BY iff.item_producto, p.prod_detalle, p.prod_codigo
HAVING iff.item_producto IN (
    SELECT IFF2.item_producto FROM Item_Factura IFF2
    JOIN Factura F2 ON f2.fact_numero+f2.fact_sucursal+f2.fact_tipo = iff2.item_numero+iff2.item_sucursal+iff2.item_tipo
    WHERE YEAR(f2.fact_fecha) = 2011
    GROUP BY iff2.item_producto
    HAVING SUM(IFF2.item_cantidad) < SUM(IFF.item_cantidad)
)
-- HAVING sum(IFF.item_cantidad) >
--     (
--     SELECT
--         sum(IFF2.item_cantidad) as cantidad_vendida
--     FROM PRODUCTO P2
--         JOIN Item_Factura iff2 on iff2.item_producto = p2.prod_codigo
--         JOIN FACTURA F2 ON f2.fact_numero+f2.fact_sucursal+f2.fact_tipo = iff2.item_numero+iff2.item_sucursal+iff2.item_tipo
--     WHERE YEAR(f2.fact_fecha) = 2011 AND P2.prod_codigo = P.prod_codigo
--     GROUP BY P2.prod_codigo, P2.prod_detalle
--     )
ORDER BY iff.item_producto

-- 6. Mostrar para todos los rubros de artículos código, detalle, cantidad de artículos de ese
-- rubro y stock total de ese rubro de artículos. Solo tener en cuenta aquellos artículos que
-- tengan un stock mayor al del artículo ‘00000000’ en el depósito ‘00’.

SELECT R.rubr_id, R.rubr_detalle, COUNT(DISTINCT P.prod_codigo) as [Cantidad de Articulos], SUM(S.stoc_cantidad) AS [Stock Total]
FROM Producto P
	INNER JOIN RUBRO R
		ON R.rubr_id = P.prod_rubro
	INNER JOIN STOCK S
		ON S.stoc_producto = P.prod_codigo
	INNER JOIN DEPOSITO D
		ON D.depo_codigo = S.stoc_deposito
WHERE S.stoc_cantidad > (
		SELECT stoc_cantidad
		FROM STOCK
		WHERE stoc_producto = '00000000'
			AND stoc_deposito = '00'
		)
GROUP BY R.rubr_id,R.rubr_detalle
ORDER BY 1

-- 6. Mostrar para todos los rubros de artículos código, detalle, cantidad de artículos de ese
-- rubro y stock total de ese rubro de artículos. Solo tener en cuenta aquellos artículos que
-- tengan un stock mayor al del artículo ‘00000000’ en el depósito ‘00’.

SELECT R.rubr_id, R.rubr_detalle, COUNT(distinct P.prod_codigo) AS cant_articulos, SUM(s.stoc_cantidad) AS stock_total FROM PRODUCTO P
    JOIN STOCK S ON S.stoc_producto = P.prod_codigo
    JOIN RUBRO R ON R.rubr_id = P.prod_rubro
WHERE p.prod_codigo IN (
    SELECT P2.prod_codigo FROM Producto P2
    JOIN STOCK S2 ON S2.stoc_producto = P2.prod_codigo
    WHERE S2.stoc_cantidad > (SELECT S3.stoc_cantidad FROM STOCK S3 WHERE S3.stoc_producto = '00000000' AND S3.stoc_deposito = '00')
)
GROUP BY R.rubr_id, R.rubr_detalle
ORDER BY r.rubr_detalle


-- 7. Generar una consulta que muestre para cada artículo código, detalle, mayor precio
-- menor precio y % de la diferencia de precios (respecto del menor Ej.: menor precio =
-- 10, mayor precio =12 => mostrar 20 %). Mostrar solo aquellos artículos que posean
-- stock.

-- SELECT
--     P.prod_codigo,
--     P.prod_detalle,
--     (SELECT TOP 1 IFF.item_precio FROM Item_Factura IFF WHERE IFF.item_producto = P.prod_codigo ORDER BY IFF.item_precio ASC) menor_precio,
--     (SELECT TOP 1 IFF.item_precio FROM Item_Factura IFF WHERE IFF.item_producto = P.prod_codigo ORDER BY IFF.item_precio DESC) AS mayor_precio,
--     CAST((((SELECT TOP 1 IFF.item_precio FROM Item_Factura IFF WHERE IFF.item_producto = P.prod_codigo ORDER BY IFF.item_precio DESC) - (SELECT TOP 1 IFF.item_precio FROM Item_Factura IFF WHERE IFF.item_producto = P.prod_codigo ORDER BY IFF.item_precio ASC) ) * 100 / (SELECT TOP 1 IFF.item_precio FROM Item_Factura IFF WHERE IFF.item_producto = P.prod_codigo ORDER BY IFF.item_precio ASC)) AS INT) AS '%VARIACION'


-- FROM Producto P
-- WHERE P.prod_codigo IN (
--     SELECT DISTINCT(s.stoc_producto) FROM STOCK S
--     WHERE S.stoc_cantidad > 0
-- )
-- ORDER BY P.prod_detalle

SELECT
    P.prod_codigo,
    P.prod_detalle,
    MIN(IFF.item_precio) AS precio_min,
    MAX(IFF.item_precio) AS precio_max,
    CAST(((MAX(IFF.item_precio) - MIN(IFF.item_precio) ) * 100 / MIN(IFF.item_precio))AS INT) AS '%VAR'
FROM PRODUCTO P
JOIN Item_Factura IFF ON P.prod_codigo = IFF.item_producto
WHERE P.prod_codigo IN (
    SELECT DISTINCT(s.stoc_producto) FROM STOCK S
    GROUP BY S.stoc_producto
    HAVING SUM(S.stoc_cantidad) > 0
)
GROUP BY P.prod_codigo, P.prod_detalle

