-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Εξυπηρετητής: 127.0.0.1
-- Χρόνος δημιουργίας: 29 Μάη 2023 στις 13:33:47
-- Έκδοση διακομιστή: 10.4.27-MariaDB
-- Έκδοση PHP: 8.2.0

--SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
--START TRANSACTION;
--SET time_zone = "+00:00";

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

DROP SCHEMA IF EXISTS library_github_new_7;
CREATE SCHEMA library_github_new_7;
USE library_github_new_7;


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
-- Άδειασμα δεδομένων του πίνακα `belongs_to`
--

INSERT INTO `belongs_to` (`blng_to_id`, `name`, `isbn`, `nmbr_of_copies_per_school`) VALUES
(1, '2o pefkis', '1111111111111', 2),
(2, '5o hrakleiou', '1111111111111', 3),
(3, '5o hrakleiou', '2222222222222', 1),
(4, '2o pefkis', '0000000000000', 0);

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
    ELSEIF copies = 0 THEN
        UPDATE user 
        SET weekly_booking_count = weekly_booking_count + 1
        WHERE id = OLD.id;
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
    IF role = 4 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You cannot book a book as a manager';
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
    ELSEIF (role = 1 AND booking_count <=0) OR (role = 2 AND booking_count <= 0) OR (role = 3 AND booking_count <=0) THEN
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
  `summary` varchar(200) NOT NULL,
  `nmbr_of_copies` int(11) NOT NULL,
  `image` varchar(500) NOT NULL,
  `language` varchar(45) NOT NULL
) ;

--
-- Άδειασμα δεδομένων του πίνακα `books`
--

INSERT INTO `books` (`isbn`, `title`, `publisher`, `pages`, `summary`, `nmbr_of_copies`, `image`, `language`) VALUES
('0000000000000', 'To Kill a Mockingbird', 'Harper Perennial Modern Classics', 324, 'he 1930s in the fictional town of Maycomb, Alabama, it follows the story of Scout Finch as she navigates issues of racial inequality, injustice, and morality. Through the perspective of Scout, the nov', 0, '[Image URL or file path]', 'English'),
('1111111111111', 'The Great Gatsby', 'Scribner', 218, 'hello', 5, '[Image URL or file path]', 'English'),
('2222222222222', 'programming in unix', 'kleidarithmos', 768, 'programming on unix', 1, 'link', 'greek');

-- --------------------------------------------------------

--
-- Δομή πίνακα για τον πίνακα `book_author`
--

