from datetime import datetime, timedelta
from flask import Flask, render_template, request, session, redirect, url_for
from flask_wtf import FlaskForm
from flask_mysqldb import MySQL
import mysql.connector
import datetime
from wtforms import StringField, PasswordField, SubmitField, IntegerField
from wtforms.validators import DataRequired, NumberRange

app = Flask(__name__)
mysql = MySQL(app)

app.config["SECRET_KEY"] = 'eee'
app.config['MYSQL_HOST'] = '127.0.0.1'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_DB'] = 'library_final'
app.config["MYSQL_PASSWORD"] = ''

#HOMEPAGE
@app.route('/')
def home():
    return render_template('homepage.html')

#CREATE AN ACOUNT
class MyForm(FlaskForm):
    name = StringField('Name', validators=[DataRequired()])
    email = StringField('Email', validators=[DataRequired()])
    password = PasswordField('Password', validators=[DataRequired()])
    identifier = StringField('Identifier', validators=[DataRequired()])
    phonenumber = StringField('Phone Number', validators=[DataRequired()])
    age = IntegerField('Age', validators=[DataRequired()])
    submit = SubmitField('Submit')

@app.route('/register', methods=['GET'])
def register_page():
    return render_template('register.html')

@app.route('/register', methods=['POST'])
def register():
        form = MyForm()
        name = form.name.data
        email = form.email.data
        password = form.password.data
        identifier = form.identifier.data
        phonenumber = form.phonenumber.data
        age = form.age.data
        # Perform database operations
        cursor = mysql.connection.cursor()
        if identifier == '2':
            query = "INSERT INTO user(name, mail, password, number, ph_nmbr, age, weekly_borrowing_count, weekly_booking_count ) VALUES(%s, %s, %s, %s, %s, %s, '1', '1')"
            cursor.execute(query, (name, email, password, identifier, phonenumber, age))
            mysql.connection.commit()
            user_id = cursor.lastrowid

            # Store the user ID in the session
            session['user_id'] = user_id
            cursor.close()
        elif identifier == '3':
            query = "INSERT INTO user(name, mail, password, number, approved_status, ph_nmbr, age) VALUES(%s, %s, %s, %s, 'inactive', %s, %s)"
            cursor.execute(query, (name, email, password, identifier, phonenumber, age))
            mysql.connection.commit()
            user_id = cursor.lastrowid

            # Store the user ID in the session
            session['user_id'] = user_id
            cursor.close()
        elif identifier == '4':
            return "Invalid Role_Id"
        else:
            query = "INSERT INTO user(name, mail, password, number, ph_nmbr, age, weekly_borrowing_count, weekly_booking_count) VALUES(%s, %s, %s, %s, %s, %s, '2', '2')"
            cursor.execute(query, (name, email, password, identifier, phonenumber, age))
            mysql.connection.commit()
            user_id = cursor.lastrowid

            # Store the user ID in the session
            session['user_id'] = user_id
            cursor.close()

        return redirect(url_for('register_school'))

#function to retrieve the approved_status
def get_status(id):
    cursor = mysql.connection.cursor()

    # Execute a SELECT query to retrieve the password for the given id
    query = "SELECT approved_status FROM user WHERE id = %s"
    cursor.execute(query, (id,))
    result = cursor.fetchone()
    status = result[0] if result else None
    cursor.close()
    return status

#function to retrieve the password
def get_stored_password(id):

    cursor = mysql.connection.cursor()

    # Execute a SELECT query to retrieve the password for the given id
    query = "SELECT password FROM user WHERE id = %s"
    cursor.execute(query, (id,))
    result = cursor.fetchone()
    stored_password = result[0] if result else None
    cursor.close()
    return stored_password

#function to retrieve the role_id
def get_stored_identifier(id):
    cursor = mysql.connection.cursor()

    # Execute a SELECT query to retrieve the password for the given username
    query = "SELECT number FROM user WHERE id = %s"
    cursor.execute(query, (id,))

    result = cursor.fetchone()
    stored_identifier = result[0] if result else None

    cursor.close()
    return str(stored_identifier)


#LOGIN TO AN ACCOUNT
class LoginForm(FlaskForm):
    id = StringField('ID', validators=[DataRequired()])
    password = PasswordField('Password', validators=[DataRequired()])
    identifier = StringField('Identifier', validators=[DataRequired()])
    submit = SubmitField('Login')


@app.route('/login', methods=['GET'])
def login_page():
    return render_template('login.html')

# Route for processing the login form
@app.route('/login', methods=['POST'])
def login():
    form = LoginForm()
    identifier = request.form.get('identifier')
    id = request.form.get('id')
    entered_password = request.form.get('password')
    stored_password = get_stored_password(id)
    stored_identifier = get_stored_identifier(id)
    app_status = get_status(id)
    if (stored_identifier and stored_password and (stored_password == entered_password) and (identifier == stored_identifier)):
        if identifier == '1' or identifier == '2':
            app_status = get_status(id)
            if app_status == 'active':
               return redirect('/page1')
            else:
                return 'You have not been accepted yet! Try again later'
        elif identifier == '3':
            if app_status == 'active':
                return redirect('/page2')
            else:
                return 'You have not been accepted yet! Try again later'
        elif identifier == '4':
            return redirect('/page3_mod')
        else:
            return 'Invalid identifier'
    else:
        if not stored_password == entered_password:
           return 'Incorrect Password'
        if not identifier == stored_identifier:
            return 'Incorrect identifier'


@app.route('/page1', methods=['GET', 'POST'])
def page_1():
    return render_template('page1.html')

@app.route('/page2', methods=['GET', 'POST'])
def page_2():
    return render_template('page2.html')

@app.route('/page3_mod', methods=['GET', 'POST'])
def page_3():
    return render_template('page3_mod.html')


# Define the add new school form
class AddSchoolForm(FlaskForm):
    name = StringField('Name', validators=[DataRequired()])
    city = StringField('City', validators=[DataRequired()])
    phonenumber = StringField('Phonenumber', validators=[DataRequired()])
    mail = StringField('Email', validators=[DataRequired()])
    addrcode = StringField('Post Code', validators=[DataRequired()])
    address = StringField('Address', validators=[DataRequired()])
    directorname = StringField('Director Name', validators=[DataRequired()])
    submit = SubmitField('Add new School')

# Route for adding a new school
@app.route('/add_new_school', methods=['GET', 'POST'])
def add_new_school():
    form = AddSchoolForm()

    if request.method == 'POST' and form.validate_on_submit():
        name = form.name.data
        city=form.city.data
        phonenumber=form.phonenumber.data
        mail=form.mail.data
        addrcode=form.addrcode.data
        address=form.address.data
        directorname=form.directorname.data

        cursor = mysql.connection.cursor()
        query = "INSERT INTO school_unit(school_name, city, ph_nmbr, mail, addr_code, address, dir_name) VALUES(%s, %s, %s, %s, %s, %s, %s)"
        cursor.execute(query, (name, city, phonenumber, mail, addrcode, address, directorname))
        mysql.connection.commit()

        query = "INSERT INTO manages(name, id) VALUES(%s, 180000000)"
        cursor.execute(query, (name,))
        mysql.connection.commit()

        cursor.close()
        return 'School added successfully'

    return render_template('add_new_school.html', form=form)



