use bdecomerce6;
select * from categoria;
create schema VillaSur_Script_DB; 
use VillaSur_Script_DB;
drop schema villasur;
create schema villasur;
use villasur;

delimiter $$
create procedure procedCategoria()
begin
	select * from	categoria;
    
end; $$

use bdecomerce6;


CREATE DEFINER=`root`@`localhost` PROCEDURE `usuario_codigo`(cod int)
begin
select codigo,usuario,email,foto from usuarios
where codigo=cod;
end



create table usuario(
id_usuario varchar(15) primary key,
contraseña varchar(4),
tipo_usuario varchar(20),
dni varchar(8),
nombre varchar(80),
email varchar(80),
foto varchar(20));

create table categoria(
id_categoria int primary key auto_increment,
nombre varchar(60),
estado varchar(10));

create table producto(
id_producto int primary key,
id_categoria int,
nombre varchar(60),
marca varchar(30),
descripcion varchar(30),
precio decimal(12,2),
unidad varchar(5),
stock decimal(12,2),
imagen varchar(10));

create table carrito(
id_carrito int primary key,
id_usuario varchar(15),
estado varchar(20));

create table carrito_detalle(
id_detalle int primary key auto_increment,
id_carrito int,
id_producto int,
cantidad decimal(12,2),
precio decimal(12,2));

delimiter $$
create procedure sp_usuario_q01(
p_id_usuario varchar(15),
p_dni varchar(8))
begin
	Select	id_usuario, contraseña, tipo_usuario, dni, nombre, email, foto
    From	usuario
    Where	id_usuario=p_id_usuario
    or		dni=p_dni;
end; $$

delimiter $$
create procedure sp_usuario_q02(
p_id_usuario varchar(15),
p_contraseña varchar(4))
begin
	Select	id_usuario, contraseña, tipo_usuario, dni, nombre, email, foto
    From	usuario
    Where	id_usuario=p_id_usuario
    And		contraseña=p_contraseña;
end; $$

delimiter $$
create procedure sp_usuario_i01(
p_id_usuario varchar(15),
p_contraseña varchar(4),
p_tipo_usuario varchar(20),
p_dni varchar(8),
p_nombre varchar(80),
p_email varchar(80),
p_foto varchar(20))
begin
	insert into usuario
    (id_usuario, contraseña, tipo_usuario, dni, nombre, email, foto)
	values
	(p_id_usuario, p_contraseña, p_tipo_usuario, p_dni, p_nombre, p_email, p_foto);
end; $$

delimiter $$
create procedure sp_usuario_u01(
p_id_usuario varchar(15),
p_contraseña varchar(4),
p_tipo_usuario varchar(4),
p_dni varchar(8),
p_nombre varchar(80),
p_email varchar(80),
p_foto varchar(20))
begin
	update	usuario
    set		contraseña=p_contraseña,
			tipo_usuario=p_tipo_usuario,
			dni=p_dni,
			nombre=p_nombre,
			email=p_email,
			foto=p_foto
    Where	id_usuario=p_id_usuario;
end; $$

delimiter $$
create procedure sp_categoria_q01()
begin
	select	id_categoria, nombre, estado
    from	categoria;
end; $$

delimiter $$
create procedure sp_categoria_q02()
begin
	select	id_categoria, nombre, estado
    from	categoria
    where	estado='Activo';
end; $$

delimiter $$
create procedure sp_categoria_q03(
in p_id_categoria int)
begin
	select	id_categoria, nombre, estado
    from	categoria
    where	id_categoria=p_id_categoria;
end; $$

delimiter $$
create procedure sp_categoria_q04(
in p_nombre int)
begin
	select	id_categoria, nombre, estado
    from	categoria
    where	nombre=p_nombre;
end; $$

delimiter $$
create procedure sp_categoria_i01(
in p_nombre varchar(60),
in p_estado varchar(10))
begin
	insert into categoria(nombre, estado)
    values(p_nombre, p_estado);
end; $$

delimiter $$
create procedure sp_categoria_u01(
in p_id_categoria int,
in p_nombre varchar(60),
in p_estado varchar(10))
begin
	update	categoria
    set		nombre=p_nombre,
			estado=p_estado
    Where	id_categoria=p_id_categoria;
