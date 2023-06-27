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


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- realizar una consulta sql que retorne para TODOS los productos 
-- COD_PRODUCTO
-- RUBRO_PRODUCTO
-- CANT_ COMPONENTES QUE TIENE
-- CANT FACTURAS DE SUS COMPONENTES SI TIENE
-- QUE FUERON VENDIDOS

SELECT
    P.prod_codigo,
    r.rubr_detalle,
    count(C.comp_componente) AS cant_componentes,
    (
        SELECT 
            COUNT(1)
        FROM Item_Factura IFF
        JOIN Factura F ON f.fact_numero+f.fact_sucursal+f.fact_tipo = iff.item_numero+iff.item_sucursal+iff.item_tipo
        WHERE IFF.item_producto =  C.comp_componente
    )
FROM PRODUCTO P
JOIN RUBRO R ON R.rubr_id = P.prod_rubro
JOIN Composicion C ON C.comp_producto = P.prod_codigo
GROUP BY p.prod_codigo, r.rubr_detalle, C.comp_componente

-- select * from Composicion

-- SELECT 
--     COUNT(1)
-- FROM Item_Factura IFF
-- JOIN Factura F ON f.fact_numero+f.fact_sucursal+f.fact_tipo = iff.item_numero+iff.item_sucursal+iff.item_tipo
-- WHERE IFF.item_producto = '00001420'

-- realizar una consulta sql que retorne para TODOS los productos 
-- COD_PRODUCTO
-- RUBRO_PRODUCTO
-- CANT_ COMPONENTES QUE TIENE
-- CANT FACTURAS DE SUS COMPONENTES SI TIENE
-- QUE FUERON VENDIDOS

--- no esta mal approach pero diferente vista a lo que me pide

SELECT
    P.prod_codigo,
    P.prod_rubro,
    sum(distinct C.comp_cantidad) as 'cant_componentes',
    C.comp_componente

        , (select count(F2.fact_numero)
    FROM Factura F2
        JOIN Item_Factura iff2 on F2.fact_numero = iff2.item_numero and iff2.item_sucursal = f2.fact_sucursal and iff2.item_tipo = f2.fact_tipo
    WHERE iff2.item_producto = C.comp_componente
        ) AS 'cantidad de veces vendido'

FROM Producto P
    JOIN Item_Factura iff on iff.item_producto = P.prod_codigo
    JOIN Factura F on iff.item_numero = F.fact_numero and iff.item_sucursal = f.fact_sucursal and iff.item_tipo = f.fact_tipo
    LEFT JOIN Composicion C on C.comp_producto = P.prod_codigo
GROUP BY P.prod_codigo, P.prod_rubro, C.comp_componente, c.comp_cantidad
HAVING count(distinct C.comp_componente) > 0

-- realizar una consulta sql que retorne para TODOS los productos 
-- COD_PRODUCTO
-- RUBRO_PRODUCTO
-- CANT_ COMPONENTES QUE TIENE
-- CANT FACTURAS DE SUS COMPONENTES SI TIENE
-- QUE FUERON VENDIDOS


SELECT
    prod_codigo,
    prod_rubro,
    ISNULL(sum(comp_cantidad),0) as Cantidad_de_componentes,

    ISNULL(
        ( SELECT COUNT(*) FROM Item_factura
        WHERE item_producto IN (SELECT comp_componente
        FROM Composicion
        WHERE comp_producto = prod_codigo)
        ),0) AS cantidad_facturas_de_componentes

    FROM Composicion
    
    RIGHT JOIN Producto ON comp_producto = prod_codigo
    GROUP BY prod_codigo, prod_rubro
    HAVING         ( SELECT COUNT(*) FROM Item_factura
        WHERE item_producto IN (SELECT comp_componente
        FROM Composicion
        WHERE comp_producto = prod_codigo)
        ) > 0

    ORDER BY cantidad_facturas_de_componentes DESC

------casi igual approach diferencias boludas-----------

SELECT
    P.prod_codigo,
    P.prod_rubro,
    sum(C.comp_cantidad) AS cant_componentes,
(
    SELECT 
    COUNT(*)
    FROM Item_Factura IFF
    WHERE Iff.item_producto IN 
        (
        SELECT 
            comp_componente 
        FROM Composicion
        WHERE comp_producto = p.prod_codigo
        ) 
) AS cant_veces_vendidas_de_sus_componentes
FROM PRODUCTO P
JOIN Composicion C ON C.comp_producto = P.prod_codigo
GROUP BY P.prod_codigo, P.prod_rubro




------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Armar una consulta SQL que muestre aquel/aquellos clientes que en 2 años consecutivos (de existir),
--  fueron los mejores compradores, es decir, los que en monto total facturado anual fue el máximo.De esos clientes mostrar , 
--  razón social, domicilio, cantidad de unidades compradas.Nota: No se puede usar select en el from

