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



--------------------------------------------------------------------------------------------------------EJ 1ER PARCIAL 2022--------------------------------------------------------------------------------------------------------

/*
1. Realizar una consulta SQL q permita saber si un cliente compro un producto en todos los meses de 2012

mostrar para el 2012:
	1- el cliente
	2- la razon social del cliente
	3- el producto comprado
	4- el nombre del producto
	5- cantidad de productos distintos comprados por el cliente
	6- cantidad de productos con composicion comprados por el cliente

El resultado debe ser ordenado poniendo primero aquellos clientes q compraron mas de 10 productos distintos en 2012.
*/


SELECT 
    F.fact_cliente AS COD_Cliente,
    C.clie_razon_social,
    iff.item_producto,
    P.prod_detalle,
(
SELECT
    COUNT(distinct iff2.item_producto)
FROM Item_Factura IFF2
JOIN FACTURA F2 ON f2.fact_numero+f2.fact_sucursal+f2.fact_tipo = iff2.item_numero+iff2.item_sucursal+iff2.item_tipo
WHERE 
    YEAR(F2.fact_fecha) = 2012 
    AND 
    F2.fact_cliente = f.fact_cliente
) as cant_distintos_productos_comprados_2012,

(
SELECT
    count(distinct iff2.item_producto)
FROM Item_Factura IFF2
JOIN FACTURA F2 ON f2.fact_numero+f2.fact_sucursal+f2.fact_tipo = iff2.item_numero+iff2.item_sucursal+iff2.item_tipo
JOIN Composicion c on c.comp_producto = iff2.item_producto
WHERE 
    YEAR(F2.fact_fecha) = 2012 
    AND 
    F2.fact_cliente = f.fact_cliente 
) AS cant_productos_con_composicion_comprados 
FROM Factura F

JOIN Item_Factura IFF ON f.fact_numero+f.fact_sucursal+f.fact_tipo = iff.item_numero+iff.item_sucursal+iff.item_tipo
JOIN Producto P ON P.prod_codigo = IFF.item_producto
JOIN Cliente C ON C.clie_codigo = F.fact_cliente

WHERE YEAR(F.fact_fecha) = 2012
GROUP BY F.fact_cliente,C.clie_razon_social,iff.item_producto, P.prod_detalle
HAVING COUNT(DISTINCT MONTH(F.fact_fecha)) > 6

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- REALIZAR una consulta SQL que retorne para todas las zonas que tengan 3 (tres) o mas depositos 

-- - detalle zona
-- - cantidad de depositos x zona
-- - cant de productos distintos compuestos en sus depositos
-- - producto mas vendido en el anio 2012 q tenga stock en al menos uno de sus depositos
-- - mejor encargado perteneciente a esa zona ( el q mas vendio en la historia )

-- el resultado deberea ser ordenado x monto total vendido del encargado descendiente 

-- NOTA: NO Subselects en el from ni funciones definidas para el usuario

SELECT
    z.zona_detalle,
        ISNULL((
        SELECT
            COUNT(D2.depo_codigo)
        FROM DEPOSITO D2
        WHERE D2.depo_zona = Z.zona_codigo 
        HAVING count(d2.depo_codigo) >= 3

        ),0) cant_depos_por_zona,
    
    (
        SELECT 
            COUNT(DISTINCT C2.comp_producto)
        FROM STOCK S2
        JOIN DEPOSITO D2 ON D2.depo_codigo = S2.stoc_deposito
        JOIN Composicion C2 ON C2.comp_producto = S2.stoc_producto
        WHERE D2.depo_zona = Z.zona_codigo
    ) AS 'cant de productos distintos compuestos en sus depositos'

    ,(
    SELECT 
        TOP 1
        iff2.item_producto
    FROM Item_Factura IFF2
    JOIN Factura F2 ON f2.fact_numero+f2.fact_sucursal+f2.fact_tipo = iff2.item_numero+iff2.item_sucursal+iff2.item_tipo
    JOIN STOCK S2 ON S2.stoc_producto = IFF2.item_producto
    JOIN DEPOSITO D2 ON D2.depo_codigo = s2.stoc_deposito
    WHERE YEAR(F2.fact_fecha) = 2012 AND D2.depo_zona = Z.zona_codigo
    group by (iff2.item_producto)
    ORDER BY SUM(iff2.item_cantidad)DESC

    ) AS 'producto mas vendido en el anio 2012 q tenga stock en al menos uno de sus depositos'