end; $$

delimiter $$
create procedure sp_categoria_d01(
in p_id_categoria int)
begin
	delete
    from	categoria
    Where	id_categoria=p_id_categoria;
end; $$

delimiter $$
create procedure sp_producto_gen_id()
begin
	select	ifnull(max(id_producto),0)+1 as 'codigo_generado'
    From	producto;
end; $$

delimiter $$
create procedure sp_producto_i01(
p_id_producto int,
p_id_categoria int,
p_nombre varchar(60),
p_marca varchar(30),
p_descripcion varchar(30),
p_precio decimal(12,2),
p_unidad varchar(5),
p_stock decimal(12,2),
p_imagen varchar(10))
begin
	insert into producto(id_producto, id_categoria, nombre, marca, descripcion, precio, unidad, stock, imagen)
	values(p_id_producto, p_id_categoria, p_nombre, p_marca, p_descripcion, p_precio, p_unidad, p_stock, p_imagen);
end; $$


delimiter $$
create procedure sp_producto_u01(
p_id_producto int,
p_id_categoria int,
p_nombre varchar(60),
p_marca varchar(30),
p_descripcion varchar(30),
p_precio decimal(12,2),
p_unidad varchar(5),
p_stock decimal(12,2),
p_imagen varchar(10))
begin
	Update	producto
    set		id_categoria=p_id_categoria,
			nombre=p_nombre, 
			marca=p_marca, 
            descripcion=p_descripcion, 
            precio=p_precio, 
            unidad=p_unidad, 
            stock=p_stock
	Where	id_producto=p_id_producto;
end; $$

delimiter $$
create procedure sp_producto_d01(
p_id_producto int)
begin
	delete	
    from	producto
	Where	id_producto=p_id_producto;
end; $$

delimiter $$
create procedure sp_producto_q01()
begin
	select	p.id_producto as id_producto, 
			p.id_categoria as id_categoria, 
            c.nombre as categoria,
            p.nombre as nombre, 
            p.marca as marca, 
            p.descripcion as descripcion, 
            p.precio as precio, 
            p.unidad as unidad, 
            p.stock as stock, 
            p.imagen as imagen
    From	producto p inner join
			categoria c on p.id_categoria=c.id_categoria;
end; $$

delimiter $$
create procedure sp_producto_q02(
p_id_producto int)
begin
	select	id_producto, id_categoria, nombre, marca, descripcion, precio, unidad, stock, imagen
    From	producto
    where	id_producto=p_id_producto;
end; $$

delimiter $$
create procedure sp_producto_q03(
p_id_categoria int)
begin
	select	id_producto, id_categoria, nombre, marca, descripcion, precio, unidad, stock, imagen
    From	producto
    where	id_categoria=p_id_categoria
	and		stock>0;
end; $$

delimiter $$
create procedure sp_carrito_agregar_producto(
p_id_usuario varchar(15),
p_id_producto int)
begin
	declare carritos_proceso int default 0;
    declare codigo_carrito int default 0;
    declare codigo_detalle int default 0;
    declare producto_cantidad decimal(12,2) default 0.0;
    declare producto_precio decimal(12,2) default 0.0;
    declare registros int default 0;
    
    select	precio
    into	producto_precio
    from	producto
    where	id_producto=p_id_producto;
    
	select	count(id_carrito)
    into	carritos_proceso
    from	carrito
    where	id_usuario=p_id_usuario
    and		estado='proceso';
    
    if carritos_proceso=0 then
		select	ifnull(max(id_carrito),0) + 1
        into	codigo_carrito
        from	carrito;
    
		insert into carrito(id_carrito, id_usuario, estado)
        values(codigo_carrito, p_id_usuario, 'proceso');
        
		set producto_cantidad=1;
		insert into carrito_detalle(id_carrito, id_producto, cantidad, precio)
		values(codigo_carrito, p_id_producto, producto_cantidad, producto_precio);
    else
		select	id_carrito
		into	codigo_carrito
		from	carrito
		where	id_usuario=p_id_usuario
		and		estado='proceso';
        
        select	count(id_detalle)
        into	registros
        from	carrito_detalle
        where	id_carrito=codigo_carrito
        and		id_producto=p_id_producto;
        
        if registros=0 then
			set producto_cantidad=1;
			insert into carrito_detalle(id_carrito, id_producto, cantidad, precio)
			values(codigo_carrito, p_id_producto, producto_cantidad, producto_precio);
        else
			select	id_detalle
			into	codigo_detalle
			from	carrito_detalle
			where	id_carrito=codigo_carrito
			and		id_producto=p_id_producto;
			
			Update	carrito_detalle
            set		cantidad=cantidad+1
            where	id_detalle=codigo_detalle;
        end if;
    end if;