SELECT
    C.clie_razon_social,
    C.clie_domicilio,
    SUM(F.fact_total) as total,
    (
        SELECT SUM(iff2.item_cantidad) FROM Item_Factura IFF2
        JOIN Factura F2 on F2.fact_numero = iff2.item_numero and iff2.item_sucursal = f2.fact_sucursal and iff2.item_tipo = f2.fact_tipo
        WHERE f2.fact_cliente = f.fact_cliente
        AND
        YEAR(f2.fact_fecha) = YEAR(f.fact_fecha) OR YEAR(f2.fact_fecha) = YEAR(f.fact_fecha)+1


    ) AS cant_unidades_compradas

FROM FACTURA F
JOIN CLIENTE C ON C.clie_codigo = F.fact_cliente
GROUP BY C.clie_razon_social, C.clie_domicilio, YEAR(f.fact_fecha), C.clie_codigo,f.fact_cliente
HAVING 
C.clie_codigo = (
    SELECT TOP 1
        f2.fact_cliente
    FROM FACTURA F2
    WHERE YEAR(F2.fact_fecha) = YEAR(F.fact_fecha)
    GROUP BY F2.fact_cliente
    ORDER BY SUM(F2.fact_total) DESC
)
AND
C.clie_codigo = (
    SELECT TOP 1
        f2.fact_cliente
    FROM FACTURA F2
    WHERE YEAR(F2.fact_fecha) = YEAR(F.fact_fecha)+1
    GROUP BY F2.fact_cliente
    ORDER BY SUM(F2.fact_total) DESC
)
ORDER BY total DESC

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Realizar una consulta SQL que devuelva los clientes que NO tuvieron la facturacion maxima y la facturacion minima en el 2012.
-- de estos clientes mostrar:
-- el NUM DE ORDEN: asignando 1 al cliente de mayor venta y N al de menor venta. Entiendase el N como el num correspondiente al que menos vendio en el 
-- 2012. Entiendase venta como total facturado

-- El codigo del cliente
-- El monto total comprado en el 2012
-- La cant de unidades de productos compradas en el 2012
-- NOTA: no se permiten select en el from etc etc

SELECT
    ROW_NUMBER() OVER (ORDER BY SUM(F.fact_total) DESC) AS num_orden,
    F.fact_cliente,
    SUM(F.fact_total) as total_facturado,
    SUM(Iff.item_cantidad) as cant_productos_comprados
FROM FACTURA F
JOIN Item_Factura iff ON iff.item_sucursal+iff.item_numero+iff.item_tipo = f.fact_sucursal+f.fact_numero+f.fact_tipo
WHERE YEAR(F.fact_fecha) = 2012
GROUP BY F.fact_cliente
HAVING
F.fact_cliente NOT IN
(
    (
    SELECT TOP 1
        f2.fact_cliente
    FROM FACTURA F2
    WHERE YEAR(F2.fact_fecha) = 2012
    GROUP BY F2.fact_cliente
    ORDER BY SUM(F2.fact_total) DESC
    )
)
AND
F.fact_cliente NOT IN 
(
    (
    SELECT TOP 1
        f2.fact_cliente
    FROM FACTURA F2
    WHERE YEAR(F2.fact_fecha) = 2012
    GROUP BY F2.fact_cliente
    ORDER BY SUM(F2.fact_total) ASC
    )
)
order by SUM(F.fact_total) DESC




--------hermoso uso del rownumber partition by order by--------------------------------------------------------------------------------------------------------
SELECT
    ROW_NUMBER() OVER (PARTITION BY F.fact_vendedor ORDER BY SUM(F.fact_total) DESC) AS num_orden,
    F.fact_cliente,
    SUM(F.fact_total) as total_facturado,
    SUM(Iff.item_cantidad) as cant_productos_comprados,
    F.fact_vendedor
FROM FACTURA F
JOIN Item_Factura iff ON iff.item_sucursal+iff.item_numero+iff.item_tipo = f.fact_sucursal+f.fact_numero+f.fact_tipo
WHERE YEAR(F.fact_fecha) = 2012
GROUP BY F.fact_cliente, F.fact_vendedor
HAVING
F.fact_cliente NOT IN
(
    (
    SELECT TOP 1
        f2.fact_cliente
    FROM FACTURA F2
    WHERE YEAR(F2.fact_fecha) = 2012
    GROUP BY F2.fact_cliente
    ORDER BY SUM(F2.fact_total) DESC
    )
)
AND
F.fact_cliente NOT IN 
(
    (
    SELECT TOP 1
        f2.fact_cliente
    FROM FACTURA F2
    WHERE YEAR(F2.fact_fecha) = 2012
    GROUP BY F2.fact_cliente
    ORDER BY SUM(F2.fact_total) ASC
    )
)
-- order by SUM(F.fact_total) DESC
