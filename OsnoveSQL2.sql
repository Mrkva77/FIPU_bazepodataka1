-- =========================================================================
-- 1. KREIRANJE BAZE PODATAKA I TABLICA
-- =========================================================================

CREATE DATABASE fiputube;
USE fiputube;

-- Kreiranje tablice korisnik
CREATE TABLE korisnik (
    id INT PRIMARY KEY,
    email VARCHAR(100),
    ime VARCHAR(50),
    prezime VARCHAR(50)
);

-- Kreiranje tablice video
CREATE TABLE video (
    id INT PRIMARY KEY,
    naslov VARCHAR(100),
    broj_pregleda INT,
    video_sadrzaj VARCHAR(100)
);

-- Kreiranje tablice komentar
CREATE TABLE komentar (
    id INT PRIMARY KEY,
    id_video INT,
    id_korisnik INT,
    datum DATE,
    sadrzaj TEXT,
    id_nad_komentar INT,
    FOREIGN KEY (id_video) REFERENCES video(id),
    FOREIGN KEY (id_korisnik) REFERENCES korisnik(id),
    -- ON DELETE CASCADE automatski briše pod-komentare kada se obriše glavni komentar
    FOREIGN KEY (id_nad_komentar) REFERENCES komentar(id) ON DELETE CASCADE
);

-- =========================================================================
-- 2. DODAVANJE REDAKA U TABLICE (INSERT)
-- =========================================================================

-- Unos korisnika
INSERT INTO korisnik (id, email, ime, prezime) VALUES
(1, 'marko.maric@email.hr', 'Marko', 'Marić'),
(2, 'toni.milovan@email.hr', 'Toni', 'Milovan'),
(3, 'ime.prezime@email.hr', 'Ime', 'Prezime'),
(4, 'ime2.prezime@email.hr', 'Ime2', 'Prezime');

-- Unos videa
INSERT INTO video (id, naslov, broj_pregleda, video_sadrzaj) VALUES
(11, 'Formula 1 Australian Grand Prix', 500, 'video1'),
(12, 'Learn Relational Algebra: Part II', 30, 'video2'),
(13, '*** Music Video', 250, 'video3'),
(14, 'Prezentacija projekta BP1', 0, 'video4');

-- Unos glavnih komentara (oni koji nemaju nad-komentar)
INSERT INTO komentar (id, id_video, id_korisnik, datum, sadrzaj, id_nad_komentar) VALUES
(21, 11, 1, '2020-01-02', 'First!', NULL),
(22, 11, 1, '2020-01-04', 'I was first, just saying', NULL),
(23, 11, 3, '2020-01-04', 'What happened at 02:00?', NULL),
(24, 12, 1, '2020-01-07', 'What does "sigma" actually do?', NULL),
(25, 12, 2, '2020-01-07', 'This video was very helpful. Thanks!', NULL),
(28, 13, 1, '2020-01-09', 'She sings amazing.', NULL);

-- Unos pod-komentara (moraju se unijeti nakon što komentar 24 već postoji u bazi)
INSERT INTO komentar (id, id_video, id_korisnik, datum, sadrzaj, id_nad_komentar) VALUES
(26, 12, 3, '2020-01-07', 'It filter tuples based on the specific condition', 24),
(27, 12, 3, '2020-01-07', 'Basically, it is just a filter', 24);

-- =========================================================================
-- 3. TRAŽENI UPITI (SELECT)
-- =========================================================================

-- Upit 1: Svi video zapisi s više od 200 pregleda koji u naslovu imaju riječ video
SELECT * FROM video 
WHERE broj_pregleda > 200 AND naslov LIKE '%video%';

-- Upit 2: Prikaži sve pod-komentare
SELECT * FROM komentar 
WHERE id_nad_komentar IS NOT NULL;

-- Upit 3: Svi komentari za video sa naslovom "Learn Relational Algebra: Part II"
SELECT k.* FROM komentar k
JOIN video v ON k.id_video = v.id
WHERE v.naslov = 'Learn Relational Algebra: Part II';

-- Upit 4: Svi korisnici i naslovi videa na kojima su objavili barem jedan komentar
SELECT DISTINCT kor.ime, kor.prezime, v.naslov 
FROM korisnik kor
JOIN komentar kom ON kor.id = kom.id_korisnik
JOIN video v ON kom.id_video = v.id;

-- =========================================================================
-- 4. BRISANJE KOMENTARA I POD-KOMENTARA (DELETE)
-- =========================================================================

-- Brisanje komentara 24 (zbog ON DELETE CASCADE, automatski se brišu i 26 i 27)
DELETE FROM komentar 
WHERE id = 24;

-- (Opcionalno) Provjera jesu li komentar 24 i njegovi odgovori uspješno obrisani
SELECT * FROM komentar;
