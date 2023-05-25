TYPE=TRIGGERS
triggers='CREATE DEFINER=`root`@`localhost` TRIGGER `insert_borrowing_trigger` BEFORE INSERT ON `borrowing` FOR EACH ROW BEGIN\n    DECLARE copies INT;\n    DECLARE role_id INT;\n    DECLARE bor_books INT;\n    \n    SET copies = (SELECT nmbr_of_copies FROM books WHERE isbn = NEW.isbn);\n    SET role_id = (SELECT role_id FROM users WHERE user_id = NEW.user_id);\n    SET bor_books = (SELECT COUNT(*) FROM borrowing WHERE user_id = NEW.user_id);\n    \n    IF copies <= 0 THEN\n    SIGNAL SQLSTATE \'45000\' SET MESSAGE_TEXT = \'There is not any copies available, please book the book.\';\n    \n    ELSEIF (role_id = 1 AND bor_books >= 2) OR (role_id = 2 AND bor_books >= 1) OR (role_id = 3 AND bor_books >= 1) THEN\n        SIGNAL SQLSTATE \'45000\' SET MESSAGE_TEXT = \'You cannot borrow more books.\';\n    END IF;\nEND' 'CREATE DEFINER=`root`@`localhost` TRIGGER `increase_books_trigger` AFTER INSERT ON `borrowing` FOR EACH ROW BEGIN\n DECLARE copies INT;\n    \n    UPDATE users\n    SET nmbr_of_books = nmbr_of_books + 1\n    WHERE user_id = NEW.user_id;\n    \n    UPDATE books\n    SET nmbr_of_copies = nmbr_of_copies - 1\n   	WHERE isbn = NEW.isbn;\nEND'
sql_modes=1098907648 1098907648
definers='root@localhost' 'root@localhost'
client_cs_names='utf8mb4' 'utf8mb4'
connection_cl_names='utf8mb4_unicode_ci' 'utf8mb4_unicode_ci'
db_cl_names='utf8mb4_general_ci' 'utf8mb4_general_ci'
created=1685016981896883 1685017023323323
