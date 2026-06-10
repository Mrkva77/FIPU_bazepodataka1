CREATE DATABASE polog_novca;
USE polog_novca;

-- Kreiranje tablice zaposlenik
CREATE TABLE zaposlenik (
    id INT PRIMARY KEY,
    ime VARCHAR(50),
    prezime VARCHAR(50),
    datum_zaposlenja DATE
);

-- Kreiranje tablice gradanin (povezuje se na zaposlenika)
-- Napomena: u definiciji je dodan i 'broj_telefona' iako ga nema u testnim podacima
CREATE TABLE gradanin (
    id INT PRIMARY KEY,
    ime VARCHAR(50),
    prezime VARCHAR(50),
    broj_telefona VARCHAR(20), 
    oib VARCHAR(11),
    id_zaposlenik INT,
    FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik(id)
);

-- Kreiranje tablice stednja (povezuje se na građanina)
CREATE TABLE stednja (
    id INT PRIMARY KEY,
    id_gradanin INT,
    broj_racuna VARCHAR(20),
    stanje DECIMAL(10,2),
    kamatna_stopa DECIMAL(4,2),
    FOREIGN KEY (id_gradanin) REFERENCES gradanin(id)
);

-- Kreiranje tablice tekuci (povezuje se na građanina)
CREATE TABLE tekuci (
    id INT PRIMARY KEY,
    id_gradanin INT,
    broj_racuna VARCHAR(20),
    stanje DECIMAL(10,2),
    iznos_prekoracenja DECIMAL(10,2),
    FOREIGN KEY (id_gradanin) REFERENCES gradanin(id)
);


-- Unos zaposlenika (datumi su pretvoreni u SQL format YYYY-MM-DD)
INSERT INTO zaposlenik (id, ime, prezime, datum_zaposlenja) VALUES
(1, 'Marina', 'Rović', '2020-01-10'),
(2, 'Teo', 'Zović', '2020-01-11'),
(3, 'Mauro', 'Matić', '2020-01-12');

-- Unos građana (broj_telefona ostaje NULL jer nije zadan u primjeru)
INSERT INTO gradanin (id, ime, prezime, broj_telefona, oib, id_zaposlenik) VALUES
(11, 'Teo', 'Zović', NULL, '1313233', 1),
(12, 'Ana', 'Babić', NULL, '1321133', 1),
(13, 'Linda', 'Horvat', NULL, '1321112', 2);

-- Unos štednji
INSERT INTO stednja (id, id_gradanin, broj_racuna, stanje, kamatna_stopa) VALUES
(21, 11, '0001', 10000.00, 3.0),
(22, 11, '0002', 3000.00, 2.5),
(23, 12, '0003', 15000.00, 4.0);

-- Unos tekućih računa
INSERT INTO tekuci (id, id_gradanin, broj_racuna, stanje, iznos_prekoracenja) VALUES
(31, 11, '0011', 1000.00, 2000.00),
(32, 12, '0012', 4000.00, 3000.00),
(33, 12, '0013', 25000.00, 3000.00),
(34, 13, '0014', 100.00, 3000.00);

SELECT * FROM zaposlenik
order by prezime desc, ime asc;

SELECT * FROM gradanin where ime in (select ime from zaposlenik); 

SELECT distinct prezime
from gradani
where prezime not in (select prezime from zaposlenik);

select max(stanje) as najveci_iznos_tekuci
from tekuci;

select g.*
from gradanin g
JOIN stednja s on g.id = s.id_gradanin
where s.stanje = (select min(stanje) from stednja);

select t.* from tekuci t
join gradanin g on t.id_gradanin = g.id
where g.ime = "Ana";

SELECT z.id, z.ime, z.prezime, COUNT(g.id) AS broj_gradana
FROM zaposlenik z
LEFT JOIN gradanin g ON z.id = g.id_zaposlenik
GROUP BY z.id, z.ime, z.prezime;

SELECT g.*
FROM gradanin g
JOIN tekuci t ON g.id = t.id_gradanin
GROUP BY g.id, g.ime, g.prezime, g.broj_telefona, g.oib, g.id_zaposlenik
HAVING COUNT(t.id) = 1;

SELECT g.*, COALESCE(SUM(t.stanje), 0.00) AS ukupno_stanje_tekuci
FROM gradanin g
LEFT JOIN tekuci t ON g.id = t.id_gradanin
GROUP BY g.id, g.ime, g.prezime, g.broj_telefona, g.oib, g.id_zaposlenik;