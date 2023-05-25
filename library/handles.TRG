TYPE=TRIGGERS
triggers='CREATE DEFINER=`root`@`localhost` TRIGGER `insert_handles_trigger` BEFORE INSERT ON `handles` FOR EACH ROW BEGIN\n    DECLARE role INT;\n    SELECT role_id INTO role FROM user WHERE id = NEW.id;\n    IF role <> 3 THEN\n        SIGNAL SQLSTATE \'45000\' SET MESSAGE_TEXT = \'Only users with role_id = 3 are allowed.\';\n    END IF;\nEND'
sql_modes=1098907648
definers='root@localhost'
client_cs_names='utf8mb4'
connection_cl_names='utf8mb4_unicode_ci'
db_cl_names='utf8mb4_general_ci'
created=1685043179526661
