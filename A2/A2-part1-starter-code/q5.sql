-- Bigger and smaller spenders.

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber, public;
DROP TABLE IF EXISTS q5 CASCADE;

CREATE TABLE q5(
    client_id INTEGER,
    month VARCHAR(7),
    total FLOAT,
    comparison VARCHAR(30)
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS AllClient CASCADE;
DROP VIEW IF EXISTS AllMonth CASCADE;
DROP VIEW IF EXISTS AllBill CASCADE;
DROP VIEW IF EXISTS MonthAvg CASCADE;
DROP VIEW IF EXISTS ClientTotal1 CASCADE;
DROP VIEW IF EXISTS ClientTotal2 CASCADE;
DROP VIEW IF EXISTS ClientTotal CASCADE;


-- Define views for your intermediate steps here:


-- All clients' id 
CREATE VIEW AllClient AS

SELECT DISTINCT client_id

FROM Client;




-- all months has rides
CREATE VIEW AllMonth AS

SELECT DISTINCT TO_CHAR(Request.datetime, 'YYYY MM') AS month

FROM Request, Dropoff

WHERE Dropoff.request_id = Request.request_id;



-- all paid bills
CREATE VIEW AllBill AS

SELECT client_id, 
    Request.request_id AS request_id,
    amount,
    TO_CHAR(Request.datetime, 'YYYY MM') AS month

FROM Request, Dropoff, Billed

WHERE Request.request_id = Dropoff.request_id AND
    Dropoff.request_id = Billed.request_id;



-- average total of every month
CREATE VIEW MonthAvg AS

SELECT e.month AS month, AVG(e.t) AS average

FROM (
    SELECT client_id, SUM(amount) AS t, month
    FROM AllBill
    GROUP BY client_id, month) e

GROUP BY e.month;



-- total of those who had a bill this month
CREATE VIEW ClientTotal1 AS

SELECT client_id, 
    SUM(amount) AS total, 
    month

FROM AllBill

GROUP BY client_id, month;



-- total of those who had no bill this month
CREATE VIEW ClientTotal2 AS

SELECT client_id, 
    0 AS total, 
    month

FROM AllClient, AllMonth

WHERE NOT EXISTS(
    SELECT *
    FROM AllBill a
    WHERE a.client_id = AllClient.client_id AND a.month = AllMonth.month);



-- total of every client every month
CREATE VIEW ClientTotal AS
(SELECT * FROM ClientTotal1) UNION (SELECT * FROM ClientTotal2);



-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q5

SELECT DISTINCT client_id, 
    ClientTotal.month AS month, 
    total, 
    CASE
        WHEN total < MonthAvg.average THEN 'below'
        ELSE 'at or above'
    END AS comparison

FROM ClientTotal, MonthAvg 

WHERE ClientTotal.month = MonthAvg.month;