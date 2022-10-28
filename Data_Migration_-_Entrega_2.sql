------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------ MIGRACION -------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
-- RECORDAR QUE CUANDO SE CORRA LA MIGRACION, ES IMPORTANTE MANTENER ESTE ORDEN DADO QUE LA MAYORIA DE LAS TABLAS TIENEN FK --
------------------------------------------------------------------------------------------------------------------------------
/*
BEGIN TRANSACTION
	--INSERT INTO)
   
	SELECT DISTINCT 
		
	FROM [gd_esquema].[Maestra]
	WHERE 
--COMMIT
ROLLBACK*/

-- Reset AutoIncrement
--DBCC CHECKIDENT ('sale_worson.Variante', RESEED, 0)
--DBCC CHECKIDENT ('sale_worson.Variante', RESEED, 0)


-------------------------------------------------------- VARIANTE ------------------------

BEGIN TRANSACTION
	INSERT INTO [sale_worson].[Variante]

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
	WHERE VENTA_CANAL IS NOT NULL

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
BEGIN TRANSACTION
	INSERT INTO [sale_worson].[venta_detalle]

	SELECT DISTINCT
		v.VENTA_CODIGO VD_VENTA,
		p.PV_CODIGO VD_PV,
		SUM(m.VENTA_PRODUCTO_CANTIDAD) VD_PV_CANTIDAD,
		SUM(m.VENTA_PRODUCTO_PRECIO * m.VENTA_PRODUCTO_CANTIDAD) as VD_PV_PRECIO

	FROM [gd_esquema].[Maestra] m

	INNER JOIN [sale_worson].[producto_variante] p ON m.PRODUCTO_VARIANTE_CODIGO = p.PV_CODIGO
	INNER JOIN [sale_worson].[venta] v ON m.VENTA_CODIGO = v.VENTA_CODIGO

	GROUP BY v.VENTA_CODIGO, PV_CODIGO

--COMMIT
ROLLBACK

-------------------------------------------
SELECT * FROM [sale_worson].[venta_detalle]
-------------------------------------------


-------------------------------------------------------- CUPON VENTA----------------------------
BEGIN TRANSACTION
	
	INSERT INTO [sale_worson].[cupon_venta]
   
	SELECT DISTINCT
		VENTA_CUPON_CODIGO,
		VENTA_CUPON_FECHA_DESDE,
		VENTA_CUPON_FECHA_HASTA,
		VENTA_CUPON_VALOR,
		VENTA_CUPON_TIPO 
		
	FROM [gd_esquema].[Maestra]
	WHERE VENTA_CUPON_CODIGO IS NOT NULL

--COMMIT
ROLLBACK

-----------------------------------------
SELECT * FROM [sale_worson].[cupon_venta]
-----------------------------------------


-------------------------------------------------------- VENTA X CUPON -------------------------
BEGIN TRANSACTION
	INSERT INTO [sale_worson].[venta_x_cupon]

	SELECT DISTINCT
		v.VENTA_CODIGO,
		cv.CUPON_VENTA_CODIGO,
		m.VENTA_CUPON_IMPORTE
	FROM [gd_esquema].[Maestra] m

	INNER JOIN [sale_worson].[venta] v ON m.VENTA_CODIGO = v.VENTA_CODIGO
	INNER JOIN [sale_worson].cupon_venta cv ON m.VENTA_CUPON_CODIGO = cv.CUPON_VENTA_CODIGO

--COMMIT
ROLLBACK

-------------------------------------------
SELECT * FROM [sale_worson].[venta_x_cupon]
-------------------------------------------

-------------------------------------------------------- DESCUENTO VENTA -----------------------
BEGIN TRANSACTION
	INSERT INTO [sale_worson].[descuento_venta]
   
	SELECT DISTINCT 
			VENTA_DESCUENTO_IMPORTE,
			VENTA_DESCUENTO_CONCEPTO
		
	FROM [gd_esquema].[Maestra]
	WHERE VENTA_DESCUENTO_IMPORTE IS NOT NULL

--COMMIT
ROLLBACK

---------------------------------------------
SELECT * FROM [sale_worson].[descuento_venta]
---------------------------------------------


-------------------------------------------------------- VENTA X DESCUENTO ---------------------
BEGIN TRANSACTION
	
	INSERT INTO [sale_worson].[venta_x_descuento]

	SELECT DISTINCT
		v.VENTA_CODIGO,
		dv.DESCUENTO_VENTA_ID
	FROM [gd_esquema].[Maestra] m

	INNER JOIN [sale_worson].[venta] v ON v.VENTA_CODIGO = m.VENTA_CODIGO
	INNER JOIN [sale_worson].[descuento_venta] dv ON dv.DESCUENTO_VENTA_IMPORTE = m.VENTA_DESCUENTO_IMPORTE AND dv.DESCUENTO_VENTA_CONCEPTO = m.VENTA_DESCUENTO_CONCEPTO


--COMMIT
ROLLBACK

