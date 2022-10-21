--CREACION DE TABLAS

CREATE TABLE [GD2C2022].[sale_worson].Variante
(
	VARIANTE_CODIGO nvarchar(100) PRIMARY KEY,
	VARIANTE_TIPO_ nvarchar(100),
	VARIANTE_DESCRIPCION nvarchar(100)
)


-------

CREATE TABLE [GD2C2022].[sale_worson].Producto
(
	PRODUCTO_CODIGO nvarchar(100) PRIMARY KEY,
	PRODUCTO_NOMBRE nvarchar(100),
	PRODUCTO_DESCRIPCION nvarchar(100),
	PRODUCTO_MARCA nvarchar(510),
	PRODUCTO_CATEGORIA nvarchar(510),
	PRODUCTO_MATERIAL nvarchar(100),
	
)

-----

CREATE TABLE [GD2C2022].[sale_worson].Producto_variente
( 
	PRODUCTO_VARIANTE_CODIGO nvarchar(100) PRIMARY KEY,
	VARIANTE_CODIGO nvarchar(100),		--FK a variante.variante_codigo
	PRODUCTO_CODIGO nvarchar(100)		-- FK  a producto.producto_codigo
)
-----

CREATE TABLE [GD2C2022].[sale_worson].Venta_detalle
(
	VENTA_CODIGO decimal(18,2),				--FK a Venta.VENTA_CODIGO
	PRODUCTO_VARIANTE_CODIGO nvarchar(100), --FK a Producto.PRODUCTO_VARIENTE_CODIGO
	VENTA_PRODUCTO_CANTIDAD decimal(18,2),
	VENTA_PRODUCTO_PRECIO decimal(18,2),
	PRIMARY KEY (VENTA_CODIGO, PRODUCTO_VARIANTE_CODIGO)
)

-----/

CREATE TABLE [GD2C2022].[sale_worson].Venta
(
	VENTA_CODIGO decimal(18,2) NOT NULL PRIMARY KEY,
	VENTA_FECHA date,
	VENTA_MEDIO_PAGO_ID decimal(18,2),
	VENTA_TOTAL decimal(18,2),
	VENTA_MEDIO_ENVIO_ID decimal,	--FK a Medio_envio.VENTA_MEDIO_ENVIO_ID
	CANAL_VENTA_ID decimal,			--FK a Canal_venta.CANAL_VENTA_TIPO
	CLIENTE_ID decimal(18,2)		--FK CLiente
	CONSTRAINT ck_venta_total CHECK(VENTA_TOTAL > 0)	--CONTRAIN DE TOTAL MAYOR A CERO 
)

-----

CREATE TABLE [GD2C2022].[sale_worson].Medio_envio
(
	VENTA_MEDIO_ENVIO_ID decimal PRIMARY KEY IDENTITY(1,1),
	VENTA_MEDIO_ENVIO nvarchar(510),
	VENTA_ENVIO_PRECIO decimal(18,2)
)

------

CREATE TABLE [GD2C2022].[sale_worson].Canal_venta
(
	CANAL_VENTA_ID decimal PRIMARY KEY IDENTITY(1,1), --lo creamos nosotros
	CANAL_COSTO decimal(18,2),
	CANAL_VENTA nvarchar(450) 
)

-----

CREATE TABLE [GD2C2022].[sale_worson].Venta_por_cupon
(
	VENTA_CODIGO decimal(18,2),			--FK a Venta.VENTA_CODIGO
	VENTA_CUPON_CODIGO nvarchar(255),	--FK a Venta_cupon.VENTA_CUPON_CODIGO
	VENTA_CUPON_IMPORTE decimal(18,2), 
	PRIMARY KEY (VENTA_CODIGO, VENTA_CUPON_CODIGO)
)

-----

CREATE TABLE [GD2C2022].[sale_worson].Venta_cupon
(
	VENTA_CUPON_CODIGO nvarchar(255) PRIMARY KEY,
	VENTA_CUPON_IMPORTE decimal(18,2),
	VENTA_CUPON_FECHA_DESDE date,
	VENTA_CUPON_FECHA_HASTA date,
	VENTA_CUPON_VALOR decimal(18,2),
	VENTA_CUPON_TIPO nvarchar(100)
									-- AGREGAR CONSTRAIN fehca desde < fecha hasta ?
)

----

