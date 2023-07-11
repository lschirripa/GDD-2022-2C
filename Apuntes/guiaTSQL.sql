-- 1. Hacer una función que dado un artículo y un deposito devuelva un string que
-- indique el estado del deposito según el artículo. Si la cantidad almacenada es
-- menor al límite retornar “OCUPACION DEL DEPOSITO XX %” siendo XX el
-- % de ocupación. Si la cantidad almacenada es mayor o igual al límite retornar
-- “DEPOSITO COMPLETO”. stock

CREATE FUNCTION 23func1(@articulo VARCHAR(8), @deposito CHAR(2))
RETURNS CHAR(200)
AS
BEGIN

DECLARE @porcentaje DECIMAL(12,2)

(
    SELECT @porcentaje = SELECT s.stoc_cantidad*100/s.stoc_stock_maximo 
    FROM STOCK S where s.stoc_producto = @articulo AND s.stoc_deposito = @deposito
)

IF (@porcentaje < 100)
    RETURN 'deposito con' +  CONVERT(Varchar(10),@porcentaje) '% de capacidad'
ELSE
    RETURN 'MAX CAPACITY'

END

CREATE FUNCTION Func1(@art VARCHAR(8), @depo char(2))
RETURNS CHAR(200)
AS
BEGIN
DECLARE @porcentaje DECIMAL(12,2)
(
    SELECT @porcentaje =  s.stoc_cantidad*100/s.stoc_stock_maximo FROM STOCK S
    WHERE s.stoc_producto = @art AND s.stoc_deposito = @depo
)
IF (@porcentaje < 100)
    BEGIN
    return 'ocupacion del deposito al %'+ CONVERT(Varchar(10),@porcentaje)
    END

RETURN 'deposito completo'

END

SELECT dbo.Func1('00000030','00')
SELECT dbo.Func1('00000106','00')

-- ---otra sol

CREATE FUNCTION dbo.Ejercicio1 (@art varchar(8),@depo char(2))

RETURNS varchar(30)

AS
BEGIN 
	DECLARE @result DECIMAL(12,2)
	(
		SELECT @result = ISNULL((S.stoc_cantidad*100) / S.stoc_stock_maximo,0)
		FROM STOCK S
		WHERE S.stoc_producto = @art AND S.stoc_deposito = @depo
	)
RETURN
	CASE
		WHEN @result < 100
		THEN 
			('Ocupacion del Deposito: ' + CONVERT(varchar(10),@result) + '%')
		ELSE
			'Deposito Completo'
	END
END
GO

select dbo.Ejercicio1('00000102','16')

-- 3. Cree el/los objetos de base de datos necesarios para corregir la tabla empleado
-- en caso que sea necesario. Se sabe que debería existir un único gerente general
-- (debería ser el único empleado sin jefe). Si detecta que hay más de un empleado
-- sin jefe deberá elegir entre ellos el gerente general, el cual será seleccionado por
-- mayor salario. Si hay más de uno se seleccionara el de mayor antigüedad en la
-- empresa. Al finalizar la ejecución del objeto la tabla deberá cumplir con la regla
-- de un único empleado sin jefe (el gerente general) y deberá retornar la cantidad
-- de empleados que había sin jefe antes de la ejecución.

-- ALTER PROCEDURE proc3
-- AS
-- BEGIN
-- DECLARE @EMPL_elegido VARCHAR(2)
-- DECLARE @cant int

-- SELECT
--     @cant = count(e.empl_codigo)
--     FROM Empleado E
-- WHERE e.empl_jefe is NULL

-- IF @cant > 1

-- BEGIN
     
--     print 'entered to if clause'

--     SELECT 
--         TOP 1 @EMPL_elegido = e.empl_codigo
--         FROM EMPLEADO E
--     WHERE e.empl_jefe is NULL
--     ORDER BY e.empl_salario DESC, e.empl_ingreso ASC

--     UPDATE Empleado SET empl_jefe = @EMPL_elegido  WHERE empl_jefe is NULL and empl_codigo <> @EMPL_elegido

-- END
--     print 'there were'  + convert(varchar(2),@cant-1) + 'unnasigned employees'
-- END


-- UPDATE EMPLEADO set empl_ingreso = '2001-01-03'  where empl_codigo = 10
-- INSERT INTO EMPLEADO VALUES(11,'pobre','dwt',1978-01-01,'2001-01-03','testPROC',250,0,NULL,1)

-- BEGIN TRANSACTION
-- EXEC proc3
-- ROLLBACK


---same solucion
-- ALTER PROC Ejercicio3 (@Modif int OUTPUT)
-- AS
-- BEGIN
-- DECLARE @GerenteGral numeric(6,0) = ( 
-- 										SELECT TOP 1 empl_codigo
-- 										FROM Empleado
-- 										ORDER BY empl_salario DESC, empl_ingreso ASC
-- 									)
-- SET @Modif = ( 
-- 										SELECT count(*)
-- 										FROM Empleado E
-- 										WHERE E.empl_jefe IS NULL
-- 											AND empl_codigo <> @GerenteGral
-- 									)
-- IF 	@Modif > 1 
	
-- 	UPDATE Empleado SET empl_jefe = @GerenteGral
-- 	WHERE empl_jefe IS NULL
-- 		AND empl_codigo <> @GerenteGral

-- --ELSE PRINT 'Solo hay un Gerente General'

-- --SELECT @Modif AS [Rows Modificadas]
-- RETURN
-- END

-- 4. Cree el/los objetos de base de datos necesarios para actualizar la columna de
-- empleado empl_comision con la sumatoria del total de lo vendido por ese
-- empleado a lo largo del último año. Se deberá retornar el código del vendedor
-- que más vendió (en monto) a lo largo del último año.

-- CREATE PROCEDURE proc4 
-- AS 
-- BEGIN

-- UPDATE EMPLEADO SET empl_comision = (

--                                     SELECT sum(f.fact_total) FROM FACTURA F
--                                     WHERE YEAR(F.fact_fecha) =(
--                                                             SELECT DISTINCT TOP 1 
--                                                             YEAR(F2.fact_fecha) FROM FACTURA F2
--                                                             ORDER BY YEAR(F2.fact_fecha) DESC 
--                                                         )
--                                     AND
--                                     f.fact_vendedor = empl_codigo
                                    
--                                     )

-- SELECT (
--         SELECT TOP 1 e.empl_nombre FROM FACTURA F
--         JOIN Item_Factura IFF ON f.fact_numero+f.fact_sucursal+f.fact_tipo = iff.item_numero+iff.item_sucursal+iff.item_tipo
--         JOIN Empleado e ON f.fact_vendedor = empl_codigo
--         GROUP BY e.empl_nombre
--         order by count(distinct f.fact_numero) DESC
--         )
-- RETURN
-- END

-- BEGIN TRANSACTION
--   EXEC proc4
-- ROLLBACK

------------------otra sol



-- ALTER PROC Ejercicio4
--     (@EmplQueMasVendio numeric(6,0) OUTPUT)
-- AS
-- BEGIN
    /*SET @EmplQueMasVendio = (
										SELECT TOP 1 empl_codigo
										FROM Empleado
											INNER JOIN Factura
												ON fact_vendedor = empl_codigo
												WHERE YEAR(fact_fecha) = (
																			SELECT TOP 1 YEAR(fact_fecha)
																			FROM Factura
																			ORDER BY fact_fecha DESC
																			)
												GROUP BY empl_codigo
												ORDER BY SUM(fact_total) DESC
										
										)*/

--     UPDATE Empleado Set empl_comision = 

--     (
-- 	SELECT SUM(F.fact_total)
--     FROM Factura F
--     WHERE YEAR(fact_fecha) =    (
--                                     SELECT TOP 1
--                                     YEAR(fact_fecha)
--                                     FROM Factura
--                                     ORDER BY fact_fecha DESC
--                                 )   
--     AND F.fact_vendedor = empl_codigo 
-- 	)

--     set @EmplQueMasVendio = (SELECT TOP 1
--         empl_codigo
--     FROM Empleado
--     ORDER BY empl_comision DESC)
--     RETURN
-- END

-- BEGIN TRANSACTION
--     DECLARE @vendedor_que_mas_vendio numeric(6,0)
--     EXEC Ejercicio4 @EmplQueMasVendio = @vendedor_que_mas_vendio OUTPUT
--     SELECT @vendedor_que_mas_vendio AS [Vendedor que mas vendio]
-- ROLLBACK

/*
SELECT E.empl_codigo,SUM(F.fact_total)
FROM Factura F
	INNER JOIN Empleado E
		ON E.empl_codigo = F.fact_vendedor
WHERE YEAR(fact_fecha) = (
							SELECT TOP 1 YEAR(fact_fecha)
							FROM Factura
							ORDER BY fact_fecha DESC
							)
GROUP BY E.empl_codigo
ORDER BY 2 DESC
*/

-- 31. Desarrolle el o los objetos de base de datos necesarios, para que un jefe no pueda
-- tener más de 20 empleados a cargo, directa o indirectamente, si esto ocurre
-- debera asignarsele un jefe que cumpla esa condición, si no existe un jefe para
-- asignarle se le deberá colocar como jefe al gerente general que es aquel que no
-- tiene jefe.

/*30. Agregar el/los objetos necesarios para crear una regla por la cual un cliente no
pueda comprar más de 100 unidades en el mes de ningún producto, si esto
ocurre no se deberá ingresar la operación y se deberá emitir un mensaje “Se ha
superado el límite máximo de compra de un producto”. Se sabe que esta regla se
cumple y que las facturas no pueden ser modificadas.*/

alter TRIGGER ej30
ON Item_Factura 
AFTER INSERT --logica a aplicar el trigger
AS
BEGIN TRANSACTION

    declare @item varchar(10)
    declare @item_cant decimal (12,2)
    declare @cliente varchar(10)
    declare @fact_fecha VARCHAR(7)
    declare @suma_total_de_unidades decimal(12,2)

    DECLARE mi_cursor CURSOR FOR select item_producto, sum(item_cantidad), convert(varchar(7), fact_fecha, 126), fact_cliente
	from inserted i
