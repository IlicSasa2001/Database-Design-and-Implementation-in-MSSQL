--Prva procedura
if object_id('Angazovanje.PrvaProcedura','P') is not null
	drop proc Angazovanje.PrvaProcedura;
go
create proc Angazovanje.PrvaProcedura
@status as varchar(30)
as
begin
declare @ime as varchar(30);
declare @prezime as varchar(30);
declare @ukupnoZaposlenih as int;
declare @plata as numeric(10,2);
declare @osnov as varchar(50);
declare @vrstaRadnogOdnosa as varchar(50);
declare @proveraStatusa as int;
declare @redniBroj as int;
declare @duzinaAngazovanja as int;
declare @datumAngazovanjaDo as date;

set @proveraStatusa = (select count(*) from Angazovanje.Status_Angazovanja where naziv_statusa_ang=@status)
if(@proveraStatusa=0)
begin
print 'Ne postoji status angažovanja ' + @status;
return;
end

set @ukupnoZaposlenih = (select count(id_zaposlenog) from Angazovanje.Angazovanje
where id_statusa_ang=(select id_statusa_ang from Angazovanje.Status_Angazovanja where naziv_statusa_ang=@status))
if(@ukupnoZaposlenih=0)
begin
print 'Ne postoje zaposleni sa datim statusom angažovanja - ' + @status;
end
else
begin
set @redniBroj=1;
print 'Status angažovanja ' + @status + ' imaju sledeæi zaposleni';

declare cursor_zaposleni cursor fast_forward read_only for
select z_ime,z_prezime,z_plt,naziv_vrste_radod,osnov_zaposlenja,datediff(month,dat_ang_od,isnull(dat_ang_do,sysdatetime())),dat_ang_do
from Angazovanje.Zaposleni zap inner join Angazovanje.Angazovanje ang on (ang.id_zaposlenog=zap.id_zaposlenog)
 inner join Angazovanje.Osnov o on (o.id_osnova=ang.id_osnova)
inner join Angazovanje.Vrsta_radnog_odnosa vrs on (vrs.id_vrsta_radod=ang.id_vrsta_radod)
where ang.id_statusa_ang=(select id_statusa_ang from Angazovanje.Status_Angazovanja where naziv_statusa_ang=@status)
order by dat_ang_od asc;

open cursor_zaposleni;

fetch next from cursor_zaposleni into @ime,@prezime,@plata,@vrstaRadnogOdnosa,@osnov,@duzinaAngazovanja,@datumAngazovanjaDo;
while(@@FETCH_STATUS=0)
begin
if(@datumAngazovanjaDo is null)
begin
print concat(@redniBroj,'. ',@ime,' ',@prezime,' sa platom ',isnull(cast(@plata as varchar),'koja nije poznata'),' i vrstom radnog odnosa ',@vrstaRadnogOdnosa,' je angazovan po osnovu ',@osnov,
'. Angazovanje traje  ',@duzinaAngazovanja,' meseci.');
end
else
begin
print concat(@redniBroj,'. ',@ime,' ',@prezime,' sa platom ',isnull(cast(@plata as varchar),'koja nije poznata'),' i vrstom radnog odnosa ',@vrstaRadnogOdnosa,' je bio angazovan po osnovu ',@osnov,
'. Angazovanje je trajalo ',@duzinaAngazovanja,' meseci.');
end
fetch next from cursor_zaposleni into @ime,@prezime,@plata,@vrstaRadnogOdnosa,@osnov,@duzinaAngazovanja,@datumAngazovanjaDo;
set @redniBroj=@redniBroj+1;
end
close cursor_zaposleni;
deallocate cursor_zaposleni;
print 'Ukupno zaposlenih sa statusom angažovanja ' + @status +': ' + cast(@ukupnoZaposlenih as varchar);
end
end

select * from Angazovanje.Status_Angazovanja

exec Angazovanje.PrvaProcedura 'Aktivno angažovanje'
exec Angazovanje.PrvaProcedura 'Prekinuto angažovanje'
exec Angazovanje.PrvaProcedura 'Ovakvo angažovanje ne postoji'

select * from Angazovanje.Angazovanje


if object_id('Angazovanje.DrugaProcedura','P') is not null
	drop proc Angazovanje.DrugaProcedura;
go 
create proc Angazovanje.DrugaProcedura
@id_zaposlenog as int
as
begin
declare @ime as varchar(30);
declare @prezime as varchar(30);
declare @adresa as varchar(100);
declare @kontakt as varchar(20);
declare @radnoMesto as varchar(30);
declare @proveraZaposlenog as int;
declare @plata as numeric(10,2);
declare @brojEvaluacionihTestova as int;
declare @brojProjekata as int;
declare @brojKonkursa as int;
declare @rezultatZaIspis as varchar(100);

