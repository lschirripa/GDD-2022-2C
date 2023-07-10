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


-- IF OBJECT_ID('Fact_table','U') IS NOT NULL 
-- DROP TABLE Fact_table
-- GO
-- Create table Fact_table
-- (
-- anio char(4) NOT NULL, --YEAR(fact_fecha)
-- mes char(2) NOT NULL, --RIGHT('0' + convert(varchar(2),MONTH(fact_fecha)),2)
-- familia char(3) NOT NULL,--prod_familia
-- rubro char(4) NOT NULL,--prod_rubro
-- zona char(3) NOT NULL,--depa_zona
-- cliente char(6) NOT NULL,--fact_cliente
-- producto char(8) NOT NULL,--item_producto
-- cantidad decimal(12,2) NOT NULL,--item_cantidad
-- monto decimal(12,2)--asumo que es item_precio debido a que es por cada producto, 
-- 				   --asumo tambien que el precio ya esta determinado por total y no por unidad (no debe multiplicarse por cantidad)
-- )
-- Alter table Fact_table
-- Add constraint pk_Fact_table_ID primary key(anio,mes,familia,rubro,zona,cliente,producto)
-- GO

-- IF OBJECT_ID('Ejercicio5','P') IS NOT NULL
-- DROP PROCEDURE Ejercicio5
-- GO

-- CREATE PROCEDURE Ejercicio5
-- AS
-- BEGIN
-- 	INSERT INTO Fact_table
-- 	SELECT YEAR(fact_fecha)
-- 		,RIGHT('0' + convert(varchar(2),MONTH(fact_fecha)),2)
-- 		,prod_familia
-- 		,prod_rubro
-- 		,depa_zona
-- 		,fact_cliente
-- 		,prod_codigo
-- 		,SUM(item_cantidad)
-- 		,sum(item_precio)
-- 	FROM Factura F
-- 		INNER JOIN Item_Factura IFACT
-- 			ON IFACT.item_tipo =f.fact_tipo AND IFACT.item_sucursal = F.fact_sucursal AND IFACT.item_numero = F.fact_numero
-- 		INNER JOIN Producto P
-- 			ON P.prod_codigo = IFACT.item_producto
-- 		INNER JOIN Empleado E
-- 			ON E.empl_codigo = F.fact_vendedor
-- 		INNER JOIN Departamento D
-- 			ON D.depa_codigo = E.empl_departamento
-- 	GROUP BY YEAR(fact_fecha)
-- 		,RIGHT('0' + convert(varchar(2),MONTH(fact_fecha)),2)
-- 		,prod_familia
-- 		,prod_rubro
-- 		,depa_zona
-- 		,fact_cliente
-- 		,prod_codigo
-- END
-- GO

-- /*
-- EXEC Ejercicio5

-- SELECt * 
-- FROM Fact_table*/





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
		FOR SELECT 
            prod_codigo
			,prod_detalle
			,SUM(item_cantidad)
			,AVG(item_precio)
			,SUM(item_cantidad*item_precio)
			FROM Producto
				INNER JOIN Item_Factura
					ON item_producto = prod_codigo
				INNER JOIN Factura
					ON fact_tipo = item_tipo AND fact_sucursal = fact_sucursal AND fact_numero = item_numero
			-- WHERE fact_fecha BETWEEN @StartingDate AND @FinishingDate
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

select * from Factura
order by fact_fecha desc

select * from ventas*/


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
