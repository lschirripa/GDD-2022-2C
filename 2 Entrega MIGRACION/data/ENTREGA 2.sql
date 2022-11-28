--CREACION DEL ESQUEMA
USE [GD2C2022]
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'sale_worson')
BEGIN
	EXEC('CREATE SCHEMA sale_worson')
END
GO

-- ================================================
-- ================================================
-- ================================================
-- ============SP DECREACION DE TABLAS=============
-- ================================================
-- ================================================
-- ================================================
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		sale_worson
-- Create date: 10/26
-- Description:	sp para crear las tablas
-- =============================================
CREATE PROCEDURE [sale_worson].prc_creacion_de_tablas
	-- Add the parameters for the stored procedure here
	--
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	--CREACION DE TABLAS

	-- USE GD2C2022 --> No se puede poner el USE en un SP

	BEGIN TRANSACTION

	CREATE TABLE [GD2C2022].[sale_worson].variante
	(
		VARIANTE_ID				decimal PRIMARY KEY IDENTITY(1,1),	--lo creamos nosotros
		VARIANTE_TIPO_			nvarchar(100),
		VARIANTE_DESCRIPCION	nvarchar(100)
	)


	-------------------------------------------------------------------------------------------

	CREATE TABLE [GD2C2022].[sale_worson].producto
	(
		PRODUCTO_CODIGO			nvarchar(100) PRIMARY KEY,
		PRODUCTO_NOMBRE			nvarchar(100),
		PRODUCTO_DESCRIPCION	nvarchar(100),
		PRODUCTO_MARCA			nvarchar(510),
		PRODUCTO_CATEGORIA		nvarchar(510),
		PRODUCTO_MATERIAL		nvarchar(100),
	
	)

	-------------------------------------------------------------------------------------------

	CREATE TABLE [GD2C2022].[sale_worson].producto_variante
	( 
		PV_CODIGO					nvarchar(100) PRIMARY KEY,
		PV_VARIANTE					decimal(18,0),		-- FK a variante.VARIANTE_ID		--lo creamos nosotros
		PV_PRODUCTO					nvarchar(100),		-- FK a producto.PRODUCTO_CODIGO	--lo creamos nosotros
		PV_PRECIO_UNITARIO_ACTUAL	decimal(18,2),											--lo creamos nosotros
		PV_STOCK_ACTUAL				decimal(18,0)											--lo creamos nosotros
	)

	-------------------------------------------------------------------------------------------

	CREATE TABLE [GD2C2022].[sale_worson].venta
	(
		VENTA_CODIGO			decimal(18,0) PRIMARY KEY,
		VENTA_FECHA				date,
		VENTA_MEDIO_PAGO		decimal,					--FK a medio_pago.MEDIO_PAGO_ID		--lo creamos nosotros
		VENTA_MEDIO_ENVIO		decimal,					--FK a medio_envio.MEDIO_ENVIO_ID	--lo creamos nosotros
		VENTA_CANAL				decimal,					--FK a canal_venta.CANAL_VENTA_ID	--lo creamos nosotros
		VENTA_CLIENTE			decimal,					--FK a cliente.CLIENTE_ID			--lo creamos nosotros
		VENTA_TOTAL				decimal(18,2)
	)

	-------------------------------------------------------------------------------------------

	CREATE TABLE [GD2C2022].[sale_worson].venta_detalle
	(
		VD_VENTA			decimal(18,0),			--FK a venta.VENTA_CODIGO				--lo creamos nosotros
		VD_PV				nvarchar(100),			--FK a producto_variante.PV_CODIGO		--lo creamos nosotros
		VD_PV_CANTIDAD		decimal(18,0),
		VD_PV_PRECIO		decimal(18,2),													--lo creamos nosotros
		PRIMARY KEY (VD_VENTA, VD_PV)
	)

	-------------------------------------------------------------------------------------------


	CREATE TABLE [GD2C2022].[sale_worson].medio_envio
	(
		MEDIO_ENVIO_ID				decimal PRIMARY KEY IDENTITY(1,1), --lo creamos nosotros
		MEDIO_ENVIO_DESCRIPCION		nvarchar(510),
		MEDIO_ENVIO_PRECIO			decimal(18,2)
	)

	-------------------------------------------------------------------------------------------

	CREATE TABLE [GD2C2022].[sale_worson].canal_venta
	(
		CANAL_VENTA_ID				decimal PRIMARY KEY IDENTITY(1,1), --lo creamos nosotros
		CANAL_VENTA_COSTO			decimal(18,2),
		CANAL_VENTA_DESCRIPCION		nvarchar(450) 
	)

	-------------------------------------------------------------------------------------------

	CREATE TABLE [GD2C2022].[sale_worson].venta_x_cupon
	(
		VXC_VENTA				decimal(18,0),	--FK a venta.VENTA_CODIGO				--lo creamos nosotros
		VXC_CUPON				nvarchar(255),	--FK a cupon_venta.CUPON_VENTA_CODIGO	--lo creamos nosotros
		VXC_IMPORTE				decimal(18,2), 
		PRIMARY KEY (VXC_VENTA, VXC_CUPON)
	)

	-------------------------------------------------------------------------------------------

	CREATE TABLE [GD2C2022].[sale_worson].cupon_venta
	(
		CUPON_VENTA_CODIGO			nvarchar(255) PRIMARY KEY,
		CUPON_VENTA_FECHA_INICIO	date,
		CUPON_VENTA_FECHA_FIN		date,
		CUPON_VENTA_VALOR			decimal(18,2),
		CUPON_VENTA_TIPO			nvarchar(100)
	
	)

	-------------------------------------------------------------------------------------------

	CREATE TABLE [GD2C2022].[sale_worson].venta_x_descuento
	(
		VXD_VENTA		decimal(18,0),			--FK a venta.VENTA_CODIGO					--lo creamos nosotros
		VXD_DESCUENTO	decimal,				--FK a descuento_venta.DESCUENTO_VENTA_ID	--lo creamos nosotros
		PRIMARY KEY (VXD_VENTA, VXD_DESCUENTO)
	)

	-------------------------------------------------------------------------------------------

	CREATE TABLE [GD2C2022].[sale_worson].descuento_venta
	(
		DESCUENTO_VENTA_ID			decimal PRIMARY KEY IDENTITY(1,1),	--lo creamos nosotros
		DESCUENTO_VENTA_IMPORTE		decimal(18,2),
		DESCUENTO_VENTA_CONCEPTO	nvarchar(510)
	)

	-------------------------------------------------------------------------------------------

	CREATE TABLE [GD2C2022].[sale_worson].medio_pago
	(
		MEDIO_PAGO_ID				decimal PRIMARY KEY IDENTITY(1,1),	--lo creamos nosotros
		MEDIO_PAGO_DESCRIPCION		nvarchar(510),
		MEDIO_PAGO_COSTO			decimal(18,2)
	)

	-------------------------------------------------------------------------------------------

	CREATE TABLE [GD2C2022].[sale_worson].cliente
	(
		CLIENTE_ID					decimal PRIMARY KEY IDENTITY(1,1),	--lo creamos nosotros
		CLIENTE_NOMBRE				nvarchar(510),
		CLIENTE_APELLIDO			nvarchar(510),
		CLIENTE_DNI					decimal(18,0),
		CLIENTE_DIRECCION			nvarchar(510),
		CLIENTE_TELEFONO			decimal(18,0),
		CLIENTE_MAIL				nvarchar(510),
		CLIENTE_FECHA_NAC			date,
		CLIENTE_LOCALIDAD			nvarchar(510),
		CLIENTE_CODIGO_POSTAL		decimal(18,0),
		CLIENTE_PROVINCIA			nvarchar(510),
	)

	-------------------------------------------------------------------------------------------

	CREATE TABLE [GD2C2022].[sale_worson].compra
	(
		COMPRA_NUMERO		decimal(18,0) PRIMARY KEY,
		COMPRA_PROVEEDOR	decimal,							--FK a proveedor.PROVEEDOR_ID	--lo creamos nosotros
		COMPRA_FECHA		date,
		COMPRA_MEDIO_PAGO	nvarchar(510),
		COMPRA_TOTAL		decimal(18,2),
		--CONSTRAINT ck_compra_total CHECK(COMPRA_TOTAL > 0)	--CONSTRAINT DE TOTAL MAYOR A CERO --> Puede haber compras en las que el total sea nulo por x motivo
	)

	-------------------------------------------------------------------------------------------

	CREATE TABLE [GD2C2022].[sale_worson].compra_detalle
	(
		CD_COMPRA					decimal(18,0) ,		--FK a compra.COMPRA_NUMERO				--lo creamos nosotros
		CD_PV						nvarchar(100),		--FK a producto_variante.PV_CODIGO		--lo creamos nosotros
		CD_CANTIDAD					decimal(18,0),
		CD_PRECIO					decimal(18,2),
		PRIMARY KEY (CD_COMPRA, CD_PV)
	)

	-------------------------------------------------------------------------------------------

	CREATE TABLE [GD2C2022].[sale_worson].compra_x_descuento
	(
		CXD_COMPRA		decimal(18,0),		--FK a compra.COMPRA_NUMERO							--lo creamos nosotros
		CXD_DESCUENTO	decimal(18,0),		--FK a descuento_compra.DESCUENTO_COMPRA_CODIGO		--lo creamos nosotros
		PRIMARY KEY (CXD_COMPRA, CXD_DESCUENTO)
	)

	-------------------------------------------------------------------------------------------

	CREATE TABLE [GD2C2022].[sale_worson].descuento_compra
	(
		DESCUENTO_COMPRA_CODIGO		decimal(18,0) PRIMARY KEY,
		DESCUENTO_COMPRA_PORCENTAJE	decimal(18,2)
	)

	-------------------------------------------------------------------------------------------

	CREATE TABLE [GD2C2022].[sale_worson].proveedor
	(
		PROVEEDOR_ID			decimal PRIMARY KEY IDENTITY(1,1), --lo creamos nosotros
		PROVEEDOR_RAZON_SOCIAL	nvarchar(100),
		PROVEEDOR_CUIT			nvarchar(100),
		PROVEEDOR_DOMICILIO		nvarchar(100),
		PROVEEDOR_MAIL			nvarchar(100),
		PROVEEDOR_LOCALIDAD		nvarchar(100),
		PROVEEDOR_CODIGO_POSTAL decimal(18,2),
		PROVEEDOR_PROVINCIA		nvarchar(100),
	)

	-------------------------------------------------------------------------------------------

	--ROLLBACK
	COMMIT