# Define the change approval status form
class ChangeApprovalStatusForm(FlaskForm):
    id = StringField('ID', validators=[DataRequired()])
    status = StringField('New Approval Status', validators=[DataRequired()])
    submit = SubmitField('Change Approval Status')

# Route for the change approval status page
@app.route('/change_approval_status', methods=['GET', 'POST'])
def change_approval_status():
    form = ChangeApprovalStatusForm()

    if request.method == 'POST' and form.validate_on_submit():
        id = form.id.data
        status = form.status.data

        cursor = mysql.connection.cursor()

        query = "UPDATE user SET approved_status = %s WHERE id = %s"
        cursor.execute(query, (status, id))
        mysql.connection.commit()

        query = "SELECT id FROM user WHERE id = %s"
        cursor.execute(query, (id,))
        id = cursor.fetchone()
        mysql.connection.commit()

        query = "SELECT number FROM user WHERE id = %s"
        cursor.execute(query, (id,))
        auth = cursor.fetchone()
        mysql.connection.commit()

        cursor.close()

        return "Your card:     ID=" + str(id) +",    Authority=" + str(auth)

    return render_template('change_approval_status.html', form=form)

#CHANGE PASSWORD
# Define the change password form
class ChangePasswordForm(FlaskForm):
    id = StringField('ID', validators=[DataRequired()])
    new_password = PasswordField('New Password', validators=[DataRequired()])
    entered_password = PasswordField('Entered Password', validators=[DataRequired()])
    submit = SubmitField('Change Password')

# Route for the change password page
@app.route('/change_password', methods=['GET', 'POST'])
def change_password():
    form = ChangePasswordForm()

    if request.method == 'POST' and form.validate_on_submit():
        id = form.id.data
        new_password = form.new_password.data
        entered_password = form.entered_password.data
        stored_password = get_stored_password(id)
        if stored_password == entered_password:

         cursor = mysql.connection.cursor()

         query = "UPDATE user SET password = %s WHERE id = %s"
         cursor.execute(query, (new_password, id))
         mysql.connection.commit()
         cursor.close()

         return 'Password updated successfully'
        else:
         return 'Access denied'

    return render_template('change_password.html', form=form)



#SEE INSERTED DATA FOR USER
#CHANGE PERSONAL INFORMATION
# Define the access personal info form
class AccessPersonalDataForm(FlaskForm):
    name = StringField('Name', validators=[DataRequired()])
    password = StringField('Password', validators=[DataRequired()])
    id = StringField('User Id', validators=[DataRequired()])
    submit = SubmitField('Access Personal Data')

# Route for the access personal info page
@app.route('/access_pesonal_data', methods=['GET','POST'])
def access_personal_data():
    form = AccessPersonalDataForm()
    if request.method=='POST' and form.validate_on_submit():
        name = form.name.data
        password = form.password.data
        id = form.id.data
        entered_password = get_stored_password(id)
        if entered_password == password:
           cursor = mysql.connection.cursor()
           query = "SELECT * FROM user WHERE id = %s"
           cursor.execute(query, (id,))
           user_data = cursor.fetchone()
           mysql.connection.commit()
           cursor.close()
           user_id = user_data[0]
           name = user_data[2]
           age = user_data[3]
           ph_nmbr = user_data[4]
           mail = user_data[5]
           nmbr_of_books = user_data[6]

           return render_template('access_personal_data.html', user_id=user_id, name=name, age=age,
                                       ph_nmbr=ph_nmbr, mail=mail, nmbr_of_books=nmbr_of_books)
        else:
           return 'Access Denied'

    return render_template('request_to_access_personal_data.html', form=form)


#CHANGE PERSONAL INFORMATION
# Define the change info form
class ChangePersonalInformationForm(FlaskForm):
    name = StringField('Name', validators=[DataRequired()])
    age = StringField('Age', validators=[DataRequired()])
    phonenumber = StringField('PhoneNumber', validators=[DataRequired()])
    id = StringField('User ID', validators=[DataRequired()])
    mail = StringField('Email', validators=[DataRequired()])
    entered_password = PasswordField('Entered Password', validators=[DataRequired()])
    submit = SubmitField('Change Personal Information')

# Route for the change personal info page
@app.route('/change_personal_information', methods=['GET', 'POST'])
def change_personal_information():
    form = ChangePersonalInformationForm()
    if request.method == 'POST' and form.validate_on_submit():
         name = form.name.data
         age = form.age.data
         id = form.id.data
         phonenumber = form.phonenumber.data
         mail=form.mail.data
         entered_password = form.entered_password.data
         stored_password = get_stored_password(id)
         stored_id = get_stored_identifier(id)
         if stored_id == '1':
             return "Can't Change your Personal Imformation, sorry!:("
         elif stored_password == entered_password:
             cursor = mysql.connection.cursor()
             query = "UPDATE user SET age = %s WHERE id = %s"
             cursor.execute(query, (age, id))
             mysql.connection.commit()

             query = "UPDATE user SET ph_nmbr = %s WHERE id = %s"
             cursor.execute(query, (phonenumber, id))
             mysql.connection.commit()

             query = "UPDATE user SET mail = %s WHERE id = %s"
             cursor.execute(query, (mail, id))
             mysql.connection.commit()

             query = "UPDATE user SET name = %s WHERE id = %s"
             cursor.execute(query, (name, id))
             mysql.connection.commit()
             cursor.close()


             return 'Personal Info changed Successfully!'
         else:
            return 'Access denied'

    return render_template('change_personal_information.html', form=form)



#when registing, we have to connect the user with their school
# Define the SchoolForm
class SchoolForm(FlaskForm):
    school = StringField('School', validators=[DataRequired()])
    submit = SubmitField('Submit')

# Route for capturing school information
@app.route('/register/school', methods=['GET', 'POST'])
def register_school():
    form = SchoolForm()
    if request.method == 'POST' and form.validate_on_submit():
        if 'user_id' in session:
            user_id = session['user_id']
            school = form.school.data
            # Perform database operations to retrieve role_id
            cursor = mysql.connection.cursor()
            query = "SELECT * FROM user WHERE id = %s"

            cursor.execute(query, (user_id,))
            mysql.connection.commit()
            user = cursor.fetchone()
            cursor.close()

            cursor = mysql.connection.cursor()
            if user[7] == 1 or user[7] == 2:
                query = "INSERT INTO goes_to(id, name) VALUES(%s, %s)"
                cursor.execute(query, (user_id, school))

            elif user[7] == 3:
                query = "INSERT INTO handles(id, school_name) VALUES(%s, %s)"
                cursor.execute(query, (user_id, school))


            mysql.connection.commit()
            cursor.close()

        return 'Request submmited!'

    return render_template('register_school.html', form=form)

