--1. Mostrar el código, razón social de todos los clientes cuyo límite de crédito sea mayor o
--igual a $ 1000 ordenado por código de cliente.

-- SELECT C.clie_codigo, C.clie_razon_social FROM CLIENTE C
-- WHERE C.clie_limite_credito >= 1000
-- ORDER BY clie_limite_credito

-- 2. Mostrar el código, detalle de todos los artículos vendidos en el año 2012 ordenados por
-- cantidad vendida.

-- SELECT P.prod_codigo, P.prod_detalle, SUM(iff.item_cantidad) as cant_total_vendida FROM Producto P
-- JOIN Item_Factura iff ON iff.item_producto = P.prod_codigo
-- JOIN Factura F ON f.fact_numero+f.fact_sucursal+f.fact_tipo = iff.item_numero+iff.item_sucursal+iff.item_tipo
-- WHERE YEAR(F.fact_fecha) = 2012
-- GROUP BY p.prod_codigo, P.prod_detalle
-- ORDER BY cant_total_vendida DESC

-- 3. Realizar una consulta que muestre código de producto, nombre de producto y el stock
-- total, sin importar en que deposito se encuentre, los datos deben ser ordenados por
-- nombre del artículo de menor a mayor.

-- SELECT P.prod_codigo, prod_detalle, sum(S.stoc_cantidad) as stock_total FROM Producto P
-- JOIN STOCK S ON S.stoc_producto = P.prod_codigo
-- GROUP by p.prod_codigo, prod_detalle
-- ORDER BY p.prod_detalle

-- 4. Realizar una consulta que muestre para todos los artículos código, detalle y cantidad de
-- artículos que lo componen. Mostrar solo aquellos artículos para los cuales el stock
-- promedio por depósito sea mayor a 100.

-- SELECT  P.prod_codigo,
--         p.prod_detalle, 
--         AVG(s.stoc_cantidad) as stoc_promedio,
--         ISNULL((select sum(c2.comp_cantidad)from composicion c2 WHERE c2.comp_producto = P.prod_codigo),0) as cantidad_componentes

-- FROM PRODUCTO P
--     left OUTER JOIN Composicion C on P.prod_codigo = C.comp_producto
--     JOIN STOCK S ON s.stoc_producto = p.prod_codigo
--     JOIN DEPOSITO D ON d.depo_codigo = s.stoc_deposito

-- GROUP BY p.prod_codigo, p.prod_detalle 
-- HAVING AVG(s.stoc_cantidad) > 0 -- and (select sum(c2.comp_cantidad) from composicion c2 WHERE c2.comp_producto = P.prod_codigo) is not null
-- ORDER BY 3 DESC

-- componentes con composicion:
-- 00001104
-- 00001718
-- 00001707
-- 00006411
-- 00006404
-- 00006402


-- 5. Realizar una consulta que muestre código de artículo, detalle y cantidad de egresos de
-- stock que se realizaron para ese artículo en el año 2012 (egresan los productos que
-- fueron vendidos). Mostrar solo aquellos que hayan tenido más egresos que en el 2011.

-- SELECT  P.prod_codigo, 
--         P.prod_detalle,
--         sum(IFF.item_cantidad) as cantidad_vendida

--     FROM PRODUCTO P
--         JOIN Item_Factura iff on iff.item_producto = p.prod_codigo
--         JOIN FACTURA F ON f.fact_numero+f.fact_sucursal+f.fact_tipo = iff.item_numero+iff.item_sucursal+iff.item_tipo
--     WHERE YEAR(f.fact_fecha) = 2012
--     GROUP BY p.prod_codigo, P.prod_detalle
--     HAVING sum(IFF.item_cantidad) > 

--         (
--         SELECT 
--             sum(IFF2.item_cantidad) as cantidad_vendida
--         FROM PRODUCTO P2
--             JOIN Item_Factura iff2 on iff2.item_producto = p2.prod_codigo
--             JOIN FACTURA F2 ON f2.fact_numero+f2.fact_sucursal+f2.fact_tipo = iff2.item_numero+iff2.item_sucursal+iff2.item_tipo
--         WHERE YEAR(f2.fact_fecha) = 2011 AND P2.prod_codigo = P.prod_codigo 
--         GROUP BY p2.prod_codigo, P2.prod_detalle
--         )