JOIN Factura f ON f.fact_numero+f.fact_sucursal+f.fact_tipo = i.item_numero+i.item_sucursal+i.item_tipo
    group by item_producto, convert(varchar(7), convert(varchar(7), fact_fecha, 126), 126), fact_cliente

            -- Query sobre en que el cursor va a iterar


    OPEN mi_cursor
    --apunta al prinicpio
    FETCH mi_cursor INTO @item, @item_cant, @fact_fecha, @cliente
    -- se va a la siguiente fila y a donde esta posicionado, me carga las x variables que le asigne



    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT  @item
        PRINT  @item_cant
        PRINT  convert(varchar(7), @fact_fecha, 126)
        PRINT  @cliente


        set @suma_total_de_unidades = (SELECT sum(IFF2.item_cantidad)
                                    FROM Factura f2 
                                    JOIN Item_Factura iff2 ON f2.fact_numero+f2.fact_sucursal+f2.fact_tipo = iff2.item_numero+iff2.item_sucursal+iff2.item_tipo
                                    where f2.fact_cliente = @cliente and convert(varchar(7), f2.fact_fecha, 126) = convert(varchar(7), @fact_fecha, 126)
                                    )
        -- Query para la logica del trigger



        FETCH NEXT FROM mi_cursor
        INTO @item, @item_cant, @fact_fecha, @cliente
        
        PRINT  isnull(@suma_total_de_unidades,0)

        IF @suma_total_de_unidades > 100
        BEGIN
        PRINT 'CON ESTA COMPRA SE ALCANZA EL LIMITE DE COMPRA DE UNA UNIDAD X MES. USTED ANTES TENIA: ' + CONVERT(VARCHAR(8),@suma_total_de_unidades - @item_cant)
        ROLLBACK
        END

    END

    CLOSE mi_cursor
    DEALLOCATE mi_cursor

COMMIT

BEGIN TRANSACTION

INSERT INTO Item_Factura VALUES('A','0003','00068710','00002814',11,1)

select * from factura where factura.fact_numero = '00068710'
SELECT sum(item_cantidad) FROM Item_Factura WHERE item_numero = '00068710' 

-- DELETE FROM Item_Factura WHERE Item_Factura.item_numero = '00068710' AND Item_Factura.item_producto = '00002814'

 


-- A	0003	00068710	2010-01-23 00:00:00	4	105.73	18.33	01634 
-- o
-- 87.3600


-- 29. Desarrolle el/los elementos de base de datos necesarios para que se cumpla
-- automaticamente la regla de que una factura no puede contener productos que
-- sean componentes de diferentes productos. En caso de que esto ocurra no debe
-- grabarse esa factura y debe emitirse un error en pantalla.

CREATE TRIGGER TG29 
ON Item_Factura
AFTER INSERT
AS
BEGIN TRANSACTION

DECLARE @comp VARCHAR(8)

SET @comp = (SELECT i.item_producto FROM inserted i)

IF @comp IN (
        SELECT C.comp_componente FROM Composicion C
        GROUP by C.comp_componente
        having count(distinct c.comp_producto) > 1
        )
BEGIN
    PRINT 'error'
    ROLLBACK
    RETURN
END


COMMIT

begin TRANSACTION
insert into Composicion VALUES(1,'00001104','00001475')
rollback

insert into Item_Factura VALUES('A','0003','00092444','00001475',1,1)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------EJS RESUELTOS GUIA DRIVE----------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*1. Hacer una función que dado un artículo y un deposito devuelva un string que
indique el estado del depósito según el artículo. Si la cantidad almacenada es
menor al límite retornar “OCUPACION DEL DEPOSITO XX %” siendo XX el
% de ocupación. Si la cantidad almacenada es mayor o igual al límite retornar
“DEPOSITO COMPLETO”.*/

CREATE FUNCTION dbo.Ejercicio1 (@art varchar(8),@depo char(2))

RETURNS varchar(30)

AS
BEGIN 
	DECLARE @result DECIMAL(12,2)
	(
		SELECT @result = ISNULL((S.stoc_cantidad*100) / S.stoc_stock_maximo,0)
		FROM STOCK S
		WHERE S.stoc_producto = @art AND S.stoc_deposito = @depo
	)
RETURN
	CASE
		WHEN @result < 100
		THEN 
			('Ocupacion del Deposito: ' + CONVERT(varchar(10),@result) + '%')
		ELSE
			'Deposito Completo'
	END
END
GO
/*
SELECT dbo.Ejercicio1('00000102','00')

SELECT dbo.Ejercicio2('00000102','2011-18-08 00:00:00')
*/

/*2. Realizar una función que dado un artículo y una fecha, retorne el stock que
existía a esa fecha*/

CREATE FUNCTION Ejercicio2 (@art varchar(8),@date datetime)

RETURNS decimal(12,2)

AS
BEGIN
RETURN
	(
		SELECT SUM(stoc_cantidad)
		FROM STOCK S
		WHERE S.stoc_producto = @art
	)
	+
	(
		SELECT SUM(item_cantidad)
		FROM Item_Factura IFACT
			INNER JOIN Factura F
				ON F.fact_tipo = IFACT.item_tipo AND F.fact_sucursal = IFACT.item_sucursal AND F.fact_numero = IFACT.item_numero
		WHERE IFACT.item_producto = @art AND F.fact_fecha <= @date
	) 
END
GO

/*3. Cree el/los objetos de base de datos necesarios para corregir la tabla empleado
en caso que sea necesario. Se sabe que debería existir un único gerente general
(debería ser el único empleado sin jefe). Si detecta que hay más de un empleado
sin jefe deberá elegir entre ellos el gerente general, el cual será seleccionado por
mayor salario. Si hay más de uno se seleccionara el de mayor antigüedad en la
empresa. Al finalizar la ejecución del objeto la tabla deberá cumplir con la regla
de un único empleado sin jefe (el gerente general) y deberá retornar la cantidad
de empleados que había sin jefe antes de la ejecución.*/

ALTER PROC Ejercicio3 (@Modif int OUTPUT)
AS
BEGIN
DECLARE @GerenteGral numeric(6,0) = ( 
										SELECT TOP 1 empl_codigo
										FROM Empleado
										ORDER BY empl_salario DESC, empl_ingreso ASC
									)
SET @Modif = ( 
										SELECT count(*)
										FROM Empleado E
										WHERE E.empl_jefe IS NULL
											AND empl_codigo <> @GerenteGral
									)
IF 	@Modif > 1 
	
	UPDATE Empleado SET empl_jefe = @GerenteGral
	WHERE empl_jefe IS NULL
		AND empl_codigo <> @GerenteGral

--ELSE PRINT 'Solo hay un Gerente General'

--SELECT @Modif AS [Rows Modificadas]
RETURN
END

/*
INSERT INTO Empleado
VALUES (10,'Pablo','Delucchi','1991-01-01 00:00:00','2000-01-01 00:00:00','Gerente',29000,0,NULL,1)*/

/*
DECLARE @Modiff int
SET @Modiff = 0
EXEC Ejercicio3 @Modiff
PRINT @Modiff
*/

/*
UPDATE Empleado SET empl_jefe = NULL
WHERE empl_codigo IN (1,10,11)
*/

/*
select * from Empleado
*/


/*3. Cree el/los objetos de base de datos necesarios para corregir la tabla empleado
en caso que sea necesario. Se sabe que debería existir un único gerente general
(debería ser el único empleado sin jefe). Si detecta que hay más de un empleado
sin jefe deberá elegir entre ellos el gerente general, el cual será seleccionado por
mayor salario. Si hay más de uno se seleccionara el de mayor antigüedad en la
empresa. Al finalizar la ejecución del objeto la tabla deberá cumplir con la regla
de un único empleado sin jefe (el gerente general) y deberá retornar la cantidad
de empleados que había sin jefe antes de la ejecución.*/

ALTER PROC Ejercicio3v2

AS
DECLARE @GerenteGral numeric(6,0) = ( 
										SELECT TOP 1 empl_codigo
										FROM Empleado
										ORDER BY empl_salario DESC, empl_ingreso ASC
									)
DECLARE @Modif numeric(6,0)

WHILE (
		SELECT COUNT(*)
		FROM Empleado E
		WHERE E.empl_jefe IS NULL
	) > 1 
BEGIN
UPDATE Empleado SET empl_jefe = @GerenteGral
	WHERE empl_jefe IS NULL
		AND empl_codigo <> @GerenteGral

SET @Modif = @Modif + 1
PRINT @Modif
END


EXEC Ejercicio3v2


/*3. Cree el/los objetos de base de datos necesarios para corregir la tabla empleado
en caso que sea necesario. Se sabe que debería existir un único gerente general
(debería ser el único empleado sin jefe). Si detecta que hay más de un empleado
sin jefe deberá elegir entre ellos el gerente general, el cual será seleccionado por
mayor salario. Si hay más de uno se seleccionara el de mayor antigüedad en la
empresa. Al finalizar la ejecución del objeto la tabla deberá cumplir con la regla
de un único empleado sin jefe (el gerente general) y deberá retornar la cantidad
de empleados que había sin jefe antes de la ejecución.*/

CREATE PROC Ejercicio3v3 (@Modif int OUTPUT)
AS
BEGIN
DECLARE @GerenteGral numeric(6,0) = ( 
										SELECT TOP 1 empl_codigo
										FROM Empleado
										ORDER BY empl_salario DESC, empl_ingreso ASC
									)
SET @Modif = ( 
										SELECT count(*)
										FROM Empleado E
										WHERE E.empl_jefe IS NULL
											AND empl_codigo <> @GerenteGral
									)	
UPDATE Empleado SET empl_jefe = @GerenteGral
WHERE empl_jefe IS NULL
	AND empl_codigo <> @GerenteGral

--ELSE PRINT 'Solo hay un Gerente General'

--SELECT @Modif AS [Rows Modificadas]
RETURN
END

DECLARE @Cant_de_empl_sin_jefe_modificados int
EXEC Ejercicio3v3 @Modif = @Cant_de_empl_sin_jefe_modificados OUTPUT
SELECT @Cant_de_empl_sin_jefe_modificados AS [Cant de filas afectadas]


UPDATE Empleado SET empl_jefe = NULL
WHERE empl_codigo IN (1,10,11)


/*4. Cree el/los objetos de base de datos necesarios para actualizar la columna de
empleado empl_comision con la sumatoria del total de lo vendido por ese
empleado a lo largo del último año. Se deberá retornar el código del vendedor
que más vendió (en monto) a lo largo del último año.*/

ALTER PROC Ejercicio4 (@EmplQueMasVendio numeric(6,0) OUTPUT)
AS
BEGIN
/*SET @EmplQueMasVendio = (
										SELECT TOP 1 empl_codigo
										FROM Empleado
											INNER JOIN Factura
												ON fact_vendedor = empl_codigo
												WHERE YEAR(fact_fecha) = (
																			SELECT TOP 1 YEAR(fact_fecha)
																			FROM Factura
																			ORDER BY fact_fecha DESC
																			)
												GROUP BY empl_codigo
												ORDER BY SUM(fact_total) DESC
										
										)*/

UPDATE Empleado Set empl_comision = (
										SELECT SUM(F.fact_total)
										FROM Factura F
												WHERE YEAR(fact_fecha) = (
																			SELECT TOP 1 YEAR(fact_fecha)
																			FROM Factura
																			ORDER BY fact_fecha DESC
																			)
													AND F.fact_vendedor = empl_codigo 
									)

set @EmplQueMasVendio = (SELECT TOP 1 empl_codigo
						   FROM Empleado
						   ORDER BY empl_comision DESC)
RETURN
END


DECLARE @vendedor_que_mas_vendio numeric(6,0)
EXEC Ejercicio4 @EmplQueMasVendio = @vendedor_que_mas_vendio OUTPUT
SELECT @vendedor_que_mas_vendio AS [Vendedor que mas vendio]