-- ,(
--     SELECT TOP 1
--         F2.fact_vendedor
--     FROM FACTURA F2
--     JOIN EMPLEADO E2 ON F2.fact_vendedor = E2.empl_codigo
--     JOIN DEPARTAMENTO D2 ON E2.empl_departamento = D2.depa_codigo
--     WHERE D2.depa_zona = Z.zona_codigo
--     GROUP BY F2.fact_vendedor
--     ORDER BY SUM(F2.fact_total) DESC
-- ) AS 'mejor encargado perteneciente a esa zona',

,(
    SELECT TOP 1 fact_vendedor
    FROM Factura 
    WHERE fact_vendedor IN (SELECT depo_encargado FROM DEPOSITO WHERE depo_zona = zona_codigo)
    GROUP BY fact_vendedor
    ORDER BY SUM(fact_total) DESC
) AS MejorEncargadoZona
            

FROM ZONA Z
JOIN DEPOSITO D ON D.depo_zona = Z.zona_codigo
GROUP BY z.zona_detalle, z.zona_codigo
ORDER BY 


-- el resultado deberea ser ordenado x monto total vendido del encargado descendiente 


-- MINI CALCS
                -- - producto mas vendido en el anio 2012 q tenga stock en al menos uno de sus depositos
                    SELECT 
                        TOP 1
                        iff.item_producto
                    FROM Item_Factura IFF
                    JOIN Factura F ON f.fact_numero+f.fact_sucursal+f.fact_tipo = iff.item_numero+iff.item_sucursal+iff.item_tipo
                    JOIN STOCK S ON S.stoc_producto = IFF.item_producto
                    WHERE YEAR(F.fact_fecha) = 2012 AND S.stoc_deposito = '00'
                    group by (iff.item_producto)
                    ORDER BY SUM(iff.item_cantidad)DESC

                    -- mejor encargado perteneciente a esa zona ( el q mas vendio en la historia )
                    SELECT TOP 10
                        F2.fact_vendedor
                    FROM FACTURA F2
                    JOIN EMPLEADO E2 ON F2.fact_vendedor = E2.empl_codigo
                    JOIN DEPARTAMENTO D2 ON E2.empl_departamento = D2.depa_codigo
                    WHERE D2.depa_zona = '004'
                    GROUP BY F2.fact_vendedor
                    ORDER BY SUM(F2.fact_total) DESC


------------------------ OTRO APPROACH Q QUEDO EN LA NADA, pero se podria seguir craneando creo
SELECT
    z.zona_detalle,
    count(d.depo_codigo) AS cant_depos_por_zona
-- ,(
-- SELECT
--     COUNT(DISTINCT S2.stoc_producto)
-- FROM STOCK S2
-- JOIN DEPOSITO D2 ON D2.depo_codigo  = S2.stoc_deposito
-- JOIN Composicion C2 ON C2.comp_producto = S2.stoc_producto
-- WHERE D2.depo_codigo = D.depo_codigo
-- ) AS cant_productos_distintos_compuestos_en_depo
FROM ZONA Z
JOIN DEPOSITO D ON D.depo_zona = Z.zona_codigo
GROUP BY z.zona_detalle, z.zona_codigo
HAVING count(d.depo_codigo) >= 3


-- PARCIAL GDD 1/7/2023

