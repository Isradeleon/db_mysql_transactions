drop database if exists BDBanco;
create database BDBanco;
use BDBanco;

create table cuentas(
	cta_id char(4) not null primary key,
	saldo int
);

insert into cuentas values ('ACC1',50);
insert into cuentas values ('ACC2',45);
insert into cuentas values ('ACC3',40);

----------------------------------------------------------------
-- TMovimientos
set @saldo := (select saldo from cuentas where cta_id = 'ACC1');

start transaction;
select (@saldo * 1.76) into @new_saldo;
update cuentas set saldo = @new_saldo
	where cta_id = 'ACC1';

set @condition := (@saldo>=45);
select IF(@condition, "COMMIT;", "ROLLBACK;") into @action; -- ACTION TO DO CONDITIONALLY

PREPARE statement FROM @action; -- PREPARING THE ACTION
EXECUTE statement;
DEALLOCATE PREPARE statement;
select IF(@condition, "TRANSACCION SATISFACTORIA", "NO CUMPLE CON LA PROMOCION");

----------------------------------------------------------------
-- TBonificacion
select "----";
set @saldo := (select saldo from cuentas where cta_id = 'ACC2');
set @condition := (@saldo > 44);

start transaction;

set @action := IF(@condition, 
	"select (@saldo * 0.84) into @new_saldo;",
	"select (@saldo * 1.125) into @new_saldo;"
);

PREPARE statement FROM @action; -- PREPARING THE ACTION
EXECUTE statement;
DEALLOCATE PREPARE statement;

update cuentas set saldo = @new_saldo
	where cta_id = 'ACC2';

COMMIT;
select IF(@condition, "16% RESTADO", "1.25% BONIFICADO");



----------------------------------------------------------------
-- TConteo
select "----";
set @saldo := (select saldo from cuentas where cta_id = 'ACC3');
set @condition := (@saldo < 50);

start transaction;
delete from cuentas where cta_id = 'ACC4';
insert into cuentas values('ACC4',100);
update cuentas set saldo = saldo * 0.91 
	where cta_id = 'ACC3';

select IF(@condition, "COMMIT;", "ROLLBACK;") into @action;

PREPARE statement FROM @action; -- PREPARING THE ACTION
EXECUTE statement;
DEALLOCATE PREPARE statement;
select IF(@condition, "TConteo EXECUTED", "TConteo NOT EXECUTED");

----------------------------------------------------------------
-- TEliminar
select "----";
set @cta_id := (select cta_id from cuentas order by saldo desc limit 1); --MAX BALANCE
select @cta_id;

start transaction;
delete from cuentas where cta_id = @cta_id;
select * from cuentas;
ROLLBACK;

-- ALL ACCOUNTS
select * from cuentas;