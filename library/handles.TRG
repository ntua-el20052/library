TYPE=TRIGGERS
triggers='CREATE DEFINER=`root`@`localhost` TRIGGER insert_handles_trigger\nBEFORE INSERT ON handles\nFOR EACH ROW\nBEGIN\n    DECLARE role INT;\n    SELECT role_id INTO role FROM users WHERE user_id = NEW.user_id;\n    IF role = 3 THEN\n        INSERT INTO handles (handle_id, user_id, school_name)\n        VALUES (NEW.handle_id, NEW.user_id, NEW.school_name);\n    END IF;\nEND'
sql_modes=1098907648
definers='root@localhost'
client_cs_names='latin1'
connection_cl_names='latin1_swedish_ci'
db_cl_names='utf8mb4_general_ci'
created=1684328414303811
