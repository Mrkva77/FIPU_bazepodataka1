-- =========================================================================
-- 1. PRIPREMA BAZE PODATAKA I KREIRANJE TABLICA
-- =========================================================================

CREATE DATABASE fiputube2;
USE fiputube2;

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
    sadrzaj VARCHAR(50),
    id_nad_komentar INTEGER
);

-- =========================================================================
-- 2. INSERTOVI (DODAVANJE PODATAKA)
-- =========================================================================

INSERT INTO korisnik VALUES (1, 'marko.maric@email.hr', 'Marko', 'Marić'),
			    (2, 'toni.milovan@email.hr', 'Toni', 'Milovan'),
			    (3, 'ime.prezime@email.hr', 'Ime', 'Prezime'),
			    (4, 'ime2.prezime@email.hr', 'Ime2', 'Prezime');
                            
INSERT INTO video VALUES (11, 'Formula 1 Australian Grand Prix', 500, 'video1'),
			 (12, 'Learn Relational Algebra: Part II', 30, 'video2'),
			 (13, '*** Music Video', 250, 'video3'),
			 (14, 'Prezentacija projekta BP1', 0, 'video4');
                         
INSERT INTO komentar VALUES (21, 11, 1, STR_TO_DATE('02.01.2020.', '%d.%m.%Y.'), 'First!', NULL),
			    (22, 11, 1, STR_TO_DATE('04.01.2020.', '%d.%m.%Y.'), 'I was first, just saying', NULL),
			    (23, 11, 3, STR_TO_DATE('04.01.2020.', '%d.%m.%Y.'), 'What happened at 02:00?', NULL),
			    (24, 12, 1, STR_TO_DATE('07.01.2020.', '%d.%m.%Y.'), 'What does "sigma" actually do?', NULL),
			    (25, 12, 2, STR_TO_DATE('07.01.2020.', '%d.%m.%Y.'), 'This video was very helpful. Thanks!', NULL),
			    (26, 12, 3, STR_TO_DATE('07.01.2020.', '%d.%m.%Y.'), 'It filter tuples based on the specific condition', 24),
			    (27, 12, 3, STR_TO_DATE('07.01.2020.', '%d.%m.%Y.'), 'Basically, it is just a filter', 24),
			    (28, 13, 1, STR_TO_DATE('09.01.2020.', '%d.%m.%Y.'), 'She sings amazing.', NULL);

-- =========================================================================
-- 3. TRAŽENI UPITI (SELECT)
-- =========================================================================

-- Upit 1: Prikaži sve komentare zajedno sa korisnikom koji ga je objavio i video za koji je objavljen
SELECT k.id AS komentar_id, k.sadrzaj, k.datum, 
       kor.ime, kor.prezime, kor.email, 
       v.naslov AS naslov_videa
FROM komentar k
JOIN korisnik kor ON k.id_korisnik = kor.id
JOIN video v ON k.id_video = v.id;


-- Upit 2: Prikaži sve korisnike i komentare koje su objavili, uključujući korisnike koji nisu objavili niti jedan komentar
SELECT kor.id AS korisnik_id, kor.ime, kor.prezime, 
       k.id AS komentar_id, k.sadrzaj, k.datum
FROM korisnik kor
LEFT JOIN komentar k ON kor.id = k.id_korisnik;


-- Upit 3: Prikaži sve video zapise sa brojem komentara (uključujući podkomentare)
SELECT v.id, v.naslov, COUNT(k.id) AS ukupno_komentara
FROM video v
LEFT JOIN komentar k ON v.id = k.id_video
GROUP BY v.id, v.naslov;


-- Upit 4: Prikaži sve komentare i broj podkomentara
SELECT k1.id, k1.sadrzaj, COUNT(k2.id) AS broj_podkomentara
FROM komentar k1
LEFT JOIN komentar k2 ON k1.id = k2.id_nad_komentar
GROUP BY k1.id, k1.sadrzaj;


-- Upit 5: Prikaži sve korisnike koji su objavili barem jedan komentar na datum '07.01.2020.'
SELECT DISTINCT kor.*
FROM korisnik kor
JOIN komentar k ON kor.id = k.id_korisnik
WHERE DATE(k.datum) = '2020-01-07';


-- Upit 6: Prikaži sve video zapise sa dodatna dva stupca: broj komentara (ne uključujući podkomentare), broj podkomentara
SELECT v.id, v.naslov,
       COUNT(CASE WHEN k.id_nad_komentar IS NULL THEN k.id END) AS broj_glavnih_komentara,
       COUNT(CASE WHEN k.id_nad_komentar IS NOT NULL THEN k.id END) AS broj_podkomentara
FROM video v
LEFT JOIN komentar k ON v.id = k.id_video
GROUP BY v.id, v.naslov;
