from flask import Flask, render_template, request, session, redirect, url_for
from flask_wtf import FlaskForm
from flask_mysqldb import MySQL
import os
import subprocess
import mysql.connector
from wtforms import StringField, PasswordField, SubmitField, IntegerField
from wtforms.validators import DataRequired


app = Flask(__name__)
mysql = MySQL(app)

app.config["SECRET_KEY"] = 'eee'
app.config['MYSQL_HOST'] = '127.0.0.1'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_DB'] = 'library_github_new_6'
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
             pages =form.pages.data
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
               cursor.execute(query, (isbn,auth))
               mysql.connection.commit()

             for keyword in key_words.split(','):
                 query = "INSERT INTO book_key_words(isbn,key_word_id) VALUES(%s,%s)"
                 cursor.execute(query, (isbn,keyword))
                 mysql.connection.commit()

             query = "INSERT INTO belongs_to(isbn, name) VALUES(%s,%s)"
             cursor.execute(query, (isbn, name))
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
             cursor.execute(query, (title, publisher, author, pages , summary, nmbr_of_copies, image, genre ,language, key_words, isbn))
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
@app.route('/borrow_book', methods=['GET', 'POST'])
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
@app.route('/user_table_statuses', methods=['GET'])
def user_table_statuses():
    # Retrieve table data from the database
    cursor = mysql.connection.cursor()
    query = "SELECT * FROM user WHERE number = '1' OR number = '2'"
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

    return render_template('user_table_statuses.html', table_forms=table_forms)



#Access Author Table; for Operators
class AuthorTableForm(FlaskForm):
    author_id = StringField('Author ID', validators=[DataRequired()])
    author_name = StringField('Author Name', validators=[DataRequired()])

@app.route('/author_table', methods=['GET'])
def author_table():
    cursor = mysql.connection.cursor()
    query = "SELECT * FROM author"
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
    key_words = StringField('KeyWord', validators=[DataRequired()])

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
        form = AuthorTableForm()
        form.key_word_id.data = row[0]
        form.key_words.data = row[1]

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
        form = AuthorTableForm()
        form.genre_id.data = row[0]
        form.genre.data = row[1]

        table_forms.append(form)

    return render_template('genre_table.html', table_forms=table_forms)


#Access Books Table; for Users
class BookTableForm(FlaskForm):
    isbn = StringField('ISBN', validators=[DataRequired()])
    title = StringField('Title', validators=[DataRequired()])
    publisher = StringField('Publisher', validators=[DataRequired()])
    author = StringField('Author', validators=[DataRequired()])
    pages = StringField('Pges', validators=[DataRequired()])
    summary = StringField('Summary', validators=[DataRequired()])
    nmbr_of_copies = StringField('Available Copies', validators=[DataRequired()])
    genre = StringField('Genre', validators=[DataRequired()])
    image = StringField('Image', validators=[DataRequired()])
    language = StringField('Language', validators=[DataRequired()])
    key_words = StringField('Keywords', validators=[DataRequired()])
@app.route('/book_list', methods=['GET'])
def book_list():
    # Retrieve table data from the database
    cursor = mysql.connection.cursor()
    query = "SELECT * FROM books"
    cursor.execute(query)
    table_data = cursor.fetchall()
    mysql.connection.commit()
    cursor.close()
    # Create a list of form instances for each row in the table
    table_forms = []
    for row in table_data:
        form = BookTableForm()
        form.isbn.data = row[0]
        form.title.data = row[1]
        form.publisher.data = row[2]
        form.author.data = row[3]
        form.pages.data = row[4]
        form.summary.data = row[5]
        form.nmbr_of_copies.data = row[6]
        form.image.data = row[7]
        form.genre = row[8]
        form.language.data = row[9]
        form.key_words.data = row[10]
        table_forms.append(form)

    return render_template('book_list.html', table_forms=table_forms)


#######################################################################################################################################################
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
class BorrowingTableForm(FlaskForm):
    id = StringField('User Id', validators=[DataRequired()])
    isbn = StringField('isbn', validators=[DataRequired()])
    status = StringField('Status', validators=[DataRequired()])
    date = StringField('Borrowing Date', validators=[DataRequired()])

@app.route('/borrowing_table', methods=['GET'])
def borrowing_table():
    cursor = mysql.connection.cursor()
    query = "SELECT * FROM borrowing"
    cursor.execute(query)
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
        query = "SELECT * FROM borrowing WHERE id = %s"
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

@app.route('/booking_table', methods=['GET'])
def booking_table():
    cursor = mysql.connection.cursor()
    query = "SELECT * FROM booking"
    cursor.execute(query)
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
            query = "DELETE FROM  goes_to WHERE id = %s"
            cursor.execute(query, (id,))
            mysql.connection.commit()

            query = "DELETE FROM  borrowing WHERE id = %s"
            cursor.execute(query, (id,))
            mysql.connection.commit()

            query = "DELETE FROM  booking WHERE id = %s"
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
    submit = SubmitField('Submit Review')

@app.route('/review_book', methods=['POST','GET'])
def review_book():
    form = ReviewForm()
    if request.method == 'POST' and form.validate_on_submit():
        id=form.id.data
        isbn=form.isbn.data
        likert_scale = form.likert_scale.data

        cursor = mysql.connection.cursor()
        query = "INSERT INTO review(id,isbn,likert_scale,review_status) VALUES(%s, %s, %s, 'inapproved')"
        cursor.execute(query, (id,isbn,likert_scale))
        mysql.connection.commit()
        cursor.close()
        return "Review Submitted Successfully!"


    return render_template('review_book.html', form=form)

#Access to reviews table; for Operators
class ReviewTableForm(FlaskForm):
    id = StringField('User ID', validators=[DataRequired()])
    isbn = StringField('ISBN', validators=[DataRequired()])
    likert_scale = StringField('Like scale up to 5', validators=[DataRequired()])
    review_status = StringField('Review Status', validators=[DataRequired()])
    submit = SubmitField('Submit Review')

#for the Library manager, so he can see the applications of Operators
@app.route('/review_table', methods=['GET'])
def review_table():
    cursor = mysql.connection.cursor()
    query = "SELECT * FROM review"
    cursor.execute(query)
    table_data = cursor.fetchall()
    mysql.connection.commit()
    cursor.close()

    table_forms = []
    for row in table_data:
        form = ReviewTableForm()
        form.id.data = row[1]
        form.isbn.data = row[2]
        form.likert_scale.data = row[3]
        form.review_status.data = row[4]

        table_forms.append(form)

    return render_template('review_table.html', table_forms=table_forms)


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
            form = ReadReviewForm()
            form.isbn.data = row[2]
            form.likert_scale.data = row[3]
            table_forms.append(form)

        return render_template('read_review.html', table_forms=table_forms)

    return render_template('ask_to_read_review.html', form=form)



if __name__ == '__main__':
    app.run(debug=True)