TYPE=TRIGGERS
triggers='CREATE DEFINER=`root`@`localhost` TRIGGER `before_insert_manages` BEFORE INSERT ON `manages` FOR EACH ROW BEGIN\n     DECLARE role INT;\n     SELECT role_id INTO role FROM user WHERE id = NEW.id;\n     IF role <> 4 THEN\n        SIGNAL SQLSTATE \'45000\' SET MESSAGE_TEXT = \'Only users with role_id = 4 are allowed.\';\n    END IF;\nEND'
sql_modes=1098907648
definers='root@localhost'
client_cs_names='utf8mb4'
connection_cl_names='utf8mb4_unicode_ci'
db_cl_names='utf8mb4_general_ci'
created=1685043196321588
