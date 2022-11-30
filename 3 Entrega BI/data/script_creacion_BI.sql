
CREATE PROCEDURE [sale_worson].prc_creacion_de_tablas_modelo_BI
AS
BEGIN
	
	SET NOCOUNT ON;


	BEGIN TRANSACTION
		CREATE TABLE  [GD2C2022].[sale_worson].BI_Dim_Tiempo (
			id					int PRIMARY KEY IDENTITY(1,1),
			mes					int NOT NULL,
			anio				int NOT NULL
		
		);
	
		CREATE TABLE  [GD2C2022].[sale_worson].BI_Dim_provincia (
			id					int PRIMARY KEY IDENTITY(1,1),
			provincia			nvarchar(100) NOT NULL
		
		);
	
	
		CREATE TABLE  [GD2C2022].[sale_worson].BI_Dim_Rango_Etario (
			id					int PRIMARY KEY IDENTITY(1,1),
			rangoInicio			int NOT NULL,
			rangoFin			int NOT NULL 
		);
	
		CREATE TABLE  [GD2C2022].[sale_worson].BI_Dim_Canal_venta (
			id					int PRIMARY KEY IDENTITY(1,1),
			costo				decimal(18,2) NOT NULL,
			descripcion			nvarchar(450) NOT NULL 
		
		);
	
		CREATE TABLE  [GD2C2022].[sale_worson].BI_Dim_Medio_Pago (
			id					int PRIMARY KEY IDENTITY(1,1),
			costo				decimal(18,2) NOT NULL,
			descripcion			nvarchar(510) NOT NULL 
		
		);
	
		CREATE TABLE  [GD2C2022].[sale_worson].BI_Dim_Categoria (
			id					int PRIMARY KEY IDENTITY(1,1),
			nombre				nvarchar(100) NOT NULL 
		
		);

		CREATE TABLE  [GD2C2022].[sale_worson].BI_Dim_producto (
			PRODUCTO_CODIGO			nvarchar(100) PRIMARY KEY,
			PRODUCTO_NOMBRE			nvarchar(100),
			PRODUCTO_DESCRIPCION	nvarchar(100), 
		
		);
	
		CREATE TABLE  [GD2C2022].[sale_worson].BI_Dim_Medio_envio (
			id					int PRIMARY KEY IDENTITY(1,1),
			precio				decimal(18,2) NOT NULL,
			descripcion			nvarchar(510) NOT NULL,
			provincia			nvarchar(100) NOT NULL,	
			codigo_postal		decimal(18,2) NOT NULL,
			venta_fecha			date NOT NULL
		);
	
	
		CREATE TABLE  [GD2C2022].[sale_worson].BI_Dim_Descuento (
			id					int PRIMARY KEY IDENTITY(1,1),
			importeP			decimal(18,2) NOT NULL,
			concepto			nvarchar(510) NOT NULL
	
		);

		CREATE TABLE  [GD2C2022].[sale_worson].BI_Dim_Proveedor (
			id			DECIMAL(18,0) PRIMARY KEY
	
		);	
	
		CREATE TABLE [GD2C2022].[sale_worson].BI_Dim_Cupon (
			CUPON_VENTA_CODIGO			nvarchar(255) PRIMARY KEY,
			FECHA_INICIO				date,
			FECHA_FIN					date,
			VENTA_VALOR			decimal(18,2),
			VENTA_TIPO			nvarchar(100)
		
		);

		------------------------------------------------------------------TABLAS DE HECHOS

		CREATE TABLE  [GD2C2022].[sale_worson].BI_HECHOS_VENTAS (
			VENTA_ID decimal(18,0),
			RANGO_ETARIO int,
			CATEGORIA int,
			TIEMPO int,
			PRODUCTO nvarchar(100),
			CANAL_VENTA int,
			MEDIO_PAGO int,
			DESCUENTO int,
			CUPON nvarchar(255),
			PROVINCIA int,
			MEDIO_ENVIO int,

			ganancia_mensual decimal(18,2),
			descuento_mensual decimal(18,2),
			cantidad_envios_x_mes int,
			cantidad_envios_total int

			PRIMARY KEY (VENTA_ID, RANGO_ETARIO, CATEGORIA, TIEMPO, PRODUCTO, CANAL_VENTA, MEDIO_PAGO, DESCUENTO, CUPON, PROVINCIA, MEDIO_ENVIO)

			FOREIGN KEY (RANGO_ETARIO) REFERENCES [GD2C2022].[sale_worson].BI_Dim_Rango_Etario([id]),
			FOREIGN KEY (CATEGORIA) REFERENCES [GD2C2022].[sale_worson].BI_Dim_Categoria ([id]),
			FOREIGN KEY (TIEMPO) REFERENCES [GD2C2022].[sale_worson].BI_Dim_TIEMPO ([id]),
			FOREIGN KEY (PRODUCTO) REFERENCES [GD2C2022].[sale_worson].BI_Dim_PRODUCTO([PRODUCTO_CODIGO]),
			FOREIGN KEY (CANAL_VENTA) REFERENCES [GD2C2022].[sale_worson].BI_Dim_CANAL_VENTA ([id]),
			FOREIGN KEY (MEDIO_PAGO) REFERENCES [GD2C2022].[sale_worson].BI_Dim_MEDIO_PAGO ([id]),
			FOREIGN KEY (descuento) REFERENCES [GD2C2022].[sale_worson].BI_Dim_descuento ([id]),
			FOREIGN KEY (CUPON) REFERENCES [GD2C2022].[sale_worson].BI_Dim_CUPON (CUPON_VENTA_CODIGO),
			FOREIGN KEY (PROVINCIA) REFERENCES [GD2C2022].[sale_worson].BI_Dim_PROVINCIA ([id]),
			FOREIGN KEY (MEDIO_ENVIO) REFERENCES [GD2C2022].[sale_worson].BI_Dim_MEDIO_ENVIO ([id])
);

		
		CREATE TABLE [GD2C2022].[sale_worson].BI_HECHOS_COMPRA (
			compra_id        decimal(18,0),
			tiempo            int,
			proveedor       DECIMAL(18,0),
			producto        nvarchar(100),
			
			costo_mensual decimal(18,2)

			PRIMARY KEY (compra_id, tiempo,producto,proveedor)

			FOREIGN KEY (tiempo) REFERENCES [sale_worson].BI_Dim_Tiempo(id),
			FOREIGN KEY (producto) REFERENCES [sale_worson].BI_Dim_PRODUCTO(PRODUCTO_CODIGO),
			FOREIGN KEY (proveedor) REFERENCES [sale_worson].BI_Dim_PROVEEDOR(id)
	
		)
	
	-----------------------------------------      Creacion de Constraints -----------------------------------------------
	ALTER TABLE [GD2C2022].[sale_worson].BI_Dim_Rango_Etario
	ADD
	CONSTRAINT rangos CHECK (rangoInicio<rangoFin)


	COMMIT

