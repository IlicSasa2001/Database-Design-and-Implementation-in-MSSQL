if object_id ('Angazovanje.Angazovanje','U') is not null
	drop table Angazovanje.Angazovanje;
go
if object_id('Angazovanje.SEQ_rbr_angazovanja','SO') is not null
	drop sequence Angazovanje.SEQ_rbr_angazovanja;
go
if object_id ('Angazovanje.Konkurs','U') is not null
	drop table Angazovanje.Konkurs;
go
if object_id('Angazovanje.SEQ_id_konkursa','SO') is not null
	drop sequence Angazovanje.SEQ_id_konkursa;
go
if object_id ('Angazovanje.Osnov','U') is not null
	drop table Angazovanje.Osnov;
go
if object_id('Angazovanje.SEQ_id_osnov','SO') is not null
	drop sequence Angazovanje.SEQ_id_osnov;
go
if object_id ('Angazovanje.Vrsta_radnog_odnosa','U') is not null
	drop table Angazovanje.Vrsta_radnog_odnosa;
go
if object_id('Angazovanje.SEQ_id_vrsta_radod','SO') is not null
	drop sequence Angazovanje.SEQ_id_vrsta_radod;
go
if object_id ('Angazovanje.Status_Angazovanja','U') is not null
	drop table Angazovanje.Status_Angazovanja;
go
if object_id('Angazovanje.SEQ_id_statusa_ang','SO') is not null
	drop sequence Angazovanje.SEQ_id_statusa_ang;
go
if object_id ('Angazovanje.Radno_Mesto','U') is not null
	drop table Angazovanje.Radno_Mesto;
go
if object_id('Angazovanje.SEQ_id_radnog_mesta','SO') is not null
	drop sequence Angazovanje.SEQ_id_radnog_mesta;
go
if object_id ('Angazovanje.Realizuje','U') is not null
	drop table Angazovanje.Realizuje;
go
if object_id ('Angazovanje.Evaluacioni_test','U') is not null
	drop table Angazovanje.Evaluacioni_test;
go
if object_id('Angazovanje.SEQ_id_ev_testa','SO') is not null
	drop sequence Angazovanje.SEQ_id_ev_testa;
go
if object_id ('Angazovanje.Radi','U') is not null
	drop table Angazovanje.Radi;
go
if object_id ('Angazovanje.Projekat','U') is not null
	drop table Angazovanje.Projekat;
go
if object_id('Angazovanje.SEQ_id_projekta','SO') is not null
	drop sequence Angazovanje.SEQ_id_projekta;
go
if object_id ('Angazovanje.Radnik','U') is not null
	drop table Angazovanje.Radnik;
go
if object_id ('Angazovanje.HR_Menadzer','U') is not null
	drop table Angazovanje.HR_Menadzer;
go
if object_id ('Angazovanje.Projektni_Menadzer','U') is not null
	drop table Angazovanje.Projektni_Menadzer;
go
if object_id ('Angazovanje.HR_Asistent','U') is not null
	drop table Angazovanje.HR_Asistent;
go
if object_id ('Angazovanje.Zaposleni','U') is not null
	drop table Angazovanje.Zaposleni;
go
if object_id('Angazovanje.SEQ_id_zaposlenog','SO') is not null
	drop sequence Angazovanje.SEQ_id_zaposlenog;
go
if schema_id ('Angazovanje') is not null
	drop schema Angazovanje;
