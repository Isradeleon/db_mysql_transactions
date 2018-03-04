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

-- Ta
set @saldo := (select saldo from cuentas where cta_id = 'ACC1');
select @saldo; -- 50

start transaction;
select (@saldo - 30) into @new_saldo; -- 20

update cuentas set saldo = @new_saldo
	where cta_id = 'ACC1';

set @condition := (@saldo>=30);
select IF(@condition, "COMMIT;", "ROLLBACK;") into @action; -- ACTION TO DO CONDITIONALLY

PREPARE statement FROM @action; -- PREPARING THE ACTION
EXECUTE statement;
DEALLOCATE PREPARE statement;

select IF(@condition, "TA EXECUTED", "TA NOT EXECUTED");

select '-----';
-- Tb
set @accounts := (select count(*) from cuentas);
select @accounts; -- CUENTAS

set @new_account := (select CONCAT('ACC', (@accounts+1))); -- NUEVA CUENTA
set @new_balance := (select (FLOOR(RAND()*100))); -- NUEVO SALDO

start transaction;
insert into cuentas values (@new_account,@new_balance);

set @condition := (@accounts > 2);
select IF(@condition, "COMMIT;", "ROLLBACK;") into @action; -- ACTION TO DO CONDITIONALLY

PREPARE statement FROM @action; -- PREPARING THE ACTION
EXECUTE statement;
DEALLOCATE PREPARE statement;

select IF(@condition, "TB EXECUTED", "TB NOT EXECUTED. NOT ENOUGH ACCOUNTS");

select '-----';
-- Tc
set @saldo := (select saldo from cuentas where cta_id = 'ACC2');
select @saldo; -- 45

start transaction;
select (@saldo - 10) into @new_saldo; -- 35

update cuentas set saldo = @new_saldo
	where cta_id = 'ACC2';

set @condition := (@saldo>=40);
select IF(@condition, "COMMIT;", "ROLLBACK;") into @action; -- ACTION TO DO CONDITIONALLY

PREPARE statement FROM @action; -- PREPARING THE ACTION
EXECUTE statement;
DEALLOCATE PREPARE statement;

select IF(@condition, "TC EXECUTED", "TC NOT EXECUTED. NOT ENOUGH MONEY");

select '-----';
-- Td
set @saldo := (select saldo from cuentas where cta_id = 'ACC3');
select @saldo; -- 40

start transaction;
select (@saldo - 15) into @new_saldo; -- 25

update cuentas set saldo = @new_saldo
	where cta_id = 'ACC3';

set @condition := (@saldo>=40);
select IF(@condition, "COMMIT;", "ROLLBACK;") into @action; -- ACTION TO DO CONDITIONALLY

PREPARE statement FROM @action; -- PREPARING THE ACTION
EXECUTE statement;
DEALLOCATE PREPARE statement;

select IF(@condition, "TD EXECUTED", "TD NOT EXECUTED. NOT ENOUGH MONEY");

select '-----';
-- Tajustes
set @saldo1 := (select saldo from cuentas where cta_id = 'ACC1');
select @saldo1;
set @saldo2 := (select saldo from cuentas where cta_id = 'ACC2');
select @saldo2;

set @condition := ( (@saldo1 between 40 and 70) and (@saldo2 between 40 and 70)  );
select @condition;
start transaction;

delete from cuentas where cta_id = 'ACC3';
select IF(@condition, "COMMIT;", "ROLLBACK;") into @action; -- ACTION TO DO CONDITIONALLY

PREPARE statement FROM @action; -- PREPARING THE ACTION
EXECUTE statement;
DEALLOCATE PREPARE statement;

select IF(@condition, "TAJUSTES EXECUTED", "TAJUSTES NOT EXECUTED");

-- ALL ACCOUNTS
select * from cuentas;
