CREATE TABLE Provincia (id int primary key, nombre char(100))

ALTER TABLE Cliente add pcia_id int NULL

ALTER TABLE Provincia add clie_codigo int NULL

INSERT INTO Provincia Values(1,'LaRioja','0000')

UPDATE Cliente SET Cliente.pcia_id=1 WHERE clie_codigo = '00000'





-- TRIGGERS
--  TABLAS INSERTED, DELETED [dbo].[Producto]
-- el update tiene las 2



-- 1) existe 1 provincia vinculada a un cliente, esta no se puede borrar.


CREATE TRIGGER tr1 ON PROVINCIA 
AFTER DELETE
AS 
BEGIN TRANSACTION/* logica que verifique que el id de provincia a borrar no sea referenciado por un cliente */
    IF EXISTS
        (
        SELECT 1 FROM deleted d 
        WHERE d.id IN (SELECT DISTINCT c.pcia_id FROM Cliente c)
        )

        BEGIN 
            PRINT('No se puede eliminar una Provincia referenciada a un Cliente')
            ROLLBACK
            RETURN        
        END

        -- en caso de haber sido un instead of (DELETE PROVINCIA WHERE ID IN (SELECT ID FROM DELETED)

        COMMIT

-- PRUEBO TRIGGER1

DELETE FROM Provincia WHERE id=1;

-- 2) Siempre que inserto o cambio un cliente, la provincia del ciente tiene que existir en la tabla Provincia

CREATE TRIGGER tr2 ON CLIENTE
AFTER INSERT,UPDATE
AS
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
BEGIN TRANSACTION

    IF NOT EXISTS(
        SELECT pcia_id from inserted i 
        where i.pcia_id in (select P.id from Provincia P)
    )
    BEGIN 
            PRINT('No se puede agregar una pcia que no existe')
            ROLLBACK
            RETURN 
    END


COMMIT

----- PRUEBO TRIGGER2:

UPDATE Cliente SET Cliente.pcia_id = 2 Where clie_codigo = '00001' 
INSERT Cliente etc etc etc

-- 3) si cambio una provincia, y la anterior tiene vinculado a un cliente, esto no puede pasar.

alter TRIGGER tr3 ON PROVINCIA
AFTER UPDATE
AS
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ  
BEGIN TRANSACTION

IF EXISTS
    (
        SELECT 1 FROM deleted d where d.id IN (SELECT C.pcia_id FROM Cliente C)  
    )
    BEGIN
    PRINT('No se puede cambiar una provincia que es referenciada por un cliente')
    ROLLBACK
    RETURN
    END

COMMIT

---- PRUEBO TRIG3

UPDATE Provincia SET id=5 where id=1


------ EJ TRIGGER 4

-- Implementar el/los objetos y crear una lógica de negocio decontrol de uso de productos activos/inactivos. Esto significaque aquellos productos que no estén activos no puedan serusados en ninguna instancia del modelo de datos en ningunacircunstancia.


ALTER TABLE Producto 
ADD activo CHAR(1)
-- lo ideal hubiese sido ALTER TABLE PRODUCTO ADD activo bit default 1

UPDATE PRODUCTO 
SET activo='N'
WHERE prod_codigo='00000033'

ALTER TRIGGER tr_4 on PRODUCTO
AFTER UPDATE
AS
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRANSACTION

    IF EXISTS (
        SELECT d.Activo FROM deleted d WHERE d.Activo = 'N'
        )
        BEGIN
        PRINT('NO se puede modificar un producto inactivo')
        ROLLBACK
        RETURN
        END

COMMIT


CREATE TRIGGER tr_5 on Item_Factura
AFTER UPDATE
AS
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRANSACTION

    IF EXISTS (
        SELECT 1 FROM deleted d
        JOIN Producto P ON P.prod_codigo = d.item_producto 
        WHERE P.Activo = 'N'
        )
        BEGIN
        PRINT('NO se puede modificar un producto inactivo')
        ROLLBACK
        RETURN
        END