--     ORDER BY p.prod_codigo

-- 6. Mostrar para todos los rubros de artículos código, detalle, cantidad de artículos de ese
-- rubro y stock total de ese rubro de artículos. Solo tener en cuenta aquellos artículos que
-- tengan un stock mayor al del artículo ‘00000000’ en el depósito ‘00’.

-- SELECT R.rubr_id, R.rubr_detalle, count(p.prod_codigo) AS CANT_PRODUCTOS_DEL_RUBRO FROM RUBRO R
-- JOIN Producto P ON p.prod_rubro = r.rubr_id
-- WHERE P.prod_codigo IN (

--     SELECT stoc_producto FROM STOCK S
--         GROUP BY s.stoc_producto, s.stoc_cantidad
--         HAVING s.stoc_cantidad > (select s2.stoc_cantidad from STOCK s2 where stoc_producto = '00000000')
 
-- )
-- GROUP BY R.rubr_id, R.rubr_detalle

--mejor solucion sin 2 subselect 

-- SELECT R.rubr_id, R.rubr_detalle, COUNT(DISTINCT P.prod_codigo) as [Cantidad de Articulos], SUM(S.stoc_cantidad) AS [Stock Total]
-- FROM Producto P
-- 	INNER JOIN RUBRO R
-- 		ON R.rubr_id = P.prod_rubro
-- 	INNER JOIN STOCK S
-- 		ON S.stoc_producto = P.prod_codigo
-- 	INNER JOIN DEPOSITO D
-- 		ON D.depo_codigo = S.stoc_deposito
-- WHERE S.stoc_cantidad > (
-- 		SELECT stoc_cantidad
-- 		FROM STOCK
-- 		WHERE stoc_producto = '00000000'
-- 			AND stoc_deposito = '00'
-- 		)
-- GROUP BY R.rubr_id,R.rubr_detalle
-- ORDER BY 1

-- 7. Generar una consulta que muestre para cada artículo código, detalle, mayor precio
-- menor precio y % de la diferencia de precios (respecto del menor Ej.: menor precio =
-- 10, mayor precio =12 => mostrar 20 %). Mostrar solo aquellos artículos que posean
-- stock.

-- SELECT   P.prod_codigo,
--          p.prod_detalle,
--         (select top 1 iff2.item_precio FROM Item_Factura IFF2 WHERE P.prod_codigo = iff2.item_producto ORDER BY iff2.item_precio DESC) AS MAX_PRECIO_VENDIDO,
--         (select top 1 iff2.item_precio FROM Item_Factura IFF2 WHERE P.prod_codigo = iff2.item_producto ORDER BY iff2.item_precio ASC) AS MIN_PRECIO_VENDIDO,
--         ((select top 1 iff2.item_precio FROM Item_Factura IFF2 WHERE P.prod_codigo = iff2.item_producto ORDER BY iff2.item_precio DESC) - (select top 1 iff2.item_precio FROM Item_Factura IFF2 WHERE P.prod_codigo = iff2.item_producto ORDER BY iff2.item_precio ASC)) * 100 / (select top 1 iff2.item_precio FROM Item_Factura IFF2 WHERE P.prod_codigo = iff2.item_producto ORDER BY iff2.item_precio ASC) AS PORCENTAJE_DE_VARIACION


--     FROM PRODUCTO P 

-- JOIN Item_Factura Iff ON IFF.item_producto = P.prod_codigo
-- JOIN STOCK S ON s.stoc_producto = p.prod_codigo

-- WHERE s.stoc_cantidad > 0 and p.prod_codigo = '00010220'

-- GROUP BY p.prod_codigo, p.prod_detalle


-- -- MEJOR USAR EL MIN Y MAX xd 

-- SELECT P.prod_codigo,P.prod_detalle
-- 		,MIN(IFACT.item_precio) AS [Menor Precio]
-- 		,MAX(IFACT.item_precio) AS [Mayor Precio]
-- 		,((MAX(IFACT.item_precio)-MIN(IFACT.item_precio))*100)/MIN(IFACT.item_precio) AS [Diferencia de Precios]
-- FROM Producto P
-- 	INNER JOIN Item_Factura IFACT
-- 		ON IFACT.item_producto = P.prod_codigo
-- 	INNER JOIN STOCK S
-- 		ON S.stoc_producto = P.prod_codigo
-- WHERE S.stoc_cantidad > 0
-- GROUP BY P.prod_codigo,P.prod_detalle