/*
SELECT E.empl_codigo,SUM(F.fact_total)
FROM Factura F
	INNER JOIN Empleado E
		ON E.empl_codigo = F.fact_vendedor
WHERE YEAR(fact_fecha) = (
							SELECT TOP 1 YEAR(fact_fecha)
							FROM Factura
							ORDER BY fact_fecha DESC
							)
GROUP BY E.empl_codigo
ORDER BY 2 DESC
*/

SELECT * FROM Empleado


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


/*6. Realizar un procedimiento que si en alguna factura se facturaron componentes
que conforman un combo determinado (o sea que juntos componen otro
producto de mayor nivel), en cuyo caso deberá reemplazar las filas
correspondientes a dichos productos por una sola fila con el producto que
componen con la cantidad de dicho producto que corresponda.*/


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

select * from Factura
order by fact_fecha desc

select * from ventas*/



/*8. Realizar un procedimiento que complete la tabla Diferencias de precios, para los
productos facturados que tengan composición y en los cuales el precio de
facturación sea diferente al precio del cálculo de los precios unitarios por
cantidad de sus componentes, se aclara que un producto que compone a otro,
también puede estar compuesto por otros y así sucesivamente, la tabla se debe
crear y está formada por las siguientes columnas:*/

IF OBJECT_ID('Diferencias','U') IS NOT NULL 
DROP TABLE Diferencias
GO

CREATE TABLE Diferencias
(
	dif_codigo char(8) NULL
	,dif_detalle char(50) NULL
	,dif_cantidad int NULL
	,dif_precio_generado decimal(12,2) NULL
	,dif_precio_facturado decimal(12,2) NULL
)

if OBJECT_ID('Ejercicio8','P') is not null
DROP PROCEDURE Ejercicio8
GO

CREATE PROCEDURE Ejercicio8
AS
BEGIN
	DECLARE @codigo char(8),@detalle char(50),@cantidad int,@precio_generado decimal(12,2),@precio_facturado decimal(12,2)
	DECLARE cursor_diferencia CURSOR
		FOR SELECT IFACT.item_producto
					,P.prod_detalle
					,(
						SELECT COUNT(comp_producto)
						FROM Composicion
						WHERE comp_producto = IFACT.item_producto
						)
					,(
						SELECT SUM(prod_precio * comp_cantidad)
						FROM Producto
							INNER JOIN Composicion
								ON comp_componente = prod_codigo
						WHERE comp_producto = IFACT.item_producto
					)
					,SUM(IFACT.item_precio)
				FROM Producto P
					INNER JOIN Item_Factura IFACT
						ON IFACT.item_producto = P.prod_codigo
				WHERE IFACT.item_producto IN (
												SELECT comp_producto
												FROM Composicion )
				GROUP BY IFACT.item_tipo+IFACT.item_sucursal+IFACT.item_numero,IFACT.item_producto,P.prod_detalle
				HAVING SUM(IFACT.item_producto * IFACT.item_cantidad) <> (
																				SELECT SUM(prod_precio * comp_cantidad)
																				FROM Producto
																					INNER JOIN Composicion
																						ON comp_componente = prod_codigo
																				WHERE comp_producto = IFACT.item_producto
																				)
			OPEN cursor_diferencia
			FETCH NEXT FROM cursor_diferencia
			INTO @codigo,@detalle,@cantidad,@precio_generado,@precio_facturado
			
			WHILE @@FETCH_STATUS = 0
			BEGIN
				INSERT INTO Diferencias
				VALUES (@codigo,@detalle,@cantidad,@precio_generado,@precio_facturado)
				FETCH NEXT FROM cursor_diferencia
				INTO @codigo,@detalle,@cantidad,@precio_generado,@precio_facturado
			END
			CLOSE cursor_diferencia
			DEALLOCATE cursor_diferencia
		END
	GO


	EXEC Ejercicio8

	select * from diferencias


/*8. Realizar un procedimiento que complete la tabla Diferencias de precios, para los
productos facturados que tengan composición y en los cuales el precio de
facturación sea diferente al precio del cálculo de los precios unitarios por
cantidad de sus componentes, se aclara que un producto que compone a otro,
también puede estar compuesto por otros y así sucesivamente, la tabla se debe
crear y está formada por las siguientes columnas:*/

IF OBJECT_ID('Diferencias2','U') IS NOT NULL 
DROP TABLE Diferencias2
GO

CREATE TABLE Diferencias2
(
	dif_codigo char(8) NULL
	,dif_detalle char(50) NULL
	,dif_cantidad int NULL
	,dif_precio_generado decimal(12,2) NULL
	,dif_precio_facturado decimal(12,2) NULL
)

if OBJECT_ID('Ejercicio8v2','P') is not null
DROP PROCEDURE Ejercicio8v2
GO

CREATE PROCEDURE Ejercicio8v2
AS
BEGIN
	INSERT INTO Diferencias2
		SELECT IFACT.item_producto
					,P.prod_detalle
					,(
						SELECT COUNT(comp_producto)
						FROM Composicion
						WHERE comp_producto = IFACT.item_producto
						)
					,(
						SELECT SUM(prod_precio * comp_cantidad)
						FROM Producto
							INNER JOIN Composicion
								ON comp_componente = prod_codigo
						WHERE comp_producto = IFACT.item_producto
					)
					,IFACT.item_precio
				FROM Producto P
					INNER JOIN Item_Factura IFACT
						ON IFACT.item_producto = P.prod_codigo
				WHERE IFACT.item_producto IN (
												SELECT comp_producto
												FROM Composicion )
				GROUP BY --IFACT.item_tipo+IFACT.item_sucursal+IFACT.item_numero,
				IFACT.item_producto,P.prod_detalle,IFACT.item_precio
				HAVING SUM(IFACT.item_producto * IFACT.item_cantidad) <> (
																				SELECT SUM(prod_precio * comp_cantidad)
																				FROM Producto
																					INNER JOIN Composicion
																						ON comp_componente = prod_codigo
																				WHERE comp_producto = IFACT.item_producto
																				)
		END
	GO


	/*EXEC Ejercicio8v2

	select * from diferencias2*/


/*9. Crear el/los objetos de base de datos que ante alguna modificación de un ítem de
factura de un artículo con composición realice el movimiento de sus
correspondientes componentes.*/

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


/*9. Crear el/los objetos de base de datos que ante alguna modificación de un ítem de
factura de un artículo con composición realice el movimiento de sus
correspondientes componentes.*/

ALTER TRIGGER Ejercicio9v2 ON item_factura FOR UPDATE
AS
BEGIN
	DECLARE @prod char(8), @cant decimal(12,2), @comp char(8), @cantComp decimal(12,2), @depo char(2)
	DECLARE cursor_update CURSOR FOR SELECT I.item_producto
											,SUM(I.item_cantidad - D.item_cantidad) 
									FROM inserted I join deleted D 
										on I.item_tipo+I.item_sucursal+I.item_numero = D.item_tipo+D.item_sucursal+D.item_numero
											AND I.item_producto = D.item_producto, Composicion C
									WHERE I.item_cantidad <> D.item_cantidad AND I.item_producto = C.comp_producto
									GROUP BY I.item_producto
	OPEN cursor_update
	FETCH NEXT FROM cursor_update 
	INTO @prod,@cant
	WHILE @@FETCH_STATUS = 0
	BEGIN
		DECLARE cursor_comp CURSOR FOR SELECT comp_componente,comp_cantidad
										FROM Composicion
										WHERE comp_producto = @prod
		OPEN cursor_comp
		FETCH NEXT FROM cursor_comp
		INTO @comp,@cantComp
		WHILE @@FETCH_STATUS = 0
		BEGIN 
			SET @depo = (
							SELECT TOP 1 stoc_deposito
							FROM STOCK
							WHERE stoc_producto = @comp
								AND stoc_cantidad > @cant*@cantComp
							) 
			UPDATE STOCK SET stoc_cantidad = stoc_cantidad - @cant*@cantComp
				WHERE stoc_deposito = @depo
			FETCH NEXT FROM cursor_comp
			INTO @comp,@cantComp
			END
			CLOSE cursor_comp
			DEALLOCATE cursor_comp
	FETCH NEXT FROM cursor_update 
	INTO @prod,@cant
	END
	CLOSE cursor_update
	DEALLOCATE cursor_update
END
GO




/*
SELECT *
FROM Item_Factura,Composicion
WHERE item_producto = comp_producto*/

select * from Item_Factura


/*10. Crear el/los objetos de base de datos que ante el intento de borrar un artículo
verifique que no exista stock y si es así lo borre en caso contrario que emita un
mensaje de error.*/

ALTER TRIGGER Ejercicio10 ON Producto INSTEAD OF DELETE
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
		ROLLBACK TRANSACTION
		PRINT 'No se puede borrar porque el articulo tiene stock'
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

SELECT * FROM Producto where prod_codigo = '00003821'

DELETE FROM Producto WHERE prod_codigo = '00006247'

SELECT * FROM Producto where prod_codigo = '00006247'

select stoc_producto,SUM(stoc_cantidad)
from STOCK
	INNER JOIN Producto
		ON prod_codigo = stoc_producto
GROUP BY stoc_producto
ORDER BY 2

*/


/*11. Cree el/los objetos de base de datos necesarios para que dado un código de
empleado se retorne la cantidad de empleados que este tiene a su cargo (directa o
indirectamente). Solo contar aquellos empleados (directos o indirectos) que
tengan un código mayor que su jefe directo.*/

CREATE FUNCTION dbo.Ejercicio11v4 (@Jefe numeric(6,0))
RETURNS int

AS
BEGIN
	DECLARE @CantEmplACargo int = 0
	DECLARE @JefeAux numeric(6,0) = @Jefe
	DECLARE @CodEmplAux numeric(6,0)
	

	IF NOT EXISTS (SELECT * FROM EMPLEADO WHERE empl_jefe = @Jefe)
	BEGIN
		RETURN @CantEmplACargo
	END

	SET @CantEmplACargo = (
							SELECT COUNT(*)
							FROM Empleado
							WHERE empl_jefe = @Jefe AND empl_codigo > @Jefe)

	DECLARE cursor_empleado CURSOR FOR SELECT E.empl_codigo
										FROM Empleado E
										WHERE empl_jefe = @Jefe
	OPEN cursor_empleado
	FETCH NEXT from cursor_empleado
	INTO @JefeAux
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @CantEmplACargo = @CantEmplACargo + dbo.Ejercicio11v4(@JefeAux)
			
	FETCH NEXT from cursor_empleado
	INTO @JefeAux
	END
	CLOSE cursor_empleado
	DEALLOCATE cursor_empleado

	RETURN @CantEmplACargo
END
GO

SELECT dbo.Ejercicio11v4(6)



/*12. Cree el/los objetos de base de datos necesarios para que nunca un producto
pueda ser compuesto por sí mismo. Se sabe que en la actualidad dicha regla se
cumple y que la base de datos es accedida por n aplicaciones de diferentes tipos
y tecnologías. No se conoce la cantidad de niveles de composición existentes.*/

