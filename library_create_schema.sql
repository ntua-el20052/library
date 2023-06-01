-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Εξυπηρετητής: 127.0.0.1
-- Χρόνος δημιουργίας: 01 Ιουν 2023 στις 22:50:51
-- Έκδοση διακομιστή: 10.4.27-MariaDB
-- Έκδοση PHP: 8.2.0

--SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
--START TRANSACTION;
--SET time_zone = "+00:00";

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

DROP SCHEMA IF EXISTS library;
CREATE SCHEMA library;
USE library;


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Βάση δεδομένων: `library`
--

-- --------------------------------------------------------

--
-- Δομή πίνακα για τον πίνακα `authors`
--

CREATE TABLE `authors` (
  `author_id` int(11) NOT NULL,
  `author_name` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


-- --------------------------------------------------------

--
-- Δομή πίνακα για τον πίνακα `belongs_to`
--

CREATE TABLE `belongs_to` (
  `blng_to_id` int(11) NOT NULL,
  `name` varchar(45) NOT NULL,
  `isbn` varchar(13) NOT NULL,
  `nmbr_of_copies_per_school` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Δείκτες `belongs_to`
--
DELIMITER $$
CREATE TRIGGER `update_nmbr_of_copies` AFTER INSERT ON `belongs_to` FOR EACH ROW BEGIN
    UPDATE books
    SET nmbr_of_copies = (SELECT SUM(nmbr_of_copies_per_school) FROM belongs_to WHERE isbn = NEW.isbn)
    WHERE isbn = NEW.isbn;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Δομή πίνακα για τον πίνακα `booking`
--

CREATE TABLE `booking` (
  `booking_id` int(11) NOT NULL,
  `id` int(11) NOT NULL,
  `isbn` varchar(13) NOT NULL,
  `booking_date` date NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Δείκτες `booking`
--
DELIMITER $$
CREATE TRIGGER ` convert_booking_to_borrowing_trigger` BEFORE DELETE ON `booking` FOR EACH ROW BEGIN
    DECLARE copies INT;
    DECLARE user_school_name VARCHAR(45);
    
    SET user_school_name = (SELECT name FROM goes_to WHERE id = OLD.id);
    SET copies = (SELECT nmbr_of_copies_per_school FROM belongs_to WHERE isbn = OLD.isbn AND name = user_school_name);
    
    IF copies > 0 THEN 
        INSERT INTO borrowing (id, isbn, status)
        VALUES (OLD.id, OLD.isbn, 'active');
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `check_booking_limit_trigger` BEFORE INSERT ON `booking` FOR EACH ROW BEGIN
    DECLARE role INT;
    DECLARE booking_count INT;
    DECLARE books_count INT;
    DECLARE situationship VARCHAR(25);
    DECLARE user_school_name VARCHAR(45);
    
    SELECT name INTO user_school_name
    FROM goes_to WHERE id=NEW.id;
    
    SELECT status INTO situationship
    FROM borrowing
    WHERE id=NEW.id AND status = 'delayed'
    LIMIT 1;
    
    SELECT number, weekly_booking_count INTO role, booking_count
    FROM user
    WHERE id = NEW.id;
    
    SELECT nmbr_of_copies_per_school INTO books_count
    FROM belongs_to
    WHERE isbn=NEW.isbn AND name = user_school_name;
    
    IF situationship = 'delayed' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You cannot book a book because you have not returned a book in time';
    END IF;
    IF role = 4 OR role = 3 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You cannot book a book as a manager or handler';
    END IF;
    
    IF EXISTS (
        SELECT 1
        FROM borrowing
        WHERE id = NEW.id AND isbn = NEW.isbn
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You have already borrowed this book.';
    ELSEIF books_count > 0 THEN 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'There is a copy of this book in your school unit available.';
    ELSEIF books_count IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'There is not this book declared in your school';
    ELSEIF (role = 1 AND booking_count <=0) OR (role = 2 AND booking_count <= 0) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You have reached the maximum booking limit.';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_booking_count` AFTER INSERT ON `booking` FOR EACH ROW BEGIN
	UPDATE user
    SET weekly_booking_count = weekly_booking_count - 1
    WHERE id = NEW.id;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Δομή πίνακα για τον πίνακα `books`
--

CREATE TABLE `books` (
  `isbn` varchar(13) NOT NULL,
  `title` varchar(45) NOT NULL,
  `publisher` varchar(45) NOT NULL,
  `pages` int(11) NOT NULL,
  `summary` varchar(500) NOT NULL,
  `nmbr_of_copies` int(11) NOT NULL,
  `image` varchar(1000) NOT NULL,
  `language` varchar(45) NOT NULL
) ;

--
-- Δομή πίνακα για τον πίνακα `book_author`
--

CREATE TABLE `book_author` (
  `book_author_id` int(11) NOT NULL,
  `isbn` varchar(13) NOT NULL,
  `author_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Άδειασμα δεδομένων του πίνακα `book_author`
--

--
-- Δομή πίνακα για τον πίνακα `book_genre`
--

CREATE TABLE `book_genre` (
  `book_genre_id` int(11) NOT NULL,
  `isbn` varchar(13) NOT NULL,
  `genre_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


--
-- Δομή πίνακα για τον πίνακα `book_key_words`
--

CREATE TABLE `book_key_words` (
  `book_key_word_id` int(11) NOT NULL,
  `isbn` varchar(13) NOT NULL,
  `key_word_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Δομή πίνακα για τον πίνακα `borrowing`
--

CREATE TABLE `borrowing` (
  `borrowing_id` int(11) NOT NULL,
  `id` int(11) NOT NULL,
  `isbn` varchar(13) NOT NULL,
  `borrowing_date` date NOT NULL DEFAULT current_timestamp(),
  `status` varchar(25) NOT NULL
) ;

--
-- Δείκτες `borrowing`
--
DELIMITER $$
CREATE TRIGGER `before_insert` BEFORE INSERT ON `borrowing` FOR EACH ROW BEGIN
    DECLARE copies INT;
    DECLARE role INT;
    DECLARE bor_books INT;
    DECLARE situationship VARCHAR(25);
    DECLARE user_school_name VARCHAR(45);
    
    SELECT status INTO situationship
    FROM borrowing
    WHERE id=NEW.id AND status = 'delayed'
    LIMIT 1;
    
    SET role = (SELECT number FROM user WHERE id = NEW.id);
    SET bor_books = (SELECT weekly_borrowing_count FROM user WHERE id = NEW.id);
    SET user_school_name = (SELECT name FROM goes_to WHERE id=NEW.id);
    SET copies = (SELECT nmbr_of_copies_per_school FROM belongs_to WHERE isbn = NEW.isbn AND name = user_school_name );
      IF EXISTS (
        SELECT 1
        FROM borrowing
        WHERE id = NEW.id AND isbn = NEW.isbn AND status='active'
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You have already borrowed this book.';
        END IF;
      
    IF situationship = 'delayed' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You cannot borrow a book because you havent returned a book in time.';
    END IF;
    
    
    IF copies IS NULL THEN 
     SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You cannot borrow a book from different school unit.';
     END IF;
    
    
    IF copies = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'There is not any copies available in your school unit, please book the book.';
     ELSEIF role = 4 OR role = 3 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You cannot borrow a book as a manager or handler';
    
    ELSEIF (role = 1 AND bor_books = 0) OR (role = 2 AND bor_books = 0) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You cannot borrow more books.';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `borrowing-trigger` AFTER INSERT ON `borrowing` FOR EACH ROW BEGIN
DECLARE handler INT;
    
    SET handler = (SELECT id
    FROM handles
    WHERE school_name = (SELECT name FROM goes_to WHERE id = NEW.id));
  UPDATE user 
         SET weekly_borrowing_count = weekly_borrowing_count-1
         WHERE id = NEW.id;
         
        IF NEW.status <> 'inactive' THEN    
        UPDATE handles
        SET borrowings_approved = borrowings_approved + 1
        WHERE id = handler;
  		END IF;
         
         UPDATE books
         SET nmbr_of_copies = nmbr_of_copies - 1
         WHERE isbn = NEW.isbn;
         
         UPDATE belongs_to
         SET nmbr_of_copies_per_school = nmbr_of_copies_per_school - 1
         WHERE (isbn = NEW.isbn) AND (name = (SELECT name FROM goes_to WHERE id = NEW.id));
         
         UPDATE user
         SET nmbr_of_books = nmbr_of_books + 1
         WHERE id = NEW.id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `increase_copies` AFTER UPDATE ON `borrowing` FOR EACH ROW BEGIN
DECLARE handler INT;
    
    SET handler = (SELECT id
    FROM handles
    WHERE school_name = (SELECT name FROM goes_to WHERE id = NEW.id));
    
    IF NEW.status = 'active' AND OLD.status = 'inactive' THEN    
        UPDATE handles
        SET borrowings_approved = borrowings_approved + 1
        WHERE id = handler;
  
    END IF;
    IF NEW.status = 'returned' AND (OLD.status ='active' OR OLD.status='delayed')
    THEN
        UPDATE books SET nmbr_of_copies = nmbr_of_copies + 1         WHERE isbn = NEW.isbn;
UPDATE belongs_to SET nmbr_of_copies_per_school = nmbr_of_copies_per_school +1 WHERE (name = (SELECT name FROM goes_to WHERE id = NEW.id)) AND isbn = NEW.isbn;
    END IF;    
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Δομή πίνακα για τον πίνακα `genres`
--

CREATE TABLE `genres` (
  `genre_id` int(11) NOT NULL,
  `genre_name` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Δομή πίνακα για τον πίνακα `goes_to`
--

CREATE TABLE `goes_to` (
  `goes_to_id` int(11) NOT NULL,
  `id` int(11) NOT NULL,
  `name` varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Δομή πίνακα για τον πίνακα `handles`
--

CREATE TABLE `handles` (
  `handle_id` int(11) NOT NULL,
  `id` int(11) NOT NULL,
  `school_name` varchar(45) NOT NULL,
  `borrowings_approved` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Δείκτες `handles`
--
DELIMITER $$
CREATE TRIGGER `insert_handles_trigger` BEFORE INSERT ON `handles` FOR EACH ROW BEGIN
    DECLARE role INT;
    SELECT number INTO role FROM user WHERE id = NEW.id;
    IF role <> 3 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Only users with role_id = 3 are allowed.';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Δομή πίνακα για τον πίνακα `key_word`
--

CREATE TABLE `key_word` (
  `key_word_id` int(11) NOT NULL,
  `key_word` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


--
-- Δομή πίνακα για τον πίνακα `manages`
--

CREATE TABLE `manages` (
  `manages_id` int(11) NOT NULL,
  `name` varchar(45) NOT NULL,
  `id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Δείκτες `manages`
--
DELIMITER $$
CREATE TRIGGER `before_insert_manages` BEFORE INSERT ON `manages` FOR EACH ROW BEGIN
     DECLARE role INT;
     SELECT number INTO role FROM user WHERE id = NEW.id;
     IF role <> 4 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Only users with role_id = 4 are allowed.';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Δομή πίνακα για τον πίνακα `review`
--

CREATE TABLE `review` (
  `review_id` int(11) NOT NULL,
  `id` int(11) NOT NULL,
  `isbn` varchar(13) NOT NULL,
  `likert_scale` int(11) NOT NULL,
  `review_text` varchar(500) NOT NULL,
  `review_status` varchar(25) NOT NULL
) ;

--
-- Δείκτες `review`
--
DELIMITER $$
CREATE TRIGGER `check_borrowed_book` BEFORE INSERT ON `review` FOR EACH ROW BEGIN
    DECLARE user_id INT;
    DECLARE book_isbn VARCHAR(13);
    DECLARE borrowed_count INT;
    DECLARE book_status VARCHAR(25);

    SET user_id = NEW.id;
    SET book_isbn = NEW.isbn;

    SELECT status INTO book_status
    FROM borrowing
    WHERE id = user_id AND isbn = book_isbn;

    SELECT COUNT(*) INTO borrowed_count
    FROM borrowing
    WHERE id = user_id AND isbn = book_isbn AND book_status<>'inactive';

    IF borrowed_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You can only review a book that you have borrowed.';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Δομή πίνακα για τον πίνακα `school_unit`
--

CREATE TABLE `school_unit` (
  `school_name` varchar(45) NOT NULL,
  `city` varchar(45) NOT NULL,
  `ph_nmbr` varchar(10) NOT NULL,
  `mail` varchar(45) NOT NULL,
  `addr_code` smallint(6) NOT NULL,
  `address` varchar(45) NOT NULL,
  `dir_name` varchar(45) NOT NULL
) ;

--
-- Δομή πίνακα για τον πίνακα `user`
--

CREATE TABLE `user` (
  `id` int(11) NOT NULL,
  `password` varchar(60) NOT NULL,
  `name` varchar(45) NOT NULL,
  `age` int(11) NOT NULL,
  `ph_nmbr` varchar(10) NOT NULL,
  `mail` varchar(45) NOT NULL,
  `nmbr_of_books` int(11) NOT NULL,
  `number` int(11) NOT NULL,
  `approved_status` varchar(25) DEFAULT NULL,
  `weekly_borrowing_count` int(11) NOT NULL,
  `weekly_booking_count` int(11) NOT NULL
) ;

--
-- Ευρετήρια για πίνακες
--

--
-- Ευρετήρια για πίνακα `authors`
--
ALTER TABLE `authors`
  ADD PRIMARY KEY (`author_id`),
  ADD KEY `author_name` (`author_name`);

--
-- Ευρετήρια για πίνακα `belongs_to`
--
ALTER TABLE `belongs_to`
  ADD PRIMARY KEY (`blng_to_id`),
  ADD KEY `belongs_to_ibfk_1` (`name`),
  ADD KEY `belongs_to_ibfk_2` (`isbn`);

--
-- Ευρετήρια για πίνακα `booking`
--
ALTER TABLE `booking`
  ADD PRIMARY KEY (`booking_id`),
  ADD KEY `booking_ibfk_1` (`id`),
  ADD KEY `booking_ibfk_2` (`isbn`),
  ADD KEY `booking_date` (`booking_date`);

--
-- Ευρετήρια για πίνακα `books`
--
ALTER TABLE `books`
  ADD PRIMARY KEY (`isbn`),
  ADD KEY `title` (`title`);

--
-- Ευρετήρια για πίνακα `book_author`
--
ALTER TABLE `book_author`
  ADD PRIMARY KEY (`book_author_id`),
  ADD KEY `book_author_ibfk_1` (`isbn`),
  ADD KEY `book_author_ibfk_2` (`author_id`);

--
-- Ευρετήρια για πίνακα `book_genre`
--
ALTER TABLE `book_genre`
  ADD PRIMARY KEY (`book_genre_id`),
  ADD KEY `book_genre_ibfk_1` (`isbn`),
  ADD KEY `book_genre_ibfk_2` (`genre_id`);

--
-- Ευρετήρια για πίνακα `book_key_words`
--
ALTER TABLE `book_key_words`
  ADD PRIMARY KEY (`book_key_word_id`),
  ADD KEY `book_key_words_ibfk_1` (`isbn`),
  ADD KEY `book_key_words_ibfk_2` (`key_word_id`);

--
-- Ευρετήρια για πίνακα `borrowing`
--
ALTER TABLE `borrowing`
  ADD PRIMARY KEY (`borrowing_id`),
  ADD KEY `borrowing_ibfk_1` (`id`),
  ADD KEY `borrowing_ibfk_2` (`isbn`),
  ADD KEY `borrowing_date` (`borrowing_date`);

--
-- Ευρετήρια για πίνακα `genres`
--
ALTER TABLE `genres`
  ADD PRIMARY KEY (`genre_id`),
  ADD KEY `genre_name` (`genre_name`);

--
-- Ευρετήρια για πίνακα `goes_to`
--
ALTER TABLE `goes_to`
  ADD PRIMARY KEY (`goes_to_id`),
  ADD KEY `goes_to_ibfk_1` (`id`),
  ADD KEY `goes_to_ibfk_2` (`name`);

--
-- Ευρετήρια για πίνακα `handles`
--
ALTER TABLE `handles`
  ADD PRIMARY KEY (`handle_id`),
  ADD KEY `handles_ibfk_1` (`id`),
  ADD KEY `handles_ibfk_2` (`school_name`);

--
-- Ευρετήρια για πίνακα `key_word`
--
ALTER TABLE `key_word`
  ADD PRIMARY KEY (`key_word_id`),
  ADD KEY `key_word` (`key_word`);

--
-- Ευρετήρια για πίνακα `manages`
--
ALTER TABLE `manages`
  ADD PRIMARY KEY (`manages_id`),
  ADD KEY `manages_ibfk_1` (`name`),
  ADD KEY `manages_ibfk_2` (`id`);

--
-- Ευρετήρια για πίνακα `review`
--
ALTER TABLE `review`
  ADD PRIMARY KEY (`review_id`),
  ADD KEY `review_ibfk_2` (`isbn`),
  ADD KEY `review_ibfk_1` (`id`);

--
-- Ευρετήρια για πίνακα `school_unit`
--
ALTER TABLE `school_unit`
  ADD PRIMARY KEY (`school_name`);

--
-- Ευρετήρια για πίνακα `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT για άχρηστους πίνακες
--

--
-- AUTO_INCREMENT για πίνακα `authors`
--
ALTER TABLE `authors`
  MODIFY `author_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=150;

--
-- AUTO_INCREMENT για πίνακα `belongs_to`
--
ALTER TABLE `belongs_to`
  MODIFY `blng_to_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=203;

--
-- AUTO_INCREMENT για πίνακα `booking`
--
ALTER TABLE `booking`
  MODIFY `booking_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=74;

--
-- AUTO_INCREMENT για πίνακα `book_author`
--
ALTER TABLE `book_author`
  MODIFY `book_author_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=167;

--
-- AUTO_INCREMENT για πίνακα `book_genre`
--
ALTER TABLE `book_genre`
  MODIFY `book_genre_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=150;

--
-- AUTO_INCREMENT για πίνακα `book_key_words`
--
ALTER TABLE `book_key_words`
  MODIFY `book_key_word_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=353;

--
-- AUTO_INCREMENT για πίνακα `borrowing`
--
ALTER TABLE `borrowing`
  MODIFY `borrowing_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT για πίνακα `genres`
--
ALTER TABLE `genres`
  MODIFY `genre_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=51;

--
-- AUTO_INCREMENT για πίνακα `goes_to`
--
ALTER TABLE `goes_to`
  MODIFY `goes_to_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=188;

--
-- AUTO_INCREMENT για πίνακα `handles`
--
ALTER TABLE `handles`
  MODIFY `handle_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT για πίνακα `key_word`
--
ALTER TABLE `key_word`
  MODIFY `key_word_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=212;

--
-- AUTO_INCREMENT για πίνακα `manages`
--
ALTER TABLE `manages`
  MODIFY `manages_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT για πίνακα `review`
--
ALTER TABLE `review`
  MODIFY `review_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT για πίνακα `user`
--
ALTER TABLE `user`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Περιορισμοί για άχρηστους πίνακες
--

--
-- Περιορισμοί για πίνακα `belongs_to`
--
ALTER TABLE `belongs_to`
  ADD CONSTRAINT `belongs_to_ibfk_1` FOREIGN KEY (`name`) REFERENCES `school_unit` (`school_name`) ON UPDATE CASCADE,
  ADD CONSTRAINT `belongs_to_ibfk_2` FOREIGN KEY (`isbn`) REFERENCES `books` (`isbn`) ON UPDATE CASCADE;
ALTER TABLE belongs_to
  ADD constraint positive_number_per_school CHECK (nmbr_of_copies_per_school >=0);

--
-- Περιορισμοί για πίνακα `booking`
--
ALTER TABLE `booking`
  ADD CONSTRAINT `booking_ibfk_1` FOREIGN KEY (`id`) REFERENCES `user` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `booking_ibfk_2` FOREIGN KEY (`isbn`) REFERENCES `books` (`isbn`) ON UPDATE CASCADE;
  
  --
  -- Περιορισμοι για πινακα 'books'
  --
  
ALTER TABLE books
  ADD CONSTRAINT positive_nmbr_of_books CHECK (nmbr_of_copies >= 0),
  ADD CONSTRAINT isbn_length CHECK (octet_length(isbn) = 13);

--
-- Περιορισμοί για πίνακα `book_author`
--
ALTER TABLE `book_author`
  ADD CONSTRAINT `book_author_ibfk_1` FOREIGN KEY (`isbn`) REFERENCES `books` (`isbn`) ON UPDATE CASCADE,
  ADD CONSTRAINT `book_author_ibfk_2` FOREIGN KEY (`author_id`) REFERENCES `authors` (`author_id`) ON UPDATE CASCADE;

--
-- Περιορισμοί για πίνακα `book_genre`
--
ALTER TABLE `book_genre`
  ADD CONSTRAINT `book_genre_ibfk_1` FOREIGN KEY (`isbn`) REFERENCES `books` (`isbn`) ON UPDATE CASCADE,
  ADD CONSTRAINT `book_genre_ibfk_2` FOREIGN KEY (`genre_id`) REFERENCES `genres` (`genre_id`) ON UPDATE CASCADE;

--
-- Περιορισμοί για πίνακα `book_key_words`
--
ALTER TABLE `book_key_words`
  ADD CONSTRAINT `book_key_words_ibfk_1` FOREIGN KEY (`isbn`) REFERENCES `books` (`isbn`) ON UPDATE CASCADE,
  ADD CONSTRAINT `book_key_words_ibfk_2` FOREIGN KEY (`key_word_id`) REFERENCES `key_word` (`key_word_id`) ON UPDATE CASCADE;

--
-- Περιορισμοί για πίνακα `borrowing`
--
ALTER TABLE `borrowing`
  ADD CONSTRAINT `borrowing_ibfk_1` FOREIGN KEY (`id`) REFERENCES `user` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `borrowing_ibfk_2` FOREIGN KEY (`isbn`) REFERENCES `books` (`isbn`) ON UPDATE CASCADE;

ALTER TABLE borrowing
  ADD CONSTRAINT status CHECK (status IN ('active', 'delayed', 'returned', 'inactive'));
--
-- Περιορισμοί για πίνακα `goes_to`
--
ALTER TABLE `goes_to`
  ADD CONSTRAINT `goes_to_ibfk_1` FOREIGN KEY (`id`) REFERENCES `user` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `goes_to_ibfk_2` FOREIGN KEY (`name`) REFERENCES `school_unit` (`school_name`) ON UPDATE CASCADE;

--
-- Περιορισμοί για πίνακα `handles`
--
ALTER TABLE `handles`
  ADD CONSTRAINT `handles_ibfk_1` FOREIGN KEY (`id`) REFERENCES `user` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `handles_ibfk_2` FOREIGN KEY (`school_name`) REFERENCES `school_unit` (`school_name`) ON UPDATE CASCADE;

--
-- Περιορισμοί για πίνακα `manages`
--
ALTER TABLE `manages`
  ADD CONSTRAINT `manages_ibfk_1` FOREIGN KEY (`name`) REFERENCES `school_unit` (`school_name`) ON UPDATE CASCADE,
  ADD CONSTRAINT `manages_ibfk_2` FOREIGN KEY (`id`) REFERENCES `user` (`id`) ON UPDATE CASCADE;

--
-- Περιορισμοί για πίνακα `review`
--
ALTER TABLE `review`
  ADD CONSTRAINT `review_ibfk_1` FOREIGN KEY (`id`) REFERENCES `user` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `review_ibfk_2` FOREIGN KEY (`isbn`) REFERENCES `books` (`isbn`);
  
ALTER TABLE review
  ADD CONSTRAINT likert_scale_constraint CHECK (likert_scale >= 0 and likert_scale <= 5),
  ADD CONSTRAINT check_review_status CHECK (review_status in ('approved', 'inapproved'));
  
--
-- Περιορισμοι για πινακα 'school_unit'
--
ALTER TABLE school_unit
  ADD CONSTRAINT sch_ph_number_length CHECK (LENGTH(ph_nmbr) = 10);

--
--Περιορισμοι για πινακα 'user'
--
ALTER TABLE user
  ADD CONSTRAINT ph_number_length CHECK (LENGTH(ph_nmbr) = 10),
  ADD CONSTRAINT positive_number_of_books CHECK (nmbr_of_books >= 0),
  ADD CONSTRAINT positive_age CHECK (age >= 0),
  ADD CONSTRAINT role_id_constraint CHECK (number >= 0 AND number <= 4),
  ADD CONSTRAINT check_approved_status CHECK (approved_status IS NULL OR approved_status IN ('active', 'inactive'));
  
DELIMITER $$
--
-- Συμβάντα
--
CREATE DEFINER=`root`@`localhost` EVENT `check_delayed_borrowings` ON SCHEDULE EVERY 1 DAY STARTS '2023-05-25 17:49:00' ON COMPLETION NOT PRESERVE ENABLE DO UPDATE borrowing
        SET status = 'delayed'
        WHERE status = 'active' AND borrowing_date < DATE_SUB(NOW(), INTERVAL 7 DAY)$$

CREATE DEFINER=`root`@`localhost` EVENT `delete_old_bookings` ON SCHEDULE EVERY 1 DAY STARTS '2023-05-25 17:49:00' ON COMPLETION NOT PRESERVE ENABLE DO DELETE FROM booking
    WHERE booking_date < DATE_SUB(NOW(), INTERVAL 7 DAY)$$

CREATE DEFINER=`root`@`localhost` EVENT `update_user_weekly_borrowing_count` ON SCHEDULE EVERY 7 DAY STARTS '2023-05-28 00:00:00' ON COMPLETION NOT PRESERVE ENABLE DO UPDATE user
SET weekly_borrowing_count = CASE
    WHEN number = 1 THEN 2
    WHEN number = 2 THEN 1
    ELSE weekly_borrowing_count
END
WHERE number IN (1, 2)$$

CREATE DEFINER=`root`@`localhost` EVENT `update_user_weekly_booking_count` ON SCHEDULE EVERY 7 DAY STARTS '2023-05-28 00:00:00' ON COMPLETION NOT PRESERVE ENABLE DO UPDATE user
SET weekly_booking_count = CASE
    WHEN number = 1 THEN 2
    WHEN number = 2 THEN 1
    ELSE weekly_booking_count
END
WHERE number IN (1, 2)$$

DELIMITER ;
--COMMIT;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