-- 8. Mostrar para el o los artículos que tengan stock en todos los depósitos, nombre del
-- artículo, stock del depósito que más stock tiene.

-- SELECT p.prod_detalle FROM PRODUCTO P
-- JOIN STOCK S on s.stoc_producto = P.prod_codigo
-- JOIN DEPOSITO D ON D.depo_codigo = S.stoc_deposito

-- SELECT  p.prod_detalle, p.prod_codigo,
--         COUNT(s.stoc_deposito) AS depositos_en_los_que_se_ubica,
--         (
--             SELECT max(s2.stoc_cantidad) 
--                 FROM STOCK s2
--             WHERE s2.stoc_producto = p.prod_codigo

--         ) as max_stock
--         FROM STOCK S
-- JOIN PRODUCTO P on P.prod_codigo = S.stoc_producto
-- GROUP BY p.prod_detalle, p.prod_codigo
-- HAVING COUNT(s.stoc_deposito) = (SELECT COUNT(1) FROM Deposito)

-- --otra solucion desde tabla producto

-- SELECT P.prod_codigo
-- 		,P.prod_detalle
-- 		,(
-- 			SELECT TOP 1 stoc_cantidad
-- 			FROM STOCK
-- 			WHERE P.prod_codigo = stoc_producto
-- 			ORDER BY stoc_cantidad DESC) AS [Stock del depósito mayor cantidad]
-- 		,count(DISTINCT S.stoc_deposito)
-- FROM Producto P
-- 	INNER JOIN STOCK S
-- 		ON S.stoc_producto = P.prod_codigo
-- GROUP BY P.prod_codigo,P.prod_detalle

-- HAVING (count(DISTINCT S.stoc_deposito)) = (
-- 		SELECT COUNT(depo_codigo)
-- 		FROM DEPOSITO
-- 		)
-- ORDER BY 1 DESC



-- 9. Mostrar el código del jefe, código del empleado que lo tiene como jefe, nombre del
-- mismo y la cantidad de depósitos que ambos tienen asignados.

-- SELECT  e.empl_jefe,
--         e.empl_codigo,
--         e.empl_nombre,
--         (
--             SELECT COUNT(1) FROM DEPOSITO WHERE depo_encargado = e.empl_jefe
--         ) as depositos_del_jefe,
        
--         (
--             SELECT COUNT(1) FROM DEPOSITO WHERE depo_encargado = e.empl_codigo
--         ) as depositos_del_empleado
--     FROM EMPLEADO e
-- --otra solucion muy parecida
-- SELECT J.empl_codigo AS [Codigo Jefe]
-- 		,E.empl_codigo [Codigo Empleado]
-- 		,E.empl_nombre [Nombre Empleado]
-- 		,E.empl_apellido [Apellido Empleado]
-- 		,COUNT(D.depo_encargado) AS [Depositos Empleado]
-- 		,(
-- 			SELECT COUNT(depo_encargado)
-- 			FROM DEPOSITO
-- 			WHERE J.empl_codigo = depo_encargado
-- 		) AS [Depositos Jefe]
-- FROM Empleado E
-- 	LEFT JOIN Empleado J
-- 		ON J.empl_codigo = E.empl_jefe
-- 	LEFT JOIN DEPOSITO D
-- 		ON D.depo_encargado = E.empl_codigo
-- 	GROUP BY J.empl_codigo,E.empl_codigo,E.empl_nombre,E.empl_apellido



-- 10. Mostrar los 10 productos más vendidos en la historia y también los 10 productos menos
-- vendidos en la historia. Además mostrar de esos productos, quien fue el cliente que
-- mayor compra realizo.