END
GO


-- ================================================
-- ================================================
-- ================================================
-- ============SP CREACION DE CONSTRAINS===========
-- ================================================
-- ================================================
-- ================================================
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		sale_worson
-- Create date: 10/26
-- Description:	sp para crear los constrains de las fk
-- =============================================
CREATE PROCEDURE [sale_worson].prc_creacion_de_FK_constrains
	-- Add the parameters for the stored procedure here
	--
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	-- CREACION DE CONSTRAINTS Y FK

	BEGIN TRANSACTION

	ALTER TABLE [GD2C2022].[sale_worson].Producto_variante
	ADD CONSTRAINT FK_varianteCodigo
	FOREIGN KEY (PV_VARIANTE) REFERENCES [GD2C2022].[sale_worson].Variante(VARIANTE_ID)

	ALTER TABLE [GD2C2022].[sale_worson].Producto_variante
	ADD CONSTRAINT FK_ProductoCodigo
	FOREIGN KEY (PV_PRODUCTO) REFERENCES [GD2C2022].[sale_worson].Producto(PRODUCTO_CODIGO)


	-----/////////////////////////////////////////////////////////////////////////-----


	ALTER TABLE [GD2C2022].[sale_worson].Venta_detalle
	ADD CONSTRAINT FK_Venta_detalleVenta
	FOREIGN KEY (VD_VENTA) REFERENCES [GD2C2022].[sale_worson].Venta(VENTA_CODIGO)

	ALTER TABLE [GD2C2022].[sale_worson].Venta_detalle
	ADD CONSTRAINT FK_Venta_detalleVarianteProducto
	FOREIGN KEY (VD_PV) REFERENCES [GD2C2022].[sale_worson].Producto_variante(PV_CODIGO)


	-----/////////////////////////////////////////////////////////////////////////-----


	ALTER TABLE [GD2C2022].[sale_worson].Venta
	ADD CONSTRAINT FK_VentaMedio_pago
	FOREIGN KEY (VENTA_MEDIO_PAGO) REFERENCES [GD2C2022].[sale_worson].Medio_pago(MEDIO_PAGO_ID)

	ALTER TABLE [GD2C2022].[sale_worson].Venta
	ADD CONSTRAINT FK_VentaMedio_envio
	FOREIGN KEY (VENTA_MEDIO_ENVIO) REFERENCES [GD2C2022].[sale_worson].Medio_envio(MEDIO_ENVIO_ID)

	ALTER TABLE [GD2C2022].[sale_worson].Venta
	ADD CONSTRAINT FK_VentaCanalId
	FOREIGN KEY (VENTA_CANAL) REFERENCES [GD2C2022].[sale_worson].Canal_venta(CANAL_VENTA_ID)

	ALTER TABLE [GD2C2022].[sale_worson].Venta
	ADD CONSTRAINT FK_VentaClientelId 
	FOREIGN KEY (VENTA_CLIENTE) REFERENCES [GD2C2022].[sale_worson].Cliente(CLIENTE_ID)


	-----/////////////////////////////////////////////////////////////////////////-----


	ALTER TABLE [GD2C2022].[sale_worson].venta_x_cupon
	ADD CONSTRAINT FK_Venta_por_cuponVenta
	FOREIGN KEY (VXC_VENTA) REFERENCES [GD2C2022].[sale_worson].Venta(VENTA_CODIGO)

	ALTER TABLE [GD2C2022].[sale_worson].venta_x_cupon
	ADD CONSTRAINT FK_Venta_por_cuponVenta_cupon
	FOREIGN KEY (VXC_CUPON) REFERENCES [GD2C2022].[sale_worson].cupon_venta(CUPON_VENTA_CODIGO)


	-----/////////////////////////////////////////////////////////////////////////-----


	ALTER TABLE [GD2C2022].[sale_worson].venta_x_descuento
	ADD CONSTRAINT FK_Venta_por_descuentoVenta
	FOREIGN KEY (VXD_VENTA) REFERENCES [GD2C2022].[sale_worson].Venta(VENTA_CODIGO)

	ALTER TABLE [GD2C2022].[sale_worson].venta_x_descuento
	ADD CONSTRAINT FK_Venta_por_descuentoDescuento_venta
	FOREIGN KEY (VXD_DESCUENTO) REFERENCES [GD2C2022].[sale_worson].Descuento_venta(DESCUENTO_VENTA_ID)


	-----/////////////////////////////////////////////////////////////////////////-----


	ALTER TABLE [GD2C2022].[sale_worson].Compra
	ADD CONSTRAINT FK_CompraProveedor
	FOREIGN KEY (COMPRA_PROVEEDOR) REFERENCES [GD2C2022].[sale_worson].Proveedor(PROVEEDOR_ID)


	-----/////////////////////////////////////////////////////////////////////////-----


	ALTER TABLE [GD2C2022].[sale_worson].Compra_detalle
	ADD CONSTRAINT FK_Compra_detalleCompra
	FOREIGN KEY (CD_COMPRA) REFERENCES [GD2C2022].[sale_worson].Compra(COMPRA_NUMERO)

	ALTER TABLE [GD2C2022].[sale_worson].Compra_detalle
	ADD CONSTRAINT FK_Compra_detalle_VarianteProducto
	FOREIGN KEY (CD_PV) REFERENCES [GD2C2022].[sale_worson].Producto_variante(PV_CODIGO)

	-----/////////////////////////////////////////////////////////////////////////-----


	ALTER TABLE [GD2C2022].[sale_worson].compra_x_descuento
	ADD CONSTRAINT FK_Compra_por_descuentoCompra
	FOREIGN KEY (CXD_COMPRA) REFERENCES [GD2C2022].[sale_worson].Compra(COMPRA_NUMERO)

	ALTER TABLE [GD2C2022].[sale_worson].compra_x_descuento
	ADD CONSTRAINT FK_Compra_por_descuentoDescuento_compra
	FOREIGN KEY (CXD_DESCUENTO) REFERENCES [GD2C2022].[sale_worson].Descuento_compra(DESCUENTO_COMPRA_CODIGO)


	-----/////////////////////////////////////////////////////////////////////////-----


	--ROLLBACK
	COMMIT
