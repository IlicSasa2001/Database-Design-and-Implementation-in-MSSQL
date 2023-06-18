/*Funkcija koja za prosledjeni id i naziv radnog mesta vraca prosecnu platu radnika na tom radnom mestu,informaciju o tome koliko je prosecna plata  na tom radnom mestu
manja od maksimalne plate u kompaniji i ime i prezime radnika sa najvecom platom na tom radnom mestu. Parametri funkcije su opcioni,te se funkcija moze pozivati
na vise nacina,prosledjivanjem samo naziva radnog mesta,prosledjivanjem ID radnog mesta,ili prosledjivanjem i naziva i ID. */
if object_id ('Angazovanje.PrvaFunkcija','FN') is not null
	drop function Angazovanje.PrvaFunkcija;
go
create function Angazovanje.PrvaFunkcija
(
	@idRadnogMesta as int = null,
	@nazivRadnogMesta as varchar(30) = null
)
returns varchar(200)
as
begin
declare @rezultat as varchar(200);
declare @avgPlata as int;
declare @maxPlata as int;
declare @maxPlataRadnogMesta as int;
declare @ime as varchar(30);
declare @prezime as varchar(30);

set @maxPlata = (select max(z_plt) from Angazovanje.Zaposleni)


if(@idRadnogMesta is not null and @nazivRadnogMesta is not null)
begin
declare @provera as int = (select count(*) from Angazovanje.Radno_Mesto where naziv_radnog_mesta=@nazivRadnogMesta and id_radnog_mesta=@idRadnogMesta);
if(@provera=0)
begin
set @rezultat = 'Pogrešno zadati parametri funkcije! Ne postoji radno mesto sa takvom kombinacijom parametara!'
end
else
begin
set @avgPlata = (select avg(z_plt) from Angazovanje.Zaposleni zap inner join Angazovanje.Angazovanje ang on (ang.id_zaposlenog=zap.id_zaposlenog) 
where id_radnog_mesta = @idRadnogMesta and id_radnog_mesta in (select id_radnog_mesta from Angazovanje.Radno_Mesto where naziv_radnog_mesta=@nazivRadnogMesta));
set @maxPlataRadnogMesta = (select top 1 max(z_plt) from Angazovanje.Zaposleni zap inner join Angazovanje.Angazovanje ang on (ang.id_zaposlenog=zap.id_zaposlenog) 
where id_radnog_mesta = @idRadnogMesta and id_radnog_mesta in (select id_radnog_mesta from Angazovanje.Radno_Mesto where naziv_radnog_mesta=@nazivRadnogMesta));
set @ime = (select top 1 z_ime from Angazovanje.Zaposleni zap inner join Angazovanje.Angazovanje ang on (ang.id_zaposlenog=zap.id_zaposlenog) 
where id_radnog_mesta = @idRadnogMesta and id_radnog_mesta in (select id_radnog_mesta from Angazovanje.Radno_Mesto where naziv_radnog_mesta=@nazivRadnogMesta) and
z_plt=@maxPlataRadnogMesta order by z_ime);
set @prezime = (select top 1 z_prezime from Angazovanje.Zaposleni zap inner join Angazovanje.Angazovanje ang on (ang.id_zaposlenog=zap.id_zaposlenog) 
where id_radnog_mesta = @idRadnogMesta and id_radnog_mesta in (select id_radnog_mesta from Angazovanje.Radno_Mesto where naziv_radnog_mesta=@nazivRadnogMesta) and
z_plt=@maxPlataRadnogMesta);
set @rezultat = 'Prosecna plata na radnom mestu ' + @nazivRadnogMesta+ ' sa ID ' + cast(@idRadnogMesta as varchar) + ' je ' + cast(@avgPlata as varchar) + 
' što je za ' + cast(@maxPlata-@avgPlata as varchar) +' manje od najvece plate u kompaniji.Radnik na tom radnom mestu sa najvecom platom  od ' + cast(@maxPlataRadnogMesta as varchar) + ' je ' + @ime + ' '+ @prezime
end
end

else if(@idRadnogMesta is not null and @nazivRadnogMesta is null)
begin
declare @proveraID as int = (select count(*) from Angazovanje.Radno_Mesto where id_radnog_mesta=@idRadnogMesta);
if(@proveraID=0)
begin
set @rezultat = 'Pogrešno zadati parametri funkcije! Ne postoji radno mesto sa takvim ID!'
end
else
begin
set @avgPlata = (select avg(z_plt) from Angazovanje.Zaposleni zap inner join Angazovanje.Angazovanje ang on (ang.id_zaposlenog=zap.id_zaposlenog) 
where id_radnog_mesta = @idRadnogMesta)
set @maxPlataRadnogMesta = (select top 1 max(z_plt) from Angazovanje.Zaposleni zap inner join Angazovanje.Angazovanje ang on (ang.id_zaposlenog=zap.id_zaposlenog) 
where id_radnog_mesta = @idRadnogMesta)
set @ime = (select top 1 z_ime from Angazovanje.Zaposleni zap inner join Angazovanje.Angazovanje ang on (ang.id_zaposlenog=zap.id_zaposlenog) 
where id_radnog_mesta = @idRadnogMesta  and z_plt=@maxPlataRadnogMesta)
set @prezime = (select top 1 z_prezime from Angazovanje.Zaposleni zap inner join Angazovanje.Angazovanje ang on (ang.id_zaposlenog=zap.id_zaposlenog) 
where id_radnog_mesta = @idRadnogMesta  and z_plt=@maxPlataRadnogMesta)
set @rezultat = 'Prosecna plata na radnom mestu sa ID ' + cast(@idRadnogMesta as varchar) + ' je ' + cast(@avgPlata as varchar) + 
' što je za ' + cast(@maxPlata-@avgPlata as varchar) +' manje od najvece plate u kompaniji.Radnik na tom radnom mestu sa najvecom platom  od ' + cast(@maxPlataRadnogMesta as varchar) + ' je ' + @ime + ' '+ @prezime
end
end

