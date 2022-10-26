--CREACION DE TABLAS

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
	PV_VARIANTE					decimal,			-- FK a variante.VARIANTE_ID		--lo creamos nosotros
	PV_PRODUCTO					nvarchar(100)		-- FK a producto.PRODUCTO_CODIGO	--lo creamos nosotros
	PV_PRECIO_UNITARIO_ACTUAL	decimal(18,2)											--lo creamos nosotros
	PV_STOCK_ACTUAL				decimal(18,0)											--lo creamos nosotros
)

-------------------------------------------------------------------------------------------

CREATE TABLE [GD2C2022].[sale_worson].venta
(
	VENTA_CODIGO			decimal(18,0) NOT NULL PRIMARY KEY,
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
	PRIMARY KEY (VENTA_CODIGO, PRODUCTO_VARIANTE_CODIGO)
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
	VXC_VENTA				decimal(18,O),	--FK a venta.VENTA_CODIGO				--lo creamos nosotros
	VXC_CUPON				nvarchar(510),	--FK a cupon_venta.CUPON_VENTA_CODIGO	--lo creamos nosotros
	VXC_IMPORTE				decimal(18,2), 
	PRIMARY KEY (VENTA_CODIGO, VENTA_CUPON_CODIGO)
)

-------------------------------------------------------------------------------------------

CREATE TABLE [GD2C2022].[sale_worson].cupon_venta
(
	CUPON_VENTA_CODIGO			nvarchar(255) PRIMARY KEY,
	CUPON_VENTA_FECHA_INICIO	date,
	CUPON_VENTA_FECHA_FIN		date,
	CUPON_VENTA_VALOR			decimal(18,2),
	CUPON_VENTA_TIPO			nvarchar(100)
	-- AGREGAR CONSTRAINT fecha desde < fecha hasta ?
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
	DESCUENTO_VENTA_IMPORTE		decimal(18,2) NOT NULL,
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
	--CONSTRAINT CON LA FECHAAA
)

-------------------------------------------------------------------------------------------

CREATE TABLE [GD2C2022].[sale_worson].compra
(
	COMPRA_NUMERO		decimal(18,0) PRIMARY KEY,
	COMPRA_PROVEEDOR	decimal,							--FK a proveedor.PROVEEDOR_ID	--lo creamos nosotros
	COMPRA_FECHA		date,
	COMPRA_MEDIO_PAGO	nvarchar(510),
	COMPRA_TOTAL		decimal(18,2),
	--CONSTRAINT ck_compra_total CHECK(COMPRA_TOTAL > 0)	--CONSTRAINT DE TOTAL MAYOR A CERO 
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
	PRIMARY KEY (COMPRA_NUMERO, COMPRA_DESCUENTO_ID)
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