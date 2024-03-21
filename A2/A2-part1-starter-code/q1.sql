-- Months.

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber, public;
DROP TABLE IF EXISTS q1 CASCADE;

CREATE TABLE q1(
    client_id INTEGER,
    email VARCHAR(30),
    months INTEGER
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS AllClients CASCADE;
DROP VIEW IF EXISTS Rides CASCADE;


-- Define views for your intermediate steps here:


CREATE VIEW AllClients AS 
SELECT client_id, email
FROM Client;

CREATE VIEW Rides AS
SELECT client_id,  EXTRACT(YEAR FROM Request.datetime) AS Year, EXTRACT(MONTH FROM Request.datetime) AS Month
FROM Request JOIN Dropoff ON Request.request_id = Dropoff.request_id;



-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q1
SELECT client_id, email, count(DISTINCT CAST(year AS CHAR(20)) || Cast(month AS CHAR(20))) AS months
FROM AllClients NATURAL LEFT JOIN Rides
GROUP BY client_id, email;