CREATE TABLE [GD2C2022].[sale_worson].Venta_por_descuento
(
	VENTA_CODIGO decimal(18,2),			--FK a Venta.VENTA_CODIGO
	VENTA_DESCUENTO_ID decimal(18,2),	--FK a Descuento_venta.VENTA_DESCUENTO_ID
	PRIMARY KEY (VENTA_CODIGO, VENTA_DESCUENTO_ID)
)

-----

CREATE TABLE [GD2C2022].[sale_worson].Descuento_venta
(
	VENTA_DESCUENTO_ID decimal(18,2) PRIMARY KEY IDENTITY(1,1), --lo creamos nosotros
	VENTA_DESCUENTO_IMPORTE decimal(18,2) NOT NULL,
	VENTA_DESCUENTO_CONCEPTO nvarchar(510)
)

-----

CREATE TABLE [GD2C2022].[sale_worson].Venta_medio_de_pago
(
	VENTA_MEDIO_PAGO_ID decimal PRIMARY KEY IDENTITY(1,1),		--lo creamos nosotros
	VENTA_MEDIO_PAGO nvarchar(510),
	VENTA_MEDIO_PAGO_COSTO decimal(18,2)
)

-----

CREATE TABLE [GD2C2022].[sale_worson].Cliente
(
	CLIENTE_ID decimal PRIMARY KEY IDENTITY(1,1),				--lo creamos nosotros
	CLIENTE_NOMBRE nvarchar(510),
	CLIENTE_APELLIDO nvarchar(510),
	CLIENTE_DNI decimal(18,2),
	CLIENTE_TELEFONO decimal(18,2),
	CLIENTE_MAIL nvarchar(510),
	CLIENTE_FECHA_NACIMIENTO date,
	CLIENTE_LOCALIDAD decimal(18,2),
	CLIENTE_CODIGO_POSTAL decimal(18,2),
	CLIENTE_PROVINCIA decimal(18,2),
	CLIENTE_DIRECCION decimal(18,2)
	--CONSTRAIN CON LA FECHAAA
)

-----

CREATE TABLE [GD2C2022].[sale_worson].Compra
(
	COMPRA_NUMERO decimal(19,0) PRIMARY KEY,
	COMPRA_TOTAL decimal(18,2),
	COMPRA_PROVEEDOR_ID decimal,	--FK a Proveedor.CODIGO_PROVEEDOR
	COMPRA_FECHA date,
	COMPRA_MEDIO_PAGO nvarchar(510)
	CONSTRAINT ck_compra_total CHECK(COMPRA_TOTAL > 0)		 --CONTRAIN DE TOTAL MAYOR A CERO 
)

-----

CREATE TABLE [GD2C2022].[sale_worson].Compra_detalle
(
	COMPRA_NUMERO decimal(19,0) ,				--FK a Compra.COMPRA_NUMERO
	PRODUCTO_VARIANTE_CODIGO nvarchar(100),		--FK a Producto.PRODUCTO_VARIENTE_CODIGO
	COMPRA_PRODUCTO_CANTIDAD decimal(18,0),
	COMPRA_PRODUCTO_PRECIO decimal(18,0),
	PRIMARY KEY (COMPRA_NUMERO, PRODUCTO_VARIANTE_CODIGO)
)

-----

CREATE TABLE [GD2C2022].[sale_worson].Proveedor
(
	CODIGO_PROVEEDOR decimal PRIMARY KEY IDENTITY(1,1), --lo creamos nosotros
	PROVEEDOR_RAZON_SOCIAL nvarchar(100),
	PROVEEDOR_CUIT nvarchar(100),
	PROVEEDOR_MAIL nvarchar(100),
	PROVEEDOR_LOCALIDAD decimal(18,2),
	PROVEEDOR_CODIGO_POSTAL decimal(18,2),
	PROVEEDOR_PROVINCIA decimal(18,2),
	PROVEEDOR_CALLE decimal(18,2)
)

-----

CREATE TABLE [GD2C2022].[sale_worson].Descuento_compra
(
	COMPRA_DESCUENTO_ID decimal PRIMARY KEY IDENTITY(1,1), --lo creamos nosotros,
	DESCUENTO_COMPRA_CODIGO decimal(19,0),
	DESCUENTO_COMPRA_VALOR decimal(18,2)
)

-----

CREATE TABLE [GD2C2022].[sale_worson].Compra_por_descuento
(
	COMPRA_NUMERO decimal(19,0),	--FK a Compra.COMPRA_NUMERO
	COMPRA_DESCUENTO_ID decimal,	--FK a Descuento_compra.COMPRA_DESCUENTO_ID
	PRIMARY KEY (COMPRA_NUMERO, COMPRA_DESCUENTO_ID)
)
