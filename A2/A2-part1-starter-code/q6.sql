-- Frequent riders.

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber, public;
DROP TABLE IF EXISTS q6 CASCADE;

CREATE TABLE q6(
    client_id INTEGER,
    year CHAR(4),
    rides INTEGER
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS AllRides CASCADE;
DROP VIEW IF EXISTS AllYear CASCADE;
DROP VIEW IF EXISTS RidesPerYear1 CASCADE;
DROP VIEW IF EXISTS RidesPerYear2 CASCADE;
DROP VIEW IF EXISTS RidesPerYear CASCADE;
DROP VIEW IF EXISTS TopRidesNum CASCADE;
DROP VIEW IF EXISTS BottomRidesNum CASCADE;
DROP VIEW IF EXISTS TopClient CASCADE;
DROP VIEW IF EXISTS BottomClient CASCADE;

-- Define views for your intermediate steps here:


-- all rides info
CREATE VIEW AllRides AS

SELECT Client.client_id AS client_id,
    Request.request_id AS request_id,
    TO_CHAR(Request.datetime, 'YYYY') AS year

FROM Client, Request, Dropoff

WHERE Client.client_id = Request.client_id AND
    Request.request_id = Dropoff.request_id;



-- all year with rides
CREATE VIEW AllYear AS

SELECT DISTINCT year

FROM AllRides;



-- count rides for those having rides this year
CREATE VIEW RidesPerYear1 AS

SELECT client_id, year, COUNT(request_id) AS rides

FROM AllRides

GROUP BY client_id, year;



-- count rides for those not having rides this year
CREATE VIEW RidesPerYear2 AS

SELECT client_id, year, 0 AS rides

FROM AllYear, 
    (SELECT DISTINCT client_id
    FROM Client) AllClient

WHERE NOT EXISTS (
    SELECT *
    FROM RidesPerYear1 r
    WHERE r.client_id = AllClient.client_id AND
        r.year = AllYear.year);



-- count rides for everyone yearly
CREATE VIEW RidesPerYear AS
(SELECT * FROM RidesPerYear1) UNION (SELECT * FROM RidesPerYear2);



-- top 3 rides number
CREATE VIEW TopRidesNum AS

SELECT DISTINCT rides

FROM RidesPerYear

ORDER BY rides DESC

LIMIT 3;



-- bottom 3 rides number
CREATE VIEW BottomRidesNum AS

SELECT DISTINCT rides

FROM RidesPerYear

ORDER BY rides

LIMIT 3;



-- top clients
CREATE VIEW TopClient AS

SELECT client_id, year, RidesPerYear.rides AS rides

FROM RidesPerYear, TopRidesNum

WHERE RidesPerYear.rides = TopRidesNum.rides;



-- bottom clients
CREATE VIEW BottomClient AS

SELECT client_id, year, RidesPerYear.rides AS rides

FROM RidesPerYear, BottomRidesNum

WHERE RidesPerYear.rides = BottomRidesNum.rides;





-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q6
(SELECT * FROM TopClient) UNION (SELECT * FROM BottomClient);