#BOOK OPERATIONS
#Add a new book
# Define the add book form
class AddNewBookForm(FlaskForm):
    isbn = StringField('ISBN', validators=[DataRequired()])
    title = StringField('Title', validators=[DataRequired()])
    publisher = StringField('Publisher', validators=[DataRequired()])
    author = StringField('Author', validators=[DataRequired()])
    pages = StringField('Number of Pages', validators=[DataRequired()])
    summary = StringField('Summary', validators=[DataRequired()])
    nmbr_of_copies =  StringField('Number of available Copies', validators=[DataRequired()])
    genre = StringField('Genre', validators=[DataRequired()])
    image = StringField('Link for image of the Cover', validators=[DataRequired()])
    language = StringField('Language', validators=[DataRequired()])
    key_words = StringField('Keywords', validators=[DataRequired()])
    school_name = StringField('School', validators=[DataRequired()])
    submit = SubmitField('Add New Book')

# Route for the add new book page
@app.route('/add_new_book', methods=['GET', 'POST'])
def add_new_book():
    form = AddNewBookForm()
    if request.method == 'POST' and form.validate_on_submit():
             isbn = form.isbn.data
             title = form.title.data
             publisher = form.publisher.data
             author = form.author.data
             pages = form.pages.data
             summary=form.summary.data
             nmbr_of_copies=form.nmbr_of_copies.data
             image = form.image.data
             genre=form.genre.data
             language=form.language.data
             name = form.school_name.data
             key_words =form.key_words.data


             cursor = mysql.connection.cursor()
             query = "INSERT INTO books(isbn, title, publisher,pages, summary, nmbr_of_copies,image,  language) VALUES(%s,%s,%s,%s,%s,%s,%s,%s)"
             cursor.execute(query, (isbn, title,publisher,pages,summary,nmbr_of_copies,image,language))
             mysql.connection.commit()

             for gen in genre.split(','):
                 query = "INSERT INTO book_genre(isbn,genre_id) VALUES(%s,%s)"
                 cursor.execute(query, (isbn, gen))
                 mysql.connection.commit()

             for auth in author.split(','):
               query = "INSERT INTO book_author(isbn,author_id) VALUES(%s,%s)"
               cursor.execute(query, (isbn, auth))
               mysql.connection.commit()

             for keyword in key_words.split(','):
                 query = "INSERT INTO book_key_words(isbn,key_word_id) VALUES(%s,%s)"
                 cursor.execute(query, (isbn, keyword))
                 mysql.connection.commit()

             query = "INSERT INTO belongs_to(isbn, name, nmbr_of_copies_per_school) VALUES(%s,%s,%s)"
             cursor.execute(query, (isbn, name, nmbr_of_copies))
             mysql.connection.commit()

             cursor.close()
             return 'Book Added Successfully!'

    return render_template('add_new_book.html', form=form)

#Edit a book's Info
# Define the edit book form
class EditBookInformationForm(FlaskForm):
    isbn = StringField('ISBN', validators=[DataRequired()])
    title = StringField('Title', validators=[DataRequired()])
    publisher = StringField('Publisher', validators=[DataRequired()])
    pages = StringField('Number of Pages', validators=[DataRequired()])
    summary = StringField('Summary', validators=[DataRequired()])
    nmbr_of_copies =  StringField('Number of available Copies', validators=[DataRequired()])
    image = StringField('Image', validators=[DataRequired()])
    language = StringField('Language', validators=[DataRequired()])
    submit = SubmitField('Edit Book Information')

# Route for the edit book page
@app.route('/edit_book_information', methods=['GET', 'POST'])
def edit_book_information():
    form = EditBookInformationForm()
    if request.method == 'POST' and form.validate_on_submit():
             isbn = form.isbn.data
             title = form.title.data
             publisher = form.publisher.data
             pages =form.pages.data
             summary=form.summary.data
             nmbr_of_copies=form.nmbr_of_copies.data
             image = form.image.data
             language=form.language.data

             cursor = mysql.connection.cursor()
             query = "UPDATE books SET title = %s, publisher = %s, pages = %s, summary= %s, nmbr_of_copies = %s, image = %s, language = %s  WHERE isbn = %s"
             cursor.execute(query, (title, publisher, pages , summary, nmbr_of_copies, image, language, isbn))
             mysql.connection.commit()
             cursor.close()

             return 'Book Information Changed Successfully!'

    return render_template('edit_book_information.html', form=form)

#Borrowing a book
class BorrowBookForm(FlaskForm):
    isbn = StringField('ISBN', validators=[DataRequired()])
    id = StringField('User ID', validators=[DataRequired()])
    submit = SubmitField('Borrow Book')

# Route for borrowing a book
@app.route('/borrow_book', methods=['POST','GET'])
def borrow_book():
    form = BorrowBookForm()

    if request.method == 'POST' and form.validate_on_submit():
        isbn = form.isbn.data
        id = form.id.data

        cursor = mysql.connection.cursor()
        query = "INSERT INTO borrowing(isbn, id, status) VALUES(%s, %s, 'inactive')"
        cursor.execute(query, (isbn, id))
        mysql.connection.commit()
        cursor.close()

        return 'Request for borrowing the book was successful!'

    return render_template('borrow_book_form.html', form=form)


#allowing borrowing a book, for operator
class AllowBorrowingForm(FlaskForm):
    isbn = StringField('ISBN', validators=[DataRequired()])
    id = StringField('User ID', validators=[DataRequired()])
    submit = SubmitField('Borrow Book')

# Route for allowing borrowing a book
@app.route('/allow_borrowing_book', methods=['GET', 'POST'])
def allow_borrowing_book():
    form = AllowBorrowingForm()

    if request.method == 'POST' and form.validate_on_submit():
        isbn = form.isbn.data
        id = form.id.data

        cursor = mysql.connection.cursor()
        query = "UPDATE borrowing SET status = 'active' WHERE isbn = %s AND id = %s"
        cursor.execute(query, (isbn, id))
        mysql.connection.commit()
        cursor.close()

        return 'The book is now available to user!'

    return render_template('allow_borrowing_book_form.html', form=form)


#returning a book, the school operator does that
class ReturnBookForm(FlaskForm):
    isbn = StringField('ISBN', validators=[DataRequired()])
    id = StringField('User ID', validators=[DataRequired()])
    submit = SubmitField('Return Book')

# Route for returning a book
@app.route('/return_book', methods=['GET', 'POST'])
def return_book():
    form = ReturnBookForm()

    if request.method == 'POST' and form.validate_on_submit():
        isbn = form.isbn.data
        id = form.id.data

        cursor = mysql.connection.cursor()
        query = "UPDATE borrowing SET status = 'returned' WHERE isbn = %s AND id = %s"
        cursor.execute(query, (isbn, id))
        mysql.connection.commit()
        cursor.close()

        return 'The book is returned!'

    return render_template('return_book_form.html', form=form)



#Access User Table; for the Library Manager
class UserTableForm(FlaskForm):
    id = StringField('User Id', validators=[DataRequired()])
    name = StringField('Name', validators=[DataRequired()])
    age = StringField('Age', validators=[DataRequired()])
    ph_nmbr = StringField('Phone Number', validators=[DataRequired()])
    mail = StringField('Email', validators=[DataRequired()])
    number = StringField('Role id', validators=[DataRequired()])
    approved_status = StringField('Status', validators=[DataRequired()])

