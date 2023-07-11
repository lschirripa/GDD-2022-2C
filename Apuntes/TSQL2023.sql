-- 1. Hacer una función que dado un artículo y un deposito devuelva un string que
-- indique el estado del deposito según el artículo. Si la cantidad almacenada es
-- menor al límite retornar “OCUPACION DEL DEPOSITO XX %” siendo XX el
-- % de ocupación. Si la cantidad almacenada es mayor o igual al límite retornar
-- “DEPOSITO COMPLETO”. stock

ALTER FUNCTION newfunc1(@articulo VARCHAR(8), @deposito CHAR(2))
RETURNS CHAR(200)
AS
BEGIN

DECLARE @porcentaje DECIMAL(12,2)

(
    SELECT @porcentaje = s.stoc_cantidad*100/s.stoc_stock_maximo 
    FROM STOCK S where s.stoc_producto = @articulo AND s.stoc_deposito = @deposito
)
RETURN
    CASE WHEN (@porcentaje < 100)
        THEN 'deposito con ' +  CONVERT(Varchar(10),@porcentaje) + '% de capacidad'
    ELSE
        'MAX CAPACITY'
    END
END

SELECT dbo.newfunc1('00000030','00')
SELECT dbo.newfunc1('00000106','00')

-- realizar una funcion que dado un articulo y una fecha, retorne el stock que existia a esa fecha

CREATE FUNCTION Ejercicio2(@art varchar(8), @fecha DATETIME)

RETURNS DECIMAL(12,2)
AS
BEGIN

RETURN (
    SELECT
        sum(S.stoc_cantidad)
    FROM STOCK S
    WHERE S.stoc_producto = @art
)
+
(
    SELECT SUM(i.item_cantidad)
    FROM Item_Factura I
    JOIN Factura f ON f.fact_numero+f.fact_sucursal+f.fact_tipo = i.item_numero+i.item_sucursal+i.item_tipo
    WHERE i.item_producto = @art AND F.fact_fecha <= @fecha
)

END

SELECT dbo.Ejercicio2('00001415','2012-01-23')

-- realizar un stored proc que reciba un CODIGO de producto y una FECHA
-- y devuelva la mayor cantidad de dias consecutivos a partir de esa fecha
-- que el producto tuvo al menos la venta de una unidad en el dia,
-- el sistema de ventas online esta habilitado 24/7 por lo que se deben evaluar
-- todos los dias incluyendo domingos y feriados

ALTER PROCEDURE NEWProcParcial(@codigo VARCHAR(8), @fecha VARCHAR(7))
AS
BEGIN

DECLARE @fecha_proxima VARCHAR(10) = (
    SELECT TOP 1
    F.fact_fecha
    FROM FACTURA F
    JOIN Item_Factura ON item_numero+item_tipo+item_sucursal=fact_numero+fact_tipo+fact_sucursal
    WHERE F.fact_fecha > @fecha
    AND item_producto = @codigo
    ORDER BY F.fact_fecha ASC
)

DECLARE @cant_dias VARCHAR(10) = convert(decimal(12,2), @fecha_proxima, 126) - convert(decimal(12,2), @fecha, 126)

RETURN @cant_dias

END

BEGIN TRANSACTION
EXECUTE dbo.NEWProcParcial('00010200','2011-01-23')
ROLLBACK

-- 3. Cree el/los objetos de base de datos necesarios para corregir la tabla empleado
-- en caso que sea necesario. Se sabe que debería existir un único gerente general
-- (debería ser el único empleado sin jefe). Si detecta que hay más de un empleado
-- sin jefe deberá elegir entre ellos el gerente general, el cual será seleccionado por
-- mayor salario. Si hay más de uno se seleccionara el de mayor antigüedad en la
-- empresa. Al finalizar la ejecución del objeto la tabla deberá cumplir con la regla
-- de un único empleado sin jefe (el gerente general) y deberá retornar la cantidad
-- de empleados que había sin jefe antes de la ejecución.


--UPDATE Empleado  SET empl_jefe =NULL WHERE empl_codigo =2 OR empl_codigo =3

ALTER PROCEDURE NEWFunc3
AS
BEGIN

DECLARE @gerente decimal(12,2)

SELECT TOP 1 @gerente =
e.empl_codigo
FROM Empleado E 
ORDER BY e.empl_salario DESC,e.empl_ingreso ASC