CREATE FUNCTION dbo.Ejercicio12Func(@Componente char(8))
RETURNS BIT

AS
BEGIN
	DECLARE @ProdAux char(8)

	IF EXISTS ( SELECT *
				FROM Composicion
				WHERE comp_producto = @Componente
				)
		BEGIN
			RETURN 1
		END
	DECLARE cursor_componente CURSOR FOR SELECT C.comp_producto
										FROM Composicion C
										WHERE C.comp_componente = @Componente
	OPEN cursor_componente
	FETCH NEXT from cursor_componente
	INTO @ProdAux
	WHILE @@FETCH_STATUS = 0
		BEGIN
			IF(dbo.Ejercicio12Func(@Componente)) = 1 -- ACA COMO LLAMO A LA EJECUCION DE LA MISMA FUNCION???
			BEGIN
				Return 1
			END
		FETCH NEXT from cursor_componente
		INTO @ProdAux
		END
	CLOSE cursor_componente
	DEALLOCATE cursor_componente
	RETURN 0
	END
GO

CREATE TRIGGER Ejercicio12 ON COMPOSICION AFTER INSERT
AS
BEGIN
	IF EXISTS (SELECT comp_producto FROM inserted WHERE dbo.Ejercicio12Func(comp_producto) = 1)
		BEGIN
			PRINT 'Un producto no puede componerse a si mismo ni ser parte de un producto que se compone a si mismo'
			ROLLBACK TRANSACTION
			RETURN
		END
END
GO

SELECT * FROM Composicion

INSERT INTO Composicion
VALUES(1, '00001104','00001104')



/*
13. Cree el/los objetos de base de datos necesarios para implantar la siguiente regla
“Ningún jefe puede tener un salario mayor al 20% de las suma de los salarios de
sus empleados totales (directos + indirectos)”. Se sabe que en la actualidad dicha
regla se cumple y que la base de datos es accedida por n aplicaciones de
diferentes tipos y tecnologías
*/

ALTER FUNCTION dbo.Ejercicio13Func (@Jefe numeric(6,0))
RETURNS decimal(12,2)

AS
BEGIN
	DECLARE @SueldoEmpl decimal(12,2)
	DECLARE @JefeAux numeric(6,0) = @Jefe
	DECLARE @CodEmplAux numeric(6,0)
	
	
	IF NOT EXISTS (SELECT * FROM EMPLEADO WHERE empl_jefe = @Jefe)
	BEGIN
		SET @SueldoEmpl = 0
		RETURN @SueldoEmpl
	/*
		SET @SueldoEmpl = (
							SELECT empl_salario
							FROM Empleado
							WHERE empl_codigo = @Jefe
							)
		RETURN @SueldoEmpl
	*/
	END

	SET @SueldoEmpl = (
						SELECT SUM(empl_salario)
						FROM Empleado
						WHERE empl_jefe = @Jefe  --AND empl_codigo > @Jefe
						)

	DECLARE cursor_empleado CURSOR FOR SELECT E.empl_codigo
										FROM Empleado E
										WHERE empl_jefe = @Jefe
	OPEN cursor_empleado
	FETCH NEXT from cursor_empleado
	INTO @JefeAux
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @SueldoEmpl = @SueldoEmpl + dbo.Ejercicio13Func(@JefeAux)
			
	FETCH NEXT from cursor_empleado
	INTO @JefeAux
	END
	CLOSE cursor_empleado
	DEALLOCATE cursor_empleado

	RETURN @SueldoEmpl
END
GO

CREATE TRIGGER Ejercicio13 ON Empleado AFTER INSERT,UPDATE
AS
BEGIN
	IF EXISTS(
		SELECT I.empl_codigo
		FROM inserted I
		WHERE I.empl_salario >  (dbo.Ejercicio13Func(I.empl_salario) * 0.2)
		)
		BEGIN
			PRINT 'Un jefe no puede superar el 20% de la suma del sueldo total de sus empleados'
			ROLLBACK
		END
	END
GO


/*
13.v2. Cree el/los objetos de base de datos necesarios para implantar la siguiente regla
“Ningún jefe puede tener un salario mayor al 20% de las suma de los salarios de
sus empleados totales (directos + indirectos)”. Se sabe que en la actualidad dicha
regla se cumple y que la base de datos es accedida por n aplicaciones de
diferentes tipos y tecnologías
*/


ALTER FUNCTION dbo.Ejercicio13Func2 (@Jefe numeric(6,0))
RETURNS decimal(12,2)
AS
BEGIN
       DECLARE @SueldoEmpl decimal(12,2)
       DECLARE @JefeAux numeric(6,0) = @Jefe
       DECLARE @CodEmplAux numeric(6,0)

       IF NOT EXISTS (SELECT * FROM EMPLEADO WHERE empl_jefe = @Jefe)
       BEGIN
              --SET @SueldoEmpl = 0
              RETURN @SueldoEmpl
       END
       SET @SueldoEmpl = (SELECT SUM(dbo.Ejercicio13Func2(empl_salario))
                                           FROM Empleado
                                           WHERE empl_jefe = @Jefe  --AND empl_codigo > @Jefe
                                           )
       RETURN @SueldoEmpl
END
GO

SELECT dbo.Ejercicio13Func2(2)

SELECT * from Empleado

ALTER TRIGGER Ejercicio13v2 ON Empleado AFTER INSERT, UPDATE
AS
BEGIN
	IF EXISTS(
		SELECT I.empl_codigo
		FROM inserted I
		WHERE I.empl_salario >  (dbo.Ejercicio13Func2(I.empl_salario) * 0.2)
		)
		BEGIN
			PRINT 'Un jefe no puede superar el 20% de la suma del sueldo total de sus empleados'
			ROLLBACK
		END
	END
GO

SELECT dbo.Ejercicio13Func(2)



/*15. Cree el/los objetos de base de datos necesarios para que el objeto principal
reciba un producto como parametro y retorne el precio del mismo.
Se debe prever que el precio de los productos compuestos sera la sumatoria de
los componentes del mismo multiplicado por sus respectivas cantidades. No se
conocen los nivles de anidamiento posibles de los productos. Se asegura que
nunca un producto esta compuesto por si mismo a ningun nivel. El objeto
principal debe poder ser utilizado como filtro en el where de una sentencia
select.*/

Alter FUNCTION dbo.ejercicio15 (@producto char(8))
RETURNS decimal(12,2)
AS
BEGIN
	DECLARE @precioProd decimal(12,2) = 0
	DECLARE @prodCompuesto char(8)
	DECLARE @cantProdCompuesto decimal(12,2)
	IF NOT EXISTS(SELECT * FROM Composicion WHERE comp_producto = @producto)
	BEGIN
		SET @precioProd = (
							SELECT prod_precio
							FROM Producto
							WHERE prod_codigo = @producto
							)
		RETURN @precioProd
	END
	ELSE
	BEGIN
		DECLARE cursor_prod CURSOR FOR SELECT comp_componente,comp_cantidad
										FROM Composicion
										WHERE comp_producto = @producto
		OPEN cursor_prod
		FETCH NEXT FROM cursor_prod
		INTO @prodCompuesto,@cantProdCompuesto
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @precioProd = @precioProd + (
												SELECT prod_precio
												FROM Producto
												WHERE prod_codigo = @prodCompuesto
												) * @cantProdCompuesto
		FETCH NEXT FROM cursor_prod
		INTO @prodCompuesto,@cantProdCompuesto
		END
		CLOSE cursor_prod
		DEALLOCATE cursor_prod
		RETURN @precioProd
	END
	RETURN @precioProd
END
GO

select * from Composicion

select dbo.ejercicio15('00001104')

select * from Producto
where prod_codigo = '00001718'


/*15v2. Cree el/los objetos de base de datos necesarios para que el objeto principal
reciba un producto como parametro y retorne el precio del mismo.
Se debe prever que el precio de los productos compuestos sera la sumatoria de
los componentes del mismo multiplicado por sus respectivas cantidades. No se
conocen los nivles de anidamiento posibles de los productos. Se asegura que
nunca un producto esta compuesto por si mismo a ningun nivel. El objeto
principal debe poder ser utilizado como filtro en el where de una sentencia
select.*/

ALTER FUNCTION dbo.ejercicio15 (@producto char(8))
RETURNS decimal(12,2)
AS
BEGIN
	RETURN dbo.precioCompuesto3(@producto)
END
GO


CREATE FUNCTION dbo.precioCompuesto3 (@producto char(8))
RETURNS decimal(12,2)
AS
BEGIN
	DECLARE @precioProd decimal(12,2) = 0
	DECLARE @prodCompuesto char(8)
	DECLARE @cantProdCompuesto decimal(12,2)
	IF NOT EXISTS(SELECT * FROM Composicion WHERE comp_producto = @producto)
	BEGIN
		SET @precioProd = (
							SELECT prod_precio
							FROM Producto
							WHERE prod_codigo = @producto
							)
		RETURN @precioProd
	END
	ELSE
	BEGIN
		DECLARE cursor_prod CURSOR FOR SELECT comp_componente,comp_cantidad
										FROM Composicion
										WHERE comp_producto = @producto
		OPEN cursor_prod
		FETCH NEXT FROM cursor_prod
		INTO @prodCompuesto,@cantProdCompuesto
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @precioProd = @precioProd + dbo.precioCompuesto3(@prodCompuesto) * @cantProdCompuesto
		FETCH NEXT FROM cursor_prod
		INTO @prodCompuesto,@cantProdCompuesto
		END
		CLOSE cursor_prod
		DEALLOCATE cursor_prod
		RETURN @precioProd
	END
	RETURN @precioProd
END
GO


/*
ALTER FUNCTION dbo.ejercicio15 (@producto char(8))
RETURNS decimal(12,2)
AS
BEGIN
	DECLARE @precioProd decimal(12,2) = 0
	DECLARE @prodCompuesto char(8)
	DECLARE @cantProdCompuesto decimal(12,2)
		DECLARE cursor_prod CURSOR FOR SELECT comp_componente,comp_cantidad
										FROM Composicion
										WHERE comp_producto = @producto
		OPEN cursor_prod
		FETCH NEXT FROM cursor_prod
		INTO @prodCompuesto,@cantProdCompuesto
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @precioProd = @precioProd + dbo.precioCompuesto3(@prodCompuesto) * @cantProdCompuesto
		FETCH NEXT FROM cursor_prod
		INTO @prodCompuesto,@cantProdCompuesto
		END
		CLOSE cursor_prod
		DEALLOCATE cursor_prod
		RETURN @precioProd	
END
GO
*/


/*select * from Composicion

select dbo.ejercicio15('00001104')

select * from Producto
where prod_codigo = '00001718'*/

