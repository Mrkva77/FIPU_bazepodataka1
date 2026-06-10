CREATE DATABASE evidencija_kolegija;
USE evidencija_kolegija;

CREATE TABLE kolegiji (
	id INT PRIMARY KEY,
    naziv VARCHAR(50),
    semestar_izvodenja VARCHAR(50),
    sati_nastave int
);
    
insert into kolegiji (id, naziv, semestar_izvodenja, sati_nastave) VALUES
(1, "Programiranje", 1, 30),
(2, "Baze podataka 1", 2, 30),
(3, "Baze podataka 2", 3, 30),
(4, "Napredne tehnike programiranja", 3, 30);

select * from kolegiji where semestar_izvodenja = 3;

select * from kolegiji where naziv like "%podataka%";

select *, UPPER(naziv) as naziv_velika_slova from kolegiji;

SELECT a.*, b.*
FROM kolegiji a, kolegiji b
WHERE a.semestar_izvodenja >= 3 and b.semestar_izvodenja >= 3;

SELECT distinct semestar_izvodenja FROM kolegiji;

DELETE FROM kolegiji WHERE semestar_izvodenja = 1;