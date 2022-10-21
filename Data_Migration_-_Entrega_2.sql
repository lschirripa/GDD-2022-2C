----------------------------------------------------------------
-------------------------- MIGRACION ---------------------------
----------------------------------------------------------------

-------////////////////////-----
	   ----- VARIANTE -----
-------////////////////////-----
BEGIN TRANSACTION
	INSERT INTO sale_worson.Variante
	SELECT DISTINCT 
		PRODUCTO_VARIANTE_CODIGO,
		PRODUCTO_TIPO_VARIANTE,
		PRODUCTO_VARIANTE
	FROM [gd_esquema].[Maestra]
	WHERE PRODUCTO_VARIANTE_CODIGO IS NOT NULL
--COMMIT
ROLLBACK

SELECT * FROM sale_worson.Variante
---------------------------------------------
---------------------------------------------


-------////////////////////-----
	   ----- PRODUCTO -----
-------////////////////////-----
BEGIN TRANSACTION
BEGIN
	INSERT INTO sale_worson.Producto
	SELECT DISTINCT
	PRODUCTO_CODIGO,
	PRODUCTO_NOMBRE,
	PRODUCTO_DESCRIPCION,
	PRODUCTO_MARCA,
	PRODUCTO_CATEGORIA,
	PRODUCTO_MATERIAL
	FROM gd_esquema.Maestra
	--sin distinct 299.064
	--distinct 1311

END
--COMMIT
ROLLBACK



-------////////////////////-----
	 -- PRODUCTO_VARIANTE --
-------////////////////////-----
