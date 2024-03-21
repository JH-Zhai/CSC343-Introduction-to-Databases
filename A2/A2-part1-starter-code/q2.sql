-- Lure them back.

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber, public;
DROP TABLE IF EXISTS q2 CASCADE;

CREATE TABLE q2(
    client_id INTEGER,
    name VARCHAR(41),
  	email VARCHAR(30),
  	billed FLOAT,
  	decline INTEGER
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS AllClients CASCADE;
DROP VIEW IF EXISTS AllRides CASCADE;
DROP VIEW IF EXISTS Above500 CASCADE;
DROP VIEW IF EXISTS Between1t10 CASCADE;
DROP VIEW IF EXISTS Rides2020 CASCADE;
DROP VIEW IF EXISTS Rides2021 CASCADE;
DROP VIEW IF EXISTS FewerRides1 CASCADE;
DROP VIEW IF EXISTS FewerRides2 CASCADE;
DROP VIEW IF EXISTS FewerRides CASCADE;


-- Define views for your intermediate steps here:

-- All clients' info
CREATE VIEW AllClients AS 
SELECT client_id, firstname ||' ' || surname AS name, email
FROM Client;



-- All rides' info
CREATE VIEW AllRides AS 
SELECT client_id, Request.request_id AS request_id, EXTRACT(YEAR FROM Request.datetime) AS year, amount
FROM Request, Dropoff, Billed
WHERE Request.request_id = Dropoff.request_id AND Dropoff.request_id = Billed.request_id;



-- ID of clients above 500 before 2020 and how much
CREATE VIEW Above500 AS 
SELECT client_id, sum(amount) AS billed
FROM AllRides
WHERE year < 2020
GROUP BY client_id
HAVING sum(amount) >= 500;



-- ID of clients had 1 to 10 rides in 2020
CREATE VIEW Between1t10 AS
SELECT client_id
FROM AllRides
WHERE year = 2020
GROUP BY client_id
HAVING count(*) >= 1 AND count(*) <= 10;



-- clients' rides number in 2020
CREATE VIEW Rides2020 AS
SELECT client_id, count(*) AS rides
FROM AllRides
WHERE year = 2020
GROUP BY client_id;



-- clients' rides number in 2021
CREATE VIEW Rides2021 AS
SELECT client_id, count(*) AS rides
FROM AllRides
WHERE year = 2021
GROUP BY client_id;



-- ID of clients had fewer rides in 2021 than in 2020, but took at least 1 rides in 2021
CREATE VIEW FewerRides1 AS
SELECT Rides2020.client_id AS client_id, Rides2021.rides - Rides2020.rides AS decline
FROM Rides2020, Rides2021
WHERE (Rides2020.client_id = Rides2021.client_id AND Rides2020.rides > Rides2021.rides);



-- ID of clients had rides in 2020 but not in 2021
CREATE VIEW FewerRides2 AS
SELECT client_id, - rides AS decline
FROM Rides2020
WHERE Rides2020.client_id NOT IN (SELECT client_id FROM Rides2021);



-- ID of clients had fewer rides in 2021 than in 2020
CREATE VIEW FewerRides AS
(SELECT client_id, decline FROM FewerRides1)
UNION
(SELECT client_id, decline FROM FewerRides2);



-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q2
SELECT AllClients.client_id AS client_id, AllClients.name AS name, AllClients.email AS email, Above500.billed AS billed, FewerRides.decline AS decline
FROM AllClients, Above500, Between1t10, FewerRides
WHERE AllClients.client_id = Above500.client_id AND Above500.client_id = Between1t10.client_id AND 
	Between1t10.client_id = FewerRides.client_id;