-- SELECT distinct iff.item_producto, F.fact_cliente AS cliente_que_mas_compro, p.prod_detalle
--     FROM Item_Factura Iff
-- JOIN factura f ON f.fact_numero+f.fact_sucursal+f.fact_tipo = iff.item_numero+iff.item_sucursal+iff.item_tipo
-- JOIN Producto P on p.prod_codigo = iff.item_producto
-- WHERE (
-- iff.item_producto IN 
-- (SELECT TOP 10 iff.item_producto
--         FROM Item_Factura IFF
-- group by iff.item_producto
-- order by sum(iff.item_cantidad) DESC
-- ) OR 
-- iff.item_producto IN 
-- (SELECT TOP 10 iff.item_producto
--         FROM Item_Factura IFF
-- group by iff.item_producto
-- order by sum(iff.item_cantidad) ASC
-- ) ) AND
-- F.fact_cliente = (
--     SELECT top 1 f2.fact_cliente FROM Factura f2
--     JOIN Item_Factura iff2 ON f2.fact_numero+f2.fact_sucursal+f2.fact_tipo = iff2.item_numero+iff2.item_sucursal+iff2.item_tipo
--     where iff2.item_producto = iff.item_producto
--     group by f2.fact_cliente
--     order by max(fact_total)
-- )
-- GROUP BY iff.item_producto, F.fact_cliente,  p.prod_detalle


-- SELECT TOP 10 iff.item_producto FROM Item_Factura IFF
-- group by iff.item_producto
-- order by sum(iff.item_cantidad) DESC

-- SELECT 
--     TOP 10 iff.item_producto order by sum(iff.item_cantidad) ASC
--     FROM Item_Factura iff


-- SELECT
-- 	P.prod_codigo AS [Codigo vendido]
-- 	,P.prod_detalle [Detalle vendido]
-- 	,(
-- 		SELECT TOP 1 F1.fact_cliente
-- 		FROM Factura F1
-- 			INNER JOIN Item_Factura IFACT1
-- 				ON F1.fact_sucursal = IFACT1.item_sucursal AND F1.fact_numero = IFACT1.item_numero AND F1.fact_tipo = IFACT1.item_tipo
-- 		WHERE P.prod_codigo=IFACT1.item_producto
-- 		GROUP BY F1.fact_cliente
-- 		ORDER BY SUM(IFACT1.item_cantidad) DESC
-- 	) AS [Cliente que realizó la compra]
	
-- FROM Producto P
-- 	INNER JOIN Item_Factura IFACT
-- 		ON IFACT.item_producto = P.prod_codigo
-- WHERE 
-- 	P.prod_codigo IN(
-- 		SELECT TOP 10 item_producto
-- 		FROM Item_Factura
-- 		GROUP BY item_producto
-- 		ORDER BY SUM(item_cantidad) DESC
-- 	)
-- 	OR
-- 	P.prod_codigo IN(
-- 		SELECT TOP 10 item_producto
-- 		FROM Item_Factura
-- 		GROUP BY item_producto
-- 		ORDER BY SUM(item_cantidad) ASC
-- 	)
-- GROUP BY P.prod_codigo,P.prod_detalle


-- 11. Realizar una consulta que retorne el detalle de la familia, la cantidad diferentes de
-- productos vendidos y el monto de dichas ventas sin impuestos. Los datos se deberán
-- ordenar de mayor a menor, por la familia que más productos diferentes vendidos tenga,
-- solo se deberán mostrar las familias que tengan una venta superior a 20000 pesos para
-- el año 2012.

--mi solucion q creo q es la mejor de todas dios mio las demas son horribles

-- SELECT 
--     Fam.fami_detalle,
--     count(distinct iff.item_producto) AS cant_productos_distintos,
--     sum(iff.item_cantidad*iff.item_precio) AS monto_ventas_total
--     FROM FAMILIA fam
-- JOIN Producto P ON p.prod_familia = fam.fami_id
-- JOIN Item_Factura iff ON iff.item_producto = p.prod_codigo
-- JOIN Factura F ON f.fact_numero+f.fact_sucursal+f.fact_tipo = iff.item_numero+iff.item_sucursal+iff.item_tipo

-- WHERE fami_id IN 
-- (
--     SELECT 
--         fam2.fami_id
--         FROM FAMILIA Fam2
--     JOIN Producto P2 on P2.prod_familia = FAM2.fami_id
--     JOIN Item_Factura iff2 ON iff2.item_producto = p2.prod_codigo
--     JOIN Factura F2 ON f2.fact_numero+f2.fact_sucursal+f2.fact_tipo = iff2.item_numero+iff2.item_sucursal+iff2.item_tipo
--     WHERE YEAR(f2.fact_fecha) = 2012
--     GROUP BY Fam2.fami_detalle, fam2.fami_id    
--     HAVING sum(iff2.item_cantidad*iff2.item_precio) > 20000
-- )