-- 1. realizar una consulta SQL que muestre aquellos clientes que en 2 anios consecutivos compraron.
-- De estos clientes mostrar:
-- 1. el cod cliente
-- 2. el nombre del cliente
-- 3. El num de rubros que compro el cliente
-- 4. la cant de productos con composicion que compro el cliente en 2012

-- el resultado debera ser ordenado por cantidad de facturas del cliente en toda la historia de manera ascendente

SELECT
    F.fact_cliente, C.clie_razon_social, count(distinct r.rubr_detalle) AS num_rubros_cliente_compro
    ,(
        SELECT COUNT(1)
        FROM Composicion CO2
        JOIN Producto P2 ON P2.prod_codigo = CO2.comp_producto
        JOIN ITEM_FACTURA IFF2 ON P2.prod_codigo = IFF2.item_producto
        JOIN FACTURA F2 ON f2.fact_numero+f2.fact_sucursal+f2.fact_tipo = iff2.item_numero+iff2.item_sucursal+iff2.item_tipo
        WHERE YEAR(F2.fact_fecha) = 2012 AND F2.fact_cliente = F.fact_cliente

    ) AS 'cant de productos con composicion que compro el cliente en 2012'
FROM FACTURA F
JOIN ITEM_FACTURA IFF ON f.fact_numero+f.fact_sucursal+f.fact_tipo = iff.item_numero+iff.item_sucursal+iff.item_tipo
JOIN Producto P ON P.prod_codigo = IFF.item_producto
JOIN Rubro R ON R.rubr_id = P.prod_rubro
JOIN CLIENTE C ON C.clie_codigo = F.fact_cliente
WHERE F.fact_cliente IN
(
    SELECT
    F2.fact_cliente
    FROM Factura F2
    WHERE YEAR(F2.fact_fecha) = YEAR(f.fact_fecha)-1 OR YEAR(F2.fact_fecha) = YEAR(F2.fact_fecha)+1
)
GROUP by F.fact_cliente, C.clie_razon_social
ORDER BY (
    SELECT
        COUNT(F2.fact_cliente)
    FROM Factura F2
    WHERE F2.fact_cliente = F.fact_cliente
    GROUP BY F2.fact_cliente
) ASC


SELECT clie_codigo, clie_razon_social,
 (SELECT COUNT(p1.prod_rubro) from Producto p1
join Item_Factura if2 on if2.item_producto = p1.prod_rubro
join Factura f2 on f2.fact_tipo+f2.fact_sucursal+f2.fact_numero = if2.item_tipo + if2.item_sucursal + if2.item_numero
where f2.fact_cliente = clie_codigo)
, (SELECT COUNT(item_producto) from item_factura if3

join Factura f3 on f3.fact_tipo+f3.fact_sucursal+f3.fact_numero = if3.item_tipo + if3.item_sucursal + if3.item_numero
join composicion c1 on c1.comp_producto = if3.item_producto
where f3.fact_cliente = clie_codigo and year(f3.fact_fecha) = 2012)

from factura f0
join cliente on f0.fact_cliente = clie_codigo

where 
clie_codigo IN (
SELECT c3.clie_codigo FROM Cliente c3 
JOIN Factura f3 ON c3.clie_codigo = f3.fact_cliente
WHERE YEAR(f0.fact_fecha) = YEAR(f3.fact_fecha)
GROUP BY c3.clie_codigo, YEAR(f3.fact_fecha))

AND 

clie_codigo IN (
SELECT c4.clie_codigo FROM Cliente c4
JOIN Factura f4 ON c4.clie_codigo = f4.fact_cliente
WHERE YEAR(f0.fact_fecha) + 1 = YEAR(f4.fact_fecha)
GROUP BY c4.clie_codigo, YEAR(f4.fact_fecha))

group by clie_codigo, clie_razon_social
order by sum(fact_total) asc

SELECT * FROM FACTURA WHERE FACT_CLIENTE = 02740 
