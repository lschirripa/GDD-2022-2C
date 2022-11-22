-- 1. Hacer una función que dado un artículo y un deposito devuelva un string que
-- indique el estado del depósito según el artículo. Si la cantidad almacenada es
-- menor al límite retornar “OCUPACION DEL DEPOSITO XX %” siendo XX el
-- % de ocupación. Si la cantidad almacenada es mayor o igual al límite retornar
-- “DEPOSITO COMPLETO”.

-- alter FUNCTION Func1(@art VARCHAR(8), @depo char(2))
-- RETURNS CHAR(200)
-- AS
-- BEGIN
-- DECLARE @porcentaje DECIMAL(12,2)
-- (
--     SELECT @porcentaje =  s.stoc_cantidad*100/s.stoc_stock_maximo FROM STOCK S
--     WHERE s.stoc_producto = @art AND s.stoc_deposito = @depo
-- )
-- IF (@porcentaje < 100)
--     BEGIN
--     return 'ocupacion del deposito al %'+ CONVERT(Varchar(10),@porcentaje)
--     END

-- RETURN 'deposito completo'

-- END

-- -- SELECT dbo.Func1('00000102','16')

-- ---otra sol

-- CREATE FUNCTION dbo.Ejercicio1 (@art varchar(8),@depo char(2))

-- RETURNS varchar(30)

-- AS
-- BEGIN 
-- 	DECLARE @result DECIMAL(12,2)
-- 	(
-- 		SELECT @result = ISNULL((S.stoc_cantidad*100) / S.stoc_stock_maximo,0)
-- 		FROM STOCK S
-- 		WHERE S.stoc_producto = @art AND S.stoc_deposito = @depo
-- 	)
-- RETURN
-- 	CASE
-- 		WHEN @result < 100
-- 		THEN 
-- 			('Ocupacion del Deposito: ' + CONVERT(varchar(10),@result) + '%')
-- 		ELSE
-- 			'Deposito Completo'
-- 	END
-- END
-- GO

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