/*
Alter FUNCTION dbo.ejercicio15 (@producto char(8))
RETURNS decimal(12,2)
AS
BEGIN
	DECLARE @precioProd decimal(12,2) = 0
	DECLARE @prodCompuesto char(8)
	DECLARE @cantProdCompuesto decimal(12,2)
	IF NOT EXISTS(SELECT * FROM Composicion WHERE comp_producto = @producto)
	BEGIN
		SET @precioProd = (
							SELECT prod_precio
							FROM Producto
							WHERE prod_codigo = @producto
							)
		RETURN @precioProd
	END
	ELSE
	BEGIN
		DECLARE cursor_prod CURSOR FOR SELECT comp_componente,comp_cantidad
										FROM Composicion
										WHERE comp_producto = @producto
		OPEN cursor_prod
		FETCH NEXT FROM cursor_prod
		INTO @prodCompuesto,@cantProdCompuesto
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @precioProd = @precioProd + (
												SELECT prod_precio
												FROM Producto
												WHERE prod_codigo = @prodCompuesto
												) * @cantProdCompuesto
		FETCH NEXT FROM cursor_prod
		INTO @prodCompuesto,@cantProdCompuesto
		END
		CLOSE cursor_prod
		DEALLOCATE cursor_prod
		RETURN @precioProd
	END
	RETURN @precioProd
END
GO
*/


/*16. Desarrolle el/los elementos de base de datos necesarios para que ante una venta
automaticamante se descuenten del stock los articulos vendidos. Se descontaran
del deposito que mas producto poseea y se supone que el stock se almacena
tanto de productos simples como compuestos (si se acaba el stock de los
compuestos no se arman combos)
En caso que no alcance el stock de un deposito se descontara del siguiente y asi
hasta agotar los depositos posibles. En ultima instancia se dejara stock negativo
en el ultimo deposito que se desconto.*/


CREATE TRIGGER Ejercicio16 ON item_factura FOR INSERT
AS
BEGIN
	DECLARE @prod char(8), @cant decimal(12,2), @comp char(8), @cantComp decimal(12,2), @depo char(2)
	DECLARE cursor_update CURSOR FOR SELECT I.item_producto
											,SUM(I.item_cantidad - D.item_cantidad) 
									FROM inserted I join deleted D 
										on I.item_tipo+I.item_sucursal+I.item_numero = D.item_tipo+D.item_sucursal+D.item_numero
											AND I.item_producto = D.item_producto
									WHERE I.item_cantidad <> D.item_cantidad
									GROUP BY I.item_producto

	OPEN cursor_update
	FETCH NEXT FROM cursor_update 
	INTO @prod,@cant
	WHILE @@FETCH_STATUS = 0
		IF (dbo.EsProductoCompuesto(@prod)) = 1
			BEGIN
				DECLARE cursor_comp CURSOR FOR SELECT comp_componente,comp_cantidad
											FROM Composicion
											WHERE comp_producto = @prod
				OPEN cursor_comp
				FETCH NEXT FROM cursor_comp
				INTO @comp,@cantComp
				WHILE @@FETCH_STATUS = 0
				BEGIN 
					SET @depo = (
									SELECT TOP 1 stoc_deposito
									FROM STOCK
									WHERE stoc_producto = @comp
										AND stoc_cantidad > @cant*@cantComp
									) 
					UPDATE STOCK SET stoc_cantidad = stoc_cantidad - @cant*@cantComp
						WHERE stoc_deposito = @depo
				FETCH NEXT FROM cursor_comp
				INTO @comp,@cantComp
				END
				CLOSE cursor_comp
				DEALLOCATE cursor_comp
			END
		ELSE
			BEGIN
					SET @depo = (
									SELECT TOP 1 stoc_deposito
									FROM STOCK
									WHERE stoc_producto = @prod
										AND stoc_cantidad > @cant
									) 
					UPDATE STOCK SET stoc_cantidad = stoc_cantidad - @cant
						WHERE stoc_deposito = @depo
			END
END
GO


/*16.v2 Desarrolle el/los elementos de base de datos necesarios para que ante una venta
automaticamante se descuenten del stock los articulos vendidos. Se descontaran
del deposito que mas producto poseea y se supone que el stock se almacena
tanto de productos simples como compuestos (si se acaba el stock de los
compuestos no se arman combos)
En caso que no alcance el stock de un deposito se descontara del siguiente y asi
hasta agotar los depositos posibles. En ultima instancia se dejara stock negativo
en el ultimo deposito que se desconto.*/


CREATE TRIGGER Ejercicio16 ON item_factura FOR INSERT
AS
BEGIN
	DECLARE @prod char(8), @cant decimal(12,2), @comp char(8), @cantComp decimal(12,2), @depo char(2)
	DECLARE cursor_update CURSOR FOR SELECT I.item_producto
											,SUM(I.item_cantidad - D.item_cantidad) 
									FROM inserted I join deleted D 
										on I.item_tipo+I.item_sucursal+I.item_numero = D.item_tipo+D.item_sucursal+D.item_numero
											AND I.item_producto = D.item_producto
									WHERE I.item_cantidad <> D.item_cantidad
									GROUP BY I.item_producto

	OPEN cursor_update
	FETCH NEXT FROM cursor_update 
	INTO @prod,@cant
	WHILE @@FETCH_STATUS = 0
		IF (dbo.EsProductoCompuesto(@prod)) = 1
			BEGIN
				DECLARE cursor_comp CURSOR FOR SELECT comp_componente,comp_cantidad
											FROM Composicion
											WHERE comp_producto = @prod
				OPEN cursor_comp
				FETCH NEXT FROM cursor_comp
				INTO @comp,@cantComp
				WHILE @@FETCH_STATUS = 0
				BEGIN 
					DECLARE @depo decimal(12,2)
					DECLARE @cantidadDepo decimal (12,2)
					DECLARE @cantidadADescontar decimal (12,2) = @cantComp * @cant
					DECLARE cursor_stock CURSOR FOR SELECT stoc_deposito,stoc_cantidad
													FROM STOCK
													WHERE stoc_producto = @prod
													ORDER BY stoc_cantidad DESC
					OPEN cursor_stock
					FETCH NEXT FROM cursor_stock
					INTO @depo,@cantidadDepo
					WHILE @cantidadADescontar <> 0 OR @@FETCH_STATUS = 0
					BEGIN
						IF @cantidadDepo >= @cantidadADescontar * @cant
						BEGIN
							UPDATE STOCK SET stoc_cantidad = stoc_cantidad - @cantidadADescontar
							WHERE stoc_deposito = @depo
							SET @cantidadADescontar = 0
						END
						IF @cantidadDepo < @cantidadADescontar
						BEGIN
							SET @cantidadADescontar -= @cantidadDepo
							UPDATE STOCK SET stoc_cantidad = 0
							WHERE stoc_deposito = @depo
						END
					FETCH NEXT FROM cursor_stock
					INTO @depo,@cantidadDepo
					END
					CLOSE cursor_stock
					DEALLOCATE cursor_stock
				FETCH NEXT FROM cursor_comp
				INTO @comp,@cantComp
				END
				CLOSE cursor_comp
				DEALLOCATE cursor_comp
			END
		ELSE
			BEGIN
				DECLARE @cantidadADescontarSimple decimal (12,2) = @cant
				DECLARE cursor_stock CURSOR FOR SELECT stoc_deposito,stoc_cantidad
												FROM STOCK
												WHERE stoc_producto = @prod
												ORDER BY stoc_cantidad DESC
				OPEN cursor_stock
				FETCH NEXT FROM cursor_stock
				INTO @depo,@cantidadDepo
				WHILE @cantidadADescontar <> 0 OR @@FETCH_STATUS = 0
				BEGIN
					IF @cantidadDepo >= @cant
					BEGIN
						UPDATE STOCK SET stoc_cantidad = stoc_cantidad - @cantidadADescontarSimple
						WHERE stoc_deposito = @depo
						SET @cantidadADescontarSimple = 0
					END
					IF @cantidadDepo < @cantidadADescontarSimple
					BEGIN
						SET @cantidadADescontarSimple -= @cantidadDepo
						UPDATE STOCK SET stoc_cantidad = 0
						WHERE stoc_deposito = @depo
					END
				FETCH NEXT FROM cursor_stock
				INTO @depo,@cantidadDepo
				END
				CLOSE cursor_stock
				DEALLOCATE cursor_stock

			END
END
GO


/*17. Sabiendo que el punto de reposicion del stock es la menor cantidad de ese objeto
que se debe almacenar en el deposito y que el stock maximo es la maxima
cantidad de ese producto en ese deposito, cree el/los objetos de base de datos
necesarios para que dicha regla de negocio se cumpla automaticamente. No se
conoce la forma de acceso a los datos ni el procedimiento por el cual se
incrementa o descuenta stock*/

CREATE TRIGGER dbo.ejercicio17 ON STOCK	FOR INSERT,UPDATE
AS
BEGIN
	DECLARE @producto CHAR(8),
			@deposito CHAR(8),
			@cantidad DECIMAL (12,2),
			@minimo DECIMAL (12,2),
			@maximo DECIMAL (12,2)

	DECLARE cursor_inserted CURSOR FOR SELECT stoc_cantidad,stoc_punto_reposicion,stoc_stock_maximo,stoc_producto,stoc_deposito
										FROM inserted
	OPEN cursor_inserted
	FETCH NEXT FROM cursor_inserted
	INTO @cantidad,@minimo,@maximo,@producto,@deposito
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @cantidad > @maximo
			BEGIN
				PRINT 'Se está excediendo la cantidad maxima del producto ' + @producto + ' en el deposito ' + @deposito + ' por ' + STR(@cantidad - @maximo) + ' unidades. No se puede realizar la operacion'
				ROLLBACK
			END

		ELSE IF @cantidad < @minimo
			BEGIN
				PRINT 'El producto ' + @producto + ' en el deposito ' + @deposito + ' se encuentra por debajo del minimo. Reponer!'
			END
	FETCH NEXT FROM cursor_inserted
	INTO @cantidad,@minimo,@maximo,@producto,@deposito
	END
	CLOSE cursor_inserted
	DEALLOCATE cursor_inserted
END
GO

/*18. Sabiendo que el limite de credito de un cliente es el monto maximo que se le
puede facturar mensualmente, cree el/los objetos de base de datos necesarios
para que dicha regla de negocio se cumpla automaticamente. No se conoce la
forma de acceso a los datos ni el procedimiento por el cual se emiten las facturas*/