COMMIT

----pruebo trig4
--no me tiene q dejar
UPDATE Producto SET prod_precio = 1 WHERE prod_codigo = '00000032'

begin TRANSACTION
DELETE Producto WHERE prod_codigo = '00000032'
ROLLBACK
-- me tiene q dejar
BEGIN TRANSACTION
UPDATE Producto SET prod_precio = 1 WHERE prod_codigo = '00000031'
ROLLBACK

-----pruebo trig 5------ no me tiene q dejar
UPDATE PRODUCTO 
SET activo='N'
WHERE prod_codigo='00001415'

BEGIN TRANSACTION
UPDATE Item_Factura SET item_precio = 1 WHERE item_numero = '00092444'
--ROLLBACK





-- Implementar el/los objetos necesarios para que cada vez que se genere una venta,
-- si existe un producto compuesto, descuente del STOCK los componentes.


ALTER TRIGGER descontar_stock on FACTURA
AFTER INSERT
AS 
--SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRANSACTION

    DECLARE @var1 VARCHAR(100)
    SET @var1 = (select top 1 producto.prod_codigo from inserted i
                JOIN Item_Factura on i.fact_numero = Item_Factura.item_numero
                JOIN Producto on Producto.prod_codigo = Item_Factura.item_producto
                )
    print(@var1)

    IF EXISTS(
            SELECT comp_producto from Composicion
            WHERE comp_producto = @var1
            )
    BEGIN

        PRINT('se ha actualizado el stock de la composicion del producto')
        UPDATE STOCK SET stoc_cantidad = (stoc_cantidad - 1) WHERE stoc_producto = @var1

    END
    ELSE print('no se vendio un producto con compuestos')


COMMIT

-- elegi el producto 102, para darme cuenta cual es su item numero use esta query
select item_numero from Item_Factura
JOIN Producto on item_producto = Producto.prod_codigo
where prod_codigo = '00001707'

select f.fact_numero,item_numero, prod_codigo from Factura f 
join Item_Factura iff on  iff.item_numero = f.fact_numero
join Producto on item_producto = prod_codigo 
where prod_codigo = '00001707'

-- pruebo descontar stock
INSERT INTO FACTURA Values('A','010','00068711','2022-04-04 00:00:00',4,10,10,'01634')

INSERT INTO FACTURA Values('B','0003','00087973','2022-04-04 00:00:00',4,10,10,'01634')



/*
pueda comprar más de 100 unidades en el mes de ningún producto, si esto
ocurre no se deberá ingresar la operación y se deberá emitir un mensaje “Se ha
superado el límite máximo de compra de un producto”. Se sabe que esta regla se
cumple y que las facturas no pueden ser modificadas.
*/

CREATE TRIGGER trg_compra_max ON Item_Factura
AFTER INSERT
AS 
BEGIN TRANSACTION

    IF EXISTS(SELECT fi.fact_cliente FROM inserted i
              JOIN FACTURA fi ON fi.fact_numero = i.item_numero AND fi.fact_tipo = i.item_tipo AND fi.fact_sucursal = i.item_sucursal 
              WHERE fi.fact_cliente IN
              
              (
                  SELECT f.fact_cliente FROM Factura F
                    JOIN Item_Factura iff on iff.item_tipo = f.fact_tipo AND iff.item_sucursal = f.fact_sucursal AND iff.item_numero = f.fact_numero
                    GROUP BY f.fact_cliente, CONVERT(CHAR(6), f.fact_fecha, 112)
                    HAVING SUM(item_cantidad) > 100
              )
              
              )
    BEGIN
        PRINT('YA COMPRO MAS DE 100 U')
        ROLLBACK
        RETURN
    END



COMMIT

--PRUEBO

BEGIN TRANSACTION
INSERT INTO Item_Factura
VALUES ('A','0003','00068710','00010200',50,0.5)



