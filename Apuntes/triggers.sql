CREATE TABLE Provincia (id int primary key, nombre char(100))

ALTER TABLE Cliente add pcia_id int NULL

ALTER TABLE Provincia add clie_codigo int NULL

INSERT INTO Provincia Values(1,'LaRioja','0000')

UPDATE Cliente SET Cliente.pcia_id=1 WHERE clie_codigo = '00000'





-- TRIGGERS
--  TABLAS INSERTED, DELETED 
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


