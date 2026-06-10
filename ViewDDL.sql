-- =========================================================================
-- 1. KREIRANJE BAZE PODATAKA I PROŠIRENIH TABLICA (DDL)
-- =========================================================================

CREATE DATABASE polog_novca2;
USE polog_novca2;

CREATE TABLE zaposlenik(
    id INTEGER PRIMARY KEY,
    ime VARCHAR(20) NOT NULL,
    prezime VARCHAR(20) NOT NULL,
    datum_zaposlenja DATETIME NOT NULL
);

CREATE TABLE gradanin(
    id INTEGER PRIMARY KEY,
    ime VARCHAR(20) NOT NULL,
    prezime VARCHAR(20) NOT NULL,
    oib CHAR(11) NOT NULL UNIQUE, -- OIB mora biti jedinstven
    id_zaposlenik INTEGER NOT NULL,
    
    -- Strani ključ: Poveznica na zaposlenika
    FOREIGN KEY (id_zaposlenik) REFERENCES zaposlenik(id),
    
    -- Uvjet: Ime mora imati manji broj znakova od prezimena (manje ili jednako prema "ne smije biti duže")
    CONSTRAINT chk_ime_prezime CHECK (LENGTH(ime) <= LENGTH(prezime))
);

CREATE TABLE stednja(
    id INTEGER PRIMARY KEY,
    id_gradanin INTEGER NOT NULL UNIQUE, -- UNIQUE osigurava da građanin smije imati samo JEDNU štednju
    broj_racuna CHAR(4) NOT NULL UNIQUE, -- Broj računa mora biti jedinstven
    stanje NUMERIC(7,2) NOT NULL DEFAULT 10, -- Zadana vrijednost je 10
    kamatna_stopa NUMERIC(2,1) NOT NULL,
    
    -- Strani ključ: Prilikom brisanja građanina, briše se i njegova štednja
    FOREIGN KEY (id_gradanin) REFERENCES gradanin(id) ON DELETE CASCADE,
    
    -- Uvjet: Stanje i kamatna stopa moraju biti pozitivni (>= 0)
    CONSTRAINT chk_stednja_pozitivno CHECK (stanje >= 0 AND kamatna_stopa >= 0)
);

CREATE TABLE tekuci(
    id INTEGER PRIMARY KEY,
    id_gradanin INTEGER NOT NULL,
    broj_racuna CHAR(4) NOT NULL UNIQUE, -- Broj računa mora biti jedinstven
    stanje NUMERIC(7,2) NOT NULL DEFAULT 10, -- Zadana vrijednost je 10
    iznos_prekoracenja NUMERIC(7,2) NOT NULL,
    
    -- Strani ključ: Prilikom brisanja građanina, briše se i njegov tekući račun
    FOREIGN KEY (id_gradanin) REFERENCES gradanin(id) ON DELETE CASCADE,
    
    -- Uvjet: Stanje i iznos prekoračenja moraju biti pozitivni (>= 0)
    CONSTRAINT chk_tekuci_pozitivno CHECK (stanje >= 0 AND iznos_prekoracenja >= 0)
);

-- =========================================================================
-- 2. UNOS POČETNIH PODATAKA (INSERT)
-- *Napomena*: Podaci iz vašeg primjera su prilagođeni da zadovolje nova pravila
-- (npr. oib ima 11 znakova, a imena nisu duža od prezimena).
-- =========================================================================

INSERT INTO zaposlenik VALUES (1, 'Marina', 'Rović', STR_TO_DATE('10.01.2020.', '%d.%m.%Y.')),
			                  (2, 'Teo', 'Zović', STR_TO_DATE('11.01.2020.', '%d.%m.%Y.')),
                              (3, 'Mauro', 'Matić', STR_TO_DATE('12.01.2020.', '%d.%m.%Y.'));
                              
INSERT INTO gradanin VALUES (11, 'Teo', 'Zović', '12345678901', 1),
			                (12, 'Ana', 'Babić', '12345678902', 1),
			                (13, 'Jan', 'Horvat', '12345678903', 2); -- Promijenjeno 'Linda' u 'Jan' da ime bude kraće od prezimena
                            
INSERT INTO stednja VALUES (21, 11, '0001', 10000, 3.0),
			               (22, 12, '0002', 3000, 2.5),
		                   (23, 13, '0003', 15000, 4.0);
                           
INSERT INTO tekuci VALUES (31, 11, '0011', 1000, 2000),
			              (32, 12, '0012', 4000, 3000),
			              (33, 12, '0013', 25000, 3000),
			              (34, 13, '0014', 100, 3000);

-- =========================================================================
-- 3. KREIRANJE POGLEDA (VIEWS)
-- =========================================================================

-- Zadatak 1: Pogled gradanin_tekuci (Prikazuje građane i njihovo ukupno stanje tekućih računa)
CREATE VIEW gradanin_tekuci AS
SELECT g.id, g.ime, g.prezime, g.oib, g.id_zaposlenik, 
       COALESCE(SUM(t.stanje), 0.00) AS ukupno_stanje_tekuci
FROM gradanin g
LEFT JOIN tekuci t ON g.id = t.id_gradanin
GROUP BY g.id, g.ime, g.prezime, g.oib, g.id_zaposlenik;


-- Zadatak 2: Pogled vip_gradanin (Samo građani sa stanjem tekućih računa > 20000)
-- Pogled povlači podatke direktno iz tablice 'gradanin' uz podupit za stanje. 
-- Ključna riječ 'WITH CHECK OPTION' osigurava da se preko pogleda mogu unijeti samo ispravni podaci.
CREATE VIEW vip_gradanin AS
SELECT g.id, g.ime, g.prezime, g.oib, g.id_zaposlenik
FROM gradanin g
WHERE (SELECT COALESCE(SUM(t.stanje), 0) FROM tekuci t WHERE t.id_gradanin = g.id) > 20000
WITH CHECK OPTION;

-- =========================================================================
-- 4. UNOS NOVOG GRAĐANINA PREKO POGLEDA
-- =========================================================================

-- Zadatak 3: Budući da pogled vip_gradanin zahtijeva da građanin odmah ima preko 20000 na tekućem,
-- u transakciji prvo unosi građana kroz pogled, a zatim mu pridružuje tekući račun kako bi uvjet bio zadovoljen.

START TRANSACTION;

-- Unos novog građanina (ID: 14, Ime 'Leo' ima 3 znaka, prezime 'Marić' 5)
INSERT INTO vip_gradanin (id, ime, prezime, oib, id_zaposlenik) 
VALUES (14, 'Leo', 'Marić', '12345678904', 1);

-- Odmah mu dodajemo račun s iznosom od 25000 kako bi se zadovoljio uvjet VIP pogleda (>20000)
INSERT INTO tekuci (id, id_gradanin, broj_racuna, stanje, iznos_prekoracenja) 
VALUES (35, 14, '0015', 25000.00, 1000.00);

COMMIT;

-- Provjera unesenih podataka kroz pogled
SELECT * FROM vip_gradanin;
