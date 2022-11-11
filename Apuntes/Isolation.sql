--- ISOLATION LEVELS ---

VIOLATIONS (try to avoid)->

 - DIRTY READ: an item is read (from transac1) before it has been committed (from another transac2) so transac1 gets a dirty value

 - REPETEABLE READ (not a violation, but for the example) - the rows that are readed are locked from being changed. EXAMPLE: in the same query1 i get 3 select * from a table. in the exact middle of the read, there is an insert, a delete and a update. the DELETE AND UPDATE are not taken as if there were made. but the insert IS readed cause that is the case of a PHANTOM value . 
 
 - NON REPETEABLE READ: T1 reads a value and gets '10' , T2 writes the same value as '20' without ending the transac, T1 reads again and it gets '20'

 - PHANTOM: a query1 reads from a table , then another query updates or inserts in the same table, then the query1 gets back a new row that accomplish the query condition

 --- now for which isolation leves which violations are allowed

-- the default is read committed
------------------------------------------------------------------------------|
-- ISOLATION LEVEL      DIRTY READ       NON-REPETEABLE READ      PHANTOM
------------------------------------------------------------------------------|
-- read uncommitted      allows read DR        ALLOWS              ALLOWS
--
-- read committed          NO                  ALLOWS              ALLOWS
-- 
-- repeteable read         NO                  NO                  ALLOWS
--
-- serializable            NO                  NO                  NO           LOCKS the data item until the transaction is done using the data (like a sem)
------------------------------------------------------------------------------|


-- deadlock can happen in certain circunstances

------------------------------- ISOLATION RULES -----------------------------------
-- Statements cannot read data that has been modified but not yet committed by other transactions.

-- No other transactions can modify data that has been read by the current transaction until the current transaction completes.

-- Other transactions cannot insert new rows with key values that would fall in the range of keys read by any statements in the current transaction until the current transaction completes.
