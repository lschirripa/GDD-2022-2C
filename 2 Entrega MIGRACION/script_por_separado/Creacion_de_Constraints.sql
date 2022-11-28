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