#for the Library manager, so he can see the applications of Operators
@app.route('/user_table', methods=['GET'])
def user_table():
    # Retrieve table data from the database
    cursor = mysql.connection.cursor()
    query = "SELECT * FROM user WHERE number='3' "
    cursor.execute(query)
    table_data = cursor.fetchall()
    mysql.connection.commit()
    cursor.close()
    # Create a list of form instances for each row in the table
    table_forms = []
    for row in table_data:
        form = UserTableForm()
        form.id.data = row[0]
        form.name.data = row[2]
        form.age.data = row[3]
        form.ph_nmbr.data = row[4]
        form.mail.data = row[5]
        form.number.data = row[7]
        form.approved_status.data = row[8]
        table_forms.append(form)

    return render_template('user_table.html', table_forms=table_forms)


#See the applications for simple users, aka students and teachers; for Operators
class UserTableHandlersForm(FlaskForm):
    name = StringField('My School Name', validators=[DataRequired()])
    submit = SubmitField('Find me the application for students or teachers in my school')

@app.route('/user_table_statuses', methods=['POST','GET'])
def user_table_statuses():
    form = UserTableHandlersForm()
    if request.method == 'POST' and form.validate_on_submit():
            name = form.name.data
            cursor = mysql.connection.cursor()

            query = """ SELECT u.*
                FROM user u
                JOIN goes_to gt ON u.id = gt.id
                JOIN school_unit su ON gt.name = su.school_name
                WHERE (u.number = '1' OR u.number = '2') AND su.school_name = %s
                """

            cursor.execute(query, (name,))
            table_data = cursor.fetchall()
            mysql.connection.commit()
            cursor.close()

            # Create a list of form instances for each row in the table
            table_forms = []
            for row in table_data:
                form = UserTableForm()
                form.id.data = row[0]
                form.name.data = row[2]
                form.age.data = row[3]
                form.ph_nmbr.data = row[4]
                form.mail.data = row[5]
                form.number.data = row[7]
                form.approved_status.data = row[8]
                table_forms.append(form)

            return render_template('user_table_statuses.html', table_forms=table_forms)

    return render_template('ask_user_table_statuses.html', form=form)



#Access Author Table; for Operators
class AuthorTableForm(FlaskForm):
    author_id = StringField('Author ID', validators=[DataRequired()])
    author_name = StringField('Author Name', validators=[DataRequired()])

@app.route('/author_table', methods=['GET'])
def author_table():
    cursor = mysql.connection.cursor()
    query = "SELECT * FROM authors"
    cursor.execute(query)
    table_data = cursor.fetchall()
    mysql.connection.commit()
    cursor.close()
    # Create a list of form instances for each row in the table
    table_forms = []
    for row in table_data:
        form = AuthorTableForm()
        form.author_id.data = row[0]
        form.author_name.data = row[1]

        table_forms.append(form)

    return render_template('author_table.html', table_forms=table_forms)


#Access Keywords Table; for Operators
class KeywordsTableForm(FlaskForm):
    key_word_id = StringField('Keyword Id', validators=[DataRequired()])
    key_word = StringField('KeyWord', validators=[DataRequired()])

@app.route('/keyword_table', methods=['GET'])
def keyword_table():
    cursor = mysql.connection.cursor()
    query = "SELECT * FROM key_word"
    cursor.execute(query)
    table_data = cursor.fetchall()
    mysql.connection.commit()
    cursor.close()
    # Create a list of form instances for each row in the table
    table_forms = []
    for row in table_data:
        form = KeywordsTableForm()
        form.key_word_id.data = row[0]
        form.key_word.data = row[1]

        table_forms.append(form)

    return render_template('keyword_table.html', table_forms=table_forms)


#Access Genre Table; for Operators
class GenreTableForm(FlaskForm):
    genre_id = StringField('Genre ID', validators=[DataRequired()])
    genre = StringField('Genre', validators=[DataRequired()])

@app.route('/genre_table', methods=['GET'])
def genre_table():
    cursor = mysql.connection.cursor()
    query = "SELECT * FROM genres"
    cursor.execute(query)
    table_data = cursor.fetchall()
    mysql.connection.commit()
    cursor.close()
    # Create a list of form instances for each row in the table
    table_forms = []
    for row in table_data:
        form = GenreTableForm()
        form.genre_id.data = row[0]
        form.genre.data = row[1]

        table_forms.append(form)

    return render_template('genre_table.html', table_forms=table_forms)


class BookTableForm(FlaskForm):
    isbn = StringField('ISBN', validators=[DataRequired()])
    title = StringField('Title', validators=[DataRequired()])
    publisher = StringField('Publisher', validators=[DataRequired()])
    authors = StringField('Authors', validators=[DataRequired()])
    pages = StringField('Pages', validators=[DataRequired()])
    summary = StringField('Summary', validators=[DataRequired()])
    nmbr_of_copies = StringField('Available Copies', validators=[DataRequired()])
    genres = StringField('Genres', validators=[DataRequired()])
    image = StringField('Image', validators=[DataRequired()])
    language = StringField('Language', validators=[DataRequired()])
    school_unit = StringField('School Unit', validators=[DataRequired()])
    key_words = StringField('Keywords', validators=[DataRequired()])


@app.route('/book_list', methods=['GET'])
def book_list():
    cursor = mysql.connection.cursor()
    query = """
       SELECT books.isbn, books.title, books.publisher, GROUP_CONCAT(DISTINCT authors.author_name) as authors,
               books.pages, books.summary, books.nmbr_of_copies,
               GROUP_CONCAT(DISTINCT genres.genre_name) as genres,
               books.image, books.language,
               GROUP_CONCAT(DISTINCT key_word.key_word) as key_word,
               GROUP_CONCAT(DISTINCT school_unit.school_name) as school_unit
        
                FROM books
                
                JOIN book_author ON books.isbn = book_author.isbn
                JOIN authors ON book_author.author_id = authors.author_id
                
                JOIN book_genre ON books.isbn = book_genre.isbn
                JOIN genres ON book_genre.genre_id = genres.genre_id
                
                JOIN book_key_words ON books.isbn = book_key_words.isbn
                JOIN key_word ON book_key_words.key_word_id = key_word.key_word_id
                        
                JOIN belongs_to ON books.isbn = belongs_to.isbn
                JOIN school_unit ON belongs_to.name = school_unit.school_name
                        
                GROUP BY books.isbn

    """

    cursor.execute(query)
    table_data = cursor.fetchall()

    cursor.close()

    table_forms = []
    for row in table_data:
        form = BookTableForm()
        form.isbn.data = row[0]
        form.title.data = row[1]
        form.publisher.data = row[2]
        form.authors.data = row[3]
        form.pages.data = row[4]
        form.summary.data = row[5]
        form.nmbr_of_copies.data = row[6]
        form.genres.data = row[7]
        form.image.data = row[8]
        form.language.data = row[9]
        form.key_words.data = row[10]
        form.school_unit.data = row[11]

        table_forms.append(form)

    return render_template('book_list.html', table_forms=table_forms)