-- GROUP BY Fam.fami_detalle
-- ORDER BY count(distinct p.prod_codigo) DESC

------------------------otra solucion malarda---------------------------


-- SELECT fami_detalle, COUNT(DISTINCT prod_codigo) as cant_prod, SUM(item_precio * item_cantidad) as monto_ventas
-- FROM Familia fam
-- 	 JOIN Producto p ON fami_id = prod_familia
-- 	 JOIN Item_Factura i ON prod_codigo = item_producto
-- 	 JOIN Factura fac ON item_numero = fact_numero
-- 				 AND item_tipo = fact_tipo
-- 				 AND item_sucursal = fact_sucursal
-- GROUP BY fami_detalle,fami_id
-- HAVING
-- 		EXISTS(SELECT TOP 1 fact_numero, fact_tipo, fact_sucursal
-- 		FROM Factura JOIN Item_Factura ON fact_sucursal=item_sucursal AND fact_tipo=item_tipo AND fact_numero=item_numero
-- 					 JOIN Producto ON item_producto = prod_codigo
-- 		WHERE YEAR(fact_fecha)=2012 AND prod_familia='002' --fam.fami_id
-- 		GROUP BY fact_numero, fact_tipo, fact_sucursal
-- 		HAVING SUM(item_precio * item_cantidad)>20000)
-- ORDER BY monto_ventas DESC

-------------------------------------------------------------------------

-- 35. Se requiere realizar una estadística de ventas por año y producto, para ello se solicita
-- que escriba una consulta sql que retorne las siguientes columnas:
--  Año
--  Codigo de producto
--  Detalle del producto
--  Cantidad de facturas emitidas a ese producto ese año
--  Cantidad de vendedores diferentes que compraron ese producto ese año.
--  Cantidad de productos a los cuales compone ese producto, si no compone a ninguno
-- se debera retornar 0.
--  Porcentaje de la venta de ese producto respecto a la venta total de ese año.
-- Los datos deberan ser ordenados por año y por producto con mayor cantidad vendida.


-- SELECT DISTINCT
--     P.prod_codigo,
--     p.prod_detalle,
--     YEAR(f.fact_fecha) AS año,

--     (
--         SELECT
--             count(F2.fact_numero)
--             FROM Producto p2
--         JOIN Item_Factura iff2 ON iff2.item_producto = p2.prod_codigo
--         JOIN Factura F2 ON f2.fact_numero+f2.fact_sucursal+f2.fact_tipo = iff2.item_numero+iff2.item_sucursal+iff2.item_tipo
--         WHERE p2.prod_codigo = P.prod_codigo AND YEAR(f2.fact_fecha) = YEAR(f.fact_fecha)
            
--     ) AS Facturas_emitidas_en_el_año,

--     (
--         SELECT
--             count(DISTINCT f2.fact_vendedor)
--             from factura f2
--         JOIN Item_Factura iff2 ON f2.fact_numero+f2.fact_sucursal+f2.fact_tipo = iff2.item_numero+iff2.item_sucursal+iff2.item_tipo
--         JOIN Producto p2 ON P.prod_codigo = iff2.item_producto
--         WHERE iff2.item_producto = IFF.item_producto AND YEAR(F2.fact_fecha) = YEAR(F.fact_fecha)
--         GROUP BY IFF2.item_producto, YEAR(F2.fact_fecha) 
--     ) AS vendedores_distintos,

--     ISNULL((
--         SELECT 
--             count(*)
--             FROM Composicion c2
--         WHERE c2.comp_componente = p.prod_codigo
--     ),0) AS productos_que_compone,

--     (
--     (
--         SUM(iff.item_cantidad*iff.item_precio)
--     ) *100 /
--     (
--     SELECT 
--         sum(F2.fact_total)
--         FROM Factura F2
--     JOIN Item_Factura iff2 on f2.fact_numero+f2.fact_sucursal+f2.fact_tipo = iff2.item_numero+iff2.item_sucursal+iff2.item_tipo
--     WHERE YEAR(F2.fact_fecha) = YEAR(F.fact_fecha)
--     )
--     ) AS porcentaje_sobre_total_ventas_en_el_año

