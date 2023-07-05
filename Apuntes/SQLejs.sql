-- REALIZAR UNA CONSULTA SQL QUE PERMITA SABER LOS CLIENTES QUE COMPRARON TODOS LOS RUBROS DISPONIBLES DEL SISTEMA EN EL 2012
-- de estos clientes mostrar siempre para el 2012:

--cod cliente
--cod de producto que en cantidades mas compro
-- nombre del producto del punto 2
--cant de productos distintos comprados por el cliente
--cant de productos con composicion comprados por el cliente

-- el resultado debera ser ordenado por razon social del cliente alfabeticamente primero y luego, los clientes que compraron entre un 20 y 30%
-- del total facturado en el 2012 primero, luego los restantes

SELECT DISTINCT F.fact_cliente,

(SELECT TOP 1 iff2.item_numero FROM Item_Factura iff2
JOIN FACTURA F2 ON Iff2.item_numero+iff2.item_sucursal+iff2.item_tipo = f2.fact_numero+f2.fact_sucursal+f2.fact_tipo
WHERE
	YEAR(fact_fecha) = '2012'
	AND f2.fact_cliente = F.fact_cliente
		GROUP BY iff2.item_numero
		ORDER BY SUM(iff2.item_cantidad) DESC
	) AS 'codigo del mas comprado'

,(SELECT TOP 1 P.prod_detalle FROM Item_Factura iff3
    JOIN Producto P ON prod_codigo = item_producto
    JOIN Factura f3 ON f3.fact_cliente = F.fact_cliente
		WHERE
		YEAR(fact_fecha) = '2012'
		GROUP BY P.prod_detalle
		ORDER BY SUM(item_cantidad) DESC
	) AS 'Nombre del mas comprado'
    
,(SELECT COUNT (distinct prod_codigo)
    FROM Producto P2
    JOIN Item_Factura iff4 on item_producto = prod_codigo
    JOIN Factura f4 on Iff4.item_numero+iff4.item_sucursal+iff4.item_tipo = f4.fact_numero+f4.fact_sucursal+f4.fact_tipo
    WHERE YEAR(fact_fecha) = '2012' AND f4.fact_cliente = F.fact_cliente
    GROUP BY f4.fact_cliente
) AS 'cantidad de productos distintos comprados por el cliente'

,(SELECT COUNT(DISTINCT P3.prod_codigo)
		FROM Producto P3
		JOIN Composicion C ON C.comp_producto = P3.prod_codigo
		JOIN Item_Factura iff5 on iff5.item_producto = P3.prod_codigo
		JOIN Factura F5 on f5.fact_sucursal = iff5.item_sucursal and f5.fact_tipo = iff5.item_tipo and f5.fact_numero = iff5.item_numero
		WHERE f5.fact_cliente = F.fact_cliente) AS 'Cantidad de productos compuestos'


FROM FACTURA F
JOIN Item_Factura iff on Iff.item_numero+iff.item_sucursal+iff.item_tipo = f.fact_numero+f.fact_sucursal+f.fact_tipo
JOIN Producto P ON P.prod_codigo = iff.item_producto
JOIN Rubro R ON P.prod_rubro = R.rubr_id
JOIN CLIENTE C ON F.fact_cliente = C.clie_codigo
WHERE YEAR(F.fact_fecha) = 2012
GROUP BY F.fact_cliente
HAVING COUNT(DISTINCT p.prod_rubro) = (SELECT COUNT(1) FROM Rubro R)