DECLARE @cant decimal(12,2) = (
    SELECT
    COUNT(1)
    FROM Empleado
    WHERE empl_jefe is NULL
    AND
    empl_codigo != @gerente
)

UPDATE EMPLEADO SET empl_jefe = @gerente WHERE empl_jefe is NULL

PRINT('HABIA ' + CONVERT(VARCHAR(10), @cant) + ' empleados SIN JEFE')

END

BEGIN TRANSACTION
EXECUTE dbo.NewFunc3
ROLLBACK

-- 4. Cree el/los objetos de base de datos necesarios para actualizar la columna de
-- empleado empl_comision con la sumatoria del total de lo vendido por ese
-- empleado a lo largo del último año. Se deberá retornar el código del vendedor
-- que más vendió (en monto) a lo largo del último año

CREATE PROCEDURE NEWProc4
AS
BEGIN

DECLARE @Empl_que_mas_vendio varchar(8) = (
    SELECT TOP 1
        F.fact_vendedor AS total
    FROM Factura F
    WHERE YEAR(F.fact_fecha) = (SELECT TOP 1 YEAR(F2.fact_fecha) AS anio FROM FACTURA F2 ORDER BY anio DESC)
    GROUP BY F.fact_vendedor
    ORDER BY total DESC
)

UPDATE Empleado SET empl_comision = (
    SELECT SUM(F.fact_total) as total
    FROM FACTURA F
    WHERE YEAR(F.fact_fecha) = 2012 AND empl_codigo = f.fact_vendedor
    GROUP BY F.fact_vendedor
)

END

BEGIN TRANSACTION
EXECUTE dbo.NEWProc4
ROLLBACK

/*5. Realizar un procedimiento que complete con los datos existentes en el modelo
provisto la tabla de hechos denominada Fact_table tiene las siguiente definición:
Create table Fact_table
( anio char(4),
mes char(2),
familia char(3),
rubro char(4),
zona char(3),
cliente char(6),
producto char(8),
cantidad decimal(12,2),
monto decimal(12,2)
)
Alter table Fact_table
Add constraint primary key(anio,mes,familia,rubro,zona,cliente,producto)*/


IF OBJECT_ID('Fact_table','U') IS NOT NULL 
DROP TABLE Fact_table
GO
Create table Fact_table
(
anio char(4) NOT NULL, --YEAR(fact_fecha)
mes char(2) NOT NULL, --RIGHT('0' + convert(varchar(2),MONTH(fact_fecha)),2)
familia char(3) NOT NULL,--prod_familia
rubro char(4) NOT NULL,--prod_rubro
zona char(3) NOT NULL,--depa_zona
cliente char(6) NOT NULL,--fact_cliente
producto char(8) NOT NULL,--item_producto
cantidad decimal(12,2) NOT NULL,--item_cantidad
monto decimal(12,2)--asumo que es item_precio debido a que es por cada producto, 
				   --asumo tambien que el precio ya esta determinado por total y no por unidad (no debe multiplicarse por cantidad)
)
Alter table Fact_table
Add constraint pk_Fact_table_ID primary key(anio,mes,familia,rubro,zona,cliente,producto)
GO

IF OBJECT_ID('Ejercicio5','P') IS NOT NULL
DROP PROCEDURE Ejercicio5
GO

CREATE PROCEDURE Ejercicio5
AS
BEGIN
	INSERT INTO Fact_table
	SELECT YEAR(fact_fecha)
		,RIGHT('0' + convert(varchar(2),MONTH(fact_fecha)),2)
		,prod_familia
		,prod_rubro
		,depa_zona
		,fact_cliente
		,prod_codigo
		,SUM(item_cantidad)
		,sum(item_precio)
	FROM Factura F
		INNER JOIN Item_Factura IFACT
			ON IFACT.item_tipo =f.fact_tipo AND IFACT.item_sucursal = F.fact_sucursal AND IFACT.item_numero = F.fact_numero
		INNER JOIN Producto P
			ON P.prod_codigo = IFACT.item_producto
		INNER JOIN Empleado E
			ON E.empl_codigo = F.fact_vendedor
		INNER JOIN Departamento D
			ON D.depa_codigo = E.empl_departamento
	GROUP BY YEAR(fact_fecha)
		,RIGHT('0' + convert(varchar(2),MONTH(fact_fecha)),2)
		,prod_familia
		,prod_rubro
		,depa_zona
		,fact_cliente
		,prod_codigo
