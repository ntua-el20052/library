# library
databases

Project for the Databases 2023 class in NTUA ECE that simulates a Database for a union of libraries of different schools, LibraryDB.
Authors:
Konstantinos Spiliotopoulos, 03120881
Skourtis Pavlos, 03120052
Mei Areti, 03120062

E-R Diagram

Relational Model

Guide for Installation:Steps
First you need to clone the git repo using the command 
git clone https://github.com/… into a local directory.
Then, you need to install the requirements.txt text, using the command git install requirements.txt. Make sure that you make the installation in the same working directory that you saved the repository above in.
After that you need to create the database using MySQL/Maria DB and running the commands :
mysql -u root -p
source library_create_schema.sql
source library_insert_data.sql
Run python app.py or python 3 app.py , acoording to the version pf python your machine runs, and you are ready to go!

Requirements
The requirements.txt:
click==8.1.2
dnspython==2.2.1
email-validator==1.1.3
Faker==13.3.4
Flask==2.1.1
Flask-MySQLdb==1.0.1
Flask-WTF==1.0.1
idna==3.3
importlib-metadata==4.11.3
itsdangerous==2.1.2
Jinja2==3.1.1
MarkupSafe==2.1.1
mysqlclient==2.1.0
python-dateutil==2.8.2
six==1.16.0
Werkzeug==2.1.1
WTForms==3.0.1
zipp==3.8.0



Usage
Via the UI that we developed, the user, according to whether he has as simple user’s authorization(as teacher or student), an operator’s authorization or the Library Manager’s authorization, he can access different pages  and take information from queries about the library. All of these abilities are provided by the FlashWTForms of the UI.

For manual Backup:You need to access through your terminal the directory ‘C:\xampp\mysql\bin’ and run the command:
mysqldump --databases library_final -u root -p > path\to\backup_file

For manual Restore:You need to access through your terminal the directory ‘C:\xampp\mysql\bin’
Once you're in the bin directory, run the following command to start the MySQL command-line tool:
mysql -u root -p
This will prompt you to enter the password for the MySQL root user. Enter the password and press Enter.
Finally, you can run the source command to execute the SQL statements from the backup file.
SOURCE path\to\backup_file