set @proveraZaposlenog= (select count(*) from Angazovanje.Zaposleni where id_zaposlenog=@id_zaposlenog);
if(@proveraZaposlenog=0)
begin
print 'Ne postoje informacije o zaposlenom za prosledjeni ID ' + cast(@id_zaposlenog as varchar);
return;
end
else
begin
set @ime = (select z_ime from Angazovanje.Zaposleni where id_zaposlenog=@id_zaposlenog);
set @prezime = (select z_prezime from Angazovanje.Zaposleni where id_zaposlenog=@id_zaposlenog);
set @adresa = (select iif(z_adresa is null,'',z_adresa +',') + iif(z_grad is null,'',z_grad + ',') + iif(z_drzava is null,'',z_drzava)  from Angazovanje.Zaposleni where id_zaposlenog=@id_zaposlenog);
set @kontakt = (select z_broj_tel from Angazovanje.Zaposleni where id_zaposlenog=@id_zaposlenog);
set @radnoMesto = (select naziv_radnog_mesta from Angazovanje.Zaposleni zap inner join Angazovanje.Angazovanje ang on (ang.id_zaposlenog=zap.id_zaposlenog) 
inner join Angazovanje.Radno_Mesto rm on (rm.id_radnog_mesta=ang.id_radnog_mesta) where zap.id_zaposlenog=@id_zaposlenog);
set @plata = (select z_plt from Angazovanje.Zaposleni where id_zaposlenog=@id_zaposlenog);

if(@radnoMesto = 'HR menadzer')
begin
set @brojEvaluacionihTestova = (select count(*) from Angazovanje.Realizuje r left join Angazovanje.HR_Menadzer hr on (hr.id_hr_menadzer=r.id_hr_menadzer)
left join Angazovanje.Zaposleni zap on (hr.id_hr_menadzer=zap.id_zaposlenog) where id_zaposlenog=@id_zaposlenog);
if(@brojEvaluacionihTestova=0)
begin
set @rezultatZaIspis = 'ovaj zaposleni nije realizovao nijedan evaluacioni test';
end
else
begin
set @rezultatZaIspis = 'Broj evaluacionih testova koji je realizovao ovaj zaposleni je ' + cast(@brojEvaluacionihTestova as varchar);
end
end
else if(@radnoMesto = 'HR asistent')
begin
set @brojKonkursa = (select count(*) from Angazovanje.Konkurs where id_hr_asistenta=@id_zaposlenog);
if(@brojKonkursa=0)
begin
set @rezultatZaIspis = 'Radeci na mestu HR asistenta ovaj zaposleni nije bio zadužen ni za jedan konkurs';
end
else
begin
set @rezultatZaIspis = 'Broj konkursa za koje je bio odgovoran ovaj zaposleni je ' + cast(@brojKonkursa as varchar);
end
end
else if(@radnoMesto='Projektni menadzer')
begin
set @brojProjekata = (select count(*) from Angazovanje.Projekat where id_proj_menadzer=@id_zaposlenog);
if(@brojProjekata=0)
begin
set @rezultatZaIspis = 'Radeci na mestu projektnog menadzera ovaj zaposleni nije bio projektni menadzer ni na jednom projektu';
end
else
begin
set @rezultatZaIspis = 'Broj projekata na kom je ovaj zaposleni bio projektni menadzer je ' + cast(@brojProjekata as varchar);
end
end
else
begin
set @brojProjekata = (select count(*) from Angazovanje.Radi where id_radnik=@id_zaposlenog);
if(@brojProjekata=0)
begin
set @rezultatZaIspis = 'Radeci na mestu ' + @radnoMesto + ' ovaj zaposleni nije radio ni na jednom projektu';
end
else
begin
set @rezultatZaIspis = 'Broj projekata na kom je ovaj zaposleni radio je ' + cast(@brojProjekata as varchar);
end
end
end
print 'Informacije o zaposlenom sa ID-jem ' + cast(@id_zaposlenog as varchar);
print concat('Ime i prezime: ',@ime,' ',@prezime);
print concat('Adresa i kontakt: ',@adresa,', ',@kontakt);
print concat('Plata: ',isnull(cast(@plata as varchar),'nije poznata'));
print concat('Zaposlen je na radnom mestu ',@radnoMesto);
print @rezultatZaIspis;
end

select * from Angazovanje.Projekat

exec Angazovanje.DrugaProcedura 8