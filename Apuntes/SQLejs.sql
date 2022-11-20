-- realizar una consulta sql que retorne para TODOS los productos 
-- COD_PRODUCTO
-- RUBRO_PRODUCTO
-- CANT_ COMPONENTES QUE TIENE
-- CANT FACTURAS DE SUS COMPONENTES SI TIENE
-- QUE FUERON VENDIDOS

-- mi planteo (queda medio choto)
-- SELECT
--     P.prod_codigo,
--     P.prod_rubro,
--     sum(distinct C.comp_cantidad) as 'cant_componentes',
--     C.comp_componente

--         , (select count(F2.fact_numero)
--     FROM Factura F2
--         JOIN Item_Factura iff2 on F2.fact_numero = iff2.item_numero and iff2.item_sucursal = f2.fact_sucursal and iff2.item_tipo = f2.fact_tipo
--     WHERE iff2.item_producto = C.comp_componente
--         ) AS 'cantidad de veces vendido'

-- FROM Producto P
--     JOIN Item_Factura iff on iff.item_producto = P.prod_codigo
--     JOIN Factura F on iff.item_numero = F.fact_numero and iff.item_sucursal = f.fact_sucursal and iff.item_tipo = f.fact_tipo
--     LEFT JOIN Composicion C on C.comp_producto = P.prod_codigo
-- GROUP BY P.prod_codigo, P.prod_rubro, C.comp_componente, c.comp_cantidad
-- HAVING count(distinct C.comp_componente) > 0

--buen approach pero con 2 subselect

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


    -- Armar una consulta SQL que muestre aquel/aquellos clientes que en 2 años consecutivos (de existir),
    --  fueron los mejores compradores, es decir, los que en monto total facturado anual fue el máximo.De esos clientes mostrar , 
    --  razón social, domicilio, cantidad de unidades compradas.Nota: No se puede usar select en el from

SELECT  C.clie_codigo, C.clie_razon_social , clie_domicilio, SUM(iff.item_cantidad) as cant_unidades_compradas, YEAR(F.fact_fecha)FROM Cliente c
    JOIN Factura F on F.fact_cliente = C.clie_codigo
    JOIN Item_Factura Iff ON iff.item_tipo = f.fact_tipo AND iff.item_sucursal = f.fact_sucursal AND iff.item_numero = f.fact_numero
    GROUP BY C.clie_codigo, F.fact_fecha, C.clie_razon_social, C.clie_domicilio

    HAVING C.clie_codigo = (

        SELECT TOP 1 F2.fact_cliente FROM Factura F2 
        WHERE YEAR(F2.fact_fecha) = YEAR(F.fact_fecha) 
        GROUP BY F2.fact_cliente
        ORDER BY SUM(F2.fact_total) DESC

    )
    AND
    C.clie_codigo = (
        SELECT TOP 1 F3.fact_cliente FROM Factura F3
        WHERE YEAR(F3.fact_fecha) = YEAR(F.fact_fecha)+1 
        GROUP BY F3.fact_cliente
        ORDER BY SUM(F3.fact_total) DESC
    )

-- si lo hago con el where en vez de having, es menos performante. Having ya me filtra bastantes resultados


-- Realizar una consulta SQL que devuelva los clientes que NO tuvieron la facturacion maxima y la facturacion minima en el 2012.
-- de estos clientes mostrar:
-- el NUM DE ORDEN: asignando 1 al cliente de mayor venta y N al de menor venta. Entiendase el N como el num correspondiente al que menos vendio en el 
-- 2012. Entiendase venta como total facturado

-- El codigo del cliente
-- El monto total comprado en el 2012
-- La cant de unidades de productos compradas en el 2012
-- NOTA:    no se permiten select en el from etc etc

SELECT 
    ROW_NUMBER() OVER (ORDER BY SUM(f.fact_total)) as NUM_ORDEN,
    clie_codigo,
    SUM(f.fact_total) AS MONTO_TOTAL_COMPRADO_2012,
    SUM(iff.item_cantidad) AS UNIDADES_COMPRADAS_2012

    
    FROM Cliente C

JOIN Factura F ON f.fact_cliente = C.clie_codigo
JOIN Item_Factura iff ON iff.item_sucursal+iff.item_numero+iff.item_tipo = f.fact_sucursal+f.fact_numero+f.fact_tipo
WHERE YEAR(F.fact_fecha) = 2012 

AND

clie_codigo != (
    SELECT TOP 1 F.fact_cliente FROM Factura F
    WHERE YEAR(F.fact_fecha) = 2012
    GROUP BY F.fact_cliente
    ORDER BY SUM(f.fact_total) DESC
)

AND

clie_codigo != (
SELECT TOP 1 F.fact_cliente FROM Factura F
WHERE YEAR(F.fact_fecha) = 2012
GROUP BY F.fact_cliente
ORDER BY SUM(f.fact_total) ASC
)

GROUP BY clie_codigo