END
GO


-- ================================================
-- ================================================
-- ================================================
-- ================SP MIGRACION====================
-- ================================================
-- ================================================
-- ================================================
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		sale_worson
-- Create date: 10/30
-- Description:	sp para migrar los datos
-- =============================================
CREATE PROCEDURE [sale_worson].prc_migracion
	-- Add the parameters for the stored procedure here
	--
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	------------------------------------------------------------------------------------------------------------------------------
	------------------------------------------------------ MIGRACION -------------------------------------------------------------
	------------------------------------------------------------------------------------------------------------------------------
	-- RECORDAR QUE CUANDO SE CORRA LA MIGRACION, ES IMPORTANTE MANTENER ESTE ORDEN DADO QUE LA MAYORIA DE LAS TABLAS TIENEN FK --
	------------------------------------------------------------------------------------------------------------------------------

	-------------------------------------------------------- VARIANTE ------------------------

	BEGIN TRANSACTION
		INSERT INTO [sale_worson].[Variante]

		SELECT DISTINCT 
			PRODUCTO_TIPO_VARIANTE,
			PRODUCTO_VARIANTE
		FROM [gd_esquema].[Maestra]
		WHERE PRODUCTO_VARIANTE_CODIGO IS NOT NULL

	COMMIT
	--ROLLBACK


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
	COMMIT
	--ROLLBACK



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


	COMMIT
	--ROLLBACK



	-------------------------------------------------------- MEDIO ENVIO   -------------------------
	BEGIN TRANSACTION
		INSERT INTO [sale_worson].[medio_envio]
  
		SELECT DISTINCT 
			VENTA_MEDIO_ENVIO,
			VENTA_ENVIO_PRECIO
		FROM [gd_esquema].[Maestra]
		WHERE VENTA_MEDIO_ENVIO IS NOT NULL

	COMMIT
	--ROLLBACK



	-------------------------------------------------------- CANAL VENTA   -------------------------
	BEGIN TRANSACTION
		INSERT INTO [sale_worson].[canal_venta]
  
		SELECT DISTINCT 
				VENTA_CANAL_COSTO,
				VENTA_CANAL
		FROM [gd_esquema].[Maestra]
		WHERE VENTA_CANAL IS NOT NULL

	COMMIT
	--ROLLBACK



	-------------------------------------------------------- MEDIO PAGO ----------------------------
	BEGIN TRANSACTION
		INSERT INTO [sale_worson].[medio_pago]

		SELECT DISTINCT 
			VENTA_MEDIO_PAGO,
			VENTA_MEDIO_PAGO_COSTO
		
		FROM [gd_esquema].[Maestra]
		WHERE VENTA_MEDIO_PAGO IS NOT NULL

	COMMIT
	--ROLLBACK



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

	COMMIT
	--ROLLBACK



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

	COMMIT
	--ROLLBACK

	-- Si dejamos las subconsultas resulta mucho menos performante (1min contra 3seg)



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

	COMMIT
	--ROLLBACK



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

	COMMIT
	--ROLLBACK



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

	COMMIT
	--ROLLBACK



	-------------------------------------------------------- DESCUENTO VENTA -----------------------
	BEGIN TRANSACTION
		INSERT INTO [sale_worson].[descuento_venta]
   
		SELECT DISTINCT 
				VENTA_DESCUENTO_IMPORTE,
				VENTA_DESCUENTO_CONCEPTO
		
		FROM [gd_esquema].[Maestra]
		WHERE VENTA_DESCUENTO_IMPORTE IS NOT NULL

	COMMIT
	--ROLLBACK



	-------------------------------------------------------- VENTA X DESCUENTO ---------------------
	BEGIN TRANSACTION
	
		INSERT INTO [sale_worson].[venta_x_descuento]

		SELECT DISTINCT
			v.VENTA_CODIGO,
			dv.DESCUENTO_VENTA_ID
		FROM [gd_esquema].[Maestra] m

		INNER JOIN [sale_worson].[venta] v ON v.VENTA_CODIGO = m.VENTA_CODIGO
		INNER JOIN [sale_worson].[descuento_venta] dv ON dv.DESCUENTO_VENTA_IMPORTE = m.VENTA_DESCUENTO_IMPORTE AND dv.DESCUENTO_VENTA_CONCEPTO = m.VENTA_DESCUENTO_CONCEPTO


	COMMIT
	--ROLLBACK



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

	COMMIT
	--ROLLBACK



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

	COMMIT
	--ROLLBACK


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


	COMMIT
	--ROLLBACK


	-------------------------------------------------------- DESCUENTO COMPRA-----------------------

	BEGIN TRANSACTION
		INSERT INTO [sale_worson].[descuento_compra]
   
		SELECT DISTINCT 
				DESCUENTO_COMPRA_CODIGO,
				DESCUENTO_COMPRA_VALOR
		FROM [gd_esquema].[Maestra]
		WHERE DESCUENTO_COMPRA_CODIGO IS NOT NULL

	COMMIT
	--ROLLBACK


	-------------------------------------------------------- COMPRA X DESCUENTO --------------------
	BEGIN TRANSACTION
		INSERT INTO [sale_worson].[compra_x_descuento]

		SELECT DISTINCT
			c.COMPRA_NUMERO,
			dc.DESCUENTO_COMPRA_CODIGO

		FROM  [gd_esquema].[Maestra] m

		INNER JOIN [sale_worson].[compra] c ON m.COMPRA_NUMERO = c.COMPRA_NUMERO
		INNER JOIN [sale_worson].[descuento_compra] dc ON m.DESCUENTO_COMPRA_CODIGO = dc.DESCUENTO_COMPRA_CODIGO

	COMMIT
	--ROLLBACK


END
GO


-- ================================================
-- ================================================
-- ================================================



-- ================================================
-- ================================================
-- ================================================



-- ================================================
-- ===========Llamado de los SP=================
-- ================================================


EXEC [sale_worson].prc_creacion_de_tablas
EXEC [sale_worson].prc_creacion_de_FK_constrains
EXEC [sale_worson].prc_migracion
