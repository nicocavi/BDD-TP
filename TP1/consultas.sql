CREATE TABLE factura(
	nro integer,
	importe float not null,
	constraint pk_factura primary key (nro)
);

CREATE TABLE producto(
	id integer,
	descr varchar(250),
	stock integer not null,
	constraint pk_producto primary key (id)
);


CREATE TABLE detalle(
	id integer,
	nro integer,
	cantidad integer not null,
	precio float not null,
	constraint pk_detalle primary key (id,nro),
	constraint fk_facturaDetalle foreign key (NRO) references factura(nro),
	constraint fk_productoDetalle foreign key (id) references producto(id)
);

#agregue la columna PRECIO_BASE a tabla producto (use el mismo tipo de dato que DETALLE.PRECIO), para guardar allí el precio de referencia del producto

alter table producto add PRECIO_BASE float not null;

#agregue la columna PRECIO_COSTO a tabla producto (use el mismo tipo de dato que DETALLE.PRECIO), para guardar allí el precio de costo del producto

alter table producto add PRECIO_COSTO float not null;

#agregue la columna ESTADO a tabla factura (tipo SMALLINT), la cual indica el estado de la factura (0 iniciada, 1 finalizada, 2 anulada)

alter table factura add ESTADO SMALLINT not null;

#agregue la columna FECHA a tabla factura (tipo DATE), la cual indica la fecha de la factura.

alter table factura add FECHA DATE;

/*
En un esquema de implementación B[1] (el usuario/aplicaciones NO interactúa directamente con las
tablas), resuelva (agregue los campos o tablas que considere necesarios):

1. Cada vez que se vende un producto, se descuenta su cantidad de stock (cada vez que deja de
vender un producto, sume su cantidad al stock). Un producto no puede venderse si el stock no es
suficiente.
*/


# Creacion de los generators 

CREATE GENERATOR GEN_FACTURA_ID;
SET GENERATOR GEN_FACTURA_ID TO 0;

CREATE GENERATOR GEN_PRODUCTO_ID;
SET GENERATOR GEN_PRODUCTO_ID TO 0;

#Trigger para los generators

CREATE EXCEPTION EX_FECHA1 'La fecha de la facha de la factura no puede ser menor a la de la factura antereor';

SET TERM ^;
CREATE TRIGGER TRG_BIFACTURA FOR FACTURA
ACTIVE BEFORE insert POSITION 0
AS
BEGIN
	NEW.NRO = GEN_ID(GEN_FACTURA_ID,1);
	NEW.ESTADO= 0;
	NEW.FECHA= 'TODAY';
END^
SET TERM ;^



SET TERM ^;
CREATE TRIGGER TRG_BIPRODUCTO FOR PRODUCTO
ACTIVE BEFORE INSERT POSITION 0
AS
BEGIN
	new.id = GEN_ID(GEN_PRODUCTO_ID,1);
END^
SET TERM ;^


/*Si el stock es isuficiente error*/

CREATE EXCEPTION EX_STOCK1 'Cantidad de stock es insuficiente';
SET TERM ^;
CREATE TRIGGER TRG_BUPRODUCTO FOR PRODUCTO
ACTIVE BEFORE UPDATE POSITION 0
AS
BEGIN

 	IF ( NEW.stock >= 0) THEN
 		EXCEPTION EX_STOCK1;

END^
SET TERM ;^

CREATE EXCEPTION EX_PRECIO1 'El precio del detalle no puede ser menor al precio del producto';

SET TERM ^;
CREATE TRIGGER TRG_BIDETALLE FOR DETALLE
ACTIVE BEFORE insert POSITION 0
as
declare variable PRECIO_BASE type of column PRODUCTO.PRECIO_BASE;
declare variable ESTADO type of column FACTURA.ESTADO;
begin
    select F.ESTADO
    from FACTURA as F
    where F.NRO = new.NRO
    into ESTADO;
   
    if (ESTADO = 1) then
    -- No agregar un Detalle a una Factura finalizada
        exception EX_DETALLE_FIN;
    if (new.CANTIDAD < 1) then
        exception EX_DETALLE_QTY;
       
    select P.PRECIO_BASE
    from PRODUCTO as P
    where P.ID = new.ID
    into PRECIO_BASE;
   
    if (new.PRECIO < PRECIO_BASE) then
        exception EX_DETALLE_PRC;

END^

SET TERM ;^


CREATE EXCEPTION EX_ESTADO1 'El estado de una factura no puede cambiar de finalizada a iniciada';
CREATE EXCEPTION EX_ESTADO2 'El estado de una factura no puede cambiar de anulada a iniciada';



SET TERM^;

CREATE TRIGGER TRG_BUFACTURA FOR FACTURA 
ACTIVE BEFORE UPDATE POSITION 0 
AS suspend
	
	declare variable ESTADO type of column FACTURA.ESTADO;
	

