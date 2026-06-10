-- =========================================================================
-- 1. PRIPREMA BAZE PODATAKA I KREIRANJE TABLICA
-- =========================================================================

DROP DATABASE IF EXISTS fiputube;
CREATE DATABASE fiputube;

USE fiputube;

CREATE TABLE korisnik (
	id INTEGER PRIMARY KEY,
	email VARCHAR(40),
	ime VARCHAR(15),
	prezime VARCHAR(20)
);

CREATE TABLE video (
	id INTEGER PRIMARY KEY,
	naslov VARCHAR(40),
	broj_pregleda INTEGER,
	video_sadrzaj VARCHAR(20)
);

CREATE TABLE komentar (
	id INTEGER PRIMARY KEY,
	id_video INTEGER,
	id_korisnik INTEGER,
	datum DATETIME,
	sadrzaj VARCHAR(100),
	id_nad_komentar INTEGER
);

-- =========================================================================
-- 2. UNOS PODATAKA (INSERT)
-- =========================================================================

INSERT INTO korisnik VALUES (1, 'marko.maric@email.hr', 'Marko', 'Marić'),
                            (2, 'toni.milovan@email.hr', 'Toni', 'Milovan'),
                            (3, 'ime.prezime@email.hr', 'Ime', 'Prezime'),
                            (4, 'ime2.prezime@email.hr', 'Ime2', 'Prezime');
                            
INSERT INTO video VALUES (11, 'Formula 1 Australian Grand Prix', 500, 'video1'),
                         (12, 'Learn Relational Algebra: Part II', 30, 'video2'),
                         (13, '*** Music Video', 250, 'video3'),
                         (14, 'Prezentacija projekta BP1', 0, 'video4');

INSERT INTO komentar 
		VALUES (21, 11, 1, STR_TO_DATE('02.01.2020.', '%d.%m.%Y.'), 'First!', NULL),
			   (22, 11, 1, STR_TO_DATE('04.01.2020.', '%d.%m.%Y.'), 'I was first, just saying', NULL),
			   (23, 11, 3, STR_TO_DATE('04.01.2020.', '%d.%m.%Y.'), 'What happened at 02:00?', NULL),
			   (24, 12, 1, STR_TO_DATE('07.01.2020.', '%d.%m.%Y.'), 'What does "sigma" actually do?', NULL),
			   (25, 12, 2, STR_TO_DATE('07.01.2020.', '%d.%m.%Y.'), 'This video was very helpful. Thanks!', NULL),
			   (26, 12, 3, STR_TO_DATE('07.01.2020.', '%d.%m.%Y.'), 'It filter tuples based on the specific condition', 24),
			   (27, 12, 3, STR_TO_DATE('07.01.2020.', '%d.%m.%Y.'), 'Basically, it is just a filter', 24),
			   (28, 13, 1, STR_TO_DATE('09.01.2020.', '%d.%m.%Y.'), 'She sings amazing.', NULL);

-- =========================================================================
-- 3. RJEŠAVANJE ZADATAKA (SELECT & UPDATE)
-- =========================================================================

-- Zadatak 1: Prikaži video sa najvećim brojem brojem pregleda (bez korištenja podupita)
-- (Sortiramo silazno prema pregledima i uzimamo samo prvi red pomoću LIMIT 1)
SELECT * FROM video
ORDER BY broj_pregleda DESC
LIMIT 1;


-- Zadatak 2: Prikaži korisnike koji nisu objavili niti jedan komentar
-- (Tražimo korisnike kod kojih je ID komentara ostao NULL nakon LEFT JOIN-a)
SELECT kor.* 
FROM korisnik kor
LEFT JOIN komentar k ON kor.id = k.id_korisnik
WHERE k.id IS NULL;


-- Zadatak 3: Prikaži video zapise i broj njihovih komentara
-- (LEFT JOIN osigurava da vidimo i videozapise s 0 komentara)
SELECT v.id, v.naslov, COUNT(k.id) AS broj_komentara
FROM video v
LEFT JOIN komentar k ON v.id = k.id_video
GROUP BY v.id, v.naslov;


-- Zadatak 4: Prikaži sve komentare koje je objavio korisnik sa imenom 'Marko'
SELECT k.* 
FROM komentar k
JOIN korisnik kor ON k.id_korisnik = kor.id
WHERE kor.ime = 'Marko';


-- Zadatak 5: Prikaži video zapise koji imaju samo jedan komentar
-- (Grupiramo po videu i pomoću HAVING filtriramo točno one koji imaju COUNT = 1)
SELECT v.id, v.naslov
FROM video v
JOIN komentar k ON v.id = k.id_video
GROUP BY v.id, v.naslov
HAVING COUNT(k.id) = 1;


-- Zadatak 6: Prikaži korisnika koji ima objavljen najmanji broj komentara 
-- (Ne uključujući one koji nisu objavili niti jedan komentar)
-- (Običan JOIN automatski preskače korisnike bez komentara, sortiramo uzlazno i uzimamo prvog)
SELECT kor.id, kor.ime, kor.prezime, COUNT(k.id) AS broj_komentara
FROM korisnik kor
JOIN komentar k ON kor.id = k.id_korisnik
GROUP BY kor.id, kor.ime, kor.prezime
ORDER BY broj_komentara ASC
LIMIT 1;


-- Zadatak 7: Prikaži video koji ima najviše komentara (uključujući podkomentare)
-- (Grupiramo komentare po videu, sortiramo silazno i uzimamo prvi najviši rezultat)
SELECT v.id, v.naslov, COUNT(k.id) AS broj_komentara
FROM video v
JOIN komentar k ON v.id = k.id_video
GROUP BY v.id, v.naslov
ORDER BY broj_komentara DESC
LIMIT 1;


-- Zadatak 8: Ažuriraj komentare koji nemaju niti jedan podkomentar 
-- tako da im se u sadržaj doda izraz '(nema komentara)'
-- (Koristi se funkcija CONCAT za spajanje starog teksta i novog izraza. 
-- Podupit pronalazi sve ID-ove koji se pojavljuju kao nad-komentari kako bismo ih isključili iz izmjene)
UPDATE komentar
SET sadrzaj = CONCAT(sadrzaj, ' (nema komentara)')
WHERE id NOT IN (
    SELECT DISTINCT id_nad_komentar 
    FROM (SELECT id_nad_komentar FROM komentar) AS privremena_tablica 
    WHERE id_nad_komentar IS NOT NULL
);

-- (Opcionalno) Provjera rezultata ažuriranja iz 8. zadatka
SELECT * FROM komentar;
