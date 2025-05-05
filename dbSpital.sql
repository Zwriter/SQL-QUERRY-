--Sa se creeze baza de date dbSpitalA

CREATE database dbSpital

--Sa se creeze tabelul tSectii (codSectie (pk), denumire)

CREATE table tSectii(
	codSectie char(10) constraint pk_Sectie primary key,
	denumire varchar(30),
);

--Sa se creeze tabelul tDoctori (codDoctor, nume, prenume, grad, salariu, prima, codSectie)

CREATE table tDoctori(
	codDoctor char(10) constraint pk_Doctori primary key,
	nume varchar(15),
	prenume varchar(20),
	grad varchar(20),
	salariu int,
	prima int,
	codSectie char(10) constraint fk_CodSectie foreign key references tSectii(codSectie),
);

--Sa se creeze schema Spital

CREATE schema Spital;

--Sa se transfere tabelele tSectii si tDoctori in schema Spital

alter schema Spital transfer tSectii;
alter schema Spital transfer tDoctori;

--Sa se creeze sinonime pentru cele doua tabele

create synonym tSectii for Spital.tSectii;
create synonym tDoctori for Spital.tDoctori;

--Sa se insereze date in tabelul tSectii

insert into tSectii(codSectie,denumire)
values ('S1','ORL'),('S2','Interne'),('S3', 'Chirurgie'),('S4', 'Cardiologie');

--Sa se modifice tipul coloanei grad in int

alter table Spital.tDoctori 
alter column grad int

--Sa se insereze date in tDoctori

insert into tDoctori(codDoctor, nume, prenume, grad, salariu, prima, codSectie)
values ('1','Ionsecu','Marin',3,10000,null,'S1'),
('2', 'Grigore', 'Alexandru', 2, 9000, null, 'S1'),
('3', 'Popescu', 'Mihai', 1, 11000, 3000, 'S2'),
('4', 'Petrescu', 'Andreea', 3, 12000, 3500, 'S2'),
('5', 'Grigorescu', 'Mihai', 2, 8000, 1000, 'S3'),
('6', 'Grigorescu', 'Ion', 1, 13000, 2000, 'S3'),
('7', 'Marinescu', 'Dorel', 3, 6500, null, 'S3')

--Sa se adauge coloana sefSectie (fk) in tabelul tSectii

alter table Spital.tSectii
add sefSectie char(10) constraint fk_sefSectie foreign key references Spital.tDoctori(codDoctor)

--Sa se afiseze tabelul tSectii

select * from tSectii

--Sa se actualizeze tabelul tSectii

update tSectii 
set sefSectie = '1'
where codSectie = 'S1'

update tSectii
set sefSectie = '4'
where codSectie = 'S2'

update tSectii
set sefSectie = '7'
where codSectie = 'S3'

--Sa se afiseze codDoctor, nume, prenume, salariu, prima, venit total

select codDoctor, nume, prenume, salariu, isnull(prima,0) as prima, salariu + isnull(prima,0) as [venit total]
from tDoctori 

--Sa se afiseze sectiile care nu au seful nominalizat

select * from tSectii
where sefSectie is NULL

--Sa se afiseze sectiile care au seful nominalizat

select * from tSectii
where sefSectie is not NULL

--Sa se afiseze codSectie, denumire, cod sef, nume, prenume

select A.codSectie, denumire, sefSectie as [cod sef], nume, prenume
from tSectii as A inner join tDoctori as B on A.sefSectie = B.codDoctor

--Trebuie sa apara si sectiile fara sef

select A.codSectie, denumire, sefSectie as [cod sef], nume, prenume
from tSectii as A left join tDoctori as B on A.sefSectie = B.codDoctor

--Sa se inlocuiasca null cu -

select A.codSectie, denumire, 
	isnull(sefSectie,'-') as [cod sef], 
	isnull(nume,'-') as nume, 
	isnull(prenume,'-') as prenume
from tSectii as A left join tDoctori as B on A.sefSectie = B.codDoctor

--Sa se afiseze sectiile care au medici angajati

select * from tSectii
where codSectie in (select distinct codSectie from tDoctori) 

--Sa se afiseze sectiile care nu au medici angajati

select * from tSectii
where codSectie not in (select distinct codSectie from tDoctori) 

--Sa se afiseze numarul de medici la nivel de sectie

select A.codSectie, denumire, count(codDoctor) as [Numar Doctori]
from tSectii as A inner join tDoctori as B on A.codSectie = B.codSectie
group by A.codSectie, denumire

--Sa se afiseze si sectiile care nu au angajati

select A.codSectie, denumire, count(codDoctor) as [Numar Doctori]
from tSectii as A left join tDoctori as B on A.codSectie = B.codSectie
group by A.codSectie, denumire

--Sa se afiseze cheltuiala totala cu salariile si primele la nivel de sectie

select A.codSectie, denumire, sum(isnull(prima,0) + isnull(salariu,0)) as [Total Cheltuieli]
from tSectii as A inner join tDoctori as B on A.codSectie = B.codSectie
group by A.codSectie, denumire 

--Sa se afiseze doctorii care au salariul cel mai mare

select codDoctor, nume, prenume, salariu
from tDoctori
where salariu = (select max(salariu) from tDoctori)

--Sa se afiseze doctorii care au salariul cel mai mare impreuna cu doctorii care au salariul cel mai mic

select codDoctor, nume, prenume, salariu
from tDoctori
where salariu in (select max(salariu) from tDoctori union select min(salariu) from tDoctori)

--Sa se afiseze doctorii care au salariul cel mai mare (metoda 2 - ineficienta)

select top 1 with ties codDoctor, nume, prenume, salariu
from tDoctori
order by salariu desc

update tDoctori
set salariu = 13000
where codDoctor = '1'

--Sa se afiseze sectia cu cele mai mari cheltuieli salariale (salariu + prima)

select A.codSectie, denumire, sum(isnull(prima,0) + isnull(salariu,0)) as [Total Cheltuieli]
from tSectii as A inner join tDoctori as B on A.codSectie = B.codSectie
group by A.codSectie, denumire 

select max([Total Salarii])
from (
	select A.codSectie, denumire, sum(isnull(prima,0) + isnull(salariu,0)) as [Total Cheltuieli]
	from tSectii as A left join tDoctori as B on A.codSectie = B.codSectie
	group by A.codSectie, denumire
	) as T

select A.codSectie, denumire, sum(isnull(salariu, 0) + isnull(prima, 0)) as [Total salarii]
from tSectii as A left join tDoctori as B on A.codSectie = B.codSectie
group by A.codSectie, denumire
having sum(isnull(salariu, 0) + isnull(prima, 0)) = (select max([Total salarii])
from (select A.codSectie, sum(isnull(salariu, 0) + isnull(prima, 0)) as [Total salarii]
	 from tSectii as A left join tDoctori as B on A.codSectie = B.codSectie
     group by A.codSectie) as T)

--METODA A II-A CU utilizarea unei vederi

go 
create view vTotalSalariiPerSectii
as	select A.codSectie, denumire, sum(isnull(prima,0) + isnull(salariu,0)) as [Total salarii]
	from tSectii as A left join tDoctori as B on A.codSectie = B.codSectie
	group by A.codSectie, denumire 

select * from vTotalSalariiPerSectii
order by [Total salarii] desc

select codSectie, denumire, [Total salarii]
from vTotalSalariiPerSectii
where [Total salarii] = (select max([Total salarii]) from vTotalSalariiPerSectii)