go
create schema Angazovanje;
go
create sequence Angazovanje.SEQ_id_zaposlenog as int
start with 1
increment by 1
no cycle
go
go
create sequence Angazovanje.SEQ_id_projekta as int
start with 1
increment by 1
no cycle
go
go
create sequence Angazovanje.SEQ_id_ev_testa as smallint
start with 1
increment by 1
no cycle
go
create sequence Angazovanje.SEQ_rbr_angazovanja as int
start with 1
increment by 1
no cycle
go
create sequence Angazovanje.SEQ_id_radnog_mesta as int
start with 1
increment by 1
no cycle
go
create sequence Angazovanje.SEQ_id_statusa_ang as tinyint
start with 1
increment by 1
no cycle
go
create sequence Angazovanje.SEQ_id_osnov as tinyint
start with 1
increment by 1
no cycle
go
create sequence Angazovanje.SEQ_id_vrsta_radod as tinyint
start with 1
increment by 1
no cycle
go
create sequence Angazovanje.SEQ_id_konkursa as int
start with 1
increment by 1
no cycle
go
create table Angazovanje.Zaposleni (
id_zaposlenog int not null constraint DFT_Zaposleni_id_zaposlenog default(next value for Angazovanje.SEQ_id_zaposlenog),
z_jmbg varchar(13) not null,
z_ime varchar(20) not null,
z_prezime varchar(20) not null,
z_pol char(1) not null,
z_dat_rodj date not null,
z_adresa varchar (50),
z_grad varchar(20),
z_broj_tel varchar(15),
z_drzava varchar(20),
z_datum_zap date not null constraint DFT_Zaposleni_datum_zap default (sysdatetime()),
z_plt numeric(8),

constraint PK_Zaposleni primary key(id_zaposlenog),
constraint CHK_Zaposleni_jmbg check (len(z_jmbg)=13),
constraint UQ_Zaposleni_jmbg unique (z_jmbg),
constraint CHK_Zaposleni_pol check (z_pol in ('m','z')),
constraint CHK_Zaposleni_adresa check (((z_adresa is not null) and z_grad is not null and z_drzava is not null) or
((z_adresa is null) and (z_grad is not null or z_grad is null) and (z_drzava is not null or z_drzava is null))),
constraint CHK_Zaposleni_plt check ((z_plt is not null and len(z_plt) between 5 and 8) or z_plt is null ),
constraint CHK_jmbg_dat_rodj check (z_jmbg like (concat(iif(datepart(day,z_dat_rodj)<10,concat('0',datepart(day,z_dat_rodj)),cast(datepart(day,z_dat_rodj) as varchar)),
iif(datepart(month,z_dat_rodj)<10,concat('0',datepart(month,z_dat_rodj)),cast(datepart(month,z_dat_rodj) as varchar)),
cast(right(datepart(year,z_dat_rodj),3) as varchar),'%')))
);
go
create table Angazovanje.HR_Asistent (
id_hr_asistenta int not null,

constraint PK_HR_Asistent primary key (id_hr_asistenta),
constraint FK_HR_Asistent_id_zaposlenog foreign key (id_hr_asistenta) references Angazovanje.Zaposleni (id_zaposlenog)
)
go
create table Angazovanje.Projektni_Menadzer (
id_proj_menadzer int not null,

constraint PK_Projektni_Menadzer primary key (id_proj_menadzer),
constraint FK_Projektni_Menadzer_id_zaposlenog foreign key (id_proj_menadzer) references Angazovanje.Zaposleni (id_zaposlenog)
);
go
create table Angazovanje.HR_Menadzer (
id_hr_menadzer int not null,

constraint PK_HR_Menadzer primary key (id_hr_menadzer),
constraint FK_HR_Menadzer_id_zaposlenog foreign key (id_hr_menadzer) references Angazovanje.Zaposleni (id_zaposlenog)
);
go
create table Angazovanje.Radnik (
id_radnik int not null,

constraint PK_Radnik primary key (id_radnik),
constraint FK_Radnik_id_zaposlenog foreign key (id_radnik) references Angazovanje.Zaposleni (id_zaposlenog)
);
go
create table Angazovanje.Projekat (
id_projekta int not null constraint DFT_Projekat_id_projekta default (next value for Angazovanje.SEQ_id_projekta),
id_proj_menadzer int,
naziv_proj varchar(80) not null,
dat_poc_proj date not null constraint DFT_Projekat_dat_poc_proj default (sysdatetime()),
dat_zav_proj date,
narucilac varchar(30),

constraint PK_Projekat primary key (id_projekta),
constraint FK_Projekat_id_proj_menadzer foreign key (id_proj_menadzer) references Angazovanje.Projektni_Menadzer (id_proj_menadzer) on delete set null,
constraint CHK_dat_poc_projekta_dat_zav_proj check (dat_zav_proj >= dat_poc_proj)
);
go
create table Angazovanje.Radi (
id_radnik int not null,
id_projekta int not null,
broj_casova numeric(4,0)

constraint PK_Radi primary key (id_radnik,id_projekta),
constraint FK_Radi_id_radnik foreign key (id_radnik) references Angazovanje.Radnik (id_radnik) on delete cascade,
constraint FK_Radi_id_projekta foreign key (id_projekta) references Angazovanje.Projekat (id_projekta) on delete cascade,
constraint CHK_Radi_broj_casova check (broj_casova >0),
);
create table Angazovanje.Evaluacioni_test (
id_ev_testa smallint not null constraint DFT_Evaluacioni_test_id_ev_testa default (next value for Angazovanje.SEQ_id_ev_testa),
vrsta_ev_testa varchar(50) not null,
opis_ev_testa varchar(200),

constraint PK_Evaluacioni_test primary key (id_ev_testa)
);
go
create table Angazovanje.Realizuje (
id_ev_testa smallint not null,
id_hr_menadzer int not null,
datum date not null constraint DFT_Realizuje_datum default (sysdatetime()),

constraint PK_Realizuje primary key (id_ev_testa,id_hr_menadzer),
constraint FK_Realizuje_id_ev_testa foreign key (id_ev_testa) references Angazovanje.Evaluacioni_test (id_ev_testa) on delete cascade,
constraint FK_Realizuje_id_hr_menadzer foreign key (id_hr_menadzer) references Angazovanje.HR_Menadzer (id_hr_menadzer) on delete cascade,
);
go
create table Angazovanje.Radno_Mesto (
id_radnog_mesta int not null constraint DFT_Radno_mesto_id_radnog_mesta default (next value for Angazovanje.SEQ_id_radnog_mesta),
naziv_radnog_mesta varchar(30) not null,
cena_po_satu numeric(4),

constraint PK_Radno_mesto primary key (id_radnog_mesta),
constraint CHK_Radno_Mesto_cena_po_satu check (cena_po_satu>=0)
);
go
create table Angazovanje.Status_Angazovanja(
id_statusa_ang tinyint not null constraint DFT_Status_angazovanja_id_statusa_ang default(next value for Angazovanje.SEQ_id_statusa_ang),
naziv_statusa_ang varchar(30) not null,

constraint PK_Status_angazovanja primary key (id_statusa_ang),
);
go
create table Angazovanje.Vrsta_radnog_odnosa(
id_vrsta_radod tinyint not null constraint DFT_Vrsta_radnog_odnosa_id_vrsta_radod default(next value for Angazovanje.SEQ_id_vrsta_radod),
naziv_vrste_radod varchar(50) not null,

constraint PK_Vrsta_radnog_odnosa primary key (id_vrsta_radod)
);
go
create table Angazovanje.Osnov(
id_osnova tinyint not null constraint DFT_Osnov_id_osnov default(next value for Angazovanje.SEQ_id_osnov),
osnov_zaposlenja varchar(40) not null,

constraint PK_Osnov primary key (id_osnova)
);
go
create table Angazovanje.Konkurs (
id_konkursa int not null constraint DFT_Konkurs_id_konkursa default (next value for Angazovanje.SEQ_id_konkursa),
id_hr_asistenta int,
datum_raspis_konkursa date not null constraint DFT_Konkurs_datum_raspis_konkursa default (sysdatetime()),
datum_zavr_konkursa date,
mesto_objavljivanja_konkursa varchar(30),
id_radnog_mesta int,

constraint PK_Konkurs primary key (id_konkursa),
constraint FK_Konkurs_id_hr_menadzer foreign key (id_hr_asistenta) references Angazovanje.HR_Asistent(id_hr_asistenta) on delete set null,
constraint FK_Konkurs_id_radnog_mesto foreign key (id_radnog_mesta) references Angazovanje.Radno_Mesto (id_radnog_mesta),
constraint CHK_Konkurs_datum_raspis_konkursa_datum_zavr_konkursa check (datum_zavr_konkursa >= datum_zavr_konkursa)
);
go
create table Angazovanje.Angazovanje (
rb_angazovanja int not null constraint DFT_Angazovanje_rbr_angazovanja default (next value for Angazovanje.SEQ_rbr_angazovanja),
id_zaposlenog int not null,
id_radnog_mesta int not null,
id_statusa_ang tinyint,
id_vrsta_radod tinyint,
id_osnova tinyint,
id_konkursa int,
dat_ang_od date not null constraint DFT_Angazovanje_dat_ang_od default (sysdatetime()),
dat_ang_do date,
trajanje_ang numeric(5),

constraint PK_Angazovanje primary key (rb_angazovanja,id_zaposlenog),
constraint FK_Angazovanje_id_zaposlenog foreign key (id_zaposlenog) references Angazovanje.Zaposleni (id_zaposlenog),
constraint FK_Angazovanje_id_radnog_mesta foreign key (id_radnog_mesta) references Angazovanje.Radno_Mesto(id_radnog_mesta),
constraint FK_Angazovanje_id_statusa_ang foreign key (id_statusa_ang) references Angazovanje.Status_Angazovanja(id_statusa_ang),
constraint FK_Angazovanje_id_osnov foreign key (id_osnova) references Angazovanje.Osnov(id_osnova),
constraint FK_Angazovanje_id_vrsta_radod foreign key (id_vrsta_radod) references Angazovanje.Vrsta_radnog_odnosa(id_vrsta_radod),
constraint FK_Angazovanje_id_konkursa foreign key (id_konkursa) references Angazovanje.Konkurs (id_konkursa),
constraint CHK_Angazovanje_dat_ang_od_dat_ang_do check(dat_ang_do >= dat_ang_od)
);
