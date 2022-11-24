-- realizar una consulta sql que muestre aquellos productos que tengan 3 componentes a nivel producto y cuyos componentes tengan 2 rubros distintos
-- De estos productos mostrar:
-- 1. El codigo de producto
-- 2. el nombre del producto
-- 3. la cant de veces que fueron vendidos sus componentes en el 2012 
-- 4. monto total vendido del producto 

-- el resultado debera ser ordenado por cant de facturas del 2012 en las cuales se vendieron los componentes   

SELECT 
    C.comp_producto,
    p2.prod_detalle,

    ISNULL((
        SELECT SUM(IFF2.item_cantidad) 
            FROM Composicion C2
        JOIN Item_Factura IFF2 ON C2.comp_componente = IFF2.item_producto
        JOIN FACTURA F2 ON Iff2.item_numero+iff2.item_sucursal+iff2.item_tipo = f2.fact_numero+f2.fact_sucursal+f2.fact_tipo
        WHERE C2.comp_producto = c.comp_producto AND YEAR(F2.fact_fecha) = 2012
    ),0) AS cant_veces_vendidas_componentes_en_2012,

    ISNULL((
        SELECT SUM(IFF2.item_precio*IFF2.item_cantidad)
            FROM PRODUCTO P2
        JOIN Item_Factura IFF2 ON P2.prod_codigo = IFF2.item_producto
        JOIN Factura F2 ON Iff2.item_numero+iff2.item_sucursal+iff2.item_tipo = f2.fact_numero+f2.fact_sucursal+f2.fact_tipo
        WHERE P2.prod_codigo = C.comp_producto
    ),0) AS Monto_total_vendido,


    ISNULL((
        SELECT count(f2.fact_numero) 
            FROM Composicion C2
        JOIN Item_Factura IFF2 ON C2.comp_componente = IFF2.item_producto
        JOIN FACTURA F2 ON Iff2.item_numero+iff2.item_sucursal+iff2.item_tipo = f2.fact_numero+f2.fact_sucursal+f2.fact_tipo
        WHERE C2.comp_producto = c.comp_producto AND YEAR(F2.fact_fecha) = 2012
    ),0) AS cantidad_facturas_de_componentes

    FROM Composicion c
JOIN PRODUCTO P ON c.comp_componente = p.prod_codigo
JOIN RUBRO R ON R.rubr_id = P.prod_rubro
JOIN PRODUCTO P2 ON c.comp_producto = p2.prod_codigo  -- tambien podria hacer un subselect pero necesito tener el nombre del producto y no del componente

GROUP BY C.comp_producto, p2.prod_detalle
HAVING count(distinct c.comp_componente) > 3
AND count(distinct r.rubr_id)=2

ORDER BY cantidad_facturas_de_componentes DESC

-- SELECT sum(item_cantidad) from Item_Factura  IFF 
-- JOIN FACTURA f ON Iff.item_numero+iff.item_sucursal+iff.item_tipo = f.fact_numero+f.fact_sucursal+f.fact_tipo
-- where item_producto = '00006411' 
-- AND YEAR(F.fact_fecha) = 2012  





-----

CREATE TRIGGER TGPARCIAL 
ON COMPOSICION 
AFTER INSERT
AS
BEGIN TRANSACTION

DECLARE @rubrPRODUCTO VARCHAR(8)
DECLARE @rubrCOMP VARCHAR(8)


SET @rubrPRODUCTO = (
                SELECT r.rubr_id 
                    FROM inserted i
                JOIN Producto P ON P.prod_codigo = I.comp_producto 
                JOIN Rubro R ON R.rubr_id = P.prod_codigo

            )

SET @rubrCOMP = (
                SELECT r.rubr_id 
                    FROM inserted i
                JOIN Producto P ON P.prod_codigo = I.comp_componente 
                JOIN Rubro R ON R.rubr_id = P.prod_codigo

            )

IF @rubrCOMP != @rubrPRODUCTO
BEGIN
    PRINT 'No puede el producto estar compuesto por un componente de distinto rubro'
    ROLLBACK
    RETURN
END

COMMIT





-------


CREATE TRIGGER TGPARCIAL2
ON COMPOSICION 
AFTER UPDATE
AS
BEGIN TRANSACTION

DECLARE @rubrPRODUCTO VARCHAR(8)
DECLARE @rubrCOMP VARCHAR(8)

SET @rubrPRODUCTO = (
                SELECT r.rubr_id 
                    FROM inserted i
                JOIN Producto P ON P.prod_codigo = I.comp_producto 
                JOIN Rubro R ON R.rubr_id = P.prod_codigo

            )   

SET @rubrCOMP = (
                SELECT r.rubr_id 
                    FROM inserted i
                JOIN Producto P ON P.prod_codigo = I.comp_componente 
                JOIN Rubro R ON R.rubr_id = P.prod_codigo

            )

IF @rubrCOMP != (SELECT R.rubr_id FROM inserted I
                JOIN PRODUCTO P ON I.comp_producto = p.prod_codigo
                JOIN RUBRO R ON R.rubr_id = P.prod_rubro)
BEGIN
    PRINT 'No puede el producto estar compuesto por un componente de distinto rubro'
    ROLLBACK
    RETURN
END

IF @rubrPRODUCTO != (SELECT R.rubr_id FROM inserted I
                JOIN PRODUCTO P ON I.comp_componente = p.prod_codigo
                JOIN RUBRO R ON R.rubr_id = P.prod_rubro)