else if(@idRadnogMesta is null and @nazivRadnogMesta is not null)
begin
declare @proveraNaziva as int = (select count(*) from Angazovanje.Radno_Mesto where naziv_radnog_mesta=@nazivRadnogMesta);
if(@proveraNaziva=0)
begin
set @rezultat = 'Pogrešno zadati parametri funkcije! Ne postoji radno mesto sa takvim nazivom!'
end
else
begin
set @avgPlata = (select avg(z_plt) from Angazovanje.Zaposleni zap inner join Angazovanje.Angazovanje ang on (ang.id_zaposlenog=zap.id_zaposlenog) 
where id_radnog_mesta = (select id_radnog_mesta from Angazovanje.Radno_Mesto where naziv_radnog_mesta=@nazivRadnogMesta))
set @maxPlataRadnogMesta = (select top 1 max(z_plt) from Angazovanje.Zaposleni zap inner join Angazovanje.Angazovanje ang on (ang.id_zaposlenog=zap.id_zaposlenog) 
inner join Angazovanje.Radno_Mesto rm on rm.id_radnog_mesta=ang.id_radnog_mesta where naziv_radnog_mesta=@nazivRadnogMesta)
set @ime = (select top 1 z_ime from Angazovanje.Zaposleni zap inner join Angazovanje.Angazovanje ang on (ang.id_zaposlenog=zap.id_zaposlenog) 
inner join Angazovanje.Radno_Mesto rm on rm.id_radnog_mesta=ang.id_radnog_mesta where naziv_radnog_mesta=@nazivRadnogMesta and z_plt=@maxPlataRadnogMesta)
set @prezime = (select top 1 z_prezime from Angazovanje.Zaposleni zap inner join Angazovanje.Angazovanje ang on (ang.id_zaposlenog=zap.id_zaposlenog) 
inner join Angazovanje.Radno_Mesto rm on rm.id_radnog_mesta=ang.id_radnog_mesta where naziv_radnog_mesta=@nazivRadnogMesta and z_plt=@maxPlataRadnogMesta)
set @rezultat = 'Prosecna plata na radnom mestu  ' + @nazivRadnogMesta + ' je ' + cast(@avgPlata as varchar) + 
' što je za ' + cast(@maxPlata-@avgPlata as varchar) +' manje od najvece plate u kompaniji.Radnik na tom radnom mestu sa najvecom platom  od ' + cast(@maxPlataRadnogMesta as varchar) + ' je ' + @ime + ' '+ @prezime
end
end
return @rezultat;
end

print Angazovanje.PrvaFunkcija(5,'HR menadzer')
print Angazovanje.PrvaFunkcija(5,null)
print Angazovanje.PrvaFunkcija(null,'HR menadzer')
print Angazovanje.PrvaFunkcija(5,'Ovakvo radno mesto ne postoji')

select * from Angazovanje.Konkurs

if object_id ('Angazovanje.DrugaFunkcija','TF') is not null
	drop function Angazovanje.DrugaFunkcija;
go
create function Angazovanje.DrugaFunkcija
(
    @godina int
)
returns @novaTabela table 
(
	id_konkursa int,
	ime varchar(30),
	prezime varchar(30),
	radnoMesto varchar(30),
	datum_pocetka_konkursa varchar(30),
	datum_zaposljavanja varchar(30),
	plata int,
	prosecna varchar(30)
)
as
begin
	declare @avgPlata as int;
	set @avgPlata = (select avg(z_plt) from Angazovanje.Zaposleni zap inner join Angazovanje.Angazovanje ang on (zap.id_zaposlenog=ang.id_zaposlenog)
	where datepart(year,dat_ang_od)=@godina );

    insert @novaTabela
    select k.id_konkursa,z_ime,z_prezime,naziv_radnog_mesta, concat(datename(dw,datum_raspis_konkursa),' , ',convert(varchar,datum_raspis_konkursa,104)), 
	concat(datename(dw,dat_ang_od),' , ',convert(varchar,dat_ang_od,104)),isnull(z_plt,0),
	case when z_plt>@avgPlata then 'Plata je veca od prosecne' when z_plt=@avgPlata then 'Plata je jednaka prosecnoj' 
	when z_plt<@avgPlata then 'Plata je manja od prosecne' else 'Nepoznato' end
	from Angazovanje.konkurs k inner join Angazovanje.Angazovanje ang on (ang.id_konkursa=k.id_konkursa) 
	inner join Angazovanje.Zaposleni zap on (zap.id_zaposlenog=ang.id_zaposlenog)
	inner join Angazovanje.Radno_Mesto rm on (rm.id_radnog_mesta=ang.id_radnog_mesta)
	where datepart(year,datum_raspis_konkursa)=@godina
    return 
end

select *  from Angazovanje.DrugaFunkcija(2021)