END
GO




--****************************************************************************************************************	MIGRACION


CREATE PROCEDURE [sale_worson].prc_migracion_modelo_BI
AS
BEGIN TRANSACTION

	SET NOCOUNT ON;

	------------------------------------------------------ DIM TIEMPO------------------------------------------------
	BEGIN TRANSACTION
	INSERT INTO  [GD2C2022].[sale_worson].BI_Dim_Tiempo
		SELECT DISTINCT 
		month(VENTA_FECHA),
		year(VENTA_FECHA)
		FROM  [GD2C2022].[sale_worson].[venta]
	COMMIT

	------------------------------------------------------ DIM PROVINCIA----------------------------------------------
	BEGIN TRANSACTION
	INSERT INTO  [GD2C2022].[sale_worson].BI_Dim_provincia
		SELECT DISTINCT 
		UBICACION_PROVINCIA
		FROM  [GD2C2022].[sale_worson].[ubicacion]
	COMMIT


	------------------------------------------------------ DIM RANGO ETARIO------------------------------------------------
	BEGIN TRANSACTION
	INSERT INTO [GD2C2022].[sale_worson].BI_Dim_Rango_Etario (rangoInicio, rangoFin)
	VALUES (0, 25),(25, 35),(35, 55),(55, 150)
	COMMIT

	------------------------------------------------------ DIM CANAL VENTA------------------------------------------------

	BEGIN TRANSACTION
	INSERT INTO  [GD2C2022].[sale_worson].BI_Dim_Canal_venta
		SELECT DISTINCT 
		CANAL_VENTA_COSTO,
		CANAL_VENTA_DESCRIPCION
		FROM  [GD2C2022].[sale_worson].[canal_venta]
	COMMIT

	------------------------------------------------------ DIM MEDIO PAGO  -----------------------------------------------

	BEGIN TRANSACTION
	INSERT INTO  [GD2C2022].[sale_worson].BI_Dim_Medio_Pago
		SELECT DISTINCT 
		MEDIO_PAGO_COSTO,
		MEDIO_PAGO_DESCRIPCION
		FROM  [GD2C2022].[sale_worson].[medio_pago]
	COMMIT

	------------------------------------------------------ DIM CATEGORIA  ------------------------------------------------

	BEGIN TRANSACTION
	INSERT INTO  [GD2C2022].[sale_worson].BI_Dim_Categoria
		SELECT DISTINCT 
		CATEGORIA_NOMBRE
		FROM  [GD2C2022].[sale_worson].[categoria]
	COMMIT


	------------------------------------------------------- DIM PRODUCTO --------------------------------------------------

	BEGIN TRANSACTION
		INSERT INTO [sale_worson].BI_Dim_producto

		SELECT DISTINCT 
			pv.PV_CODIGO,
			PRODUCTO_NOMBRE,
			PRODUCTO_DESCRIPCION
		
		FROM [GD2C2022].[sale_worson].[producto] p
		INNER JOIN sale_worson.producto_variante pv ON pv.PV_PRODUCTO = p.PRODUCTO_CODIGO
		WHERE PRODUCTO_CODIGO IS NOT NULL
	COMMIT
	------------------------------------------------------ DIM MEDIO ENVIO  ------------------------------------------------
	
	BEGIN TRANSACTION
	INSERT INTO  [GD2C2022].[sale_worson].BI_Dim_Medio_envio	
		SELECT 
		MEDIO_ENVIO_PRECIO,
		MEDIO_ENVIO_DESCRIPCION,
		UBICACION_PROVINCIA, 
		UBICACION_CP,
		VENTA_FECHA 
		FROM
		[GD2C2022].[sale_worson].[medio_envio] ME
		INNER JOIN 
		[GD2C2022].[sale_worson].[ubicacion] U
		ON ME.MEDIO_ENVIO_UBICACION = U.UBICACION_ID
		JOIN [GD2C2022].[sale_worson].[venta] V ON V.VENTA_MEDIO_ENVIO = ME.MEDIO_ENVIO_ID
	COMMIT
	
	------------------------------------------------------ PROVEEDOR  ------------------------------------------------
	BEGIN TRANSACTION
	INSERT INTO  [GD2C2022].[sale_worson].BI_Dim_Proveedor
		SELECT DISTINCT 
		PROVEEDOR_ID
		FROM  [GD2C2022].[sale_worson].[proveedor]
	COMMIT

	------------------------------------------------------ DIM DESCUENTO------------------------------------------------

	BEGIN TRANSACTION
	INSERT INTO  [GD2C2022].[sale_worson].BI_Dim_Descuento
		SELECT DISTINCT 
		DESCUENTO_VENTA_IMPORTE,
        DESCUENTO_VENTA_CONCEPTO
		FROM  [GD2C2022].[sale_worson].[descuento_venta]
	COMMIT
	
	------------------------------------------------------ DIM CUPON    ------------------------------------------------
	BEGIN TRANSACTION
	INSERT INTO  [GD2C2022].[sale_worson].BI_Dim_Cupon
		SELECT  [CUPON_VENTA_CODIGO]
      ,[CUPON_VENTA_FECHA_INICIO]
      ,[CUPON_VENTA_FECHA_FIN]
      ,[CUPON_VENTA_VALOR]
      ,[CUPON_VENTA_TIPO]
	FROM [GD2C2022].[sale_worson].[cupon_venta]
  
	COMMIT

	--------------------------------------------------------- Fact_VENTAS ---------------------------------------------------------

	BEGIN TRANSACTION
	INSERT INTO [GD2C2022].[sale_worson].BI_HECHOS_VENTAS

		SELECT 
			v.VENTA_CODIGO,
			CASE WHEN (SELECT DATEDIFF(year, (select DISTINCT c.CLIENTE_FECHA_NAC FROM sale_worson.cliente c WHERE c.CLIENTE_ID = cl.CLIENTE_ID), GETDATE())) < 25 THEN 1  
				WHEN (SELECT DATEDIFF(year, (select DISTINCT c.CLIENTE_FECHA_NAC FROM sale_worson.cliente c WHERE c.CLIENTE_ID = cl.CLIENTE_ID), GETDATE())) < 35 THEN 2  
				WHEN (SELECT DATEDIFF(year, (select DISTINCT c.CLIENTE_FECHA_NAC FROM sale_worson.cliente c WHERE c.CLIENTE_ID = cl.CLIENTE_ID), GETDATE())) < 55 THEN 3  else 4 
					end as rango_etario,
			cat.CATEGORIA_ID,
			dt.id TIEMPO,	--convert(varchar(7), v.VENTA_FECHA, 126) fecha,
			pv.PV_CODIGO,
			cv.CANAL_VENTA_ID,
			mp.MEDIO_PAGO_ID,
			dv.DESCUENTO_VENTA_ID,
			cuv.CUPON_VENTA_CODIGO,
			dp.id PROVINCIA,
			me.MEDIO_ENVIO_ID,
	

			SUM(VENTA_TOTAL) OVER (PARTITION BY v.VENTA_CODIGO, convert(varchar(7), v.VENTA_FECHA, 126)) ganancia_mensual,
			SUM(DESCUENTO_VENTA_IMPORTE) OVER (PARTITION BY v.VENTA_CODIGO, cuv.CUPON_VENTA_CODIGO, mp.MEDIO_PAGO_ID, cv.CANAL_VENTA_ID) descuento_mensual,
			(SELECT COUNT(1) FROM sale_worson.venta v2 WHERE v2.VENTA_FECHA = v.VENTA_FECHA) cantidad_envios_x_mes,
			(SELECT COUNT(1) FROM sale_worson.venta v2) cantidad_envios_total


		FROM sale_worson.venta v
		JOIN sale_worson.venta_detalle vd ON vd.VD_VENTA = v.VENTA_CODIGO
		JOIN sale_worson.producto_variante pv ON pv.PV_CODIGO = vd.VD_PV
		JOIN sale_worson.producto prod ON prod.PRODUCTO_CODIGO = pv.PV_PRODUCTO
		JOIN sale_worson.categoria cat ON cat.CATEGORIA_ID = prod.PRODUCTO_CATEGORIA
		JOIN sale_worson.canal_venta cv ON cv.CANAL_VENTA_ID = v.VENTA_CANAL
		JOIN sale_worson.medio_pago mp ON mp.MEDIO_PAGO_ID = v.VENTA_MEDIO_PAGO
		JOIN sale_worson.venta_x_descuento vxd ON vxd.VXD_VENTA = v.VENTA_CODIGO
		JOIN sale_worson.descuento_venta dv ON dv.DESCUENTO_VENTA_ID = vxd.VXD_DESCUENTO
		JOIN sale_worson.venta_x_cupon vxc ON vxc.VXC_VENTA = v.VENTA_CODIGO
		JOIN sale_worson.cupon_venta cuv ON cuv.CUPON_VENTA_CODIGO = vxc.VXC_CUPON
		JOIN sale_worson.medio_envio me ON me.MEDIO_ENVIO_ID = v.VENTA_MEDIO_ENVIO
		JOIN sale_worson.ubicacion u ON u.UBICACION_ID = me.MEDIO_ENVIO_UBICACION
		JOIN sale_worson.cliente cl ON cl.CLIENTE_ID = v.VENTA_CLIENTE
		JOIN sale_worson.BI_Dim_Tiempo dt ON dt.anio = YEAR(v.VENTA_FECHA) AND dt.mes = MONTH(v.VENTA_FECHA)
		JOIN sale_worson.BI_Dim_provincia dp ON dp.provincia = u.UBICACION_PROVINCIA


	COMMIT

	--------------------------------------------------------- FACT_COMPRAS ---------------------------------------------------------
	BEGIN TRANSACTION
	INSERT INTO [sale_worson].BI_HECHOS_COMPRA

			SELECT DISTINCT
				c.COMPRA_NUMERO,
				dt.id TIEMPO,
				c.COMPRA_PROVEEDOR,
				pv.PV_CODIGO PRODUCTO_CODIGO,
				SUM(c.COMPRA_TOTAL) OVER (PARTITION BY c.COMPRA_NUMERO, convert(varchar(7), c.COMPRA_FECHA, 126)) costo_mensual

			FROM sale_worson.compra c
			JOIN sale_worson.BI_Dim_Tiempo dt ON dt.anio = YEAR(c.COMPRA_FECHA) AND dt.mes = MONTH(c.COMPRA_FECHA)
			JOIN sale_worson.compra_detalle cd ON cd.CD_COMPRA = c.COMPRA_NUMERO
			JOIN sale_worson.producto_variante pv ON pv.PV_CODIGO = cd.CD_PV

	COMMIT