END
GO

/*
EXEC Ejercicio5

SELECt * 
FROM Fact_table*/


/*7. Hacer un procedimiento que dadas dos fechas complete la tabla Ventas. Debe
insertar una línea por cada artículo con los movimientos de stock generados por
las ventas entre esas fechas. La tabla se encuentra creada y vacía.*/

IF OBJECT_ID('Ventas','U') IS NOT NULL 
DROP TABLE Ventas
GO
Create table Ventas
(
vent_codigo char(8) NULL, --Código del articulo
vent_detalle char(50) NULL, --Detalle del articulo
vent_movimientos int NULL, --Cantidad de movimientos de ventas (Item Factura)
vent_precio_prom decimal(12,2) NULL, --Precio promedio de venta
vent_renglon int IDENTITY(1,1) PRIMARY KEY, --Nro de linea de la tabla (PK)
vent_ganancia char(6) NOT NULL, --Precio de venta - Cantidad * Costo Actual
)
/*
Alter table Ventas
Add constraint pk_ventas_ID primary key(vent_renglon)
GO*/

if OBJECT_ID('Ejercicio7','P') is not null
DROP PROCEDURE Ejercicio7
GO

CREATE PROCEDURE Ejercicio7 (@StartingDate date, @FinishingDate date)
AS
BEGIN
	DECLARE @Codigo char(8), @Detalle char(50), @Cant_Mov int, @Precio_de_venta decimal(12,2), @Renglon int, @Ganancia decimal(12,2)
	DECLARE cursor_articulos CURSOR
		FOR SELECT prod_codigo
			,prod_detalle
			,SUM(item_cantidad)
			,AVG(item_precio)
			,SUM(item_cantidad*item_precio)
			FROM Producto
				INNER JOIN Item_Factura
					ON item_producto = prod_codigo
				INNER JOIN Factura
					ON fact_tipo = item_tipo AND fact_sucursal = fact_sucursal AND fact_numero = item_numero
			WHERE fact_fecha BETWEEN @StartingDate AND @FinishingDate
			GROUP BY prod_codigo,prod_detalle

		OPEN cursor_articulos
		SET @renglon = 0

		FETCH NEXT FROM cursor_articulos
		INTO @Codigo,@Detalle,@Cant_Mov,@Precio_de_venta,@Ganancia

		WHILE @@FETCH_STATUS = 0
		BEGIN
			--SET @Renglon = @Renglon + 1
			INSERT INTO Ventas
			VALUES (@Codigo,@Detalle,@Cant_Mov,@Precio_de_venta,@Ganancia)
			FETCH NEXT FROM cursor_articulos
			INTO @Codigo,@Detalle,@Cant_Mov,@Precio_de_venta,@Ganancia
		END
		CLOSE cursor_articulos
		DEALLOCATE cursor_articulos
	END
GO


/*
EXEC Ejercicio7 '2012-01-01','2012-07-01'
*/
--------cursor test--------


-- declaro el cursor
DECLARE cursor1 CURSOR
    FOR SELECT * FROM Factura

-- abro el cursor
open cursor1

-- abrir el cursor y navegar
FETCH NEXT FROM cursor1

-- cerrar el cursor
CLOSE cursor1

-- liberar el cursor
DEALLOCATE cursor1

--------cursor test 2--------
BEGIN

DECLARE 
@codigo_fact VARCHAR(8),
@fact_fecha DATETIME

DECLARE cursor1 CURSOR --SCROLL (allows to go back and forth (fetch prior, first, last, next))) -- GLOBAL OR LOCAL (LOCAL BY DEFAULT)
    FOR SELECT fact_numero+fact_tipo+fact_sucursal, fact_fecha FROM Factura
open cursor1
FETCH cursor1 INTO @codigo_fact, @fact_fecha

WHILE(@@FETCH_STATUS=0)
    BEGIN

    PRINT(@codigo_fact + ' ' + CONVERT(VARCHAR(10),@fact_fecha,103))
    FETCH cursor1 INTO @codigo_fact, @fact_fecha

    END

CLOSE cursor1
DEALLOCATE cursor1

END

-- convert 126 -> 2010-01-23
-- convert 103 -> 23/01/2010


