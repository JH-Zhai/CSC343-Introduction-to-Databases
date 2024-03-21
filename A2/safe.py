"""Demo of pscyopg2 with a dynamic SQL statement, that is, one whose complete
content is not known until we run the code.  Again, the statement is an
INSERT rather than a query, so there are no results to iterate over.  But this
time, we execute the statement safely.
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
    # Ask the user what course they want to add.
    print('We are going to add a new course!')
    cnum = input('Course number: ')
    name = input('Course name: ')
    dept = input('Department: ')

    # -------------------------- The safe way -------------------------- #

    # Sending a separate parameter to the execute method is safe:
    cursor.execute("INSERT INTO COURSE VALUES (%s, %s, %s);", [cnum, name, dept])

    # ----------------------------- NOT safe --------------------------- #

    # This looks similar but is VERY DIFFERENT! It is computing the complete
    # string in Python and sending that complete string to the execute method.
    # This is just as risky as how we did it before.

    # cursor.execute(f"INSERT INTO COURSE VALUES (%s, '%s', '%s');" % (cnum, name, dept))

    # ----------------------------- NOT safe --------------------------- #

    # The two unsafe approaches both compute the string *using Python string ops*
    # and send that complete string to the execute method. They just use an older
    # and a newer syntax for string formatting.

    # cursor.execute(f"INSERT INTO COURSE VALUES ({cnum}, '{name}', '{dept}');")

    # ----------------------------- NOT safe --------------------------- #

    # Another unsafe way, using simpler string manipulation:
    cursor.execute("INSERT INTO COURSE VALUES (" + cnum + ", '" + name + "', '" + dept + "');")

    # Commit the change to the database.
    conn.commit()

finally:
    # Close the cursor and our connection to the database.
    cursor.close()
    conn.close()