COMMIT
GO

--------------------------------------------------------------------------

-----------------------------------------------------------------------------
EXEC [sale_worson].prc_creacion_de_tablas_modelo_BI



EXEC [sale_worson].prc_migracion_modelo_BI

--*******************************************************


go





	----------------- CREACION DE VISTAS -----------------


	/*

	--metrica 3

	Las 5 categorías de productos más vendidos por rango etario de clientes
	por mes.
	*/

	CREATE VIEW sale_worson.vw_categorias_prod_mas_vendidas
	AS
	
	SELECT TOP(5)
		v.CATEGORIA,
		v.RANGO_ETARIO,
		dt.anio,
		dt.mes,
		COUNT(PRODUCTO) cant
	FROM [sale_worson].[BI_HECHOS_VENTAS] v
	JOIN sale_worson.BI_Dim_Tiempo dt ON dt.id = v.TIEMPO

	GROUP BY 	v.CATEGORIA,
		v.RANGO_ETARIO,
		dt.anio,
		dt.mes
	ORDER BY cant desc

	
	/*
	metrica 4

	Total de Ingresos por cada medio de pago por mes, descontando los costos
	por medio de pago (en caso que aplique) y descuentos por medio de pago
	(en caso que aplique)

	*/
	GO
	CREATE VIEW sale_worson.vw_tot_ingreso_por_medio_pago
	AS
	
	SELECT DISTINCT
	v.ganancia_mensual-descuento_mensual as tot_ingreso,
	v.medio_pago,
	 dt.anio,
	 dt.mes
	FROM [sale_worson].[BI_HECHOS_VENTAS] v
	JOIN [sale_worson].[BI_Dim_Medio_Pago] mp ON mp.id = v.medio_pago
	JOIN sale_worson.BI_Dim_Tiempo dt ON dt.id = v.TIEMPO

	GO
	
	/*
	metrica 5

	 Importe total en descuentos aplicados según su tipo de descuento, por
	canal de venta, por mes. Se entiende por tipo de descuento como los
	correspondientes a envío, medio de pago, cupones, etc)

	*/
	CREATE VIEW sale_worson.vw_dcto_mensual_canal_venta
	AS
	SELECT DISTINCT
	 v.descuento_mensual,
	 dt.anio,
	 dt.mes,
	 v.canal_venta,
	 d.concepto
	FROM [sale_worson].[BI_HECHOS_VENTAS] v
	JOIN sale_worson.BI_Dim_Tiempo dt ON dt.id = v.TIEMPO
	JOIN [sale_worson].[BI_Dim_Descuento] d ON d.id = v.descuento

	go

	

	/*
	metrica 6

	Porcentaje de envíos realizados a cada Provincia por mes. El porcentaje
	debe representar la cantidad de envíos realizados a cada provincia sobre
	total de envío mensuales.

	*/

	CREATE VIEW sale_worson.vw_porcentaje_envios_provincia
	AS
	SELECT
		PROVINCIA,
		CAST(cantidad_envios_x_mes * 100 / SUM(cantidad_envios_x_mes) as decimal(18,2)) AS PORCENTAJE
	FROM sale_worson.BI_HECHOS_VENTAS
	GROUP BY PROVINCIA, cantidad_envios_x_mes

	go
	/*
	metrica 7

	Valor promedio de envío por Provincia por Medio De Envío anual.
	*/

	CREATE VIEW sale_worson.vw_valor_promedio_de_envio
	AS
	SELECT 
		v.PROVINCIA,
		v.MEDIO_ENVIO,
		dt.anio,
		dt.mes,
		AVG(me.precio) ValorPromedio
	
	FROM [sale_worson].[BI_HECHOS_VENTAS] v
	JOIN sale_worson.BI_Dim_Tiempo dt ON dt.id = v.TIEMPO
	JOIN [sale_worson].[BI_Dim_Medio_envio] me ON me.ID = v.MEDIO_ENVIO

	GROUP BY 	v.PROVINCIA,
		v.MEDIO_ENVIO,
		dt.anio,
		dt.mes

	go
	
	/*
	metrica 8

	Aumento promedio de precios de cada proveedor anual. Para calcular este
	indicador se debe tomar como referencia el máximo precio por año menos
	el mínimo todo esto divido el mínimo precio del año. Teniendo en cuenta
	que los precios siempre van en aumento.
	*/

	CREATE VIEW sale_worson.vw_aumento_prom_de_precios
	AS
	SELECT 
		c.proveedor,
		dt.anio,
		--dt.mes,
		(MAX(costo_mensual) - MIN(costo_mensual))/MIN(costo_mensual) as promedioPrecios
	FROM [sale_worson].[BI_HECHOS_COMPRA] c
	JOIN sale_worson.BI_Dim_Tiempo dt ON dt.id = c.TIEMPO
	GROUP BY c.proveedor,	dt.anio

	go
	
	/*
	metrica 9

	Los 3 productos con mayor cantidad de reposición por mes.Los 3 productos con mayor cantidad de reposición por mes.

	*/
	CREATE VIEW sale_worson.vw_prod_mayor_repo
	AS
	SELECT
		c.producto,
		dt.anio,
		dt.mes,
		COUNT(1) cantidadRepos

	FROM [sale_worson].[BI_HECHOS_COMPRA] c
	JOIN sale_worson.BI_Dim_Tiempo dt ON dt.id = c.TIEMPO
	GROUP BY 	c.producto,
		dt.anio,
		dt.mes

	go

	-- METRICA 1:
	/*
	Las ganancias mensuales de cada canal de venta.
	Se entiende por ganancias al total de las ventas, menos el total de las
	compras, menos los costos de transacción totales aplicados asociados los
	medios de pagos utilizados en las mismas.
	*/


	CREATE VIEW sale_worson.vw_ganancia_mensual_x_canal
	as

	SELECT DISTINCT
		v.CANAL_VENTA,
		dt.anio,
		dt.mes,
		(SELECT v2.ganancia_mensual FROM [sale_worson].[BI_HECHOS_VENTAS] v2 
		WHERE v2.CANAL_VENTA = v.CANAL_VENTA AND v2.CATEGORIA = v.CATEGORIA AND v2.CUPON = v.CUPON AND v2.DESCUENTO = v.DESCUENTO AND v2.MEDIO_ENVIO = v.MEDIO_ENVIO
		AND v2.MEDIO_PAGO = v.MEDIO_PAGO AND v2.PRODUCTO = v.PRODUCTO AND v2.PROVINCIA = v.PROVINCIA AND v2.RANGO_ETARIO = v.RANGO_ETARIO AND v2.TIEMPO = v.TIEMPO AND v2.VENTA_ID = v.VENTA_ID
		) 
		- 
		(SELECT MAX(c.costo_mensual) FROM [sale_worson].[BI_HECHOS_COMPRA] c) as ganancia_mensual
	FROM [sale_worson].[BI_HECHOS_VENTAS] v
	JOIN sale_worson.BI_Dim_Tiempo dt ON dt.id = v.TIEMPO

	go
	

	-------------------------------------
	/*
	metrica 2

	Los 5 productos con mayor rentabilidad anual, con sus respectivos %
	Se entiende por rentabilidad a los ingresos generados por el producto
	(ventas) durante el periodo menos la inversión realizada en el producto
	(compras) durante el periodo, todo esto sobre dichos ingresos.
	Valor expresado en porcentaje.
	Para simplificar, no es necesario tener en cuenta los descuentos aplicados.

	*/
	CREATE VIEW sale_worson.vw_prod_rentable
	AS
	SELECT TOP(5)
	c.producto,
	SUM((ganancia_mensual - costo_mensual )*100/ganancia_mensual) rentabilidad,
	dt.anio


	FROM [sale_worson].[BI_HECHOS_VENTAS] v 
	JOIN [sale_worson].[BI_HECHOS_COMPRA] c ON c.producto = v.producto
	JOIN sale_worson.BI_Dim_Tiempo dt ON dt.id = v.TIEMPO
	GROUP by c.producto, anio
	order by 2 desc


	go