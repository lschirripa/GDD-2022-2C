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