--     FROM PRODUCTO P
-- JOIN Item_Factura iff ON iff.item_producto = p.prod_codigo
-- JOIN Factura F ON f.fact_numero+f.fact_sucursal+f.fact_tipo = iff.item_numero+iff.item_sucursal+iff.item_tipo
-- GROUP BY P.prod_codigo,
--     p.prod_detalle,
--     YEAR(f.fact_fecha),
--     iff.item_producto
-- ORDER BY YEAR(f.fact_fecha)


-- -------otra solucion distintos valores, seguro esta mal


-- SELECT YEAR(F.fact_fecha) AS [Año]
-- 	,P.prod_codigo
-- 	,P.prod_detalle
-- 	,COUNT(DISTINCT F.fact_tipo+F.fact_sucursal+F.fact_numero) AS [Cant Facturas]
-- 	,COUNT(DISTINCT F.fact_vendedor) AS [Cant vendedores diferentes del prod]
-- 	,(
-- 		SELECT COUNT(comp_componente)
-- 		FROM Composicion
-- 		WHERE comp_componente = P.prod_codigo
-- 	) AS [Cant de prods que compone]
-- 	,(
-- 		(SUM(IFACT.item_precio*IFACT.item_cantidad)
-- 		* 100)
-- 		/
-- 		(
-- 			SELECT SUM(item_precio*item_cantidad)
-- 			FROM Item_Factura
-- 				INNER JOIN Factura
-- 					ON fact_tipo = item_tipo AND fact_sucursal = item_sucursal AND fact_numero = fact_numero
-- 			WHERE YEAR(fact_fecha) = YEAR(F.fact_fecha)
-- 		)
-- 	) AS [Porcentaje de venta sobre el total]
-- 	FROM Producto P
-- 		INNER JOIN Item_Factura IFACT
-- 			ON IFACT.item_producto = P.prod_codigo
-- 		INNER JOIN Factura F
-- 			ON F.fact_tipo = IFACT.item_tipo AND F.fact_sucursal = IFACT.item_sucursal AND F.fact_numero = IFACT.item_numero
-- GROUP BY YEAR(F.fact_fecha),P.prod_codigo,P.prod_detalle
-- ORDER BY 1, SUM(IFACT.item_cantidad) DESC

-- 34. Escriba una consulta sql que retorne para todos los rubros la cantidad de facturas mal
-- facturadas por cada mes del año 2011 Se considera que una factura es incorrecta cuando
-- en la misma factura se factutan productos de dos rubros diferentes. Si no hay facturas
-- mal hechas se debe retornar 0. Las columnas que se deben mostrar son:

-- 1- Codigo de Rubro
-- 2- Mes
-- 3- Cantidad de facturas mal realizadas.

-- SELECT P.prod_rubro AS [Rubro]
-- 	,MONTH(F.fact_fecha) AS [MES]
-- 	,COUNT(DISTINCT F.fact_tipo+F.fact_sucursal+F.fact_numero) AS [Fact mal realizadas]
-- FROM Producto P
-- 	INNER JOIN Item_Factura IFACT
-- 		ON IFACT.item_producto = P.prod_codigo
-- 	INNER JOIN Factura F
-- 		ON F.fact_tipo = IFACT.item_tipo AND F.fact_sucursal = IFACT.item_sucursal AND F.fact_numero = IFACT.item_numero
-- WHERE YEAR(F.fact_fecha) = 2011 AND (
-- 										SELECT COUNT(DISTINCT prod_rubro)
-- 										FROM Producto
-- 											INNER JOIN Item_Factura
-- 												ON item_producto = prod_codigo
-- 										WHERE item_tipo+item_sucursal+item_numero = IFACT.item_tipo+IFACT.item_sucursal+IFACT.item_numero
-- 										GROUP BY item_tipo+item_sucursal+item_numero
-- 										) > 1
-- GROUP BY P.prod_rubro, MONTH(F.fact_fecha)
-- ORDER BY 1


-- 33. Se requiere obtener una estadística de venta de productos que sean componentes. Para
-- ello se solicita que realiza la siguiente consulta que retorne la venta de los
-- componentes del producto más vendido del año 2012. Se deberá mostrar:
-- a. Código de producto
-- b. Nombre del producto
-- c. Cantidad de unidades vendidas
-- d. Cantidad de facturas en la cual se facturo
-- e. Precio promedio facturado de ese producto.
-- f. Total facturado para ese producto
-- El resultado deberá ser ordenado por el total vendido por producto para el año 2012.

