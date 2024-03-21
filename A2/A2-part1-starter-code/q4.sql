-- Do drivers improve?

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber, public;
DROP TABLE IF EXISTS q4 CASCADE;

CREATE TABLE q4(
    type VARCHAR(9),
    number INTEGER,
    early FLOAT,
    late FLOAT
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS AllRides CASCADE;
DROP VIEW IF EXISTS Driver10 CASCADE;
DROP VIEW IF EXISTS DriverDates CASCADE;
DROP VIEW IF EXISTS EarlyDates CASCADE;
DROP VIEW IF EXISTS LateDates CASCADE;
DROP VIEW IF EXISTS TrainedEarly CASCADE;
DROP VIEW IF EXISTS TrainedLate CASCADE;
DROP VIEW IF EXISTS UntrainedEarly CASCADE;
DROP VIEW IF EXISTS UntrainedLate CASCADE;
DROP VIEW IF EXISTS Trained CASCADE;
DROP VIEW IF EXISTS Untrained CASCADE;


-- Define views for your intermediate steps here:




-- all rides are recorded here
CREATE VIEW AllRides AS

SELECT DISTINCT Driver.driver_id AS driver_id,
    Dispatch.request_id AS request_id,
    DriverRating.rating AS rate,
    DATE(Request.datetime) AS date,
    Driver.trained AS type 

FROM Driver, ClockedIn, Request, Dispatch, Dropoff, DriverRating

WHERE Driver.driver_id = ClockedIn.driver_id AND
    ClockedIn.shift_id = Dispatch.shift_id AND
    Dispatch.request_id = Request.request_id AND
    Dispatch.request_id = Dropoff.request_id AND
    Dropoff.request_id = DriverRating.request_id;



-- Drivers' id who has 10 or more distinct date
CREATE VIEW Driver10 AS

SELECT driver_id

FROM AllRides

GROUP BY driver_id

HAVING count(DISTINCT date) >= 10;



-- Driver and date they have rides
CREATE VIEW DriverDates AS

SELECT DISTINCT AllRides.driver_id AS driver_id, 
    date

FROM AllRides, Driver10

WHERE AllRides.driver_id = Driver10.driver_id;



-- first 5 days for each driver
CREATE VIEW EarlyDates AS

SELECT rank_filter.driver_id AS driver_id,
    rank_filter.date AS date

FROM (
    SELECT DriverDates.*,
    RANK() OVER(
        PARTITION BY driver_id
        ORDER BY date
    )
    FROM DriverDates) rank_filter

WHERE rank <= 5;



-- 6 - 10 days for each driver
CREATE VIEW LateDates AS

SELECT rank_filter.driver_id AS driver_id,
    rank_filter.date AS date

FROM (
    SELECT DriverDates.*,
    RANK() OVER(
        PARTITION BY driver_id
        ORDER BY date
    )
    FROM DriverDates) rank_filter

WHERE rank > 5 AND rank <= 10;



-- ealy days trained driver average
CREATE VIEW TrainedEarly AS

SELECT EarlyDates.driver_id AS driver_id,
    AVG(rate) AS avg_rate,
    'trained' AS type

FROM EarlyDates, AllRides

WHERE EarlyDates.driver_id = AllRides.driver_id AND
    EarlyDates.date = AllRides.date AND
    AllRides.type = TRUE

GROUP BY EarlyDates.driver_id;



-- late days trained driver average
CREATE VIEW TrainedLate AS

SELECT LateDates.driver_id AS driver_id,
    AVG(rate) AS avg_rate,
    'trained' AS type

FROM LateDates, AllRides

WHERE LateDates.driver_id = AllRides.driver_id AND
    LateDates.date = AllRides.date AND
    AllRides.type = TRUE

GROUP BY LateDates.driver_id;



-- ealy days untrained driver average
CREATE VIEW UntrainedEarly AS

SELECT EarlyDates.driver_id AS driver_id,
    AVG(rate) AS avg_rate,
    'untrained' AS type

FROM EarlyDates, AllRides

WHERE EarlyDates.driver_id = AllRides.driver_id AND
    EarlyDates.date = AllRides.date AND
    AllRides.type = FALSE

GROUP BY EarlyDates.driver_id;



-- late days untrained driver average
CREATE VIEW UntrainedLate AS

SELECT LateDates.driver_id AS driver_id,
    AVG(rate) AS avg_rate,
    'untrained' AS type

FROM LateDates, AllRides

WHERE LateDates.driver_id = AllRides.driver_id AND
    LateDates.date = AllRides.date AND
    AllRides.type = FALSE

GROUP BY LateDates.driver_id;



-- trained summary
CREATE VIEW Trained AS

SELECT 'trained' AS type,
    number, early, late

FROM 
    (SELECT AVG(avg_rate) AS early,
        count(driver_id) AS number
    FROM TrainedEarly) e, 
    (SELECT AVG(avg_rate) AS late
    FROM TrainedLate
    )l;



-- untrained summary
CREATE VIEW Untrained AS

SELECT 'untrained' AS type, 
    number, early, late

FROM 
    (SELECT AVG(avg_rate) AS early,
        count(driver_id) AS number
    FROM UntrainedEarly) e, 
    (SELECT AVG(avg_rate) AS late
    FROM UntrainedLate
    )l;



-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q4
(SELECT * FROM Trained) UNION (SELECT * FROM Untrained);