BEGIN
    PRINT 'No puede el producto estar compuesto por un componente de distinto rubro'
    ROLLBACK
    RETURN
END

COMMIT

CREATE TRIGGER TGPARCIAL3
ON Producto
AFTER INSERT, UPDATE
AS
BEGIN TRANSACTION

	DECLARE @producto		char(8)
	DECLARE @rubro_producto char(4)
	
	SELECT
		@producto = prod_codigo,
		@rubro_producto = prod_rubro
	FROM inserted
	JOIN Composicion on comp_producto = prod_codigo
	
	IF EXISTS	(
					SELECT
						prod_rubro
					FROM Producto
					JOIN Composicion on comp_componente = prod_codigo
					WHERE
						comp_producto = @producto
						AND prod_rubro != @rubro_producto
				)
        PRINT 'No puede el producto estar compuesto por un componente de distinto rubro'
		ROLLBACK
		RETURN
COMMIT




------------------------EJ TRIGGERS RESUELTOS X FRAN---------------------

------------------------------------------------------------------------------------------------------------------------
CREATE TRIGGER tr_recu2_22_11_2022
ON Composicion
AFTER INSERT, UPDATE
AS
BEGIN TRANSACTION
	
	DECLARE @producto char(8)
	DECLARE @componente char(8)
	DECLARE @rubro_producto char(4)
	DECLARE @rubro_componente char(4)

    DECLARE mi_cursor CURSOR FOR

            SELECT
				i.comp_producto,
				i.comp_componente,
				r1.rubr_id,
				r2.rubr_id
			FROM inserted i
			JOIN Producto p1	ON comp_producto = p1.prod_codigo
			JOIN Producto p2	ON comp_componente = p2.prod_codigo
			JOIN Rubro r1		ON p1.prod_rubro = r1.rubr_id
			JOIN Rubro r2		ON p2.prod_rubro = r2.rubr_id

    OPEN mi_cursor
    FETCH mi_cursor INTO
		@producto,
		@componente,
		@rubro_producto,
		@rubro_componente

    WHILE @@FETCH_STATUS = 0
    BEGIN
        
		IF(@rubro_producto != @rubro_componente)
			RAISERROR ('ERROR, UN PRODUCTO NO PUEDE ESTAR COMPUESTO POR PRODUCTOS DE DISTINTOS RUBROS AL SUYO', 16, 1)
			ROLLBACK
			RETURN

        FETCH mi_cursor INTO
		@producto,
		@componente,
		@rubro_producto,
		@rubro_componente
    
    END

    CLOSE mi_cursor
    DEALLOCATE mi_cursor
COMMIT


CREATE TRIGGER tr2_recu2_22_11_2022
ON Producto
AFTER INSERT, UPDATE
AS
BEGIN TRANSACTION

	DECLARE @producto		char(8)
	DECLARE @rubro_producto char(4)
	
	SELECT
		@producto = prod_codigo,
		@rubro_producto = prod_rubro
	FROM inserted
	JOIN Composicion on comp_producto = prod_codigo
	
	IF EXISTS	(
					SELECT
						prod_rubro
					FROM Producto
					JOIN Composicion on comp_componente = prod_codigo
					WHERE
						comp_producto = @producto
						AND prod_rubro != @rubro_producto
				)
		RAISERROR ('ERROR, UN PRODUCTO NO PUEDE ESTAR COMPUESTO POR PRODUCTOS DE DISTINTOS RUBROS AL SUYO', 16, 1)
		ROLLBACK
		RETURN
COMMIT

CREATE TRIGGER tr3_recu2_22_11_2022
ON Producto
AFTER INSERT, UPDATE
AS
BEGIN TRANSACTION

	DECLARE @componente		char(8)
	DECLARE @rubro_componente char(4)
	
	SELECT
		@componente = prod_codigo,
		@rubro_componente = prod_rubro
	FROM inserted
	JOIN Composicion on comp_componente = prod_codigo
	
	IF EXISTS	(
					SELECT
						prod_rubro
					FROM Producto
					JOIN Composicion on comp_producto = prod_codigo
					WHERE
						comp_componente = @componente
						AND prod_rubro != @rubro_componente
				)
		RAISERROR ('ERROR, UN PRODUCTO NO PUEDE ESTAR COMPUESTO POR PRODUCTOS DE DISTINTOS RUBROS AL SUYO', 16, 1)
		ROLLBACK
		RETURN
COMMIT

SELECT PROD.prod_detalle, PROD.prod_codigo, PROD.prod_precio, SUM(COMP.prod_precio * comp_cantidad) as veces_vendido
FROM Composicion

	JOIN Producto COMP ON COMP.prod_codigo = comp_componente
	JOIN Producto PROD ON PROD.prod_codigo = comp_producto
	JOIN item_factura on PROD.prod_codigo = item_producto
	JOIN factura FACT on FACT.fact_tipo + FACT.fact_sucursal + FACT.fact_numero = item_numero + item_sucursal + item_tipo 

WHERE YEAR(fact_fecha) = 2012

GROUP BY PROD.prod_detalle, PROD.prod_precio, PROD.prod_codigo, PROD.prod_rubro, YEAR(FACT.fact_fecha)
HAVING COUNT(comp_componente) >= 0 AND COUNT(DISTINCT PROD.prod_rubro) >= 0
ORDER BY (SELECT SUM(comp_cantidad) FROM composicion WHERE comp_producto = PROD.prod_codigo AND YEAR(FACT.fact_fecha) = 2012) DESC