------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------ MIGRACION -------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
/*
BEGIN TRANSACTION
	--INSERT INTO)
   
	SELECT DISTINCT 
		
	FROM [gd_esquema].[Maestra]
	WHERE 
--COMMIT
ROLLBACK*/

-- Reset AutoIncrement
DBCC CHECKIDENT ('sale_worson.Variante', RESEED, 0)
DBCC CHECKIDENT ('sale_worson.Variante', RESEED, 0)


-------------------------------------------------------- VARIANTE ------------------------

BEGIN TRANSACTION
	INSERT INTO sale_worson.Variante
	SELECT DISTINCT 
		PRODUCTO_TIPO_VARIANTE,
		PRODUCTO_VARIANTE
	FROM [gd_esquema].[Maestra]
	WHERE PRODUCTO_VARIANTE_CODIGO IS NOT NULL
--COMMIT
ROLLBACK

----------------------------------
SELECT * FROM sale_worson.Variante
----------------------------------

-------------------------------------------------------- PRODUCTO ------------------------

BEGIN TRANSACTION
	INSERT INTO [sale_worson].[producto]

	SELECT DISTINCT 
		PRODUCTO_CODIGO,
		PRODUCTO_NOMBRE,
		PRODUCTO_DESCRIPCION,
		PRODUCTO_MARCA,
		PRODUCTO_CATEGORIA,
		PRODUCTO_MATERIAL
		
	FROM [gd_esquema].[Maestra]
	WHERE PRODUCTO_CODIGO IS NOT NULL
--COMMIT
ROLLBACK

--------------------------------------
SELECT * FROM [sale_worson].[producto]
--------------------------------------


-------------------------------------------------------- PRODUCTO VARIANTE -----------------------
BEGIN TRANSACTION
INSERT INTO [sale_worson].[producto_variante]

	SELECT DISTINCT
		maa.PRODUCTO_VARIANTE_CODIGO as PV_CODIGO,
		v.VARIANTE_ID				 as PV_VARIANTE,
		maa.PRODUCTO_CODIGO			 as PV_PRODUCTO,
		maa.VENTA_PRODUCTO_PRECIO	 as PV_PRECIO_UNITARIO_ACTUAL,
		(compra.CANTIDAD_COMPRADA - venta.CANTIDAD_VENDIDA) as STOCK
	FROM [gd_esquema].[Maestra] maa

	-- Join con COMPRA
	INNER JOIN( 
		SELECT DISTINCT
			SUM(ISNULL(aa.COMPRA_PRODUCTO_CANTIDAD,0)) CANTIDAD_COMPRADA,
			aa.PRODUCTO_VARIANTE_CODIGO
		FROM [gd_esquema].[Maestra] aa
		WHERE aa.PRODUCTO_VARIANTE_CODIGO IS NOT NULL
		GROUP BY aa.PRODUCTO_VARIANTE_CODIGO

	) compra
	ON maa.PRODUCTO_VARIANTE_CODIGO = compra.PRODUCTO_VARIANTE_CODIGO

	-- Join con VENTA
	INNER JOIN(
		SELECT DISTINCT
			SUM(ISNULL(aa.VENTA_PRODUCTO_CANTIDAD,0)) CANTIDAD_VENDIDA,
			aa.PRODUCTO_VARIANTE_CODIGO
		FROM [gd_esquema].[Maestra] aa
		WHERE aa.PRODUCTO_VARIANTE_CODIGO IS NOT NULL
		GROUP BY aa.PRODUCTO_VARIANTE_CODIGO

	)venta
	ON maa.PRODUCTO_VARIANTE_CODIGO = venta.PRODUCTO_VARIANTE_CODIGO

	-- Join para traernos la fecha mas reciente, para obtener el ultimo precio de venta
	INNER JOIN 
	(
		SELECT 
			d.PRODUCTO_VARIANTE_CODIGO,
			MAX(d.VENTA_FECHA) as VENTA_MAS_RECIENTE
		FROM [gd_esquema].[Maestra] d

		WHERE VENTA_PRODUCTO_PRECIO IS NOT NULL AND PRODUCTO_VARIANTE_CODIGO IS NOT NULL
		GROUP BY d.PRODUCTO_VARIANTE_CODIGO
	) s
	ON s.PRODUCTO_VARIANTE_CODIGO = maa.PRODUCTO_VARIANTE_CODIGO AND s.VENTA_MAS_RECIENTE = maa.VENTA_FECHA

	-- Join para Unir con tabla Variante
	INNER JOIN [sale_worson].[variante] v 
	ON maa.PRODUCTO_TIPO_VARIANTE = v.VARIANTE_TIPO_ AND maa.PRODUCTO_VARIANTE = v.VARIANTE_DESCRIPCION