end; $$

delimiter $$
create procedure sp_carrito_items_q01(
p_id_usuario varchar(15))
begin
	select	d.id_producto as id_producto
    from	carrito c inner join
			carrito_detalle d on c.id_carrito=d.id_carrito
	where	id_usuario=p_id_usuario
    and		estado='proceso';
end; $$

delimiter $$
create procedure sp_carrito_nro_items_q01(
p_id_usuario varchar(15))
begin
	select	count(id_detalle) as items
    from	carrito c inner join
			carrito_detalle d on c.id_carrito=d.id_carrito
	where	id_usuario=p_id_usuario
    and		estado='proceso';
end; $$

delimiter $$
create procedure sp_carrito_comprar(
p_id_carrito varchar(15))
begin
	update	carrito
    set		estado='comprado'
    where	id_carrito=p_id_carrito;
end; $$

call sp_usuario_i01( 'AZUÑIGA', '123', 'administrador', '43809897', 'Antonio Zuñiga', 'jorgezunigarojas1@gmail.com', 'uazuñiga.jpg');
call sp_categoria_i01('Cemento y Complementos', 'Activo');
call sp_categoria_i01('Ladrillos, bloques y casetones', 'Activo');

call sp_producto_i01(1, 1, 'Cemento Sol T1', 'Sol', '42.5 kg', 22.20, 'UN', 100, 'p1.png');
call sp_producto_i01(2, 1, 'Cemento Apu', 'Apu', '42.5 kg', 20.50, 'UN', 200, 'p2.png');
call sp_producto_i01(3, 1, 'Cemento Refractario Yellow 5Kg Schemin', 'Schemin', '5 Kg', 18.60, 'UN', 300, 'p3.png');
call sp_producto_i01(4, 1, 'Cemento Refractario 1000 BBQ 5 Kg Schemin', 'Schemin', '5 Kg', 13.10, 'UN', 400, 'p4.png');
call sp_producto_i01(5, 1, 'Arena Gruesa m3 Topex', 'Producto Exclusivo', 'A pedido por metro cúbico (m3)', 57, 'UN', 500, 'p5.png');
call sp_producto_i01(6, 1, 'Piedra Chancada 1/2" m3 Topex', 'Producto Exclusivo', 'A pedido por metro cúbico (m3)', 63.90, 'UN', 600, 'p6.png');

call sp_producto_i01(7, 2, 'Ladrillo Techo 12 Pirámide', 'Pirámide', '12 x 30 x 30 cm', 2.08, 'UN', 700, 'p7.png');
call sp_producto_i01(8, 2, 'Ladrillo King Kong 18 Huecos Económica', 'Diamante', 'Construcción', 1.59, 'UN', 800, 'p8.png');
call sp_producto_i01(9, 2, 'Casetón 1.20x0.3x0.12 m Indupol', 'Indupol', '1.20 x 0.30 x 0.12 m', 8.50, 'UN', 900, 'p9.png');
call sp_producto_i01(10, 2, 'Block de Vidrio New Olas 30 x 30 cm Glass Block', 'Glass Block', '30 x 30 cm', 72.90, 'UN', 1000, 'p10.png');
call sp_producto_i01(11, 2, 'Bloque para grass michi Unicon', 'Unicon', '30 x 30 x 8 cm', 4.50, 'UN', 1100, 'p11.png');


#call sp_carrito_agregar_producto('AZUÑIGA',1)
#call sp_producto_i01(1, 1, 'Fresa', 'akme', 'Envase x 550g', 9, 'UN', 100, 'p1.jpg');
#CALL sp_carrito_nro_items_q01('AZUÑIGA')