#Booking a book; for Users
class BookBookForm(FlaskForm):
    isbn = StringField('ISBN', validators=[DataRequired()])
    id = StringField('User ID', validators=[DataRequired()])
    submit = SubmitField('Reserve Book')

# Route for booking a book
@app.route('/book_book', methods=['POST', 'GET'])
def book_book():
    form = BookBookForm()
    if request.method == 'POST' and form.validate_on_submit():
        isbn = form.isbn.data
        id = form.id.data

        cursor = mysql.connection.cursor()
        query = "INSERT INTO booking(isbn, id) VALUES(%s, %s)"
        cursor.execute(query, (isbn, id))
        mysql.connection.commit()
        cursor.close()
        return 'Request for reserving the book was successful!'

    return render_template('book_book_form.html', form=form)



#Access borrowing table; for school Operator
class SchoolAskingForm(FlaskForm):
    school_unit = StringField('My School Name', validators=[DataRequired()])
    submit = SubmitField('Submit')

class BorrowingTableForm(FlaskForm):
    id = StringField('User Id', validators=[DataRequired()])
    isbn = StringField('isbn', validators=[DataRequired()])
    status = StringField('Status', validators=[DataRequired()])
    date = StringField('Borrowing Date', validators=[DataRequired()])

@app.route('/borrowing_table', methods=['POST','GET'])
def borrowing_table():
    form = SchoolAskingForm()
    if request.method == 'POST' and form.validate_on_submit():
        school_unit = form.school_unit.data
        cursor = mysql.connection.cursor()
        query = """
        SELECT *
            FROM borrowing b
            JOIN goes_to gt ON b.id = gt.id
            JOIN school_unit su ON gt.name = su.school_name
            WHERE su.school_name = %s

        """
        cursor.execute(query, (school_unit,))
        table_data = cursor.fetchall()
        cursor.close()

        table_forms = []
        for row in table_data:
            form = BorrowingTableForm()
            form.id.data = row[1]
            form.isbn.data = row[2]
            form.date.data = row[3]
            form.status.data = row[4]

            table_forms.append(form)

        return render_template('borrowing_table.html', table_forms=table_forms)
    return render_template('ask_school_borrowing.html', form=form)

#Access borrowing table for a particular user; for school Operator
class BorrowingTableUserForm(FlaskForm):
    id = StringField('User ID', validators=[DataRequired()])
    submit = SubmitField('Submit')
@app.route('/borrowing_table_user', methods=['POST', 'GET'])
def borrowing_table_user():
    form = BorrowingTableUserForm()
    if request.method == 'POST' and form.validate_on_submit():
        id = form.id.data
        # Retrieve table data from the database
        cursor = mysql.connection.cursor()
        query = "SELECT * FROM borrowing WHERE id = %s AND status<>'inactive'"
        cursor.execute(query, (id,))
        table_data = cursor.fetchall()
        cursor.close()

        table_forms = []
        for row in table_data:
            form = BorrowingTableForm()
            form.id.data = row[1]  # Set form field values from table row
            form.isbn.data = row[2]
            form.date.data = row[3]
            form.status.data = row[4]
            table_forms.append(form)

        return render_template('borrowing_table.html', table_forms=table_forms)

    return render_template('borrowing_table_user.html', form=form)


#Access bookings table; for Operators
class BookingTableForm(FlaskForm):
    id = StringField('User ID', validators=[DataRequired()])
    isbn = StringField('isbn', validators=[DataRequired()])
    date = StringField('Borrowing Date', validators=[DataRequired()])

@app.route('/booking_table', methods=['POST','GET'])
def booking_table():
    form = SchoolAskingForm()
    if request.method == 'POST' and form.validate_on_submit():
        cursor = mysql.connection.cursor()
        school_unit = form.school_unit.data
        query = """
        SELECT *
            FROM booking b
            JOIN goes_to gt ON b.id = gt.id
            JOIN school_unit su ON gt.name = su.school_name
            WHERE su.school_name = %s
        """
        cursor.execute(query, (school_unit,))
        table_data = cursor.fetchall()
        cursor.close()

        table_forms = []
        for row in table_data:
            form = BookingTableForm()
            form.id.data = row[1]
            form.isbn.data = row[2]
            form.date.data = row[3]

            table_forms.append(form)

        return render_template('booking_table.html', table_forms=table_forms)
    return render_template('ask_school_reservations.html', form=form)


#Delete or deactivate a user's account; for Users
class DeleteDeactivateAccountForm(FlaskForm):
    id = StringField('User ID', validators=[DataRequired()])
    status = StringField('New Status', validators=[DataRequired()])
    submit = SubmitField('Delete or Deactivate Account')

@app.route('/delete_deactivate_an_account', methods=['POST', 'GET'])
def delete_deactivate_an_account():
    form = DeleteDeactivateAccountForm()

    if request.method == 'POST' and form.validate_on_submit():
        id = form.id.data
        status = form.status.data

        cursor = mysql.connection.cursor()
        if(status == 'inactive'):
            query = "UPDATE user SET approved_status = %s WHERE id = %s"
            cursor.execute(query, (status, id))
            mysql.connection.commit()

        elif (status == 'deleted'):
            query = "DELETE FROM  booking WHERE id = %s"
            cursor.execute(query, (id,))
            mysql.connection.commit()

            query = "DELETE FROM borrowing WHERE id = %s and status='returned'"
            cursor.execute(query, (id,))
            mysql.connection.commit()

            query = "DELETE FROM  goes_to WHERE id = %s"
            cursor.execute(query, (id,))
            mysql.connection.commit()

            

            query = "DELETE FROM review WHERE id = %s"
            cursor.execute(query, (id,))
            mysql.connection.commit()

            query = "DELETE FROM user WHERE id = %s"
            cursor.execute(query, (id, ))
            mysql.connection.commit()

        cursor.close()
        return "Deleted/Deactivated Account"

    return render_template('delete_deactivate_an_account.html', form=form)


#Delete a revervation of a book; for Operators
class DeleteBookingForm(FlaskForm):
    id = StringField('User ID', validators=[DataRequired()])
    isbn = StringField('ISBN', validators=[DataRequired()])
    submit = SubmitField('Delete a Reservation')

@app.route('/delete_booking', methods=['POST', 'GET'])
def delete_booking():
    form = DeleteBookingForm()
    if request.method == 'POST' and form.validate_on_submit():
        id = form.id.data
        isbn = form.isbn.data

        cursor = mysql.connection.cursor()

        query = "DELETE FROM booking WHERE id = %s AND isbn = %s"
        cursor.execute(query, (id, isbn))

        mysql.connection.commit()
        cursor.close()

        return "Reservation Deleted Successfully!"

    return render_template('delete_booking.html', form=form)


#Review Book; for the Users
class ReviewForm(FlaskForm):
    id = StringField('User ID', validators=[DataRequired()])
    isbn = StringField('ISBN', validators=[DataRequired()])
    likert_scale = StringField('Like Scale Up to 5', validators=[DataRequired()])
    text = StringField('What do you think of this book', validators=[DataRequired()])
    submit = SubmitField('Submit Review')

