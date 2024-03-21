"""Demo of pscyopg2 with a static query, that is, one whose complete content
is known at the time of writing the code.  Also demonstrates how to iterate
over the results from a query.
"""

# Import the psycopg2 library.
import psycopg2 as pg

# Create an object that holds a connection to your database.
# Substitute your database name for mine, and your username for mine.
# Password really is empty (and is unrelated to your Teaching Labs
# password).
# The argument to the options parameter allows us to set the search path
# at the same time as connecting to the database.
conn = pg.connect(
    dbname="csc343h-marinat", user="marinat", password="",
    options="-c search_path=university,public"
)

# One can also set the search path this way, as a separate step from
# connecting to the database.
# cur.execute("SET SEARCH_PATH TO university, public;")

# Open a cursor object that can (a) hold the results of a query, and 
# (b) allow us to iterate over them.
cur = conn.cursor()

# A quick explanation of try-except-finally in Python.
# First, we execute the code in the try block. If an error occurs,
# we execute the code in the except block. Either way, the last thing
# we do is execute the code in the finally block.
#
# try:
#     # The try block
#
# except pg.Error as ex:
#     # The except block
#
# finally:
#     # The finally block


try:
    # Execute a SQL query and store the results in cursor.
    cur.execute("SELECT * FROM Student;")
    # Iterate over those results.
    for record in cur:
        # Record is a Python tuple. You can print it like any Python tuple.
        print(record)
        # And you can pull elements out by index.
        sid = record[0]
        cgpa = record[5]
        print(f'Student number was {sid} and cgpa was {cgpa}.')

except pg.Error as ex:
    print("An Error occurred!")
    print(ex)
    # Handle the error by rolling back.
    # rollback undoes what you were doing when the error was raised. Everything
    # is restored to as it was beforehand.
    # If you plan to continue using the connection later in this program, you
    # must roll back or an error will be raised.
    conn.rollback()

finally:
    # We are done with the cursor, so close it.
    # If we weren't done with it, we would re-use the cursor and close
    # it at the very end of the program.
    # (You can also create multiple cursors if you need to use the results
    # of multiple queries at the same time.)
    cur.close()

    # Close our connection to the database. Always do this at the very end
    # of the program.
    conn.close()