CREATE TRIGGER dbo.ejercicio18 ON FACTURA FOR INSERT
AS
BEGIN
	DECLARE @tipo char(1)
			,@sucursal char(4)
			,@numero char(8)
			,@fecha SMALLDATETIME
			,@vendedor numeric(6,0)
			,@total decimal(12,2)
			,@cliente char(6)
	DECLARE cursor_inserted CURSOR FOR SELECT fact_tipo,fact_sucursal,fact_numero,fact_fecha,fact_vendedor,fact_total,fact_cliente
										FROM inserted
	OPEN cursor_inserted
	FETCH NEXT FROM cursor_inserted
	INTO @tipo,@sucursal,@numero,@fecha,@vendedor,@total,@cliente
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @total > (
						SELECT clie_limite_credito
						FROM Cliente
						WHERE clie_domicilio = @cliente
					)
		BEGIN
			PRINT 'Limite de credito superado para el cliente ' + STR(@cliente)
			ROLLBACK
		END
		ELSE IF @total < (
						SELECT clie_limite_credito
						FROM Cliente
						WHERE clie_domicilio = @cliente
					)
		BEGIN
			UPDATE Cliente SET clie_limite_credito -= @total
			 WHERE clie_codigo = @cliente
		END
	FETCH NEXT FROM cursor_inserted
	INTO @tipo,@sucursal,@numero,@fecha,@vendedor,@total,@cliente
	END
	CLOSE cursor_inserted
	DEALLOCATE cursor_inserted
END
CLOSE
		
	

SELECT * FROM Factura
select * from Cliente


/*19. Cree el/los objetos de base de datos necesarios para que se cumpla la siguiente
regla de negocio automáticamente “Ningún jefe puede tener menos de 5 años de
antigüedad y tampoco puede tener más del 50% del personal a su cargo
(contando directos e indirectos) a excepción del gerente general”. Se sabe que en
la actualidad la regla se cumple y existe un único gerente general.*/

CREATE TRIGGER dbo.ejercicio19 ON Empleado FOR INSERT,UPDATE
AS
BEGIN
	DECLARE @emplCod numeric (6,0),@emplJefe numeric (6,0)
	DECLARE cursor_inserted CURSOR FOR SELECT empl_codigo,empl_jefe
										FROM inserted
	OPEN cursor_inserted
	FETCH NEXT FROM cursor_inserted
	INTO @emplCod,@emplJefe
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF dbo.calculoDeAntiguedad(@emplCod) < 5
		BEGIN
			PRINT 'El empleado no puede tener menos de 5 años de antiguedad'
			ROLLBACK
		END

		ELSE IF dbo.cantidadDeSubordinados(@emplCod) > (
															SELECT COUNT(*)*0.5
															FROM Empleado
															)
				AND @emplJefe <> NULL
		BEGIN
			PRINT 'El empleado no puede tener mas del 50% del personal a su cargo'
			ROLLBACK
		END
	FETCH NEXT FROM cursor_inserted
	INTO @emplCod,@emplJefe
	END
	CLOSE cursor_inserted
	DEALLOCATE cursor_inserted
END
GO


ALTER FUNCTION dbo.calculoDeAntiguedad (@empleado numeric(6,0))
RETURNS int
AS
BEGIN
	DECLARE @todaysDate smalldatetime = GETDATE()
	DECLARE @antiguedad int = 0
	SET @antiguedad = DATEDIFF(year,(SELECT empl_ingreso
										FROM Empleado
										WHERE @empleado = empl_codigo
										),@todaysDate
								)
	RETURN @antiguedad
END
GO

CREATE FUNCTION dbo.cantidadDeSubordinados (@Jefe numeric(6,0))
RETURNS int

AS
BEGIN
	DECLARE @CantEmplACargo int = 0
	DECLARE @JefeAux numeric(6,0) = @Jefe
	DECLARE @CodEmplAux numeric(6,0)
	

	IF NOT EXISTS (SELECT * FROM EMPLEADO WHERE empl_jefe = @Jefe)
	BEGIN
		RETURN @CantEmplACargo
	END

	SET @CantEmplACargo = (
							SELECT COUNT(*)
							FROM Empleado
							WHERE empl_jefe = @Jefe AND empl_codigo > @Jefe)

	DECLARE cursor_empleado CURSOR FOR SELECT E.empl_codigo
										FROM Empleado E
										WHERE empl_jefe = @Jefe
	OPEN cursor_empleado
	FETCH NEXT from cursor_empleado
	INTO @JefeAux
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @CantEmplACargo = @CantEmplACargo + dbo.cantidadDeSubordinados(@JefeAux)
			
	FETCH NEXT from cursor_empleado
	INTO @JefeAux
	END
	CLOSE cursor_empleado
	DEALLOCATE cursor_empleado

	RETURN @CantEmplACargo
END
GO


/*20. Crear el/los objeto/s necesarios para mantener actualizadas las comisiones del
vendedor.
El cálculo de la comisión está dado por el 5% de la venta total efectuada por ese
vendedor en ese mes, más un 3% adicional en caso de que ese vendedor haya
vendido por lo menos 50 productos distintos en el mes.*/

SELECT * from Empleado


CREATE TRIGGER dbo.Ejercicio21 ON Factura FOR INSERT
AS
BEGIN
	DECLARE @fecha smalldatetime
			,@vendedor numeric(6,0)
	DECLARE @comision decimal (12,2)
	DECLARE cursor_fact CURSOR FOR SELECT fact_fecha,fact_vendedor
									FROM inserted
	OPEN cursor_fact
	FETCH NEXT FROM cursor_fact
	INTO @fecha,@vendedor
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @comision = (
							SELECT SUM(item_precio*item_cantidad)*(0.05 +
																			CASE WHEN COUNT(DISTINCT item_producto) > 50 THEN 0.03
																				ELSE 0
																				END
																				)
							FROM Factura
								INNER JOIN Item_Factura
									ON item_tipo = fact_tipo AND item_sucursal = fact_sucursal AND item_numero = fact_numero
							WHERE fact_vendedor = @vendedor
								AND YEAR(fact_fecha) = YEAR(@fecha)
								AND MONTH(fact_fecha) = MONTH(@fecha)
							)
		UPDATE Empleado SET empl_comision = @comision WHERE empl_codigo = @vendedor
		FETCH NEXT FROM cursor_fact
		INTO @fecha,@vendedor
	END
	CLOSE cursor_fact
	DEALLOCATE cursor_fact
END
GO


CREATE TRIGGER ej21 ON FACTURA FOR INSERT

AS

BEGIN
       IF exists(SELECT fact_numero+fact_sucursal+fact_tipo 
				 FROM inserted 
					INNER JOIN Item_Factura
						ON item_numero+item_sucursal+item_tipo = fact_numero+fact_sucursal+fact_tipo
					INNER JOIN Producto 
						ON prod_codigo = item_producto JOIN Familia ON fami_id = prod_familia
                     GROUP BY fact_numero+fact_sucursal+fact_tipo
                     HAVING COUNT(distinct fami_id) <> 1 )
              BEGIN
              DECLARE @NUMERO char(8),@SUCURSAL char(4),@TIPO char(1)
              DECLARE cursorFacturas CURSOR FOR SELECT fact_numero,fact_sucursal,fact_tipo FROM inserted
              OPEN cursorFacturas
              FETCH NEXT FROM cursorFacturas INTO @NUMERO,@SUCURSAL,@TIPO
              WHILE @@FETCH_STATUS = 0
              BEGIN
                     DELETE FROM Item_Factura WHERE item_numero+item_sucursal+item_tipo = @NUMERO+@SUCURSAL+@TIPO
                     DELETE FROM Factura WHERE fact_numero+fact_sucursal+fact_tipo = @NUMERO+@SUCURSAL+@TIPO
                     FETCH NEXT FROM cursorFacturas INTO @NUMERO,@SUCURSAL,@TIPO
              END
              CLOSE cursorFacturas
              DEALLOCATE cursorFacturas
              RAISERROR ('no puede ingresar productos de mas de una familia en una misma factura.',1,1)
              ROLLBACK
       END
END


/*21. Desarrolle el/los elementos de base de datos necesarios para que se cumpla
automaticamente la regla de que en una factura no puede contener productos de
diferentes familias. En caso de que esto ocurra no debe grabarse esa factura y
debe emitirse un error en pantalla.*/

CREATE TRIGGER dbo.ejercicio21 ON Item_factura FOR INSERT
AS
BEGIN
	DECLARE @tipo char(1)
	DECLARE @sucursal char(4)
	DECLARE @numero char(8)
	DECLARE @producto char(8)
	DECLARE cursor_ifact CURSOR FOR SELECT item_tipo,item_sucursal,item_numero,item_producto
									FROM inserted
	OPEN cursor_ifact
	FETCH NEXT FROM cursor_ifact
	INTO @tipo,@sucursal,@numero,@producto
	WHILE @@FETCH_STATUS = 0
	BEGIN
		declare @familiaProd char(3) = (
									SELECT prod_familia
									FROM Producto
									WHERE prod_codigo = @producto
									)
		IF EXISTS(
					SELECT *
					FROM Item_Factura
						INNER JOIN Producto
							ON prod_codigo = item_producto		
					WHERE item_tipo+item_sucursal+item_numero = @tipo+@sucursal+@numero
						AND prod_familia = @familiaProd
						AND prod_codigo <> @producto
						)
		BEGIN
			DELETE FROM Item_factura WHERE item_tipo+item_sucursal+item_numero = @tipo+@sucursal+@numero
			DELETE FROM Factura WHERE fact_tipo+fact_sucursal+fact_numero = @tipo+@sucursal+@numero
			RAISERROR('La familia del producto a insertar ya existe en la factura mencionada',1,1)
			ROLLBACK TRANSACTION
		END
	FETCH NEXT FROM cursor_ifact
	INTO @tipo,@sucursal,@numero,@producto
	END
	CLOSE cursor_ifact
	DEALLOCATE cursor_ifact
END
GO


/*22. Se requiere recategorizar los rubros de productos, de forma tal que nigun rubro
tenga más de 20 productos asignados, si un rubro tiene más de 20 productos
asignados se deberan distribuir en otros rubros que no tengan mas de 20
productos y si no entran se debra crear un nuevo rubro en la misma familia con
la descirpción “RUBRO REASIGNADO”, cree el/los objetos de base de datos
necesarios para que dicha regla de negocio quede implementada.*/