-- SELECT distinct
--     c.comp_componente,
--     p.prod_detalle,

-- (
--     SELECT
--         isnull(sum(IFF2.item_cantidad),0)
--         FROM Item_Factura iff2 
--     JOIN Factura F2 ON f2.fact_numero+f2.fact_sucursal+f2.fact_tipo = iff2.item_numero+iff2.item_sucursal+iff2.item_tipo
--     WHERE iff2.item_producto = c.comp_componente
-- ) AS CANT_VENDIDA,

-- (
--     SELECT 
--         count(iff2.item_numero)
--         FROM Item_Factura iff2
--     JOIN FACTURA F2 ON f2.fact_numero+f2.fact_sucursal+f2.fact_tipo = iff2.item_numero+iff2.item_sucursal+iff2.item_tipo
--     where iff2.item_producto = c.comp_componente
-- ) AS facturas_emitidas,

-- (
--     SELECT 
--         ISNULL(AVG(IFF2.item_precio),0)
--         FROM Item_Factura IFF2
--     JOIN FACTURA F2 ON f2.fact_numero+f2.fact_sucursal+f2.fact_tipo = iff2.item_numero+iff2.item_sucursal+iff2.item_tipo
--     WHERE IFF2.item_producto = C.comp_componente
-- ) AS precio_promedio,

-- (
--     SELECT
--         isnull(sum(IFF2.item_cantidad * iff2.item_precio),0)
--     FROM Item_Factura iff2
--     WHERE iff2.item_producto = comp_componente
-- ) AS total_vendido

--     FROM Composicion C
-- JOIN Producto P ON c.comp_componente = p.prod_codigo

-- WHERE C.comp_producto = 
--             (
--             SELECT TOP 1
--                 P2.prod_codigo
--                 FROM Producto P2
--             JOIN Item_Factura iff2 ON IFF2.item_producto = p2.prod_codigo
--             JOIN FACTURA F2 ON f2.fact_numero+f2.fact_sucursal+f2.fact_tipo = iff2.item_numero+iff2.item_sucursal+iff2.item_tipo
--             WHERE YEAR(F2.fact_fecha) = 2012
--             GROUP BY p2.prod_codigo
--             order by SUM(Iff2.item_cantidad) DESC  
--             )

-- ORDER BY total_vendido DESC


----otrqa solucion pero no sale el otro componente
-- SELECT P.prod_codigo
-- 	,P.prod_detalle
-- 	,SUM(IFACT.item_cantidad) AS [Cantidad unidades vendidas]
-- 	,COUNT(DISTINCT IFACT.item_numero+IFACT.item_tipo+IFACT.item_sucursal) [Cant fact realizadas]
-- 	,AVG(IFACT.item_precio) [Precio promedio facturado]
-- 	,SUM(IFACT.item_precio*IFACT.item_cantidad) [Total Facturado]
-- FROM Producto P
-- 	INNER JOIN Composicion C
-- 		ON C.comp_componente = P.prod_codigo
-- 	INNER JOIN Producto COMBO
-- 		ON COMBO.prod_codigo = C.comp_producto
-- 	INNER JOIN Item_Factura IFACT
-- 		ON IFACT.item_producto = P.prod_codigo
-- 	INNER JOIN Factura F
-- 		ON F.fact_numero = IFACT.item_numero AND F.fact_tipo = IFACT.item_tipo AND F.fact_sucursal = IFACT.item_sucursal
-- WHERE C.comp_producto = (
-- 							SELECT TOP 1 item_producto
-- 							FROM Item_Factura
-- 								INNER JOIN Factura
-- 									ON fact_numero = item_numero AND fact_tipo = item_tipo AND fact_sucursal = item_sucursal
-- 							WHERE item_producto IN (SELECT comp_producto FROM Composicion) AND YEAR(fact_fecha) = 2012
-- 							GROUP BY item_producto
-- 							ORDER BY SUM(item_cantidad) DESC
-- 							)
-- GROUP BY P.prod_codigo,P.prod_detalle