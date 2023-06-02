# Library Databases

Project for the Databases 2023 class of 2nd semester in NTUA ECE. It simulates a Database for a Library that consists of different schools, LibraryDB.

## Authors
- Konstantinos Spiliotopoulos, 03120881
- Skourtis Pavlos, 03120052
- Mei Areti, 03120062

## E-R Diagram

![E-R Diagram](link_to_er_diagram_image)

## Relational Model
Σχεδιακο_Διαγραμμα.pdf

## Guide for Installation

### Steps
1. First, you need to clone the git repo using the command: 
`git clone https://github.com/pavlosskourtis/library`
into a local directory.

2. Install the requirements by running the following command in the same working directory where you saved the repository:
- `pip install -r requirements.txt`

3. Create the database using MySQL/MariaDB and execute the following commands:
- `mysql -u root -p`
- `source library_create_schema.sql`
- `source library_insert_data.sql`

4. Run the application using Python:
- `python app.py`
or
- `python 3 app.py`
depending on the version of Python installed on your machine.

## Requirements

The `requirements.txt` file:

- click==8.1.2
- dnspython==2.2.1
- email-validator==1.1.3
- Faker==13.3.4
- Flask==2.1.1
- Flask-MySQLdb==1.0.1
- Flask-WTF==1.0.1
- idna==3.3
- importlib-metadata==4.11.3
- itsdangerous==2.1.2
- Jinja2==3.1.1
- MarkupSafe==2.1.1
- mysqlclient==2.1.0
- python-dateutil==2.8.2
- six==1.16.0
- Werkzeug==2.1.1
- WTForms==3.0.1
- zipp==3.8.0