--COMMIT
ROLLBACK


-----------------------------------------------
SELECT * FROM [sale_worson].[producto_variante]
-----------------------------------------------


-------------------------------------------------------- MEDIO ENVIO   -------------------------
BEGIN TRANSACTION
	INSERT INTO [sale_worson].[medio_envio]
  
	SELECT DISTINCT 
		VENTA_MEDIO_ENVIO,
		VENTA_ENVIO_PRECIO
	FROM [gd_esquema].[Maestra]
	WHERE VENTA_MEDIO_ENVIO IS NOT NULL

--COMMIT
ROLLBACK

-----------------------------------------
SELECT * FROM [sale_worson].[medio_envio]
-----------------------------------------


-------------------------------------------------------- CANAL VENTA   -------------------------
BEGIN TRANSACTION
	INSERT INTO [sale_worson].[canal_venta]
  
	SELECT DISTINCT 
			VENTA_CANAL_COSTO,
			VENTA_CANAL
	FROM [gd_esquema].[Maestra]
	WHERE VENTA_CANAL is not null
--COMMIT
ROLLBACK

-----------------------------------------
SELECT * FROM [sale_worson].[canal_venta]
-----------------------------------------


-------------------------------------------------------- MEDIO PAGO ----------------------------
BEGIN TRANSACTION
	INSERT INTO [sale_worson].[medio_pago]

	SELECT DISTINCT 
		VENTA_MEDIO_PAGO,
		VENTA_MEDIO_PAGO_COSTO
		
	FROM [gd_esquema].[Maestra]
	WHERE VENTA_MEDIO_PAGO IS NOT NULL

--COMMIT
ROLLBACK

----------------------------------------
SELECT * FROM [sale_worson].[medio_pago]
----------------------------------------


-------------------------------------------------------- CLIENTE  ------------------------------

BEGIN TRANSACTION
	
   INSERT INTO [sale_worson].[cliente]

	SELECT DISTINCT 
			CLIENTE_NOMBRE 
           ,CLIENTE_APELLIDO
           ,CLIENTE_DNI
           ,CLIENTE_DIRECCION
           ,CLIENTE_TELEFONO
           ,CLIENTE_MAIL
           ,CLIENTE_FECHA_NAC
           ,CLIENTE_LOCALIDAD
           ,CLIENTE_CODIGO_POSTAL
           ,CLIENTE_PROVINCIA
		
	FROM [gd_esquema].[Maestra]
	WHERE CLIENTE_NOMBRE IS NOT NULL AND CLIENTE_APELLIDO IS NOT NULL

--COMMIT
ROLLBACK

-------------------------------------
SELECT * FROM [sale_worson].[cliente]
-------------------------------------


-------------------------------------------------------- VENTA   -------------------------------
BEGIN TRANSACTION
	INSERT INTO [sale_worson].[venta]
	  
	SELECT DISTINCT 
		ma.VENTA_CODIGO,
		ma.VENTA_FECHA,
		mp.MEDIO_PAGO_ID as VENTA_MEDIO_PAGO,
		me.MEDIO_ENVIO_ID as VENTA_MEDIO_ENVIO,
		cv.CANAL_VENTA_ID as VENTA_CANAL,
		c.CLIENTE_ID as VENTA_CLIENTE,
		ma.VENTA_TOTAL
	FROM [gd_esquema].[Maestra] ma

	INNER JOIN [sale_worson].medio_pago mp
	ON ma.VENTA_MEDIO_PAGO = mp.MEDIO_PAGO_DESCRIPCION AND ma.VENTA_MEDIO_PAGO_COSTO= mp.MEDIO_PAGO_COSTO

	INNER JOIN [sale_worson].MEDIO_ENVIO me
	ON ma.VENTA_MEDIO_ENVIO = me.MEDIO_ENVIO_DESCRIPCION AND ma.VENTA_ENVIO_PRECIO = me.MEDIO_ENVIO_PRECIO

	INNER JOIN [sale_worson].[canal_venta] cv
	ON ma.VENTA_CANAL_COSTO = cv.CANAL_VENTA_COSTO AND ma.VENTA_CANAL = cv.CANAL_VENTA_DESCRIPCION

	INNER JOIN [sale_worson].[cliente] c
	ON		ma.CLIENTE_NOMBRE		= c.CLIENTE_NOMBRE
		AND ma.CLIENTE_APELLIDO		= c.CLIENTE_APELLIDO
		AND ma.CLIENTE_DNI			= c.CLIENTE_DNI
		AND ma.CLIENTE_DIRECCION	= c.CLIENTE_DIRECCION
		AND ma.CLIENTE_TELEFONO		= c.CLIENTE_TELEFONO
		AND ma.CLIENTE_MAIL			= c.CLIENTE_MAIL
		AND ma.CLIENTE_FECHA_NAC	= c.CLIENTE_FECHA_NAC
		AND ma.CLIENTE_LOCALIDAD	= c.CLIENTE_LOCALIDAD
		AND ma.CLIENTE_CODIGO_POSTAL= c.CLIENTE_CODIGO_POSTAL
		AND ma.CLIENTE_PROVINCIA	= c.CLIENTE_PROVINCIA