@app.route('/review_book', methods=['POST','GET'])
def review_book():
    form = ReviewForm()
    if request.method == 'POST' and form.validate_on_submit():
        id=form.id.data
        isbn=form.isbn.data
        likert_scale = form.likert_scale.data
        text = form.text.data

        cursor = mysql.connection.cursor()
        query = "INSERT INTO review(id,isbn,likert_scale,review_text,review_status) VALUES(%s, %s, %s, %s,'inapproved')"
        cursor.execute(query, (id,isbn,likert_scale,text))
        mysql.connection.commit()
        cursor.close()
        return "Review Submitted Successfully!"


    return render_template('review_book.html', form=form)

#Access to reviews table; for Operators
class ReviewTableForm(FlaskForm):
    id = StringField('User ID', validators=[DataRequired()])
    isbn = StringField('ISBN', validators=[DataRequired()])
    likert_scale = StringField('Like scale up to 5', validators=[DataRequired()])
    review_text = StringField('What users think', validators=[DataRequired()])
    review_status = StringField('Review Status', validators=[DataRequired()])
    submit = SubmitField('Submit Review')

#for the Library manager, so he can see the applications of Operators
@app.route('/review_table', methods=['POST','GET'])
def review_table():
    form = SchoolAskingForm()
    if request.method == 'POST' and form.validate_on_submit():
        school_unit = form.school_unit.data

        cursor = mysql.connection.cursor()
        query = """
        SELECT *
            FROM review r
            JOIN goes_to gt ON r.id = gt.id
            JOIN school_unit su ON gt.name = su.school_name
            WHERE su.school_name = %s
             """
        cursor.execute(query, (school_unit,))
        table_data = cursor.fetchall()
        mysql.connection.commit()
        cursor.close()

        table_forms = []
        for row in table_data:
            form = ReviewTableForm()
            form.id.data = row[1]
            form.isbn.data = row[2]
            form.likert_scale.data = row[3]
            form.review_text.data = row[4]
            form.review_status.data = row[5]

            table_forms.append(form)

        return render_template('review_table.html', table_forms=table_forms)
    return render_template('ask_school_reviews.html', form=form)


#Accept a review; for Operator
class ReviewAcceptForm(FlaskForm):
    id = StringField('User ID', validators=[DataRequired()])
    isbn = StringField('ISBN', validators=[DataRequired()])
    submit = SubmitField('Accept  review')

@app.route('/review_accept', methods=['POST','GET'])
def review_accept():
    form = ReviewAcceptForm()
    if request.method == 'POST' and form.validate_on_submit():
        id = form.id.data
        isbn = form.isbn.data
        cursor = mysql.connection.cursor()

        query = "UPDATE review SET review_status = 'approved' WHERE ID=%s AND isbn = %s"
        cursor.execute(query, (id, isbn))
        mysql.connection.commit()
        cursor.close()

        return "Review has been approved!"

    return render_template('review_accept_table.html', form=form)


#Add an author; for Operator
class AddAuthorForm(FlaskForm):
    author_name = StringField('Author Name', validators=[DataRequired()])
    submit = SubmitField('Add Author')

@app.route('/add_author', methods=['POST','GET'])
def add_author():
    form = AddAuthorForm()
    if request.method == 'POST' and form.validate_on_submit():
        author_name = form.author_name.data
        cursor = mysql.connection.cursor()

        query = "INSERT INTO authors(author_name) VALUES(%s)"
        cursor.execute(query, (author_name,))
        mysql.connection.commit()
        cursor.close()

        return "Author has been added!"

    return render_template('add_author.html', form=form)

#Add an genre; for Operator
class AddGenreForm(FlaskForm):
    genre_name = StringField('Genre', validators=[DataRequired()])
    submit = SubmitField('Add Genre')

@app.route('/add_genre', methods=['POST','GET'])
def add_genre():
    form = AddGenreForm()
    if request.method == 'POST' and form.validate_on_submit():
        genre_name = form.genre_name.data
        cursor = mysql.connection.cursor()

        query = "INSERT INTO genres(genre_name) VALUES(%s)"
        cursor.execute(query, (genre_name,))
        mysql.connection.commit()
        cursor.close()

        return "Genre has been added!"

    return render_template('add_genre.html', form=form)

#Add a keyword; for Operator
class AddKeywordForm(FlaskForm):
    key_word = StringField('Keyword', validators=[DataRequired()])
    submit = SubmitField('Add new Keyword')

@app.route('/add_keyword', methods=['POST','GET'])
def add_keyword():
    form = AddKeywordForm()
    if request.method == 'POST' and form.validate_on_submit():
        key_word = form.key_word.data
        cursor = mysql.connection.cursor()

        query = "INSERT INTO key_word(key_word) VALUES(%s)"
        cursor.execute(query, (key_word,))
        mysql.connection.commit()
        cursor.close()

        return "Keyword has been added!"

    return render_template('add_keywords.html', form=form)

#Read reviwes; for User
class ReadReviewForm(FlaskForm):
    isbn = StringField('ISBN', validators=[DataRequired()])
    likert_scale = StringField('Score', validators=[DataRequired()])
    submit = SubmitField('Accept review')

class ReadReviewsForm(FlaskForm):
    isbn = StringField('ISBN', validators=[DataRequired()])
    likert_scale = StringField('Likert Scale', validators=[DataRequired()])
    text = StringField('What people thought', validators=[DataRequired()])

class AskToReadReviewsForm(FlaskForm):
    isbn = StringField('ISBN', validators=[DataRequired()])
    submit = SubmitField('Ask to read review')

@app.route('/read_review', methods=['POST','GET'])
def ask_to_read_review():
    form = AskToReadReviewsForm()
    if request.method == 'POST' and form.validate_on_submit():
        isbn = form.isbn.data
        cursor = mysql.connection.cursor()
        query = "SELECT * FROM review WHERE isbn = %s AND review_status = 'approved'"
        cursor.execute(query, (isbn,))
        table_data = cursor.fetchall()
        mysql.connection.commit()
        cursor.close()

        table_forms = []
        for row in table_data:
            form = ReadReviewsForm()
            form.isbn.data = row[2]
            form.likert_scale.data = row[3]
            form.text.data = row[4]
            table_forms.append(form)

        return render_template('read_review.html', table_forms=table_forms)

    return render_template('ask_to_read_review.html', form=form)

#Which books a user has borrowed; for Users
class BorrowedBooksForm(FlaskForm):
    id = StringField('ID', validators=[DataRequired()])
    submit = SubmitField('See Books')

@app.route('/borrowed_books',methods=['POST','GET'])
def borrowed_books():
    form = BorrowedBooksForm()
    if request.method == 'POST' and form.validate_on_submit():
        user_id = form.id.data
        cursor = mysql.connection.cursor()

        query = """
            SELECT books.isbn, books.title
                FROM books
                JOIN borrowing ON books.isbn = borrowing.isbn
                WHERE borrowing.id = %s AND borrowing.status IN ('active', 'returned', 'delayed')

        """
        cursor.execute(query, (user_id,))
        borrowed_books = cursor.fetchall()
        mysql.connection.commit()
        cursor.close()
        return render_template('borrowed_books.html', borrowed_books=borrowed_books)

    return render_template('ask_for_borrowed_books.html', form=form)