-- 9. Crear el/los objetos de base de datos que ante alguna modificación de un ítem de
-- factura de un artículo con com`posición realice el movimiento de sus
-- correspondientes componentes.

DROP TRIGGER Ejercicio9

ALTER TRIGGER Ejercicio9 ON item_factura FOR INSERT
AS
IF (SELECT COUNT(*)
	FROM inserted I
	WHERE I.item_producto IN (
								SELECT comp_producto
								FROM Composicion
							)
	) > 0
	BEGIN
		DECLARE @Codigo char(8), @Cantidad INT, @Deposito char(2)
		DECLARE cursor_insert CURSOR
			FOR SELECT S.stoc_producto
					,S.stoc_cantidad
					,S.stoc_deposito
				FROM STOCK S
					INNER JOIN Composicion C
						ON C.comp_componente = S.stoc_producto
				WHERE S.stoc_producto IN (SELECT Comp_componente
										FROM Composicion
										INNER JOIN inserted
											ON item_producto = comp_producto
											)
					AND S.stoc_deposito = (
											SELECT RIGHT(item_sucursal,2)
											FROM inserted
											WHERE C.comp_producto = item_producto
											)

				GROUP BY S.stoc_producto,S.stoc_cantidad,S.stoc_deposito

		OPEN cursor_insert
		FETCH NEXT FROM cursor_insert
		INTO @Codigo,@cantidad,@Deposito
		WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE STOCK 
				SET stoc_cantidad = stoc_cantidad - @cantidad
				WHERE stoc_producto = @Codigo AND stoc_deposito = @Deposito
				FETCH NEXT FROM cursor_insert
				INTO @Codigo,@cantidad,@Deposito
		END
		CLOSE cursor_insert
		DEALLOCATE cursor_insert

	END
GO


/*
select * from Item_Factura
where item_producto IN (SELECT comp_producto
						FROM Composicion)

SELECT * from stock
where stoc_producto IN (SELECT comp_producto
						FROM Composicion)
						*/

                        /*
EXEC Ejercicio7 '2012-01-01','2012-07-01'
*/


-- 9. Crear el/los objetos de base de datos que ante alguna modificación de un ítem de
-- factura de un artículo con composición realice el movimiento de sus
-- correspondientes componentes.

-- DROP TRIGGER Ejercicio9

CREATE TRIGGER Ejercicio9 ON item_factura FOR INSERT
AS
IF (SELECT COUNT(*)
	FROM inserted I
	WHERE I.item_producto IN (
								SELECT comp_producto
								FROM Composicion
							)
	) > 0                                                           -- si hay algun producto que tenga composicion
	BEGIN
		DECLARE @Codigo char(8), @Cantidad INT, @Deposito char(2) 
		DECLARE cursor_insert CURSOR
			FOR SELECT S.stoc_producto
					,S.stoc_cantidad
					,S.stoc_deposito
				FROM STOCK S
					INNER JOIN Composicion C
						ON C.comp_componente = S.stoc_producto
				WHERE S.stoc_producto IN (SELECT Comp_componente
										FROM Composicion
										INNER JOIN inserted
											ON item_producto = comp_producto
											) -- todos los productos que son componentes de los productos que se insertaron
					AND S.stoc_deposito = (
											SELECT RIGHT(item_sucursal,2)
											FROM inserted
											WHERE C.comp_producto = item_producto
											)

				GROUP BY S.stoc_producto,S.stoc_cantidad,S.stoc_deposito

		OPEN cursor_insert
		FETCH NEXT FROM cursor_insert
		INTO @Codigo,@cantidad,@Deposito
		WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE STOCK 
				SET stoc_cantidad = stoc_cantidad - @cantidad
				WHERE stoc_producto = @Codigo AND stoc_deposito = @Deposito
				FETCH NEXT FROM cursor_insert
				INTO @Codigo,@cantidad,@Deposito
		END
		CLOSE cursor_insert
		DEALLOCATE cursor_insert

	END
GO


/*
select * from Item_Factura
where item_producto IN (SELECT comp_producto
						FROM Composicion)

SELECT * from stock
where stoc_producto IN (SELECT comp_producto
						FROM Composicion)
						*/



-- 10. Crear el/los objetos de base de datos que ante el intento de borrar un artículo
-- verifique que no exista stock y si es así lo borre en caso contrario que emita un
-- mensaje de error.

ALTER TRIGGER TR_10 ON PRODUCTO INSTEAD OF DELETE
AS
BEGIN

IF EXISTS(
    SELECT 1
    FROM deleted d
    WHERE d.prod_codigo IN 
        (
        SELECT prod_codigo FROM PRODUCTO JOIN STOCK S ON S.stoc_producto = d.prod_codigo
        WHERE s.stoc_cantidad > 0
        )
    ) 
    BEGIN
        RAISERROR('No se puede borrar un producto con stock', 16, 1);
    END


ELSE
    BEGIN
        DELETE FROM STOCK
            WHERE stoc_producto IN (
                                    SELECT prod_codigo
                                    FROM deleted)
        DELETE FROM Producto
            WHERE prod_codigo IN (
                                    SELECT prod_codigo
                                    FROM deleted)
    END

END

SELECT prod_codigo, stoc_cantidad FROM Producto JOIN STOCK ON stoc_producto = prod_codigo where stoc_cantidad = 0

DELETE FROM PRODUCTO WHERE prod_codigo = '00000030'	--10.00
SELECT * FROM PRODUCTO join stock on stoc_producto = prod_codigo WHERE prod_codigo = '00000030'	--10.00

DELETE FROM PRODUCTO WHERE prod_codigo = '00000173'	--00.00
SELECT * FROM PRODUCTO JOIN STOCK ON stoc_producto = prod_codigo WHERE prod_codigo = '00000173' 	--00.00

-------------------------

/*10. Crear el/los objetos de base de datos que ante el intento de borrar un artículo
verifique que no exista stock y si es así lo borre en caso contrario que emita un
mensaje de error.*/

ALTER TRIGGER TR_10 ON Producto INSTEAD OF DELETE
AS
BEGIN

IF(
	SELECT SUM(S.stoc_cantidad)
	FROM STOCK S
		INNER JOIN deleted D
			ON D.prod_codigo = S.stoc_producto
	GROUP BY S.stoc_producto
	) > 0
	BEGIN
		PRINT 'No se puede borrar porque el articulo tiene stock'
		ROLLBACK TRANSACTION
	END
ELSE 
	BEGIN
	DELETE FROM STOCK
		WHERE stoc_producto IN (
								SELECT prod_codigo
								FROM deleted)
	DELETE FROM Producto
		WHERE prod_codigo IN (
								SELECT prod_codigo
								FROM deleted)
	END
END

/*
DELETE FROM Producto WHERE prod_codigo = '00003821'

SELECT * FROM Producto join stock on stoc_producto = prod_codigo where prod_codigo = '00003821'

DELETE FROM Producto WHERE prod_codigo = '00006247'

SELECT * FROM Producto join stock on stoc_producto = prod_codigo where stoc_producto = '00006247'

select stoc_producto,SUM(stoc_cantidad)
from STOCK
	INNER JOIN Producto
		ON prod_codigo = stoc_producto
GROUP BY stoc_producto
ORDER BY 2

*/


-- considerando que una factura puede representar una venta (importe mayor a cero) o una nota de credito (importe menor a cero). Cree el/los objetos de base de datos
-- necesarios para automatiza el procedimiento de facturacion, de tal manera que se desencadenen las siguientes operaciones sin intervencion del usuario:
-- 1. si es una venta, verificar si hay stock disponible y descontar el deposito que mas tiene. En el caso que al descontar, el deposito quede por debajo
-- del limite de reposicion, imprimir por pantalla una alerta que diga "codigo producto - codigo deposito - REQUIERE REPOSICION" solo se interrumpira el proceso
-- de facturacion si no hay stock suficiente en ningun deposito. No se debe dejar stock en negativo

-- 2. Si es una nota de credito, actualizar la cantidad en el deposito que menos unidades tenga. si no hay unidades en inugn deposito, asignarle el deposito de menor codigo

-- 3. por ultimo actualizar la comision del vendedor en la tabla Empleado con el siguiente indice: monto total facturado * (anios de antiguedad del empleado / 100)

-- esta incompleto, falta todo

CREATE TRIGGER TR_PARCIAL_MANIANA ON FACTURA INSTEAD OF INSERT
AS 
BEGIN 

DECLARE @prod varchar(8) = (
    SELECT item_producto
        FROM INSERTED I
    JOIN Item_Factura ON item_numero+item_tipo+item_sucursal = I.fact_numero+I.fact_tipo+I.fact_sucursal
    ) -- codigo del producto INSERTADO

DECLARE @cant_insertada INT = (
    SELECT item_cantidad
        FROM INSERTED I
    JOIN Item_Factura ON item_numero+item_tipo+item_sucursal = I.fact_numero+I.fact_tipo+I.fact_sucursal
    ) -- cantidad INSERTADA
    

DECLARE @depo_que_mas_tiene VARCHAR(2) = (
    SELECT TOP 1 stoc_deposito 
    FROM STOCK
    WHERE stoc_producto = @prod
    ORDER BY stoc_cantidad DESC
    )



IF(
    SELECT SUM(stoc_cantidad)
    FROM STOCK
    WHERE stoc_producto = @prod
    ) > 0  -- si hay stock disponible

    BEGIN
        IF(
            (SELECT
                SUM(stoc_cantidad)
            FROM STOCK
            WHERE stoc_deposito = @depo_que_mas_tiene
        ) - @cant_insertada ) > 0   -- si al descontar, NO QUEDA NEGATIVO
        BEGIN
            UPDATE STOCK SET stoc_cantidad = stoc_cantidad - 1
            WHERE stoc_producto = @prod AND stoc_deposito = @depo_que_mas_tiene
        END
        ELSE
        RAISERROR('Codigo producto - codigo deposito - REQUIERE REPOSICION', 16, 1)
        ROLLBACK TRANSACTION
    END


END

/*30. Agregar el/los objetos necesarios para crear una regla por la cual un cliente no
pueda comprar más de 100 unidades en el mes de ningún producto, si esto
ocurre no se deberá ingresar la operación y se deberá emitir un mensaje “Se ha
superado el límite máximo de compra de un producto”. Se sabe que esta regla se
cumple y que las facturas no pueden ser modificadas.*/
--aniomes: (SELECT convert(varchar(4),YEAR(fact_fecha)) + '-'+ convert(varchar(2),MONTH(fact_fecha))) AS aniomes
-- SELECT convert(varchar(7), fact_fecha, 126) FROM FACTURA


ALTER TRIGGER TR_30 ON Item_Factura INSTEAD OF INSERT
AS
BEGIN

DECLARE @aniomes_inserted VARCHAR(7) = (
    SELECT convert(varchar(7), fact_fecha, 126) FROM INSERTED JOIN Factura ON item_numero+item_tipo+item_sucursal = fact_numero+fact_tipo+fact_sucursal
)

DECLARE @producto_inserted VARCHAR(8) = (
    SELECT I.item_producto FROM INSERTED I
)

DECLARE @cliente VARCHAR(5) = (
    SELECT fact_cliente FROM INSERTED I
    JOIN FACTURA ON I.item_numero+I.item_tipo+I.item_sucursal = factura.fact_numero+factura.fact_tipo+factura.fact_sucursal
)

DECLARE @cant_cursor int = 0
DECLARE @conteo_productos_mes int = 0

DECLARE cursor_limite_mes CURSOR FOR
    SELECT 
        SUM(item_cantidad)
    FROM Item_Factura
    JOIN Factura ON item_numero+item_tipo+item_sucursal = fact_numero+fact_tipo+fact_sucursal
    WHERE 
        fact_cliente = @cliente 
        AND
        CONVERT(varchar(7), fact_fecha, 126) = @aniomes_inserted
    GROUP BY fact_cliente, CONVERT(varchar(7), fact_fecha, 126), item_producto

OPEN cursor_limite_mes
FETCH NEXT FROM cursor_limite_mes INTO @cant_cursor
WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @conteo_productos_mes = @conteo_productos_mes + @cant_cursor 
        IF(@conteo_productos_mes > 100)
            BEGIN
                RAISERROR('EL CLIENTE HA SUPERADO LA COMPRA DE 100 PRODUCTOS POR MES', 16, 1)
            END

        FETCH NEXT FROM cursor_limite_mes INTO @cant_cursor
    END 

CLOSE cursor_limite_mes
DEALLOCATE cursor_limite_mes

IF (@conteo_productos_mes + (SELECT SUM(item_cantidad) FROM INSERTED) <= 100)
BEGIN
    INSERT INTO Item_Factura
    SELECT * FROM INSERTED
END
ELSE
BEGIN
    RAISERROR('EL CLIENTE CON ESTQ COMPRA SUPERA LOS 100 PRODUCTOS POR MES', 16, 1)
END


PRINT(@producto_inserted)
PRINT(@cliente)
PRINT(@aniomes_inserted)
print(@conteo_productos_mes)


END