--COMMIT
ROLLBACK

-- Si dejamos las subconsultas resulta mucho menos performante (1min contra 3seg)

-----------------------------------
SELECT * FROM [sale_worson].[venta]
-----------------------------------

-------------------------------------------------------- VENTA DETALLE -------------------------

-------------------------------------------------------- COMPRA DETALLE-------------------------

-------------------------------------------------------- COMPRA  -------------------------------



-------------------------------------------------------- VENTA X CUPON -------------------------
-------------------------------------------------------- VENTA X DESCUENTO ---------------------


-------------------------------------------------------- COMPRA X DESCUENTO --------------------

-------------------------------------------------------- PROVEEDOR  ----------------------------
BEGIN TRANSACTION
	
INSERT INTO [sale_worson].[proveedor]
           ([PROVEEDOR_RAZON_SOCIAL]
           ,[PROVEEDOR_CUIT]
           ,[PROVEEDOR_DOMICILIO]
           ,[PROVEEDOR_MAIL]
           ,[PROVEEDOR_LOCALIDAD]
           ,[PROVEEDOR_CODIGO_POSTAL]
           ,[PROVEEDOR_PROVINCIA])
   
	SELECT DISTINCT 
			PROVEEDOR_RAZON_SOCIAL
           ,PROVEEDOR_CUIT
           ,PROVEEDOR_DOMICILIO
           ,PROVEEDOR_MAIL
           ,PROVEEDOR_LOCALIDAD
           ,PROVEEDOR_CODIGO_POSTAL
           ,PROVEEDOR_PROVINCIA
		
	FROM [gd_esquema].[Maestra]
	WHERE PROVEEDOR_RAZON_SOCIAL is not null
--COMMIT
ROLLBACK
-------------------------------------------------------- CUPON VENTA----------------------------
BEGIN TRANSACTION
	
INSERT INTO [sale_worson].[cupon_venta]
           ([CUPON_VENTA_CODIGO]
           ,[CUPON_VENTA_FECHA_INICIO]
           ,[CUPON_VENTA_FECHA_FIN]
           ,[CUPON_VENTA_VALOR]
           ,[CUPON_VENTA_TIPO])
   
	SELECT DISTINCT
		VENTA_CUPON_CODIGO,
		VENTA_CUPON_FECHA_DESDE,
		VENTA_CUPON_FECHA_HASTA,
		VENTA_CUPON_VALOR,
		VENTA_CUPON_TIPO 
		
	FROM [gd_esquema].[Maestra]
	WHERE VENTA_CUPON_CODIGO is not null
--COMMIT
ROLLBACK


-------------------------------------------------------- DESCUENTO VENTA -----------------------
BEGIN TRANSACTION
	INSERT INTO [sale_worson].[descuento_venta]
           ([DESCUENTO_VENTA_IMPORTE]
           ,[DESCUENTO_VENTA_CONCEPTO])
   
	SELECT DISTINCT 
			VENTA_DESCUENTO_IMPORTE,
			VENTA_DESCUENTO_CONCEPTO
		
	FROM [gd_esquema].[Maestra]
	WHERE VENTA_DESCUENTO_IMPORTE is not null
--COMMIT
ROLLBACK

-------------------------------------------------------- DESCUENTO COMPRA-----------------------

-- son todos null en la maestra 
BEGIN TRANSACTION
	INSERT INTO [sale_worson].[descuento_compra]
           ([DESCUENTO_COMPRA_CODIGO]
           ,[DESCUENTO_COMPRA_PORCENTAJE])
   
	SELECT DISTINCT 
			DESCUENTO_COMPRA_CODIGO,
			DESCUENTO_COMPRA_VALOR
	FROM [gd_esquema].[Maestra]
	WHERE DESCUENTO_COMPRA_CODIGO is not null
--COMMIT
ROLLBACK