@app.route('/booked_books',methods=['POST','GET'])
def booked_books():
    form = BorrowedBooksForm()
    if request.method == 'POST' and form.validate_on_submit():
        user_id = form.id.data
        cursor = mysql.connection.cursor()

        query = """
            SELECT books.isbn, books.title
                FROM books
                JOIN booking ON books.isbn = booking.isbn
                WHERE booking.id = %s

        """
        cursor.execute(query, (user_id,))
        booked_books = cursor.fetchall()
        mysql.connection.commit()
        cursor.close()
        return render_template('booked_books.html', booked_books=booked_books)

    return render_template('ask_for_booked_books.html', form=form)

#search books by title, genre, author(for user and operator), copies(for operator)
class SearchTitleForm(FlaskForm):
    title = StringField('Title', validators=[DataRequired()])
    submit = SubmitField('Search by Title')

@app.route('/search_title',methods=['POST','GET'])
def search_title():
    form = SearchTitleForm()
    if request.method == 'POST' and form.validate_on_submit():
        title = form.title.data
        cursor = mysql.connection.cursor()

        query = """
            SELECT books.isbn, books.title, GROUP_CONCAT(authors.author_name) AS authors
            FROM books
            JOIN book_author ON books.isbn = book_author.isbn
            JOIN authors ON book_author.author_id = authors.author_id
            WHERE books.title = %s
            GROUP BY books.isbn, books.title
        """
        cursor.execute(query, (title,))
        ask_title_books = cursor.fetchone()
        mysql.connection.commit()
        cursor.close()
        return render_template('title_books.html', ask_title_books=ask_title_books)

    return render_template('ask_title_books.html', form=form)

class SearchGenreForm(FlaskForm):
    genre = StringField('Genre', validators=[DataRequired()])
    submit = SubmitField('Search by Genre')

@app.route('/search_genre',methods=['POST','GET'])
def search_genre():
    form = SearchGenreForm()
    if request.method == 'POST' and form.validate_on_submit():
        genre = form.genre.data
        cursor = mysql.connection.cursor()

        query = """
            SELECT books.isbn, books.title, GROUP_CONCAT(authors.author_name) AS authors
                FROM books
                JOIN book_genre ON books.isbn = book_genre.isbn
                JOIN book_author ON books.isbn = book_author.isbn
                JOIN authors ON book_author.author_id = authors.author_id
                JOIN genres ON book_genre.genre_id = genres.genre_id
                WHERE genres.genre_name = %s
                GROUP BY books.isbn, books.title
            """
        cursor.execute(query, (genre,))
        books_by_genre = cursor.fetchall()
        mysql.connection.commit()
        cursor.close()
        return render_template('genre_books.html', books_by_genre=books_by_genre)

    return render_template('ask_genre_books.html', form=form)

class SearchAuthorForm(FlaskForm):
    author = StringField('Author', validators=[DataRequired()])
    submit = SubmitField('Search by Author')

@app.route('/search_author', methods=['POST', 'GET'])
def search_author():
    form = SearchAuthorForm()
    if request.method == 'POST' and form.validate_on_submit():
        author = form.author.data
        cursor = mysql.connection.cursor()

        query = """
            SELECT books.isbn, books.title, GROUP_CONCAT(authors.author_name) AS authors
            FROM books
            JOIN book_author ON books.isbn = book_author.isbn
            JOIN authors ON book_author.author_id = authors.author_id
            WHERE authors.author_name LIKE %s
            GROUP BY books.isbn, books.title
        """
        cursor.execute(query, ('%' + author + '%',))
        books_by_author = cursor.fetchall()
        mysql.connection.commit()
        cursor.close()
        return render_template('author_books.html', books_by_author=books_by_author)

    return render_template('ask_author_books.html', form=form)

class SearchCopiesForm(FlaskForm):
    nmbr_of_copies = IntegerField('Number of Copies', validators=[DataRequired()])
    submit = SubmitField('Search by Number of Copies')

@app.route('/search_copies', methods=['POST', 'GET'])
def search_copies():
    form = SearchCopiesForm()
    if request.method == 'POST' and form.validate_on_submit():
        nmbr_of_copies = form.nmbr_of_copies.data
        cursor = mysql.connection.cursor()

        query = """
            SELECT books.isbn, books.title, GROUP_CONCAT(authors.author_name) AS authors
            FROM books
            JOIN book_author ON books.isbn = book_author.isbn
            JOIN authors ON book_author.author_id = authors.author_id
            WHERE books.nmbr_of_copies = %s
            GROUP BY books.isbn, books.title
        """
        cursor.execute(query, (nmbr_of_copies,))
        books_by_copies = cursor.fetchall()
        mysql.connection.commit()
        cursor.close()

        return render_template('copies_books.html', books_by_copies=books_by_copies)

    return render_template('ask_copies_books.html', form=form)


class DelaysForm(FlaskForm):
    id = StringField('User Name', validators=[DataRequired()])
    submit = SubmitField('Search')

@app.route('/search_for_delays', methods=['POST', 'GET'])
def search_for_delays():
    form = DelaysForm()
    if request.method == 'POST' and form.validate_on_submit():
        id = form.id.data

        cursor = mysql.connection.cursor()
        query = """
            SELECT user.*
              FROM user
              JOIN borrowing ON user.id = borrowing.id
              WHERE user.name = %s AND borrowing.status='delayed'
          """
        cursor.execute(query, (id,))

        delays = cursor.fetchall()
        mysql.connection.commit()
        cursor.close()

        return render_template('borrowers_list.html', delays=delays)

    return render_template('borrowers_search.html', form=form)


class DelayedDaysForm(FlaskForm):
    days = StringField('Number of Days delayed', validators=[DataRequired()])
    submit = SubmitField('Search')

@app.route('/search_for_delays_days', methods=['POST', 'GET'])
def search_for_delays_days():
    form = DelayedDaysForm()
    if request.method == 'POST' and form.validate_on_submit():
        days = form.days.data

        cursor = mysql.connection.cursor()

        query = """
            SELECT user.*
            FROM user
            JOIN borrowing ON user.id = borrowing.id
            WHERE DATE_ADD(borrowing.borrowing_date,INTERVAL %s + 7 DAY) = current_date()
            AND borrowing.status='delayed'
        """
        cursor.execute(query, (days,))

        delays = cursor.fetchall()
        mysql.connection.commit()
        cursor.close()

        return render_template('borrowers_list.html', delays=delays)

    return render_template('borrow_search_days.html', form=form)


class LoansPerSchoolForm(FlaskForm):
    month = StringField('Month', validators=[DataRequired()])
    year = StringField('Year', validators=[DataRequired()])
    submit = SubmitField('See Loan')

