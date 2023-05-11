-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Εξυπηρετητής: 127.0.0.1
-- Χρόνος δημιουργίας: 11 Μάη 2023 στις 21:18:48
-- Έκδοση διακομιστή: 10.4.27-MariaDB
-- Έκδοση PHP: 8.2.0

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


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
  `user_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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

-- --------------------------------------------------------

--
-- Δομή πίνακα για τον πίνακα `goes_to`
--

CREATE TABLE `goes_to` (
  `goes_to_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `name` varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Δομή πίνακα για τον πίνακα `manager`
--

CREATE TABLE `manager` (
  `man_id` int(11) NOT NULL,
  `name` varchar(45) NOT NULL,
  `mail` varchar(45) DEFAULT NULL,
  `ph_nmbr` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Δομή πίνακα για τον πίνακα `manages`
--

CREATE TABLE `manages` (
  `manages_id` int(11) NOT NULL,
  `name` varchar(45) DEFAULT NULL,
  `man_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Δομή πίνακα για τον πίνακα `review`
--

CREATE TABLE `review` (
  `review_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
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

-- --------------------------------------------------------

--
-- Δομή πίνακα για τον πίνακα `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `name` varchar(45) NOT NULL,
  `ph_nmbr` int(11) NOT NULL,
  `mail` varchar(45) NOT NULL,
  `nmbr_of_books` int(11) DEFAULT NULL,
  `role_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Ευρετήρια για άχρηστους πίνακες
--

--
-- Ευρετήρια για πίνακα `belongs_to`
--
ALTER TABLE `belongs_to`
  ADD PRIMARY KEY (`blng_to_id`),
  ADD KEY `name` (`name`),
  ADD KEY `user_id` (`user_id`);

--
-- Ευρετήρια για πίνακα `books`
--
ALTER TABLE `books`
  ADD PRIMARY KEY (`isbn`);

--
-- Ευρετήρια για πίνακα `goes_to`
--
ALTER TABLE `goes_to`
  ADD PRIMARY KEY (`goes_to_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `name` (`name`);

--
-- Ευρετήρια για πίνακα `manager`
--
ALTER TABLE `manager`
  ADD PRIMARY KEY (`man_id`);

--
-- Ευρετήρια για πίνακα `manages`
--
ALTER TABLE `manages`
  ADD PRIMARY KEY (`manages_id`),
  ADD KEY `name` (`name`),
  ADD KEY `man_id` (`man_id`);

--
-- Ευρετήρια για πίνακα `review`
--
ALTER TABLE `review`
  ADD PRIMARY KEY (`review_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `isbn` (`isbn`);

--
-- Ευρετήρια για πίνακα `school_unit`
--
ALTER TABLE `school_unit`
  ADD PRIMARY KEY (`school_name`);

--
-- Ευρετήρια για πίνακα `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`);

--
-- AUTO_INCREMENT για άχρηστους πίνακες
--

--
-- AUTO_INCREMENT για πίνακα `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Περιορισμοί για άχρηστους πίνακες
--

--
-- Περιορισμοί για πίνακα `belongs_to`
--
ALTER TABLE `belongs_to`
  ADD CONSTRAINT `belongs_to_ibfk_1` FOREIGN KEY (`name`) REFERENCES `school_unit` (`school_name`),
  ADD CONSTRAINT `belongs_to_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Περιορισμοί για πίνακα `goes_to`
--
ALTER TABLE `goes_to`
  ADD CONSTRAINT `goes_to_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `goes_to_ibfk_2` FOREIGN KEY (`name`) REFERENCES `school_unit` (`school_name`);

--
-- Περιορισμοί για πίνακα `manages`
--
ALTER TABLE `manages`
  ADD CONSTRAINT `manages_ibfk_1` FOREIGN KEY (`name`) REFERENCES `school_unit` (`school_name`),
  ADD CONSTRAINT `manages_ibfk_2` FOREIGN KEY (`man_id`) REFERENCES `manager` (`man_id`);

--
-- Περιορισμοί για πίνακα `review`
--
ALTER TABLE `review`
  ADD CONSTRAINT `review_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `review_ibfk_2` FOREIGN KEY (`isbn`) REFERENCES `books` (`isbn`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
