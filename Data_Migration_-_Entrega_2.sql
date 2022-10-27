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

-------------------------------------------------------- VARIANTE ------------------------

BEGIN TRANSACTION
	INSERT INTO [sale_worson].[variante]
           ([VARIANTE_TIPO_]
           ,[VARIANTE_DESCRIPCION])
   
	SELECT DISTINCT	
		PRODUCTO_TIPO_VARIANTE,
		PRODUCTO_VARIANTE
	
		
	FROM [gd_esquema].[Maestra]
	WHERE PRODUCTO_TIPO_VARIANTE is not null
--COMMIT
ROLLBACK

-------------------------------------------------------- PRODUCTO ------------------------

BEGIN TRANSACTION
	INSERT INTO [sale_worson].[producto]
           ([PRODUCTO_CODIGO]
           ,[PRODUCTO_NOMBRE]
           ,[PRODUCTO_DESCRIPCION]
           ,[PRODUCTO_MARCA]
           ,[PRODUCTO_CATEGORIA]
           ,[PRODUCTO_MATERIAL])
   
	SELECT DISTINCT 
			PRODUCTO_CODIGO
			,PRODUCTO_NOMBRE
			,PRODUCTO_DESCRIPCION
			,PRODUCTO_MARCA
			,PRODUCTO_CATEGORIA
			,PRODUCTO_MATERIAL 
		
	FROM [gd_esquema].[Maestra]
	WHERE PRODUCTO_CODIGO IS NOT NULL
--COMMIT
ROLLBACK



-------------------------------------------------------- PRODUCTO VARIANTE -----------------------
BEGIN TRANSACTION
INSERT INTO [sale_worson].[producto_variante]
           ([PV_CODIGO]
           ,[PV_VARIANTE]
           ,[PV_PRODUCTO]
           --,[PV_PRECIO_UNITARIO_ACTUAL]
           --,[PV_STOCK_ACTUAL])

	SELECT DISTINCT 
	PRODUCTO_VARIANTE_CODIGO,
	(select variante_Id from [sale_worson].variante
	where PRODUCTO_TIPO_VARIANTE=variante.VARIANTE_TIPO_ 
	and PRODUCTO_VARIANTE= variante.VARIANTE_DESCRIPCION) as PV_CODIGO ,
	PRODUCTO_CODIGO as PV_PRODUCTO
	-- precio,
	--stock
	FROM [gd_esquema].[Maestra]
	WHERE PRODUCTO_CODIGO IS NOT NULL
	
--COMMIT
ROLLBACK
-------------------------------------------------------- VENTA DETALLE -------------------------

-------------------------------------------------------- MEDIO ENVIO   -------------------------
BEGIN TRANSACTION
	INSERT INTO [sale_worson].[medio_envio]
           ([MEDIO_ENVIO_DESCRIPCION]
           ,[MEDIO_ENVIO_PRECIO])
  
	SELECT DISTINCT 
			VENTA_MEDIO_ENVIO
           ,VENTA_ENVIO_PRECIO
	FROM [gd_esquema].[Maestra]
	WHERE VENTA_MEDIO_ENVIO IS NOT NULL
--COMMIT
ROLLBACK

select * from [sale_worson].[medio_envio]
-------------------------------------------------------- CANAL VENTA   -------------------------
BEGIN TRANSACTION
	INSERT INTO [sale_worson].[canal_venta]
           ([CANAL_VENTA_COSTO]
           ,[CANAL_VENTA_DESCRIPCION])
  
  
	SELECT DISTINCT 
			VENTA_CANAL_COSTO,
			VENTA_CANAL
	FROM [gd_esquema].[Maestra]
	WHERE VENTA_CANAL is not null
--COMMIT
ROLLBACK


-------------------------------------------------------- COMPRA DETALLE-------------------------


