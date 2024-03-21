"""Demo of pscyopg2 with a dynamic SQL statement, that is, one whose complete
content is not known until we run the code.  This time, the statement is an
INSERT rather than a query, so there are no results to iterate over.
"""

# Import the psycopg2 library.
import psycopg2 as pg

# Create an object that holds a connection to your database.
conn = pg.connect(
    dbname="csc343h-marinat", user="marinat", password="",
    options="-c search_path=university,public"
)

# Open a cursor object.
cursor = conn.cursor()

try:
    # Ask the user what course they want to add to the database.
    print('We are going to add a new course!')
    cnum = input('Course number: ')
    name = input('Course name: ')
    dept = input('Department: ')

    # Build up the statement using Python string operations, then execute it.
    # NOTE: We are about to learn that this is the WRONG way of doing this.
    cursor.execute(f"INSERT INTO COURSE VALUES ({cnum}, '{name}', '{dept}');")

    # "Commit" the change to the database. If we don't do this, any changes
    # made by our program are rolled back as if they never happened.
    conn.commit()

finally:
    # Close the cursor and our connection to the database.
    cursor.close()
    conn.close()