CREATE PROC dbo.Ejercicio22
AS
BEGIN
	declare @rubro char(4)
	declare @cantProdRubro int

	declare cursor_rubro CURSOR FOR SELECT R.rubr_id,COUNT(*)
									FROM rubro R
										INNER JOIN Producto P
											ON P.prod_rubro = R.rubr_id
									GROUP BY R.rubr_id
									HAVING COUNT(*) > 20
	OPEN cursor_rubro
	FETCH NEXT FROM cursor_rubro
	INTO @rubro,@cantProdRubro
	WHILE @@FETCH_STATUS = 0
	BEGIN
		declare @cantProdRubroIndividual int = @cantProdRubro
		declare @prodCod char(8)
		declare @rubroLibre char(4)
		declare cursor_productos CURSOR FOR SELECT prod_codigo
											FROM Producto
											WHERE prod_rubro = @rubro
		OPEN cursor_productos
		FETCH NEXT FROM cursor_productos
		INTO @prodCod
		WHILE @@FETCH_STATUS = 0 OR @cantProdRubroIndividual < 21
		BEGIN
			IF EXISTS(
						SELECT TOP 1 rubr_id
						FROM Rubro
							INNER JOIN Producto
								ON prod_rubro = rubr_id
						GROUP BY rubr_id
						HAVING COUNT(*) < 20
						ORDER BY COUNT(*) ASC
						)
			BEGIN
				SET @rubroLibre = (
									SELECT TOP 1 rubr_id
									FROM Rubro
										INNER JOIN Producto
											ON prod_rubro = rubr_id
									GROUP BY rubr_id
									HAVING COUNT(*) < 20
									ORDER BY COUNT(*) ASC
									)

				UPDATE Producto SET prod_rubro = @rubroLibre WHERE prod_codigo = @prodCod
			END
			ELSE
			BEGIN
				IF NOT EXISTS(
						SELECT rubr_id
						FROM Rubro
						WHERE rubr_detalle = 'Rubro reasignado'
						)  
				INSERT INTO Rubro (RUBR_ID,rubr_detalle) VALUES ('xx','Rubro reasignado')
				UPDATE Producto set prod_rubro = (
													SELECT rubr_id
													FROM Rubro
													WHERE rubr_detalle = 'Rubro reasignado'
												)
				WHERE prod_codigo = @prodCod
			END
			SET @cantProdRubroIndividual -= 1
		FETCH NEXT FROM cursor_productos
		INTO @prodCod
		END
		CLOSE cursor_productos
		DEALLOCATE cursor_productos
	FETCH NEXT FROM cursor_rubro
	INTO @rubro,@cantProdRubro
	END
	CLOSE cursor_rubro
	DEALLOCATE cursor_productos
END
GO

/*
select R.rubr_detalle,COUNT(*)
from rubro R
	INNER JOIN Producto P
		ON P.prod_rubro = R.rubr_id
GROUP BY R.rubr_detalle

select prod_detalle,fami_detalle,rubr_detalle 
from Producto
	inner join Familia
		on fami_id = prod_familia
	INNER JOIN Rubro
		on rubr_id = prod_rubro


SELECT prod_codigo 
FROM Producto 
WHERE prod_rubro IN (SELECT rubr_id 
					FROM Rubro 
						JOIN Producto 
							ON rubr_id = prod_rubro 
					GROUP BY rubr_id
					HAVING COUNT(prod_rubro) > 20)

					*/


/*23. Desarrolle el/los elementos de base de datos necesarios para que ante una venta
automaticamante se controle que en una misma factura no puedan venderse más
de dos productos con composición. Si esto ocurre debera rechazarse la factura.*/

CREATE TRIGGER dbo.Ejercicio23 ON item_factura FOR INSERT
AS
BEGIN
	DECLARE @tipo char(1)
	DECLARE @sucursal char(4)
	DECLARE @numero char(8)
	DECLARE @producto char(8)
	DECLARE cursor_ifact CURSOR FOR SELECT item_tipo,item_sucursal,item_numero,item_producto
									FROM inserted

	OPEN cursor_ifact
	FETCH NEXT FROM cursor_ifact
	INTO @tipo,@sucursal,@numero,@producto
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF(
			SELECT COUNT(*)
			FROM inserted
			WHERE item_tipo+item_sucursal+item_numero = @tipo+@sucursal+@numero
				AND item_producto IN (
								SELECT comp_producto
								FROM Composicion
								)
			) >= 2
		BEGIN
		DELETE FROM Item_factura WHERE item_tipo+item_sucursal+item_numero = @tipo+@sucursal+@numero
		DELETE FROM Factura WHERE fact_tipo+fact_sucursal+fact_numero = @tipo+@sucursal+@numero
		RAISERROR('En una misma factura no pueden venderse mas de dos productos con composicion',1,1)
		ROLLBACK TRANSACTION
		END
	FETCH NEXT FROM cursor_ifact
	INTO @tipo,@sucursal,@numero,@producto
	CLOSE cursor_ifact
	DEALLOCATE cursor_ifact
END
CLOSE


/*24. Se requiere recategorizar los encargados asignados a los depositos. Para ello
cree el o los objetos de bases de datos necesarios que lo resueva, teniendo en
cuenta que un deposito no puede tener como encargado un empleado que
pertenezca a un departamento que no sea de la misma zona que el deposito, si
esto ocurre a dicho deposito debera asignársele el empleado con menos
depositos asignados que pertenezca a un departamento de esa zona.*/


