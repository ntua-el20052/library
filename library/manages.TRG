TYPE=TRIGGERS
triggers='CREATE DEFINER=`root`@`localhost` TRIGGER before_insert_manages\nBEFORE INSERT ON manages\nFOR EACH ROW\nBEGIN\n     DECLARE role INT;\n     SELECT role_id INTO role FROM users WHERE user_id = NEW.user_id;\n     IF role <> 4 THEN\n        SIGNAL SQLSTATE \'45000\' SET MESSAGE_TEXT = \'Only users with role_id = 4 are allowed.\';\n    END IF;\nEND'
sql_modes=1098907648
definers='root@localhost'
client_cs_names='latin1'
connection_cl_names='latin1_swedish_ci'
db_cl_names='utf8mb4_general_ci'
created=1685021202962511
