/*Za svako radno mesto na kom su angažovani zaposleni,prikazati naziv radnog mesta,ime i prezime radnika sa najduzim angazovanjem od svih radnika na tom radnom mestu */

select naziv_radnog_mesta as 'Naziv radnog mesta',z_ime + ' ' + z_prezime as 'Ime i prezime zaposlenog',z_jmbg as 'Jmbg zaposlenog',
datediff(DAY,dat_ang_od,isnull(dat_ang_do,sysdatetime())) as 'Trajanje angažovanja', concat(datename(month,dat_ang_od),' ',datepart(year,dat_ang_od)) as 'Pocetak angazovanja',
iif(dat_ang_do is null,'Angazovanje je jos uvek aktivno',cast(dat_ang_do as varchar)) as 'Kraj angažovanja'
from Angazovanje.Radno_Mesto rm inner join Angazovanje.Angazovanje ang on (rm.id_radnog_mesta=ang.id_radnog_mesta)
inner join Angazovanje.Zaposleni zap on (ang.id_zaposlenog=zap.id_zaposlenog)
inner join (select rm.id_radnog_mesta,max(datediff(day,dat_ang_od,isnull(dat_ang_do,sysdatetime()))) as 'max'
from Angazovanje.Angazovanje ang inner join Angazovanje.Radno_Mesto rm on rm.id_radnog_mesta=ang.id_radnog_mesta
group by rm.id_radnog_mesta) pomocnaTabela on (rm.id_radnog_mesta=pomocnaTabela.id_radnog_mesta)
where datediff(DAY,dat_ang_od,isnull(dat_ang_do,sysdatetime())) = pomocnaTabela.max
order by datediff(DAY,dat_ang_od,isnull(dat_ang_do,sysdatetime())) desc

/*Prikazati ime,prezime i adresu zaposlenih u punom obliku(adresa,grad,drzava) zaposlenih koji su iz Novog Sada ili Beograda,njihovu platu,kao i datum angazovanja u formatu dd.MM.yyyy
Prikazati samo zaposlene èiji je status angažovanja aktivan i koji imaju veæu platu od proseène plate radnika*/
select concat(z_ime,' ',z_prezime) as 'Ime i prezime zaposlenog',z_adresa + ','+z_grad + ',' + z_drzava as 'Adresa zaposlenog',z_plt as 'Plata zaposlenog',
naziv_radnog_mesta as 'Naziv radnog mesta',try_convert(varchar, dat_ang_od, 104) as 'Datum angažovanja'
from Angazovanje.Zaposleni zap left join Angazovanje.Angazovanje ang on (zap.id_zaposlenog=ang.id_zaposlenog)
left join Angazovanje.Radno_Mesto rm on (ang.id_radnog_mesta=rm.id_radnog_mesta)
where z_grad in ('Beograd','Novi Sad') and ang.id_statusa_ang = (select id_statusa_ang from Angazovanje.Status_Angazovanja where naziv_statusa_ang='Aktivno angažovanje')
and z_plt > (select avg(z_plt) from Angazovanje.Zaposleni) and dat_ang_do is null
order by z_plt desc,dat_ang_od asc

/*Izlistati ime i prezime HR asistenta,broj konkursa koje je on organizovao,i broj zaposlenih na osnovu tih konkursa koje je taj HR asistent organizovao.
U obzir uzeti samo konkurse organizovane 2021 i 2022 godine koji su raspisani za pozicije programera i developera. U slucaju da hr asistent nije organizovao konkurs
ispisati poruku "Hr asistent nije organizovao nijedan konkurs". Prikazati samo one asistente koji su organizovali manje od 5 konkursa,i na osnovu kojih je zaposlen bar jedan radnik */
select  hr.id_hr_asistenta as ID, z_ime as Ime,z_prezime as Prezime,iif(count(distinct k.id_konkursa)=0,'Hr asistent nije organizovao nijedan konkurs',cast(count( distinct k.id_konkursa) as varchar)) as 'Broj organizovanih konkursa', 
count(ang.id_konkursa) as 'Broj zaposlenih na osnovu konkursa'
from Angazovanje.Zaposleni zap inner join Angazovanje.HR_Asistent hr on (zap.id_zaposlenog=hr.id_hr_asistenta) 
left join Angazovanje.Konkurs k on (k.id_hr_asistenta=hr.id_hr_asistenta) left join Angazovanje.Angazovanje ang on (ang.id_konkursa=k.id_konkursa) 
inner join Angazovanje.Radno_Mesto rm on (rm.id_radnog_mesta=k.id_radnog_mesta)
where datepart(year,k.datum_raspis_konkursa) in (2021,2022) and naziv_radnog_mesta like '%developer%'  or naziv_radnog_mesta like '%menadzer%'
group by  hr.id_hr_asistenta,z_ime,z_prezime
having count(k.id_hr_asistenta) <= 5 and count(ang.id_konkursa) > 0
order by count(ang.id_konkursa) desc