BEGIN

	select f.ESTADO
	from FACTURA as f 
	where f.NRO = new.NRO
	into ESTADO;

	if (NEW.ESTADO=0 and ESTADO=1) then 
		EXCEPTION EX_ESTADO1;

	if (NEW.ESTADO=0 and ESTADO=2) then 
		EXCEPTION EX_ESTADO2;	

	if(new.estado = )
	
			
END^
SET TERM ;^


SET TERM^;


CREATE TRIGGER TRG_AUFACTURA FOR FACTURA 
ACTIVE AFTER UPDATE POSITION 0 
AS 

declare variable ID_DETALLE type of column DETALLE.ID;
declare variable CANTIDAD_DETALLE type of column DETALLE.CANTIDAD;
begin

    if (OLD.ESTADO <> NEW.ESTADO and new.ESTADO = 2) then
        for select D.ID, D.CANTIDAD
            from DETALLE as D
            where D.NRO = new.NRO
            into ID_DETALLE, CANTIDAD_DETALLE
        do
            update PRODUCTO
            set STOCK = STOCK + :CANTIDAD_DETALLE
            where PRODUCTO.ID = :ID_DETALLE;

    if (old.ESTADO = 2 and new.ESTADO = 1 ) then
        for select D.ID, D.CANTIDAD
            from DETALLE as D
            where D.NRO = new.NRO
            into ID_DETALLE, CANTIDAD_DETALLE
        do
            update PRODUCTO
            set STOCK = STOCK - :CANTIDAD_DETALLE
            where PRODUCTO.ID = :ID_DETALLE;    

END^
SET TERM;^

set term ^;

CREATE PROCEDURE RANGO_FACTURA (DESDE double precision, HASTA double precision)
    as
        declare variable nro integer;
        declare variable importe double precision;
        declare variable estado smallint;
        declare variable fecha date;
	begin

    FOR SELECT F.NRO,F.IMPORTE, F.ESTADO,F.FECHA FROM FACTURA AS F
     WHERE F.IMPORTE >= coalesce(:DESDE,:DESDE_MIN) 
                   AND F.IMPORTE <=  coalesce(:HASTA,:HASTA_MAX)
   INTO :NRO,:IMPORTE, :ESTADO,:FECHA
   DO suspend;
end^

set term; ^

CREATE PROCEDURE EXE_ABM_PRODUCTO (ACCION varchar(1),ID BIGINT, DESCR varchar,STOCK integer, PRECIO_BASE double precision, PRECIO_COSTO double precision)
as 