CREATE TABLE `book_author` (
  `book_author_id` int(11) NOT NULL,
  `isbn` varchar(13) NOT NULL,
  `author_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Δομή πίνακα για τον πίνακα `book_genre`
--

CREATE TABLE `book_genre` (
  `book_genre_id` int(11) NOT NULL,
  `isbn` varchar(13) NOT NULL,
  `genre_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Δομή πίνακα για τον πίνακα `book_key_words`
--

CREATE TABLE `book_key_words` (
  `book_key_word_id` int(11) NOT NULL,
  `isbn` varchar(13) NOT NULL,
  `key_word_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Άδειασμα δεδομένων του πίνακα `book_key_words`
--

INSERT INTO `book_key_words` (`book_key_word_id`, `isbn`, `key_word_id`) VALUES
(1, '0000000000000', 2),
(2, '0000000000000', 1),
(3, '1111111111111', 2);

-- --------------------------------------------------------

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
-- Άδειασμα δεδομένων του πίνακα `borrowing`
--

INSERT INTO `borrowing` (`borrowing_id`, `id`, `isbn`, `borrowing_date`, `status`) VALUES
(99, 981, '1111111111111', '2023-05-29', 'active');

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
        WHERE id = NEW.id AND isbn = NEW.isbn
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You have already borrowed this book.';
        END IF;
      
    IF situationship = 'delayed' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You cannot borrow a book because you havent returned a book in time.';
    END IF;
    
    IF copies IS NULL THEN 
     SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You cannot borrow a book from different school unit.';
     END IF;
    
    
    IF copies <= 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'There is not any copies available in your school unit, please book the book.';
     ELSEIF role = 4 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You cannot borrow a book as a manager';
    
    ELSEIF (role = 1 AND bor_books <= 0) OR (role = 2 AND bor_books <= 0) OR (role = 3 AND bor_books <= 0) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You cannot borrow more books.';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `increase_copies` AFTER UPDATE ON `borrowing` FOR EACH ROW BEGIN
DECLARE handler INT;
    
    SET handler = (SELECT id
    FROM handles
    WHERE school_name = (SELECT name FROM goes_to WHERE id = NEW.id));
    
    IF NEW.status = 'active' THEN    
        UPDATE handles
        SET borrowings_approved = borrowings_approved + 1
        WHERE id = handler;
        
         UPDATE user 
         SET weekly_borrowing_count = weekly_borrowing_count-1
         WHERE id = NEW.id;
         UPDATE books
         SET nmbr_of_copies = nmbr_of_copies - 1
         WHERE isbn = NEW.isbn;
         UPDATE belongs_to
         SET nmbr_of_copies_per_school = nmbr_of_copies_per_school - 1
         WHERE (isbn = NEW.isbn) AND (name = (SELECT name FROM goes_to WHERE id = NEW.id));
         UPDATE user
         SET nmbr_of_books = nmbr_of_books + 1
         WHERE id = NEW.id;
    END IF;
    IF NEW.status = 'returned' AND OLD.status <> 'returned'       THEN
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
-- Άδειασμα δεδομένων του πίνακα `goes_to`
--

INSERT INTO `goes_to` (`goes_to_id`, `id`, `name`) VALUES
(1, 981, '2o pefkis'),
(2, 980, '5o hrakleiou');

-- --------------------------------------------------------

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
-- Άδειασμα δεδομένων του πίνακα `handles`
--

INSERT INTO `handles` (`handle_id`, `id`, `school_name`, `borrowings_approved`) VALUES
(654, 456, '2o pefkis', 1),
(655, 690, '5o hrakleiou', 1);

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
-- Άδειασμα δεδομένων του πίνακα `key_word`
--

INSERT INTO `key_word` (`key_word_id`, `key_word`) VALUES
(2, 'crime'),
(1, 'romance');

-- --------------------------------------------------------

--
-- Δομή πίνακα για τον πίνακα `manages`
--

CREATE TABLE `manages` (
  `manages_id` int(11) NOT NULL,
  `name` varchar(45) NOT NULL,
  `id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Άδειασμα δεδομένων του πίνακα `manages`
--

INSERT INTO `manages` (`manages_id`, `name`, `id`) VALUES
(1, '2o pefkis', 799);

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
  `review_status` varchar(25) NOT NULL
) ;

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
-- Άδειασμα δεδομένων του πίνακα `school_unit`
--

INSERT INTO `school_unit` (`school_name`, `city`, `ph_nmbr`, `mail`, `addr_code`, `address`, `dir_name`) VALUES
('2o pefkis', 'pefki', '2102856010', '2opefkis@hotmail.com', 14122, 'xiou 15', 'kostas pap'),
('5o hrakleiou', 'hrakleio attikis', '2102856321', '5oirakliou@gmail.com', 14122, 'plapouta 69', 'dhmhtris papaioannou');

-- --------------------------------------------------------

--
-- Δομή πίνακα για τον πίνακα `user`
--

CREATE TABLE `user` (
  `id` int(11) NOT NULL,
  `password` varchar(25) NOT NULL,
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
-- Άδειασμα δεδομένων του πίνακα `user`
--

INSERT INTO `user` (`id`, `password`, `name`, `age`, `ph_nmbr`, `mail`, `nmbr_of_books`, `number`, `approved_status`, `weekly_borrowing_count`, `weekly_booking_count`) VALUES
(52, '', 'pavlos skou', 45, '6947177115', 'pavlos.skou@gmail.com', 1, 1, NULL, 2, 2),
(100, '', 'el pap', 35, '6947854313', 'elpap@gmail.com', 0, 2, NULL, 1, 1),
(123, '', 'john pap', 15, '2102856010', 'johnpap@gmail.com', 0, 1, NULL, 2, 2),
(456, '', 'jim pap', 55, '2102838310', 'jimpap@gmail.com', 2, 3, NULL, 1, 1),
(690, '', 'kostas spil', 50, '6954312560', 'kostasspil@gmail.com', 0, 3, NULL, 1, 1),
(799, '', 'Iris pal', 65, '6985687212', 'irispal@gmail.com', 0, 4, NULL, 0, 0),
(980, '', 'areti mei', 14, '6976542313', 'aretimei@gmail.com', 4, 1, NULL, 2, 2),
(981, '', 'Dhm seferiadi', 34, '6984315621', 'dhm.seferiadi@gmail.com', 4, 1, NULL, 0, 2),
(982, '', 'ioanna siakka', 28, '6954321465', 'ioannasiakka@gmail.com', 0, 2, NULL, 1, 1);

--
-- Ευρετήρια για άχρηστους πίνακες
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
  MODIFY `author_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT για πίνακα `belongs_to`
--
ALTER TABLE `belongs_to`
  MODIFY `blng_to_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT για πίνακα `booking`
--
ALTER TABLE `booking`
  MODIFY `booking_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=30;

--
-- AUTO_INCREMENT για πίνακα `book_author`
--
ALTER TABLE `book_author`
  MODIFY `book_author_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT για πίνακα `book_genre`
--
ALTER TABLE `book_genre`
  MODIFY `book_genre_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT για πίνακα `book_key_words`
--
ALTER TABLE `book_key_words`
  MODIFY `book_key_word_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT για πίνακα `borrowing`
--
ALTER TABLE `borrowing`
  MODIFY `borrowing_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT για πίνακα `genres`
--
ALTER TABLE `genres`
  MODIFY `genre_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT για πίνακα `goes_to`
--
ALTER TABLE `goes_to`
  MODIFY `goes_to_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT για πίνακα `handles`
--
ALTER TABLE `handles`
  MODIFY `handle_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=656;

--
-- AUTO_INCREMENT για πίνακα `key_word`
--
ALTER TABLE `key_word`
  MODIFY `key_word_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

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

--
-- Περιορισμοί για πίνακα `booking`
--
ALTER TABLE `booking`
  ADD CONSTRAINT `booking_ibfk_1` FOREIGN KEY (`id`) REFERENCES `user` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `booking_ibfk_2` FOREIGN KEY (`isbn`) REFERENCES `books` (`isbn`) ON UPDATE CASCADE;

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
    WHEN number = 2 OR number = 3 THEN 1
    ELSE weekly_borrowing_count
END
WHERE number IN (1, 2, 3)$$

CREATE DEFINER=`root`@`localhost` EVENT `update_user_weekly_booking_count` ON SCHEDULE EVERY 7 DAY STARTS '2023-05-28 00:00:00' ON COMPLETION NOT PRESERVE ENABLE DO UPDATE user
SET weekly_booking_count = CASE
    WHEN number = 1 THEN 2
    WHEN number = 2 OR number = 3 THEN 1
    ELSE weekly_booking_count
END
WHERE number IN (1, 2, 3)$$

DELIMITER ;
--COMMIT;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
