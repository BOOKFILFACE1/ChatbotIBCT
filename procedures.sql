USE [Empresa2]
GO
/****** Object:  StoredProcedure [dbo].[ActClientes]    Script Date: 12/20/2021 5:16:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
CREATE PROCEDURE [dbo].[ActClientes] 
	@id_cliente int,
	@nombre varchar(50),
	@apellido varchar(50),
	@email varchar(50),
	@sexo char(10),
	@direccion varchar(50),
	@fecha_naci date,
	@telefono varchar(50)
AS
set nocount on
IF @id_cliente=0
BEGIN
	Select @id_cliente=MAX(id_cliente) from Clientes
	if @id_cliente is null set @id_cliente=0
	set @id_cliente=@id_cliente+1
END
If NOT EXISTS(Select id_cliente From Clientes where id_cliente=@id_cliente)
Begin
Insert into Clientes(id_cliente,nombre,apellido,email,sexo,direccion,fecha_naci,telefono) values(@id_cliente,@nombre,@apellido,@email,@sexo,@direccion,@fecha_naci,@telefono)
END
else Update Clientes set nombre=@nombre, apellido=@apellido,email=@email,sexo=@sexo,direccion=@direccion,fecha_naci=@fecha_naci,telefono=@telefono
where id_cliente=@id_cliente
select @id_cliente as id_cliente
GO
/****** Object:  StoredProcedure [dbo].[ActPedidos]    Script Date: 12/20/2021 5:16:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
CREATE PROCEDURE [dbo].[ActPedidos] 
	@id_pedido int,
	@id_cliente int,
	@fecha datetime,
	@total float,
	@id_estado int,
	@id_tipo_pedido int
AS
set nocount on;
IF @id_pedido=0
BEGIN
	Select @id_pedido = MAX(id_pedido) from Pedidos group by id_pedido order by id_pedido
	if @id_pedido is null set @id_pedido=0
	set @id_pedido=@id_pedido+1
END
If NOT EXISTS(Select id_pedido From Pedidos where id_pedido=@id_pedido)
Begin
	Insert into Pedidos(id_pedido,id_cliente,fecha,total,id_estado,id_tipo_pedido)values(@id_pedido,@id_cliente,getdate(),@total,@id_estado,@id_tipo_pedido)
END
select @id_pedido as id_pedido
GO
/****** Object:  StoredProcedure [dbo].[ActPedidos_Adomicilio]    Script Date: 12/20/2021 5:16:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
CREATE PROCEDURE [dbo].[ActPedidos_Adomicilio] 
	@id_pedido int,
	@direccion varchar(50)
AS

set nocount on

If NOT EXISTS(Select id_pedido From Pedido_Adomicilio where id_pedido=@id_pedido)
Begin
	Insert into Pedido_Adomicilio(id_pedido,direccion)values(@id_pedido,@direccion)
END
else 
begin
	Update Pedido_Adomicilio set direccion=@direccion 
	where id_pedido=@id_pedido
end
select @id_pedido as id_pedido
GO
/****** Object:  StoredProcedure [dbo].[ActPedidos_Reserva]    Script Date: 12/20/2021 5:16:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
CREATE PROCEDURE [dbo].[ActPedidos_Reserva] 
	@id_pedido int,
	@Fecha datetime
AS

set nocount on
If NOT EXISTS(Select id_pedido From Pedido_Reserva where id_pedido=@id_pedido)
Begin
	Insert into Pedido_Reserva(id_pedido,Fecha)values(@id_pedido,@Fecha)
END
else 
begin
	Update Pedido_Reserva set Fecha=@Fecha
	where id_pedido=@id_pedido
end
select @id_pedido as id_pedido
GO
/****** Object:  StoredProcedure [dbo].[Cancel_Pedido]    Script Date: 12/20/2021 5:16:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Cancel_Pedido] 
	@id_pedido int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	update Pedidos set id_estado=4 where id_pedido=@id_pedido
END
GO
/****** Object:  StoredProcedure [dbo].[Cliente_confirmacion]    Script Date: 12/20/2021 5:16:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Cliente_confirmacion]
	@email varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select id_cliente from Clientes where email like '%' + @email + '%'
END
GO
/****** Object:  StoredProcedure [dbo].[Clientes_Pedidos]    Script Date: 12/20/2021 5:16:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Clientes_Pedidos]
	@email varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    declare @id_cliente int
	
	set @id_cliente = (select top(1) id_cliente from Clientes where email like '%' + @email + '%')

	Select 
		p.id_pedido,
		p.fecha,
		tp.nombre as Tipo_Pedido,
		e.nombre as Estado
	from
		Pedidos p 
		join Estados e on p.id_estado=e.id_estado
		join Tipo_Pedido tp on p.id_tipo_pedido=tp.id_tipo_pedido
	where
		p.id_cliente=@id_cliente
		and (p.id_estado=1 or p.id_estado =2)

END
GO
/****** Object:  StoredProcedure [dbo].[GetPedidos_Detalle]    Script Date: 12/20/2021 5:16:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
CREATE PROCEDURE [dbo].[GetPedidos_Detalle] 
	@id_pedido int
AS

select 
	pr.id_producto as Id,
	pr.nombre as Producto,
	dp.cantidad as Cantidad,
	dp.precio as Precio,
	(dp.cantidad*dp.precio) as Total
from 
	Pedidos p join Detalle_Pedido dp on p.id_pedido=dp.id_pedido
	join Productos pr on dp.id_producto=pr.id_producto where p.id_pedido=@id_pedido
GO
/****** Object:  StoredProcedure [dbo].[Insert_Detalle_Pedido]    Script Date: 12/20/2021 5:16:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Insert_Detalle_Pedido]
	-- Add the parameters for the stored procedure here
	@id_pedido int,
	@id_producto int,
	@cantidad float
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @precio int
	set @precio=(select top(1) precio from Productos where id_producto=@id_producto)
	insert into Detalle_Pedido(id_pedido,id_producto,cantidad,precio) values (@id_pedido,@id_producto,@cantidad,@precio)
END
GO
/****** Object:  StoredProcedure [dbo].[productos_data]    Script Date: 12/20/2021 5:16:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE  [dbo].[productos_data]
	@id_producto int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    Select p.id_producto, p.nombre, p.imagen,(s.nombre+' '+s.apellidos) as suplidor, (p.cantidad_existente-p.cantidad_inorden) as cantidad, p.precio from Productos p join Suplidores s on p.id_suplidor=s.id_suplidor
	where p.id_producto=@id_producto or @id_producto=0
END
GO
