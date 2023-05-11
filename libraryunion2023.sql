-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 11, 2023 at 11:02 PM
-- Server version: 10.4.27-MariaDB
-- PHP Version: 8.2.0

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `libraryunion2023`
--

-- --------------------------------------------------------

--
-- Table structure for table `belongs to`
--

CREATE TABLE `belongs to` (
  `School Name` varchar(255) NOT NULL,
  `ISBN` bigint(255) NOT NULL,
  `Copies of Particular Book` int(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `books`
--

CREATE TABLE `books` (
  `Title` text NOT NULL,
  `ISBN` int(20) NOT NULL,
  `Publishers` text NOT NULL,
  `Writers` text NOT NULL,
  `Pages` int(255) NOT NULL,
  `Summary` text NOT NULL,
  `Available Copies` int(200) NOT NULL,
  `Cover` int(100) NOT NULL,
  `Category` varchar(150) NOT NULL,
  `Language` varchar(100) NOT NULL,
  `Key Words` text DEFAULT NULL,
  `School Name` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `exists in`
--

CREATE TABLE `exists in` (
  `School Name` varchar(255) NOT NULL,
  `ID` bigint(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `library  manager`
--

CREATE TABLE `library  manager` (
  `ID` int(11) NOT NULL,
  `Name` text NOT NULL,
  `E-mail` varchar(100) NOT NULL,
  `Phone` int(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `manages`
--

CREATE TABLE `manages` (
  `School Name` varchar(100) NOT NULL,
  `Manager ID` bigint(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `schools`
--

CREATE TABLE `schools` (
  `Address` mediumtext DEFAULT NULL,
  `City` varchar(100) DEFAULT NULL,
  `Phone` bigint(255) DEFAULT NULL,
  `E-mail` longtext DEFAULT NULL,
  `Head Teacher` text DEFAULT NULL,
  `Name` varchar(100) NOT NULL,
  `Lib Manager` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `ID` int(255) NOT NULL,
  `Name` varchar(255) DEFAULT NULL,
  `Phone` bigint(255) DEFAULT NULL,
  `E-mail` text DEFAULT NULL,
  `Number of Books borrowed` int(255) DEFAULT NULL,
  `Number of Books held` int(255) DEFAULT NULL,
  `Hours` int(255) DEFAULT NULL,
  `User Identifier` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `books`
--
ALTER TABLE `books`
  ADD PRIMARY KEY (`ISBN`),
  ADD KEY `Test` (`School Name`);

--
-- Indexes for table `library  manager`
--
ALTER TABLE `library  manager`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `schools`
--
ALTER TABLE `schools`
  ADD PRIMARY KEY (`Name`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`ID`);

--
-- Constraints for dumped tables
--

--
-- Constraints for table `books`
--
ALTER TABLE `books`
  ADD CONSTRAINT `Test` FOREIGN KEY (`School Name`) REFERENCES `schools` (`Name`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