-----------------------------------------------
SELECT * FROM [sale_worson].[venta_x_descuento]
-----------------------------------------------



-------------------------------------------------------- PROVEEDOR  ----------------------------
BEGIN TRANSACTION
	
	INSERT INTO [sale_worson].[proveedor]
   
	SELECT DISTINCT 
			PROVEEDOR_RAZON_SOCIAL
           ,PROVEEDOR_CUIT
           ,PROVEEDOR_DOMICILIO
           ,PROVEEDOR_MAIL
           ,PROVEEDOR_LOCALIDAD
           ,PROVEEDOR_CODIGO_POSTAL
           ,PROVEEDOR_PROVINCIA
		
	FROM [gd_esquema].[Maestra]
	WHERE PROVEEDOR_RAZON_SOCIAL IS NOT NULL

--COMMIT
ROLLBACK

---------------------------------------
SELECT * FROM [sale_worson].[proveedor]
---------------------------------------



-------------------------------------------------------- COMPRA  -------------------------------

BEGIN TRANSACTION
	INSERT INTO [sale_worson].[compra]

	SELECT DISTINCT
		mt.COMPRA_NUMERO,
		p.PROVEEDOR_ID,
		mt.COMPRA_FECHA,
		mt.COMPRA_MEDIO_PAGO,
		mt.COMPRA_TOTAL

	FROM [gd_esquema].[Maestra] mt

	INNER JOIN [sale_worson].[proveedor] p
	ON	mt.PROVEEDOR_RAZON_SOCIAL	= p.PROVEEDOR_RAZON_SOCIAL		AND
		mt.PROVEEDOR_CUIT			= p.PROVEEDOR_CUIT				AND
		mt.PROVEEDOR_DOMICILIO		= p.PROVEEDOR_DOMICILIO			AND
		mt.PROVEEDOR_MAIL			= p.PROVEEDOR_MAIL				AND
		mt.PROVEEDOR_LOCALIDAD		= p.PROVEEDOR_LOCALIDAD			AND
		mt.PROVEEDOR_CODIGO_POSTAL	= p.PROVEEDOR_CODIGO_POSTAL		AND
		mt.PROVEEDOR_PROVINCIA		= p.PROVEEDOR_PROVINCIA

	WHERE mt.COMPRA_NUMERO IS NOT NULL

--COMMIT
ROLLBACK

------------------------------------
SELECT * FROM [sale_worson].[compra]
------------------------------------


-------------------------------------------------------- COMPRA DETALLE-------------------------
BEGIN TRANSACTION
	INSERT INTO [sale_worson].[compra_detalle]

	SELECT DISTINCT
		c.COMPRA_NUMERO as CD_COMPRA,
		p.PV_CODIGO as CD_PV,
		SUM(m.COMPRA_PRODUCTO_CANTIDAD) as CD_CANTIDAD,
		SUM(m.COMPRA_PRODUCTO_PRECIO * m.COMPRA_PRODUCTO_CANTIDAD) as CD_PRECIO

	FROM [gd_esquema].[Maestra] m

	INNER JOIN [sale_worson].[producto_variante] p ON m.PRODUCTO_VARIANTE_CODIGO = p.PV_CODIGO
	INNER JOIN [sale_worson].[compra] c ON m.COMPRA_NUMERO = c.COMPRA_NUMERO 

	GROUP BY c.COMPRA_NUMERO, p.PV_CODIGO


--COMMIT
ROLLBACK

--------------------------------------------
SELECT * FROM [sale_worson].[compra_detalle]
--------------------------------------------


-------------------------------------------------------- DESCUENTO COMPRA-----------------------

BEGIN TRANSACTION
	INSERT INTO [sale_worson].[descuento_compra]
   
	SELECT DISTINCT 
			DESCUENTO_COMPRA_CODIGO,
			DESCUENTO_COMPRA_VALOR
	FROM [gd_esquema].[Maestra]
	WHERE DESCUENTO_COMPRA_CODIGO IS NOT NULL

--COMMIT
ROLLBACK

----------------------------------------------
SELECT * FROM [sale_worson].[descuento_compra]
----------------------------------------------


-------------------------------------------------------- COMPRA X DESCUENTO --------------------
BEGIN TRANSACTION
	INSERT INTO [sale_worson].[compra_x_descuento]

	SELECT DISTINCT
		c.COMPRA_NUMERO,
		dc.DESCUENTO_COMPRA_CODIGO

	FROM  [gd_esquema].[Maestra] m

	INNER JOIN [sale_worson].[compra] c ON m.COMPRA_NUMERO = c.COMPRA_NUMERO
	INNER JOIN [sale_worson].[descuento_compra] dc ON m.DESCUENTO_COMPRA_CODIGO = dc.DESCUENTO_COMPRA_CODIGO

--COMMIT
ROLLBACK

------------------------------------------------
SELECT * FROM [sale_worson].[compra_x_descuento]
------------------------------------------------

