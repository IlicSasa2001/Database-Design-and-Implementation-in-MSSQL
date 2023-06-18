if object_id ('Angazovanje.PrviTrigger') is not null
	drop trigger Angazovanje.PrviTrigger;
go
create trigger Angazovanje.PrviTrigger
on Angazovanje.Angazovanje
instead of update,insert
as
begin
declare @stariDatum as date;
declare @noviDatum as date;
declare @stariOsnov as int;
declare @noviOsnov as int;
declare @id_konkursa as int;
declare @i as int = 0;
declare @count as int;
declare @datumRaspisivanjaKonkursa as date;
declare @osnovPoKonkursu as int;
declare @rbAngazovanja as int;
declare @id_zaposlenog as int;
declare @id_radnog_mesta as int;
declare @id_statusa_ang as int;
declare @id_vrsta_radod as int;
declare @datumAngDo as date;
declare @trajanjeAng as int;

set @osnovPoKonkursu = (select id_osnova from Angazovanje.Osnov where osnov_zaposlenja='Zaposlenje na osnovu konkursa');

declare cursor_Angazovanje_inserted cursor fast_forward read_only for
select id_konkursa,id_osnova,dat_ang_od,rb_angazovanja from inserted;

declare cursor_Angazovanje_deleted cursor fast_forward read_only for
select id_osnova,dat_ang_od from deleted;

open cursor_Angazovanje_inserted;
open cursor_Angazovanje_deleted;

fetch next from cursor_Angazovanje_inserted into @id_konkursa,@noviOsnov,@noviDatum,@rbAngazovanja;
fetch next from cursor_Angazovanje_deleted into @stariOsnov,@stariDatum;

set @count = (select count(*) from inserted)

while(@i<@count)
begin
set @id_radnog_mesta = (select id_radnog_mesta from inserted where rb_angazovanja=@rbAngazovanja);
set @id_zaposlenog= (select id_zaposlenog from inserted where rb_angazovanja=@rbAngazovanja);
set @id_statusa_ang = (select id_statusa_ang from inserted where rb_angazovanja=@rbAngazovanja);
set @id_vrsta_radod = (select id_vrsta_radod from inserted where rb_angazovanja=@rbAngazovanja);
set @datumAngDo = (select dat_ang_do from inserted where rb_angazovanja=@rbAngazovanja);
set @trajanjeAng = (select trajanje_ang from inserted where rb_angazovanja=@rbAngazovanja);
if(@id_konkursa is not null)
begin
set @datumRaspisivanjaKonkursa = (select datum_raspis_konkursa from Angazovanje.Konkurs where id_konkursa=@id_konkursa);
if(@stariDatum<>@noviDatum or @stariOsnov<>@noviOsnov or @stariDatum is null)
begin
if(@datumRaspisivanjaKonkursa>@noviDatum)
begin
raiserror('Datum angazovanja zaposlenog angazovanog na osnovu konkursa ne sme biti pre raspisivanja konkursa po kom je zaposlen',16,0);
end
else if(@noviOsnov!=@osnovPoKonkursu)
begin
raiserror('Osnov angazovanja zaposlenog angazovanog na osnovu konkursa mora biti konkurs!',16,0);
end
else
begin
if(@stariDatum<>@noviDatum or @stariOsnov<>@noviOsnov)
begin
update Angazovanje.Angazovanje
set rb_angazovanja=@rbAngazovanja,
id_zaposlenog=@id_zaposlenog,
id_radnog_mesta=@id_radnog_mesta,
id_statusa_ang=@id_statusa_ang,
id_vrsta_radod=@id_vrsta_radod,
id_osnova=@noviOsnov,
id_konkursa=@id_konkursa,
dat_ang_od=@noviDatum,
dat_ang_do=@datumAngDo,
trajanje_ang=@trajanjeAng
where rb_angazovanja=@rbAngazovanja
end
else if(@stariDatum is null)
begin
insert into Angazovanje.Angazovanje values (@rbAngazovanja,@id_zaposlenog,@id_radnog_mesta,@id_statusa_ang,@id_vrsta_radod,@noviOsnov,@id_konkursa,@noviDatum,@datumAngDo,@trajanjeAng);
end
end
end
end
fetch next from cursor_Angazovanje_inserted into @id_konkursa,@noviOsnov,@noviDatum,@rbAngazovanja;
fetch next from cursor_Angazovanje_deleted into @stariOsnov,@stariDatum;
set @i=@i+1;
end
close cursor_Angazovanje_inserted;
close cursor_Angazovanje_deleted;
deallocate cursor_Angazovanje_inserted;
deallocate cursor_Angazovanje_deleted;
end

