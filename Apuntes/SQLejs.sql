-- realizar una consulta sql que retorne para TODOS los productos 
-- COD_PRODUCTO
-- RUBRO_PRODUCTO
-- CANT_ COMPONENTES QUE TIENE
-- CANT FACTURAS DE SUS COMPONENTES SI TIENE
-- QUE FUERON VENDIDOS


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