begin
    execute statement (
        case upper(ACCION)
            when 'A' then
                'insert into PRODUCTO values ('
                || :ID || ','''
                || :DESCR || ''','
                || :STOCK || ','
                || :PRECIO_BASE || ','
                || :PRECIO_COSTO || ');'
            when 'B' then
                'delete from PRODUCTO as P where ' || :ID || '= P.ID;'
            when 'C' then
                'update PRODUCTO
                set DESCR = coalesce(''' || :DESCR || ''',DESCR),
                    STOCK = coalesce(' || :STOCK || ',STOCK),
                    PRECIO_BASE = coalesce(' || :PRECIO_BASE || ',PRECIO_BASE),
                    PRECIO_COSTO = coalesce(' || :PRECIO_COSTO || ',PRECIO_COSTO)
                where ' || :ID || ' = ID;'
            else 'exception;'
        end);
    ESTADO = 0;
    when any do ESTADO = 22023; --Invalid Parameter Value
end^

CREATE PROCEDURE EXE_BORRAR_ANULADAS (DESDE date, HASTA date)
as
begin
    delete from FACTURA
    where ESTADO = 2 and FECHA >= :DESDE and FECHA <= :HASTA;
end^

CREATE PROCEDURE EXE_FACTURA_CREAR_3 (CANTIDAD integer)
	begin
    if (:cantidad > 0) then
    begin
         insert into FACTURA(importe,estado) values (0,0);
         execute procedure EXE_FACTURA_crear_3(:cantidad-1);
     end
    end^

CREATE PROCEDURE SEL_FACTURA_1000_PRODUCTOS_6 (NRO BIGINT, IMPORTE double precision,FECHA date)

declare variable ID_2P type of column PRODUCTO.ID;
begin
    for select F.NRO, F.IMPORTE, F.FECHA
        from FACTURA as F
        where F.ESTADO = 1
        into :NRO, :IMPORTE, :FECHA
    do begin
        ID_2P = null;
        
        select first 1 skip 1 ID_PRODUCTO
        from SEL_FACTURA_PRODUCTOS_ORDENADOS(:NRO)
        into :ID_2P;
        
        if (exists (
            select P.ID
            from PRODUCTO as P
            where P.ID = :ID_2P and P.STOCK < 1000))
        then suspend;
    end
end^

CREATE PROCEDURE SEL_FACTURA_PRODUCTOS_ORDENADOS (NRO BIGINT)
as
begin
    for select F.NRO, P.ID
        from FACTURA as F
            inner join DETALLE as D on D.NRO = F.NRO
            inner join PRODUCTO as P on P.ID = D.ID
        where F.ESTADO = 1 and F.NRO = :NRO
        order by F.NRO, P.ID
        into :NRO_FACTURA, :ID_PRODUCTO
    do suspend;
end^

CREATE PROCEDURE SEL_FACTURA_X_IMPORTE_5 ()

begin
    select count(F.NRO)
    from FACTURA as F
    where F.IMPORTE <= 100
    into FAC100;
    
    select count(F.NRO)
    from FACTURA as F
    where F.IMPORTE > 100 and F.IMPORTE <= 1000
    into FAC1000;
    select count(F.NRO)
    from FACTURA as F
    where F.IMPORTE > 1000 and F.IMPORTE <= 10000
    into FAC10000;
    
    select count(F.NRO)
    from FACTURA as F
    where F.IMPORTE > 10000 and F.IMPORTE <= 100000
    into FAC100000;
    
    suspend;
end^

CREATE PROCEDURE SEL_FACTURA_X_IMPORTE_555 ()
begin
    select count(F.NRO)
    from FACTURA as F
    where F.IMPORTE <= 100
    into :FAC100;
    
    select count(F.NRO)
    from FACTURA as F
    where F.IMPORTE > 100 and F.IMPORTE <= 1000
    into :FAC1000;
    
    select count(F.NRO)
    from FACTURA as F
    where F.IMPORTE > 1000 and F.IMPORTE <= 10000
    into :FAC10000;
    
    select count(F.NRO)
    from FACTURA as F
    where F.IMPORTE > 10000 and F.IMPORTE <= 100000
    into :FAC100000;
    
    suspend;
end^

CREATE PROCEDURE SEL_PRODUCTOS_FACTURA_3 (DESDE BIGINT,HASTA BIGINT)

begin   
    for select D.ID, P.DESCR, sum(D.CANTIDAD), sum(D.CANTIDAD * D.PRECIO)
        from DETALLE as D 
            inner join FACTURA as F on F.NRO = D.NRO
            inner join PRODUCTO as P on D.ID = P.ID
        where D.NRO >= :DESDE and D.NRO <= :HASTA and F.ESTADO = 1
        group by D.ID, P.DESCR
        into :ID, :DESCR, :CANTIDAD, :TOTAL_FACTURADO
    do suspend;
end^


CREATE PROCEDURE SEL_PRODUCTOS_FACTURA_3_3 (DESDE BIGINT,HASTA BIGINT)

begin   
    for select P.DESCR, sum(D.CANTIDAD), sum(D.CANTIDAD * D.PRECIO)
        from DETALLE as D 
            inner join FACTURA as F on F.NRO = D.NRO
            inner join PRODUCTO as P on D.ID = P.ID
        where D.NRO >= :DESDE and D.NRO <= :HASTA and F.ESTADO = 1
        group by P.DESCR
        into :DESCR, :CANTIDAD, :TOTAL_FACTURADO
    do suspend;
end^


CREATE PROCEDURE SEL_PRODUCTOS_LAST3_4 ()

begin
    for select P.ID, P.DESCR, P.STOCK
        from PRODUCTO as P
        into :ID, :DESCR, :STOCK
    do begin
        FACTURA1 = null;
        FACTURA2 = null;
        FACTURA3 = null;
    
        select first 1 F.NRO
        from FACTURA as F 
            inner join DETALLE as D on F.NRO = D.NRO
        where :ID = D.ID and F.ESTADO = 1
        order by F.NRO desc
        into :FACTURA1;
        
        select first 1 skip 1 F.NRO
        from FACTURA as F 
            inner join DETALLE as D on F.NRO = D.NRO
        where :ID = D.ID and F.ESTADO = 1
        order by F.NRO desc
        into :FACTURA2;
        
        select first 1 skip 2 F.NRO
        from FACTURA as F 
            inner join DETALLE as D on F.NRO = D.NRO
        where :ID = D.ID and F.ESTADO = 1
        order by F.NRO desc
        into :FACTURA3;
        
        suspend;
    end
end^

CREATE PROCEDURE SEL_PRODUCTOS_LAST3_4 (ANIO SMALLINT)

begin
    MES = 1;
    while (MES <= 12) do begin
        TOTAL = 0;
        select sum(F.IMPORTE)
        from FACTURA as F
        where extract(year from F.FECHA) = :ANIO
            and extract(month from F.FECHA) = :MES
        into :TOTAL;
        suspend;
        MES = MES + 1;
    end
end^






-