/*Za svaki projekat prikazazi id projekta,naziv projekta i narucioca. Takodje prikazati ime,prezime i godine zaposlenog sa najmanje godina od svih zaposlenih koji rade na tom projektu.
Prikazati i broj casova i u dodatnoj koloni broj dana izveden na osnovu broja casova (jedan dan sadrzi 8 radnih casova). Takodje,prikazati broj telefona zaposlenog u formatu +3816xx.
U obzir uzeti samo radnike koje rade na projektima ciji su narucioci FTN,NIS,NS i kojima je status angažovanja aktivan.Sortirati po godinama zaposlenog opadajuce*/
select proj.id_projekta as 'Id projekta',naziv_proj as 'Naziv projekta',narucilac as Narucilac,z_ime as 'Ime zaposlenog',z_prezime as 'Prezime zaposlenog',
iif(broj_casova is not null,cast(broj_casova as varchar),'Radnik nije radio na projektu') as 'Broj casova',
isnull(cast((broj_casova/8) as int),0) as 'Broj dana',DATEDIFF(year,z_dat_rodj,SYSDATETIME()) as 'Broj godina',
iif(ltrim(z_broj_tel)='+381',z_broj_tel,concat('+381',substring(z_broj_tel,2,len(z_broj_tel)))) as 'Broj telefona'
from Angazovanje.Projekat proj inner join Angazovanje.Radi r on(proj.id_projekta=r.id_projekta)
inner join Angazovanje.Radnik rad on (r.id_radnik=rad.id_radnik) inner join Angazovanje.Zaposleni zap on (zap.id_zaposlenog=rad.id_radnik)
inner join (select proj.id_projekta,min(DATEDIFF(day,z_dat_rodj,SYSDATETIME())) 'Min godina' from Angazovanje.Projekat proj 
inner join Angazovanje.Radi r on(proj.id_projekta=r.id_projekta) inner join Angazovanje.Radnik rad on (r.id_radnik=rad.id_radnik)
inner join Angazovanje.Zaposleni zap on (zap.id_zaposlenog=rad.id_radnik) group by proj.id_projekta) pomocnaTabela on (pomocnaTabela.id_projekta=proj.id_projekta)
where DATEDIFF(day,z_dat_rodj,SYSDATETIME())=pomocnaTabela.[Min godina] and r.id_projekta in (select id_projekta from Angazovanje.Projekat where narucilac in ('NS','NIS','FTN')) 
and id_zaposlenog in (select id_zaposlenog from Angazovanje.Angazovanje where id_statusa_ang in (select id_statusa_ang from Angazovanje.Status_Angazovanja))
order by DATEDIFF(year,z_dat_rodj,SYSDATETIME()) desc

/*Izlistati ime,prezime zaposlenog, njegovu ukupnu zaradu ostvarenu tokom angazovanja u kompaniji i pol zaposlenog u formatu muški/ženski.
Takodje prikazati prosecno angazovanje svakog zaposlenog na projektima,a u sluèaju da radnik nije bio angazovan na projektima ispisati poruku 'Zaposleni nije ucestvovao na projektima'.
Prikazati samo one zaposlene cija je plata veæa od plate radnika cije ime pocinje na Ma.Pored toga prikazati radno mesto i osnov zaposlenja zaposlenog.
Sortirati po ukupnoj zaradi opadajuce,a po imeni i prezimenu rastuce */

select z_ime as Ime,z_prezime as Prezime,case when z_pol= 'm' then 'Muški' when z_pol='z' then 'Ženski' end as 'Pol zaposlenog',
z_plt * datediff(month,dat_ang_od,isnull(dat_ang_do,sysdatetime())) as 'Ukupna zarada zaposlenog',
iif(avg(broj_casova) is not null,cast(cast(avg(broj_casova) as decimal(4,2)) as varchar),'Zaposleni nije ucestvovao na projektima') as 'Prosecno angazovanje na projektima',
osnov_zaposlenja as 'Osnov zaposlenja'
from Angazovanje.Zaposleni zap left join Angazovanje.Angazovanje ang on (zap.id_zaposlenog=ang.id_zaposlenog)
left join Angazovanje.Radnik r on (r.id_radnik=zap.id_zaposlenog) left join Angazovanje.Radi rad on (rad.id_radnik=r.id_radnik) 
inner join Angazovanje.Osnov os on (os.id_osnova =ang.id_osnova)
where z_plt > all (select z_plt from Angazovanje.Zaposleni where z_ime like 'Ma%')
group by z_ime,z_prezime,z_plt * datediff(month,dat_ang_od,isnull(dat_ang_do,sysdatetime())),osnov_zaposlenja,z_pol
order by z_plt * datediff(month,dat_ang_od,isnull(dat_ang_do,sysdatetime())) desc,z_ime + z_prezime asc