@app.route('/see_loans', methods=['POST', 'GET'])
def see_loans():
    form = LoansPerSchoolForm()
    if request.method == 'POST' and form.validate_on_submit():
        month = form.month.data
        year = form.year.data
        cursor = mysql.connection.cursor()

        query = """
           SELECT su.school_name, COUNT(*) AS total_loans
               FROM borrowing b
               JOIN goes_to gt ON b.id = gt.id
               JOIN school_unit su ON gt.name = su.school_name
               WHERE YEAR(b.borrowing_date) = %s
               AND MONTH(b.borrowing_date) = %s
               GROUP BY su.school_name;
        """
        cursor.execute(query, (year, month))

        loans = cursor.fetchall()
        mysql.connection.commit()
        cursor.close()

        return render_template('loans.html', loans=loans)

    return render_template('ask_loans.html', form=form)


class AuthorsOfCategoryForm(FlaskForm):
    genre = StringField('Genre', validators=[DataRequired()])
    submit = SubmitField('Submit')
    
@app.route('/authors_of_category', methods=['POST', 'GET'])
def authors_of_category():
    form = AuthorsOfCategoryForm()
    if request.method == 'POST' and form.validate_on_submit():
        genre= form.genre.data
        cursor = mysql.connection.cursor()

        query = """
           SELECT DISTINCT a.author_name, u.name AS teacher_name
                FROM authors a
                JOIN book_author ba ON a.author_id = ba.author_id
                JOIN books b ON ba.isbn = b.isbn
                JOIN book_genre bg ON b.isbn = bg.isbn
                JOIN genres g ON bg.genre_id = g.genre_id
                LEFT JOIN borrowing bo ON b.isbn = bo.isbn
                LEFT JOIN goes_to gt ON bo.id = gt.id
                LEFT JOIN school_unit su ON gt.name = su.school_name
                LEFT JOIN `user` u ON gt.id = u.id AND u.number = 2
                WHERE g.genre_name = %s
                AND (YEAR(bo.borrowing_date) = YEAR(CURRENT_DATE) OR bo.borrowing_date IS NULL);
                        """
        cursor.execute(query, (genre,))

        authors = cursor.fetchall()
        mysql.connection.commit()
        cursor.close()

        return render_template('author_of_category.html', authors=authors)

    return render_template('ask_authors_of_category.html', form=form)


@app.route('/teachers_borrowed_category', methods=['POST', 'GET'])
def teachers_borrowed_category():
        cursor = mysql.connection.cursor()

        query = """
                  SELECT u.name, u.age, COUNT(*) AS num_books_borrowed
                    FROM user u
                    JOIN borrowing b ON u.id = b.id
                    JOIN goes_to gt ON u.id = gt.id
                    JOIN school_unit su ON gt.name = su.school_name
                    WHERE u.age < 40 AND u.number=2
                    GROUP BY u.name, u.age
                    ORDER BY num_books_borrowed DESC;
                """
        cursor.execute(query)

        teachers = cursor.fetchall()
        mysql.connection.commit()
        cursor.close()

        return render_template('teacher.html', teachers=teachers)


@app.route('/authors_not_borrowed', methods=['POST', 'GET'])
def authors_not_borrowed():
        cursor = mysql.connection.cursor()
        query = """
                  SELECT a.author_name
                       FROM authors a
                       WHERE a.author_id NOT IN (
                       SELECT ba.author_id
                       FROM book_author ba
                       JOIN books b ON ba.isbn = b.isbn
                       JOIN borrowing bo ON b.isbn = bo.isbn
);
                """
        cursor.execute(query)

        authors = cursor.fetchall()
        mysql.connection.commit()
        cursor.close()

        return render_template('authors_not_borrowed.html', authors=authors)

@app.route('/handlers_same_number', methods=['POST', 'GET'])
def handlers_same_number():
        cursor = mysql.connection.cursor()

        query = """
              SELECT u1.name AS operator_name
                  FROM user u1
                  JOIN handles h1 ON u1.id = h1.id
                  JOIN active_borrowings_view v1 ON h1.school_name = v1.school_name
                  JOIN user u2
                  JOIN handles h2 ON u2.id = h2.id
                  JOIN active_borrowings_view v2 ON h2.school_name = v2.school_name
                  WHERE u1.id <> u2.id
                  AND v1.active_borrowings_count = v2.active_borrowings_count
                  ORDER BY operator_name;
                """
        cursor.execute(query)

        handlers = cursor.fetchall()
        mysql.connection.commit()
        cursor.close()

        return render_template('handlers_same_number.html', handlers=handlers)

@app.route('/most_popular_genre', methods=['POST', 'GET'])
def most_popular_genre():
        cursor = mysql.connection.cursor()

        query = """
                 SELECT bg1.genre_id AS category1_id, g1.genre_name AS category1_name,
                       bg2.genre_id AS category2_id, g2.genre_name AS category2_name,
                       COUNT(*) AS num_borrowings
                        FROM book_genre bg1
                        JOIN book_genre bg2 ON bg1.isbn = bg2.isbn AND bg1.genre_id < bg2.genre_id
                        JOIN genres g1 ON bg1.genre_id = g1.genre_id
                        JOIN genres g2 ON bg2.genre_id = g2.genre_id
                        JOIN borrowing b ON bg1.isbn = b.isbn
                        GROUP BY bg1.genre_id, bg2.genre_id
                        ORDER BY num_borrowings DESC
                        LIMIT 3
                """
        cursor.execute(query)

        table = cursor.fetchall()
        mysql.connection.commit()
        cursor.close()

        return render_template('most_popular_genre.html', table=table)


@app.route('/authors_with_five_less', methods=['POST', 'GET'])
def authors_with_five_less():
        cursor = mysql.connection.cursor()

        query = """
                 SELECT a.author_name, COUNT(*) AS num_books
                    FROM authors a
                    JOIN book_author ba ON a.author_id = ba.author_id
                    GROUP BY a.author_name
                    HAVING (SELECT COUNT(*)
                    FROM book_author
                    GROUP BY author_id
                    ORDER BY COUNT(*) DESC
                    LIMIT 1) - COUNT(*) >= 5

                """
        cursor.execute(query)

        table = cursor.fetchall()
        mysql.connection.commit()
        cursor.close()

        return render_template('authors_with_five_less.html', table = table)


class AverageForm(FlaskForm):
    genre = StringField('Genre', validators=[DataRequired()])
    id = StringField('User ID', validators=[DataRequired()])
    submit = SubmitField('Submit')


@app.route('/average_score', methods=['POST', 'GET'])
def average_score():
    form = AverageForm()
    if request.method == 'POST' and form.validate_on_submit():
        genre = form.genre.data
        id = form.id.data
        cursor = mysql.connection.cursor()

        query = """
        SELECT u.id AS user_id, g.genre_name, AVG(r.likert_scale) AS avg_rating
            FROM review r
            INNER JOIN user u ON r.id = u.id
            INNER JOIN book_genre bg ON r.isbn = bg.isbn
            INNER JOIN genres g ON bg.genre_id = g.genre_id
            WHERE u.id = %s
            AND r.review_status = 'approved'
            AND g.genre_name = %s
            GROUP BY u.id, g.genre_name;
        """
        cursor.execute(query, (id,genre))

        score = cursor.fetchall()
        mysql.connection.commit()
        cursor.close()

        return render_template('average_score.html', score=score)

    return render_template('ask_average_score.html', form=form)

'''

'''


if __name__ == '__main__':
    app.run(debug=True)