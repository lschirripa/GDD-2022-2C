-- CREACION DE CONSTRAINTS Y FK

ALTER TABLE [GD2C2022].[sale_worson].Producto_variante
ADD CONSTRAINT FK_VarienteCodigo
FOREIGN KEY (VARIANTE_CODIGO) REFERENCES [GD2C2022].[sale_worson].Variante(VARIANTE_CODIGO)

ALTER TABLE [GD2C2022].[sale_worson].Producto_variante
ADD CONSTRAINT FK_ProductoCodigo
FOREIGN KEY (PRODUCTO_CODIGO) REFERENCES [GD2C2022].[sale_worson].Producto(PRODUCTO_CODIGO)


-----/////////////////////////////////////////////////////////////////////////-----

ALTER TABLE [GD2C2022].[sale_worson].Venta_detalle
ADD CONSTRAINT FK_Venta_detalleVenta
FOREIGN KEY (VENTA_CODIGO) REFERENCES [GD2C2022].[sale_worson].Venta(VENTA_CODIGO)

ALTER TABLE [GD2C2022].[sale_worson].Venta_detalle
ADD CONSTRAINT FK_Venta_detalleVarianteProducto
FOREIGN KEY (PRODUCTO_VARIANTE_CODIGO) REFERENCES [GD2C2022].[sale_worson].Producto_variente(PRODUCTO_VARIANTE_CODIGO)

-----/////////////////////////////////////////////////////////////////////////-----

ALTER TABLE [GD2C2022].[sale_worson].Venta
ADD CONSTRAINT FK_VentaMedio_envio
FOREIGN KEY (VENTA_MEDIO_ENVIO_ID) REFERENCES [GD2C2022].[sale_worson].Medio_envio(VENTA_MEDIO_ENVIO_ID)

ALTER TABLE [GD2C2022].[sale_worson].Venta
ADD CONSTRAINT FK_VentaCanalId
FOREIGN KEY (CANAL_VENTA_ID) REFERENCES [GD2C2022].[sale_worson].Canal_venta(CANAL_VENTA_ID)

ALTER TABLE [GD2C2022].[sale_worson].Venta
ADD CONSTRAINT FK_VentaClientelId FOREIGN KEY 
(CLIENTE_ID) 
REFERENCES [GD2C2022].[sale_worson].Cliente(CLIENTE_ID)

-----/////////////////////////////////////////////////////////////////////////-----

ALTER TABLE [GD2C2022].[sale_worson].Venta_por_cupon
ADD CONSTRAINT FK_Venta_por_cuponVenta
FOREIGN KEY (VENTA_CODIGO) REFERENCES [GD2C2022].[sale_worson].Venta(VENTA_CODIGO)

ALTER TABLE [GD2C2022].[sale_worson].Venta_por_cupon
ADD CONSTRAINT FK_Venta_por_cuponVenta_cupon
FOREIGN KEY (VENTA_CUPON_CODIGO) REFERENCES [GD2C2022].[sale_worson].Venta_cupon(VENTA_CUPON_CODIGO)

-----/////////////////////////////////////////////////////////////////////////-----

ALTER TABLE [GD2C2022].[sale_worson].Venta_por_descuento
ADD CONSTRAINT FK_Venta_por_descuentoVenta
FOREIGN KEY (VENTA_CODIGO) REFERENCES [GD2C2022].[sale_worson].Venta(VENTA_CODIGO)

ALTER TABLE [GD2C2022].[sale_worson].Venta_por_descuento
ADD CONSTRAINT FK_Venta_por_descuentoDescuento_venta
FOREIGN KEY (VENTA_DESCUENTO_ID) REFERENCES [GD2C2022].[sale_worson].Descuento_venta(VENTA_DESCUENTO_ID)

-----/////////////////////////////////////////////////////////////////////////-----

ALTER TABLE [GD2C2022].[sale_worson].Compra
ADD CONSTRAINT FK_CompraProveedor
FOREIGN KEY (COMPRA_PROVEEDOR_ID) REFERENCES [GD2C2022].[sale_worson].Proveedor(CODIGO_PROVEEDOR)

-----/////////////////////////////////////////////////////////////////////////-----

ALTER TABLE [GD2C2022].[sale_worson].Compra_detalle
ADD CONSTRAINT FK_Compra_detalleCompra
FOREIGN KEY (COMPRA_NUMERO) REFERENCES [GD2C2022].[sale_worson].Compra(COMPRA_NUMERO)

ALTER TABLE [GD2C2022].[sale_worson].Compra_detalle
ADD CONSTRAINT FK_Compra_detalle_VarianteProducto
FOREIGN KEY (PRODUCTO_VARIANTE_CODIGO) REFERENCES [GD2C2022].[sale_worson].Producto_variente(PRODUCTO_VARIANTE_CODIGO)

-----/////////////////////////////////////////////////////////////////////////-----

ALTER TABLE [GD2C2022].[sale_worson].Compra_por_descuento
ADD CONSTRAINT FK_Compra_por_descuentoCompra
FOREIGN KEY (COMPRA_NUMERO) REFERENCES [GD2C2022].[sale_worson].Compra(COMPRA_NUMERO)

ALTER TABLE [GD2C2022].[sale_worson].Compra_por_descuento
ADD CONSTRAINT FK_Compra_por_descuentoDescuento_compra
FOREIGN KEY (COMPRA_DESCUENTO_ID) REFERENCES [GD2C2022].[sale_worson].Descuento_compra(COMPRA_DESCUENTO_ID)

-----/////////////////////////////////////////////////////////////////////////-----




/*

ALTER TABLE [GD2C2022].[sale_worson].
ADD CONSTRAINT FK_
FOREIGN KEY () REFERENCES ()

-----/////////////////////////////////////////////////////////////////////////-----


*/

