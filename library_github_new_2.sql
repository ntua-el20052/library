-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Εξυπηρετητής: 127.0.0.1
-- Χρόνος δημιουργίας: 26 Μάη 2023 στις 08:03:09
-- Έκδοση διακομιστή: 10.4.27-MariaDB
-- Έκδοση PHP: 8.2.0

--SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
--START TRANSACTION;
--SET time_zone = "+00:00";
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

DROP SCHEMA IF EXISTS library_github_new_2;
CREATE SCHEMA library_github_new_2;
USE library_github_new_2;


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Βάση δεδομένων: `library`
--

-- --------------------------------------------------------

--
-- Δομή πίνακα για τον πίνακα `belongs_to`
--

CREATE TABLE `belongs_to` (
  `blng_to_id` int(11) NOT NULL,
  `name` varchar(45) NOT NULL,
  `isbn` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Δομή πίνακα για τον πίνακα `booking`
--

CREATE TABLE `booking` (
  `booking_id` int(11) NOT NULL,
  `id` int(11) NOT NULL,
  `isbn` bigint(20) NOT NULL,
  `booking_date` date NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Δείκτες `booking`
--
DELIMITER $$
CREATE TRIGGER `check_booking_limit_trigger` BEFORE INSERT ON `booking` FOR EACH ROW BEGIN
    DECLARE role INT;
    DECLARE borrow_count INT;
    DECLARE booking_count INT;
    DECLARE books_count INT;
    DECLARE situationship VARCHAR(25);
    
    SELECT status INTO situationship
    FROM borrowing
    WHERE id=NEW.id AND status = 'delayed'
    LIMIT 1;
    
    SELECT role_id, nmbr_of_books INTO role, borrow_count
    FROM user
    WHERE id = NEW.id;
    
    SELECT nmbr_of_copies INTO books_count
    FROM books
    WHERE isbn=NEW.isbn;
     
    SELECT COUNT(*) INTO booking_count
    FROM booking
    WHERE id = NEW.id;
    
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
    ELSEIF books_count > 0
    THEN 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'There is a copy of this book available.';
    
    ELSEIF (role = 1 AND borrow_count >= 2) OR (role = 2 AND borrow_count >= 1) OR (role = 3 AND borrow_count>=1) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You have reached the maximum booking limit.';
    
 
    
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Δομή πίνακα για τον πίνακα `books`
--

CREATE TABLE `books` (
  `isbn` bigint(20) NOT NULL,
  `title` varchar(45) NOT NULL,
  `publisher` varchar(45) NOT NULL,
  `author` varchar(45) NOT NULL,
  `pages` int(11) NOT NULL,
  `summary` varchar(200) NOT NULL,
  `nmbr_of_copies` int(11) NOT NULL,
  `image` varchar(45) NOT NULL,
  `gender` varchar(45) NOT NULL,
  `language` varchar(45) NOT NULL,
  `key_words` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Άδειασμα δεδομένων του πίνακα `books`
--

INSERT INTO `books` (`isbn`, `title`, `publisher`, `author`, `pages`, `summary`, `nmbr_of_copies`, `image`, `gender`, `language`, `key_words`) VALUES
(0, 'To Kill a Mockingbird', 'Harper Perennial Modern Classics', 'Harper Lee', 324, 'he 1930s in the fictional town of Maycomb, Alabama, it follows the story of Scout Finch as she navigates issues of racial inequality, injustice, and morality. Through the perspective of Scout, the nov', 0, '[Image URL or file path]', 'Fiction, Coming-of-age', 'English', 'Racism, Injustice, Morality, Compassion, Empathy, Innocence'),
(1111, 'The Great Gatsby', 'Scribner', 'F. Scott Fitzgerald', 218, 'hello', 8, '[Image URL or file path]', 'Fiction', 'English', 'Jazz Age, American Dream, wealth, love, decadence'),
(2222, '', '', '', 0, '', 0, '', '', '', '');

-- --------------------------------------------------------

--
-- Δομή πίνακα για τον πίνακα `borrowing`
--

CREATE TABLE `borrowing` (
  `borrowing_id` int(11) NOT NULL,
  `id` int(11) NOT NULL,
  `isbn` bigint(20) NOT NULL,
  `borrowing_date` date NOT NULL DEFAULT current_timestamp(),
  `status` varchar(25) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Άδειασμα δεδομένων του πίνακα `borrowing`
--

INSERT INTO `borrowing` (`borrowing_id`, `id`, `isbn`, `borrowing_date`, `status`) VALUES
(82, 52, 1111, '2023-05-18', 'returned');

--
-- Δείκτες `borrowing`
--
DELIMITER $$
CREATE TRIGGER `increase_books_trigger` AFTER INSERT ON `borrowing` FOR EACH ROW BEGIN
 DECLARE copies INT;
    
    UPDATE user
    SET nmbr_of_books = nmbr_of_books + 1
    WHERE id = NEW.id;
    
    UPDATE books
    SET nmbr_of_copies = nmbr_of_copies - 1
   	WHERE isbn = NEW.isbn;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `increase_copies` AFTER UPDATE ON `borrowing` FOR EACH ROW BEGIN
    IF NEW.status = 'returned' AND OLD.status <> 'returned' THEN
        UPDATE books SET nmbr_of_copies = nmbr_of_copies + 1 WHERE isbn = NEW.isbn;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `insert_borrowing_trigger` BEFORE INSERT ON `borrowing` FOR EACH ROW BEGIN
    DECLARE copies INT;
    DECLARE role INT;
    DECLARE bor_books INT;
    
    SET copies = (SELECT nmbr_of_copies FROM books WHERE isbn = NEW.isbn);
    SET role = (SELECT role_id FROM user WHERE id = NEW.id);
    SET bor_books = (SELECT COUNT(*) FROM borrowing WHERE id = NEW.id);
    
    IF copies <= 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'There is not any copies available, please book the book.';
     ELSEIF role = 4 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You cannot borrow a book as a manager';
    
    ELSEIF (role = 1 AND bor_books >= 2) OR (role = 2 AND bor_books >= 1) OR (role = 3 AND bor_books >= 1) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You cannot borrow more books.';
    END IF;
END
$$
DELIMITER ;

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
(1, 981, '2o pefkis');

-- --------------------------------------------------------

--
-- Δομή πίνακα για τον πίνακα `handles`
--

CREATE TABLE `handles` (
  `handle_id` int(11) NOT NULL,
  `id` int(11) NOT NULL,
  `school_name` varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Άδειασμα δεδομένων του πίνακα `handles`
--

INSERT INTO `handles` (`handle_id`, `id`, `school_name`) VALUES
(654, 456, '2o pefkis');

--
-- Δείκτες `handles`
--
DELIMITER $$
CREATE TRIGGER `insert_handles_trigger` BEFORE INSERT ON `handles` FOR EACH ROW BEGIN
    DECLARE role INT;
    SELECT role_id INTO role FROM user WHERE id = NEW.id;
    IF role <> 3 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Only users with role_id = 3 are allowed.';
    END IF;
END
$$
DELIMITER ;

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
     SELECT role_id INTO role FROM user WHERE id = NEW.id;
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
  `isbn` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Δομή πίνακα για τον πίνακα `school_unit`
--

CREATE TABLE `school_unit` (
  `school_name` varchar(45) NOT NULL,
  `city` varchar(45) NOT NULL,
  `ph_nmbr` int(11) NOT NULL,
  `mail` varchar(45) NOT NULL,
  `addr_code` smallint(6) NOT NULL,
  `address` varchar(45) NOT NULL,
  `dir_name` varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Άδειασμα δεδομένων του πίνακα `school_unit`
--

INSERT INTO `school_unit` (`school_name`, `city`, `ph_nmbr`, `mail`, `addr_code`, `address`, `dir_name`) VALUES
('2o pefkis', 'pefki', 2102856010, '2opefkis@hotmail.com', 14122, 'xiou 15', 'kostas pap');

-- --------------------------------------------------------

--
-- Δομή πίνακα για τον πίνακα `user`
--

CREATE TABLE `user` (
  `id` int(11) NOT NULL,
  `password` varchar(25) NOT NULL,
  `name` varchar(45) NOT NULL,
  `age` int(11) NOT NULL,
  `ph_nmbr` bigint(11) NOT NULL,
  `mail` varchar(45) NOT NULL,
  `nmbr_of_books` int(11) DEFAULT NULL,
  `role_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Άδειασμα δεδομένων του πίνακα `user`
--

INSERT INTO `user` (`id`, `password`, `name`, `age`, `ph_nmbr`, `mail`, `nmbr_of_books`, `role_id`) VALUES
(52, '', 'pavlos skou', 45, 6947177115, 'pavlos.skou@gmail.com', 1, 2),
(100, '', 'el pap', 35, 6947854313, 'elpap@gmail.com', 0, 2),
(123, '', 'john pap', 15, 2102856010, 'johnpap@gmail.com', 0, 1),
(456, '', 'jim pap', 55, 2102838310, 'jimpap@gmail.com', 0, 3),
(690, '', 'kostas spil', 50, 6954312560, 'kostasspil@gmail.com', 0, 3),
(799, '', 'Iris pal', 65, 6985687212, 'irispal@gmail.com', 0, 4),
(980, '', 'areti mei', 14, 6976542313, 'aretimei@gmail.com', 0, 1),
(981, '', 'Dhm seferiadi', 34, 6984315621, 'dhm.seferiadi@gmail.com', 0, 2);

--
-- Ευρετήρια για άχρηστους πίνακες
--

--
-- Ευρετήρια για πίνακα `belongs_to`
--
ALTER TABLE `belongs_to`
  ADD PRIMARY KEY (`blng_to_id`),
  ADD KEY `name` (`name`),
  ADD KEY `belongs_to_ibfk_2` (`isbn`);

--
-- Ευρετήρια για πίνακα `booking`
--
ALTER TABLE `booking`
  ADD PRIMARY KEY (`booking_id`),
  ADD KEY `isbn` (`isbn`),
  ADD KEY `booking_ibfk_1` (`id`);

--
-- Ευρετήρια για πίνακα `books`
--
ALTER TABLE `books`
  ADD PRIMARY KEY (`isbn`);

--
-- Ευρετήρια για πίνακα `borrowing`
--
ALTER TABLE `borrowing`
  ADD PRIMARY KEY (`borrowing_id`),
  ADD KEY `isbn` (`isbn`),
  ADD KEY `borrowing_ibfk_1` (`id`);

--
-- Ευρετήρια για πίνακα `goes_to`
--
ALTER TABLE `goes_to`
  ADD PRIMARY KEY (`goes_to_id`),
  ADD KEY `name` (`name`),
  ADD KEY `goes_to_ibfk_1` (`id`);

--
-- Ευρετήρια για πίνακα `handles`
--
ALTER TABLE `handles`
  ADD PRIMARY KEY (`handle_id`),
  ADD KEY `school_name` (`school_name`),
  ADD KEY `handles_ibfk_1` (`id`);

--
-- Ευρετήρια για πίνακα `manages`
--
ALTER TABLE `manages`
  ADD PRIMARY KEY (`manages_id`),
  ADD KEY `name` (`name`),
  ADD KEY `manages_ibfk_2` (`id`);

--
-- Ευρετήρια για πίνακα `review`
--
ALTER TABLE `review`
  ADD PRIMARY KEY (`review_id`),
  ADD KEY `isbn` (`isbn`),
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
-- AUTO_INCREMENT για πίνακα `belongs_to`
--
ALTER TABLE `belongs_to`
  MODIFY `blng_to_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT για πίνακα `booking`
--
ALTER TABLE `booking`
  MODIFY `booking_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT για πίνακα `borrowing`
--
ALTER TABLE `borrowing`
  MODIFY `borrowing_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=84;

--
-- AUTO_INCREMENT για πίνακα `goes_to`
--
ALTER TABLE `goes_to`
  MODIFY `goes_to_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT για πίνακα `handles`
--
ALTER TABLE `handles`
  MODIFY `handle_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=655;

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=982;

--
-- Περιορισμοί για άχρηστους πίνακες
--

--
-- Περιορισμοί για πίνακα `belongs_to`
--
ALTER TABLE `belongs_to`
  ADD CONSTRAINT `belongs_to_ibfk_1` FOREIGN KEY (`name`) REFERENCES `school_unit` (`school_name`),
  ADD CONSTRAINT `belongs_to_ibfk_2` FOREIGN KEY (`isbn`) REFERENCES `books` (`isbn`);

--
-- Περιορισμοί για πίνακα `booking`
--
ALTER TABLE `booking`
  ADD CONSTRAINT `booking_ibfk_1` FOREIGN KEY (`id`) REFERENCES `user` (`id`),
  ADD CONSTRAINT `booking_ibfk_2` FOREIGN KEY (`isbn`) REFERENCES `books` (`isbn`);

--
-- Περιορισμοί για πίνακα `borrowing`
--
ALTER TABLE `borrowing`
  ADD CONSTRAINT `borrowing_ibfk_1` FOREIGN KEY (`id`) REFERENCES `user` (`id`),
  ADD CONSTRAINT `borrowing_ibfk_2` FOREIGN KEY (`isbn`) REFERENCES `books` (`isbn`);

--
-- Περιορισμοί για πίνακα `goes_to`
--
ALTER TABLE `goes_to`
  ADD CONSTRAINT `goes_to_ibfk_1` FOREIGN KEY (`id`) REFERENCES `user` (`id`),
  ADD CONSTRAINT `goes_to_ibfk_2` FOREIGN KEY (`name`) REFERENCES `school_unit` (`school_name`);

--
-- Περιορισμοί για πίνακα `handles`
--
ALTER TABLE `handles`
  ADD CONSTRAINT `handles_ibfk_1` FOREIGN KEY (`id`) REFERENCES `user` (`id`),
  ADD CONSTRAINT `handles_ibfk_2` FOREIGN KEY (`school_name`) REFERENCES `school_unit` (`school_name`);

--
-- Περιορισμοί για πίνακα `manages`
--
ALTER TABLE `manages`
  ADD CONSTRAINT `manages_ibfk_1` FOREIGN KEY (`name`) REFERENCES `school_unit` (`school_name`),
  ADD CONSTRAINT `manages_ibfk_2` FOREIGN KEY (`id`) REFERENCES `user` (`id`);

--
-- Περιορισμοί για πίνακα `review`
--
ALTER TABLE `review`
  ADD CONSTRAINT `review_ibfk_1` FOREIGN KEY (`id`) REFERENCES `user` (`id`),
  ADD CONSTRAINT `review_ibfk_2` FOREIGN KEY (`isbn`) REFERENCES `books` (`isbn`);

DELIMITER $$
--
-- Συμβάντα
--
CREATE DEFINER=`root`@`localhost` EVENT `check_delayed_borrowings` ON SCHEDULE EVERY 1 DAY STARTS '2023-05-25 17:49:00' ON COMPLETION NOT PRESERVE ENABLE DO UPDATE borrowing
        SET status = 'delayed'
        WHERE status = 'active' AND borrowing_date < DATE_SUB(NOW(), INTERVAL 7 DAY)$$

CREATE DEFINER=`root`@`localhost` EVENT `.delete_old_bookings` ON SCHEDULE EVERY 1 DAY STARTS '2023-05-25 17:49:00' ON COMPLETION NOT PRESERVE ENABLE DO DELETE FROM booking
    WHERE booking_date < DATE_SUB(NOW(), INTERVAL 7 DAY)$$

DELIMITER ;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