select * from Angazovanje.Angazovanje

select iif('2018-01-09'>'2018-01-10','y','n')

alter table Angazovanje.Angazovanje
add constraint FK_Angazovanje_id_zaposlenog foreign key (id_zaposlenog) references Angazovanje.Zaposleni (id_zaposlenog)

drop table Angazovanje.Angazovanje
go
insert into Angazovanje.Angazovanje (id_zaposlenog,id_radnog_mesta,id_statusa_ang,id_vrsta_radod,id_osnova,id_konkursa,dat_ang_od,dat_ang_do,trajanje_ang)
values (15,6,3,3,1,3,'2021-02-09','2021-03-09',datediff(day,'2021-03-09','2021-03-09')),
(15,6,3,3,2,3,'2021-05-09','2021-09-09',datediff(day,'2021-03-09','2021-09-09'))

select * from Angazovanje.Konkurs

delete from Angazovanje.Angazovanje where rb_angazovanja =48
go
update Angazovanje.Angazovanje
set dat_ang_od = '2021-03-09',
id_statusa_ang = 2,id_vrsta_radod=3
where id_zaposlenog = 15

delete from Angazovanje.Angazovanje where rb_angazovanja=56


if object_id('Angazovanje.DrugiTrigger','TR') is not null
	drop trigger Angazovanje.DrugiTrigger;
go
create trigger Angazovanje.DrugiTrigger
on Angazovanje.Radi
instead of insert
as
begin
declare @brojProjekata as int;
declare @brojAktivnihProjekata as int;
declare @id_radnik as int;
declare @projekat as int;
declare @datumZavrsetka as date;
declare @brojCasova as int;

declare cursor_radi_inserted cursor fast_forward read_only for
select id_radnik,id_projekta,broj_casova from inserted;
open cursor_radi_inserted;
fetch next from cursor_radi_inserted into @id_radnik,@projekat,@brojCasova;
while(@@FETCH_STATUS=0)
begin
set @brojAktivnihProjekata=0;
set @datumZavrsetka = (select dat_zav_proj from Angazovanje.Projekat where id_projekta=@projekat);
set @brojProjekata = (select count(id_projekta) from Angazovanje.Radi where id_radnik=@id_radnik);
declare @id_projekta as int;
declare @i as int = 0;
declare cursor_radi_projekti cursor fast_forward read_only for
select id_projekta from Angazovanje.Radi where id_radnik=@id_radnik ;
open cursor_radi_projekti;
fetch next from cursor_radi_projekti into @id_projekta;
while(@i<@brojProjekata)
begin
declare @datum as date;
set @datum = (select dat_zav_proj from Angazovanje.Projekat where id_projekta=@id_projekta);
if(@datum is null)
begin
set @brojAktivnihProjekata = @brojAktivnihProjekata+1;
end
set @i = @i+1;
fetch next from cursor_radi_projekti into @id_projekta;
end
close cursor_radi_projekti;
deallocate cursor_radi_projekti;
if(@brojAktivnihProjekata>=3)
begin
raiserror('Radnik moze da radi na najvise 3 projekta istovremeno! Nije moguce dodati novo angazovanje!',16,0);
end
else if (@datumZavrsetka is not null)
begin
raiserror('Nije moguce dodati novo angazovanje za radnika na projektu koji je vec zavrsen!',16,0);
end
else
begin
insert into Angazovanje.Radi values (@id_radnik,@projekat,@brojCasova);
end
fetch next from cursor_radi_inserted into @id_radnik,@projekat,@brojCasova;
end
close cursor_radi_inserted;
deallocate cursor_radi_inserted;
end

select * from Angazovanje.Radi

select * from Angazovanje.Projekat

insert into Angazovanje.Projekat values (9,11,'Novo1',sysdatetime(),null,'FTN')
insert into Angazovanje.Projekat values (10,11,'Novo2',sysdatetime(),null,'FTN')
insert into Angazovanje.Projekat values (11,11,'Novo3',sysdatetime(),null,'FTN')

insert into Angazovanje.Radi(id_radnik,id_projekta,broj_casova) values (14,9,20),(14,10,20),(14,11,20)
delete from Angazovanje.radi where id_projekta in (9,10,11)

insert into Angazovanje.Radi(id_radnik,id_projekta,broj_casova) values (14,7,20)

insert into Angazovanje.Radi(id_radnik,id_projekta,broj_casova) values (14,9,20);
insert into Angazovanje.Radi(id_radnik,id_projekta,broj_casova) values(14,10,20);
insert into Angazovanje.Radi(id_radnik,id_projekta,broj_casova) values (14,11,20);

delete from Angazovanje.radi where id_projekta in (9,10,11)