CREATE PROC dbo.ejercicio24
AS
BEGIN
	
	declare @depoCodigo char(2)
	declare @depoEncargado numeric(6,0)
	declare @nuevoDepoEncargado numeric(6,0)
	declare @depoZona char(3)
	declare cursor_zona CURSOR FOR SELECT depo_codigo,depo_encargado,depo_zona
									FROM DEPOSITO
	
	OPEN cursor_zona
	FETCH NEXT FROM cursor_zona
	INTO @depoCodigo,@depoEncargado,@depoZona
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF(@depoZona <> (
							SELECT depa_zona
							FROM Departamento
								INNER JOIN Empleado
									ON empl_departamento = depa_codigo
							WHERE empl_codigo = @depoEncargado
							)
		BEGIN
			SET @nuevoDepoEncargado = (
										SELECT TOP 1 empl_codigo
										FROM Empleado
											INNER JOIN DEPOSITO
												ON depo_encargado = empl_codigo
											INNER JOIN Departamento
												ON depa_codigo = empl_departamento
										WHERE depa_zona = @depoZona
										GROUP BY empl_codigo
										ORDER BY COUNT(*) ASC
										)
			UPDATE DEPOSITO SET depo_encargado = @nuevoDepoEncargado WHERE depo_codigo = @depoCodigo
		END
	FETCH NEXT FROM cursor_zona
	INTO @depoCodigo,@depoEncargado,@depoZona
	END
	CLOSE cursor_zona
	DEALLOCATE cursor_zona
END
GO

/*
SELECT COUNT(*) from deposito
GROUP BY depo_encargado
ORDER BY count(depo_encargado)

SELECT * from DEPOSITO
order by depo_encargado

SELECT * FROM zona



SELECT TOP 1 empl_codigo
FROM Empleado
	INNER JOIN Departamento
		ON depa_codigo = empl_departamento
WHERE depa_zona = '003'
ORDER BY (
			SELECT TOP 1 COUNT(*) from deposito
			GROUP BY depo_encargado
		) ASC



SELECT TOP 1 empl_codigo,count(*)
FROM Empleado
	INNER JOIN DEPOSITO
		ON depo_encargado = empl_codigo
	INNER JOIN Departamento
		ON depa_codigo = empl_departamento
WHERE depa_zona = '004'

GROUP BY empl_codigo
ORDER BY COUNT(*) ASC
*/



/*24. Se requiere recategorizar los encargados asignados a los depositos. Para ello
cree el o los objetos de bases de datos necesarios que lo resueva, teniendo en
cuenta que un deposito no puede tener como encargado un empleado que
pertenezca a un departamento que no sea de la misma zona que el deposito, si
esto ocurre a dicho deposito debera asignársele el empleado con menos
depositos asignados que pertenezca a un departamento de esa zona.*/


CREATE PROC dbo.ejercicio24
AS
BEGIN
	
	declare @depoCodigo char(2)
	declare @depoEncargado numeric(6,0)
	declare @nuevoDepoEncargado numeric(6,0)
	declare @depoZona char(3)
	declare cursor_zona CURSOR FOR SELECT D.depo_codigo,D.depo_encargado,D.depo_zona
									FROM DEPOSITO D
										INNER JOIN Empleado
											ON empl_codigo = D.depo_encargado
									WHERE empl_departamento <> (
																	SELECT depa_codigo
																	FROM Departamento
																	WHERE depa_zona = D.depo_zona)
	
	OPEN cursor_zona
	FETCH NEXT FROM cursor_zona
	INTO @depoCodigo,@depoEncargado,@depoZona
	WHILE @@FETCH_STATUS = 0
	BEGIN
			SET @nuevoDepoEncargado = (
										SELECT TOP 1 empl_codigo
										FROM Empleado
											INNER JOIN DEPOSITO
												ON depo_encargado = empl_codigo
											INNER JOIN Departamento
												ON depa_codigo = empl_departamento
										WHERE depa_zona = @depoZona
										GROUP BY empl_codigo
										ORDER BY COUNT(*) ASC
										)
			UPDATE DEPOSITO SET depo_encargado = @nuevoDepoEncargado WHERE depo_codigo = @depoCodigo
	FETCH NEXT FROM cursor_zona
	INTO @depoCodigo,@depoEncargado,@depoZona
	END
	CLOSE cursor_zona
	DEALLOCATE cursor_zona
END
GO


/*25. Desarrolle el/los elementos de base de datos necesarios para que no se permita
que la composición de los productos sea recursiva, o sea, que si el producto A
compone al producto B, dicho producto B no pueda ser compuesto por el
producto A, hoy la regla se cumple.*/

CREATE TRIGGER dbo.ejercicio25 ON Composicion FOR INSERT,UPDATE
AS
BEGIN
	DECLARE @producto char(8)
	DECLARE @componente char(8)
	DECLARE cursor_comp CURSOR FOR (
										SELECT comp_producto,comp_componente
										FROM inserted)
	OPEN cursor_comp
	FETCH NEXT FROM cursor_comp
	INTO @producto,@componente
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF EXISTS( SELECT *
				   FROM Composicion
				   WHERE comp_producto = @componente
						AND comp_componente = @producto)
		BEGIN
			RAISERROR('El producto %s ya compone al producto %s, por lo tanto no es posible insertar',1,1,@componente,@producto)
			ROLLBACK TRANSACTION
		END
	FETCH NEXT FROM cursor_comp
	INTO @producto,@componente
	END
	CLOSE cursor_comp
	DEALLOCATE cursor_comp
END
GO


/*26. Desarrolle el/los elementos de base de datos necesarios para que se cumpla
automaticamente la regla de que una factura no puede contener productos que
sean componentes de otros productos. En caso de que esto ocurra no debe
grabarse esa factura y debe emitirse un error en pantalla.*/

CREATE TRIGGER dbo.ejercicio26v2 ON item_factura FOR Insert
AS
BEGIN
	DECLARE @tipo char(1)
	DECLARE @sucursal char(4)
	DECLARE @numero char(8)
	DECLARE @producto char(8)

	DECLARE cursor_ifact CURSOR FOR SELECT item_tipo,item_sucursal,item_numero,item_producto
									FROM inserted

	OPEN cursor_ifact
	FETCH NEXT FROM cursor_ifact
	INTO @tipo,@sucursal,@numero,@producto,@cantidad,@precio
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF EXISTS(SELECT *
				  FROM Composicion
				  WHERE comp_componente = @producto)
		BEGIN
			DELETE FROM Factura WHERE fact_tipo+fact_sucursal+fact_numero = @tipo+@sucursal+@numero
			DELETE FROM Item_Factura WHERE item_tipo+item_sucursal+item_numero = @tipo+@sucursal+@numero
			RAISERROR('EL producto a insertar es componente de otro producto, no se puede insertar en la factura',1,1)
			ROLLBACK TRANSACTION
		END
	FETCH NEXT FROM cursor_ifact
	INTO @tipo,@sucursal,@numero,@producto,@cantidad,@precio
	END
	CLOSE cursor_ifact
	DEALLOCATE cursor_ifact
END
GO


/*26.v2: Desarrolle el/los elementos de base de datos necesarios para que se cumpla
automaticamente la regla de que una factura no puede contener productos que
sean componentes de otros productos. En caso de que esto ocurra no debe
grabarse esa factura y debe emitirse un error en pantalla.*/

CREATE TRIGGER dbo.ejercicio26 ON item_factura INSTEAD OF Insert
AS
BEGIN
	DECLARE @tipo char(1)
	DECLARE @sucursal char(4)
	DECLARE @numero char(8)
	DECLARE @producto char(8)
	DECLARE @cantidad decimal(12,2)
	DECLARE @precio decimal(12,2)

	DECLARE cursor_ifact CURSOR FOR SELECT *
									FROM inserted

	OPEN cursor_ifact
	FETCH NEXT FROM cursor_ifact
	INTO @tipo,@sucursal,@numero,@producto,@cantidad,@precio
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF EXISTS(SELECT *
				  FROM Composicion
				  WHERE comp_componente = @producto)
		BEGIN
			DELETE FROM Factura WHERE fact_tipo+fact_sucursal+fact_numero = @tipo+@sucursal+@numero
			DELETE FROM Item_Factura WHERE item_tipo+item_sucursal+item_numero = @tipo+@sucursal+@numero
			RAISERROR('EL producto a insertar es componente de otro producto, no se puede insertar en la factura',1,1)
			ROLLBACK TRANSACTION
		END
		ELSE
		BEGIN
			INSERT INTO Item_Factura
			VALUES (@tipo,@sucursal,@numero,@producto,@cantidad,@precio)
		END
	FETCH NEXT FROM cursor_ifact
	INTO @tipo,@sucursal,@numero,@producto,@cantidad,@precio
	END
	CLOSE cursor_ifact
	DEALLOCATE cursor_ifact
END
GO


/*27. Se requiere reasignar los encargados de stock de los diferentes depósitos. Para
ello se solicita que realice el o los objetos de base de datos necesarios para
asignar a cada uno de los depósitos el encargado que le corresponda,
entendiendo que el encargado que le corresponde es cualquier empleado que no
es jefe y que no es vendedor, o sea, que no está asignado a ningun cliente, se
deberán ir asignando tratando de que un empleado solo tenga un deposito
asignado, en caso de no poder se irán aumentando la cantidad de depósitos
progresivamente para cada empleado.*/

CREATE PROC dbo.ejercicio27
AS
BEGIN
	declare @depoCod char(2)
	declare cursor_depo CURSOR FOR SELECT depo_codigo
								   FROM DEPOSITO
	OPEN cursor_depo
	FETCH NEXT FROM cursor_depo
	INTO @depoCod
	WHILE @@FETCH_STATUS = 0
	BEGIN
		UPDATE DEPOSITO SET depo_encargado = (
													SELECT TOP 1 empl_codigo
													FROM Empleado
														INNER JOIN DEPOSITO
															ON depo_encargado = empl_codigo
													WHERE empl_codigo NOT IN (
																				SELECT empl_jefe
																				FROM Empleado
																				WHERE empl_jefe IS NOT NULL)
																				
														AND empl_codigo NOT IN (
																				SELECT clie_vendedor
																				FROM Cliente
																				WHERE clie_vendedor IS NOT NULL
																				)

													
													GROUP BY empl_codigo
													ORDER BY COUNT(*) ASC
													)
			WHERE depo_codigo = @depoCod
		FETCH NEXT FROM cursor_depo
		INTO @depoCod
		END
		CLOSE cursor_depo
		DEALLOCATE cursor_depo
END
GO


/*28. Se requiere reasignar los vendedores a los clientes. Para ello se solicita que
realice el o los objetos de base de datos necesarios para asignar a cada uno de los
clientes el vendedor que le corresponda, entendiendo que el vendedor que le
corresponde es aquel que le vendió más facturas a ese cliente, si en particular un
cliente no tiene facturas compradas se le deberá asignar el vendedor con más
venta de la empresa, o sea, el que en monto haya vendido más.*/

CREATE PROC dbo.ejercicio28
AS
BEGIN
	CREATE @clieCodigo char(5)
	CREATE @clieVendedor numeric(6,0)
	CREATE cursor_cliente CURSOR FOR SELECT clie_codigo
									 FROM Cliente
	OPEN cursor_cliente
	FETCH NEXT FROM cursor_cliente
	INTO @clieCodigo
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF EXISTS(
					SELECT *
					FROM Factura
					WHERE fact_cliente = @clieCodigo
					)
		BEGIN
		SET @clieVendedor = (
								SELECT TOP 1 fact_vendedor
								FROM Factura
								WHERE fact_cliente = @clieCodigo
								GROUP BY fact_cliente,fact_vendedor
								ORDER BY COUNT(fact_vendedor) DESC
								)
		UPDATE Cliente SET clie_vendedor = @clieVendedor WHERE clie_codigo = @clieCodigo
		END
		ELSE
		BEGIN
		SET @clieVendedor = 
							(
								SELECT TOP 1 fact_vendedor
								FROM Factura
								GROUP BY fact_vendedor
								ORDER BY COUNT(*) DESC
								)
		UPDATE Cliente SET clie_vendedor = @clieVendedor WHERE clie_codigo = @clieCodigo
		END
	FETCH NEXT FROM cursor_cliente
	INTO @clieCodigo
	END
	CLOSE cursor_cliente
	DEALLOCATE cursor_cliente
END
GO



/*30. Agregar el/los objetos necesarios para crear una regla por la cual un cliente no
pueda comprar más de 100 unidades en el mes de ningún producto, si esto
ocurre no se deberá ingresar la operación y se deberá emitir un mensaje “Se ha
superado el límite máximo de compra de un producto”. Se sabe que esta regla se
cumple y que las facturas no pueden ser modificadas.*/

CREATE TRIGGER dbo.Ejercicio30 ON item_factura FOR INSERT
AS
BEGIN
	DECLARE @tipo char(1)
	DECLARE @sucursal char(4)
	DECLARE @numero char(8)
	DECLARE @producto char(8)
	DECLARE @cantProducto decimal(12,2)
	DECLARE @itemsVendidosEnELMes int
	DECLARE @excedente int
	DECLARE cursor_ifact CURSOR FOR SELECT item_tipo,item_sucursal,item_numero,item_cantidad
									FROM inserted
	OPEN cursor_ifact
	FETCH NEXT FROM cursor_ifact
	INTO @tipo,@sucursal,@numero,@cantProducto
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @itemsVendidosEnELMes = (
								SELECT sum(item_cantidad)
								FROM Item_Factura
									INNER JOIN Factura
										ON fact_tipo+fact_sucursal+fact_numero = @tipo+@sucursal+@numero
								WHERE item_producto = @producto
									AND fact_fecha = (SELECT MONTH(GETDATE()))
								)
		IF (@itemsVendidosEnELMes + @cantProducto) > 100
		BEGIN
			SET @excedente = (@itemsVendidosEnELMes + @cantProducto)-100
			DELETE FROM Item_Factura WHERE item_tipo+item_sucursal+item_numero = @tipo+@sucursal+@numero
			DELETE FROM Factura WHERE fact_tipo+fact_sucursal+fact_numero = @tipo+@sucursal+@numero
			RAISERROR('No se puede comprar mas del producto %s, se superaron las unidades por %i',1,1,@producto,@excedente)
			ROLLBACK TRANSACTION
		END
		FETCH NEXT FROM cursor_ifact
		INTO @tipo,@sucursal,@numero,@cantProducto
	END
	CLOSE cursor_ifact
	DEALLOCATE cursor_ifact
END
CLOSE

--Esta bien que borre la factura entera si un renglon no se puede ingresar?


/*31. Desarrolle el o los objetos de base de datos necesarios, para que un jefe no pueda
tener más de 20 empleados a cargo, directa o indirectamente, si esto ocurre
debera asignarsele un jefe que cumpla esa condición, si no existe un jefe para
asignarle se le deberá colocar como jefe al gerente general que es aquel que no
tiene jefe.*/


CREATE FUNCTION dbo.empleadosACargo (@Jefe numeric(6,0))
RETURNS int

AS
BEGIN
	DECLARE @CantEmplACargo int = 0
	DECLARE @JefeAux numeric(6,0) = @Jefe
	DECLARE @CodEmplAux numeric(6,0)
	

	IF NOT EXISTS (SELECT * FROM EMPLEADO WHERE empl_jefe = @Jefe)
	BEGIN
		RETURN @CantEmplACargo
	END

	SET @CantEmplACargo = (
							SELECT COUNT(*)
							FROM Empleado
							WHERE empl_jefe = @Jefe AND empl_codigo > @Jefe)

	DECLARE cursor_empleado CURSOR FOR SELECT E.empl_codigo
										FROM Empleado E
										WHERE empl_jefe = @Jefe
	OPEN cursor_empleado
	FETCH NEXT from cursor_empleado
	INTO @JefeAux
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @CantEmplACargo = @CantEmplACargo + dbo.Ejercicio11v4(@JefeAux)
			
	FETCH NEXT from cursor_empleado
	INTO @JefeAux
	END
	CLOSE cursor_empleado
	DEALLOCATE cursor_empleado

	RETURN @CantEmplACargo
END
GO


CREATE PROC dbo.ejercicio31
AS
BEGIN
	DECLARE @jefe numeric(6,0)
	DECLARE @nuevoJefe numeric(6,0)
	DECLARE cursor_jefe CURSOR FOR SELECT empl_codigo
								   FROM Empleado
								   WHERE empl_codigo IN (
															SELECT empl_jefe
															FROM Empleado
															WHERE empl_jefe IS NOT NULL
														)
	OPEN cursor_jefe
	FETCH NEXT FROM cursor_jefe
	INTO @jefe
	WHILE @@FETCH_STATUS = 0
	BEGIN
		 IF dbo.empleadosACargo(@jefe) > 20
		 BEGIN
			SET @nuevoJefe = (
									SELECT empl_codigo
									FROM Empleado
									WHERE dbo.empleadosACargo(empl_codigo) < 20 AND dbo.empleadosACargo(empl_codigo) >= 1
									)
			IF @nuevoJefe IS NOT NULL
			BEGIN
				UPDATE Empleado SET empl_jefe = @nuevoJefe WHERE empl_codigo = @jefe
			END
			ELSE
			BEGIN
				UPDATE Empleado SET empl_jefe = (
													SELECT empl_codigo
													FROM Empleado
													WHERE empl_jefe IS NULL
												)
					WHERE empl_codigo = @jefe
			END
		END
		FETCH NEXT FROM cursor_jefe
		INTO @jefe
	END
	CLOSE cursor_jefe
	DEALLOCATE cursor_jefe
END
GO		