-------------------------------------------------------- VENTA   -------------------------------
BEGIN TRANSACTION
	INSERT INTO [sale_worson].[venta]
           ([VENTA_CODIGO]
           ,[VENTA_FECHA]
           ,[VENTA_MEDIO_PAGO]
           ,[VENTA_MEDIO_ENVIO]
           ,[VENTA_CANAL]
           ,[VENTA_CLIENTE]
           ,[VENTA_TOTAL])
  
	SELECT DISTINCT 
			VENTA_CODIGO
			,VENTA_FECHA
			,(select MEDIO_PAGO_ID from [sale_worson].medio_pago
			where VENTA_MEDIO_PAGO = medio_pago.MEDIO_PAGO_DESCRIPCION
			and VENTA_MEDIO_PAGO_COSTO= medio_pago.[MEDIO_PAGO_COSTO]) as VENTA_MEDIO_PAGO
			,(select MEDIO_ENVIO_ID from [sale_worson].medio_envio
			where VENTA_MEDIO_ENVIO = medio_envio.MEDIO_ENVIO_DESCRIPCION 
			and VENTA_ENVIO_PRECIO = medio_envio.MEDIO_ENVIO_PRECIO) as VENTA_MEDIO_ENVIO
			,(SELECT CLIENTE_ID from [sale_worson].[cliente]
			where CLIENTE_NOMBRE = cliente.CLIENTE_NOMBRE
           and CLIENTE_APELLIDO = cliente.CLIENTE_APELLIDO
           and CLIENTE_DNI= cliente.CLIENTE_DNI
           and CLIENTE_DIRECCION = cliente.CLIENTE_DIRECCION
           and CLIENTE_TELEFONO = cliente.CLIENTE_TELEFONO
           and CLIENTE_MAIL = cliente.CLIENTE_MAIL
           and CLIENTE_FECHA_NAC = cliente.CLIENTE_FECHA_NAC
           and CLIENTE_LOCALIDAD = cliente.CLIENTE_LOCALIDAD
           and CLIENTE_CODIGO_POSTAL = cliente.CLIENTE_CODIGO_POSTAL
           and CLIENTE_PROVINCIA= cliente.CLIENTE_PROVINCIA) as VENTA_CLIENTE,
		   VENTA_TOTAL

	FROM [gd_esquema].[Maestra]
	WHERE CLIENTE_NOMBRE is  not null and CLIENTE_APELLIDO is not null
--COMMIT
ROLLBACK

SELECT * FROM [sale_worson].[medio_pago]
-------------------------------------------------------- COMPRA  -------------------------------

-------------------------------------------------------- VENTA X CUPON -------------------------
-------------------------------------------------------- VENTA X DESCUENTO ---------------------
-------------------------------------------------------- MEDIO PAGO ----------------------------
BEGIN TRANSACTION
	INSERT INTO [sale_worson].[medio_pago]
           ([MEDIO_PAGO_DESCRIPCION]
           ,[MEDIO_PAGO_COSTO])
   
	SELECT DISTINCT 
			VENTA_MEDIO_PAGO
			,VENTA_MEDIO_PAGO_COSTO
		
	FROM [gd_esquema].[Maestra]
	WHERE VENTA_MEDIO_PAGO is not null
--COMMIT
ROLLBACK
-------------------------------------------------------- CLIENTE  ------------------------------

BEGIN TRANSACTION
	
   INSERT INTO [sale_worson].[cliente]
           ([CLIENTE_NOMBRE]
           ,[CLIENTE_APELLIDO]
           ,[CLIENTE_DNI]
           ,[CLIENTE_DIRECCION]
           ,[CLIENTE_TELEFONO]
           ,[CLIENTE_MAIL]
           ,[CLIENTE_FECHA_NAC]
           ,[CLIENTE_LOCALIDAD]
           ,[CLIENTE_CODIGO_POSTAL]
           ,[CLIENTE_PROVINCIA])

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
	WHERE CLIENTE_NOMBRE is not null and CLIENTE_APELLIDO is not null
--COMMIT
ROLLBACK



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