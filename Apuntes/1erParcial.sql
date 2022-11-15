/*
1. Realizar una consulta SQL q permita saber si un cliente compro un producto en todos los meses de 2012

mostrar para el 2012:
	1- el cliente
	2- la razon social del cliente
	3- el producto comprado
	4- el nombre del producto
	5- cantidad de productos distintos comprados por el cliente
	6- cantidad de productos con composicion comprados por el cliente

El resultado debe ser ordenado poniendo primero aquellos clientes q compraron mas de 10 productos distintos en 2012.
*/


SELECT 

C.clie_codigo,

C.clie_razon_social,

P.prod_codigo,

P.prod_detalle,

(SELECT 
    
COUNT(DISTINCT I2.item_producto)    

FROM ITEM_FACTURA I2 JOIN FACTURA F2 ON I2.item_numero = F2.fact_numero AND 

                I2.item_sucursal = F2.fact_sucursal AND 

              I2.item_tipo = F2.fact_tipo 

WHERE 

F2.fact_cliente = C.clie_codigo AND 

YEAR(F2.fact_fecha) = 2012

),

(SELECT 

SUM(item_cantidad) 

FROM ITEM_FACTURA I2 JOIN FACTURA F2 ON I2.item_numero = F2.fact_numero AND 

                I2.item_sucursal = F2.fact_sucursal AND 

              I2.item_tipo = F2.fact_tipo 

WHERE 

F2.fact_cliente = C.clie_codigo AND 

YEAR(F2.fact_fecha) = 2012 AND 

EXISTS (SELECT 1 FROM COMPOSICION WHERE COMP_PRODUCTO = P.prod_codigo)

)

FROM CLIENTE C JOIN FACTURA F ON C.clie_codigo = F.fact_cliente 

          JOIN ITEM_FACTURA I ON I.item_numero = F.fact_numero AND I.item_sucursal = F.fact_sucursal AND I.item_tipo = F.fact_tipo 

          JOIN PRODUCTO P ON P.prod_codigo = I.item_producto 

WHERE 

YEAR(F.fact_fecha) = 2012

GROUP BY 

C.clie_codigo ,

C.clie_razon_social ,

P.prod_codigo ,

P.prod_detalle 

HAVING 

COUNT(DISTINCT MONTH(F.fact_fecha)) = 12 

ORDER BY 

5 DESC 

-----------------otra solucion de un 8 --------------


-- Asumo que solo se desean ver los clientes que cumplen con la condicion de que en todos los meses del 2012 compraron un mismo producto

select c.clie_codigo, c.clie_razon_social, p.prod_codigo, p.prod_detalle,
		(select count(distinct item_producto) 
				from Item_Factura
				join factura on fact_numero = item_numero and fact_sucursal = item_sucursal and fact_tipo = item_tipo
				where year(fact_fecha) = '2012' and fact_cliente = c.clie_codigo) ProductosDistintos,
		(select count(item_producto) 
				from Item_Factura
				join factura on fact_numero = item_numero and fact_sucursal = item_sucursal and fact_tipo = item_tipo
				where year(fact_fecha) = '2012' and fact_cliente = c.clie_codigo
				and exists(select 1 from Composicion where comp_producto = item_producto)) ProductosConComposicion
									
from cliente c 
join factura f  on c.clie_codigo = f.fact_cliente
join item_factura fi  on f.fact_numero = fi.item_numero and f.fact_tipo = fi.item_tipo and f.fact_sucursal = fi.item_sucursal
join Producto p on p.prod_codigo = fi.item_producto
where year(f.fact_fecha) = '2012'
group by c.clie_codigo, c.clie_razon_social, p.prod_codigo, p.prod_detalle
having
	count( distinct month(fact_fecha)) = 12   --Cuento que la cantidad de meses en los que compro el producto sean igual a 12
order by  --Al ordenar por el calculo de productos distintos en forma descentente, indefectiblemente quedaran primeros los clientes que compraron màs de 10 productos distintos en el 2012
(select count(distinct item_producto) 
				from Item_Factura
				join factura on fact_numero = item_numero and fact_sucursal = item_sucursal and fact_tipo = item_tipo
				where year(fact_fecha) = '2012' and fact_cliente = c.clie_codigo) desc


/*
2. Implementar una regla de negocio de validacion en linea que permita
implementar una logica de control de precios en las ventas.

Se debera poder seleccionar una lista de rubros y aquellos productos de los
rubros que sean los seleccionados no podran aumentar por mes mas de un 2 %

En caso que no se tenga referencia del mes anterior no validar dicha regla

*/

-- Creo una tabla donde se pueden cargar los rubros que no deben sufrir aumentos.
create table RubrosSinAumentos
(
	SinAum_Rubro char(4)
)
GO

create TRIGGER [dbo].[TR_CONTROL_AUMENTOS]
	ON [dbo].[Item_Factura]
AFTER INSERT
AS
BEGIN TRANSACTION
	 /*Seteo el inicio y fin del mes anterior para facilitar posteriormente el control del precio en el mes anterior*/
	 declare @InicioMesAnterior date
	 declare @FinMesAnterior date
	  set @InicioMesAnterior = CAST(DATEADD(month, DATEDIFF(month, 0, dateadd(month,-1, getdate())), 0)  AS date)
	  set @FinMesAnterior = eomonth ( dateadd(month,-1, getdate()))
	
	declare @producto char(8)
	declare @precioNuevo decimal(12,2)
	declare @precioAnterior decimal(12,2)

	declare my_cursor cursor for
	/*Solo voy a validar los productos que pertenezcan al rubro de los que se desean controlar y que hayan tenido ventas el mes anterior */
	SELECT i.ITEM_PRODUCTO, i.item_precio, max(fi.item_precio) MaxPrecioMesAnterior 
	from inserted i
	join Producto p on i.item_producto = p.prod_codigo
	join Item_Factura fi on fi.item_producto = p.prod_codigo  --Con este join contra item_factura y factura, busco verificar si el mes anterior tuvieron ventas, si no las tuvieron no se mostrarían en la consulta al no hacer join. Además obtengo el precio de venta del mes anterior.
	join Factura f on f.fact_numero = fi.item_numero and f.fact_tipo = fi.item_tipo and f.fact_sucursal = fi.item_sucursal
	where 
			--Controlo solo los productos que pertecen a rubros que se indicó que no deben sufrir aumentos, que se encuentran en la tabla que generé anteriormente
		exists (select 1 from RubrosSinAumentos where SinAum_Rubro = p.prod_rubro)
		and f.fact_fecha between @InicioMesAnterior and @FinMesAnterior
		group by i.ITEM_PRODUCTO, i.item_precio
			
	 open my_cursor
	 fetch my_cursor INTO @producto, @precioNuevo, @PrecioAnterior
	 
	 while @@FETCH_STATUS = 0
	 begin
	 print @producto 
	 print @precioNuevo
	 print @precioAnterior
		if (@precioNuevo > (@precioAnterior * 1.02))
		begin
			print 'El precio nuevo supera en más de un 2% al del mes anterior para este producto que se encuentra en un rubro con restriccion de aumentos'
			rollback
			return
		end
		
	 fetch next from my_cursor INTO @producto, @precioNuevo, @PrecioAnterior
	 end 	
	 close my_cursor
	 deallocate my_cursor
COMMIT
go