-- Rainmakers.

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber, public;
DROP TABLE IF EXISTS q10 CASCADE;

CREATE TABLE q10(
    driver_id INTEGER,
    month CHAR(2),
    mileage_2020 FLOAT,
    billings_2020 FLOAT,
    mileage_2021 FLOAT,
    billings_2021 FLOAT,
    mileage_increase FLOAT,
    billings_increase FLOAT
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS AllDriver CASCADE;
DROP VIEW IF EXISTS AllYear CASCADE;
DROP VIEW IF EXISTS AllMonth CASCADE;
DROP VIEW IF EXISTS AllRides CASCADE;
DROP VIEW IF EXISTS AllBills CASCADE;
DROP VIEW IF EXISTS DriverMilePerMonth1 CASCADE;
DROP VIEW IF EXISTS DriverMilePerMonth2 CASCADE;
DROP VIEW IF EXISTS DriverMilePerMonth CASCADE;
DROP VIEW IF EXISTS DriverBilledPerMonth1 CASCADE;
DROP VIEW IF EXISTS DriverBilledPerMonth2 CASCADE;
DROP VIEW IF EXISTS DriverBilledPerMonth CASCADE;


-- Define views for your intermediate steps here:


-- all drivers' id
CREATE VIEW AllDriver AS

SELECT DISTINCT driver_id

FROM Driver;



-- 2020, 2021
CREATE VIEW AllYear AS

SELECT to_char(generate_series(2020,2021), '0909') AS year;



-- 01 - 12
CREATE VIEW AllMonth AS

SELECT to_char(generate_series(01,12), 'FM09') AS month;



-- all completed rides
CREATE VIEW AllRides AS

SELECT driver_id, 
    Request.request_id AS request_id,
    Request.source <@> Request.destination AS mileage,
    to_char(EXTRACT(YEAR FROM Request.datetime), '0909') AS year, 
    to_char(EXTRACT(MONTH FROM Request.datetime), 'FM09') AS month

FROM Request, Dispatch, ClockedIn, Dropoff, Billed

WHERE Request.request_id = Dispatch.request_id AND
    Dispatch.shift_id = ClockedIn.shift_id AND
    Request.request_id = Dropoff.request_id AND
    Dispatch.request_id = Billed.request_id;



-- all paid bills
CREATE VIEW AllBills AS

SELECT driver_id, 
    Request.request_id AS request_id,
    amount,
    to_char(EXTRACT(YEAR FROM Request.datetime), '0909') AS year, 
    to_char(EXTRACT(MONTH FROM Request.datetime), 'FM09') AS month

FROM Request, ClockedIn, Dispatch, Dropoff, Billed

WHERE Request.request_id = Dispatch.request_id AND
    ClockedIn.shift_id = Dispatch.shift_id AND
    Request.request_id = Dropoff.request_id AND
    Dispatch.request_id = Billed.request_id;



-- total mileage per month, for those have rides
CREATE VIEW DriverMilePerMonth1 AS

SELECT driver_id, 
    SUM(mileage) AS total_mileage,
    year, 
    month

FROM AllRides

GROUP BY driver_id, year, month;



-- total mileage 0 per month, for those have no rides
CREATE VIEW DriverMilePerMonth2 AS

SELECT driver_id,
    0 AS total_mileage,
    year, 
    month

FROM AllDriver, AllYear, AllMonth

WHERE NOT EXISTS(
    SELECT *
    FROM DriverMilePerMonth1
    WHERE DriverMilePerMonth1.driver_id = AllDriver.driver_id AND
        DriverMilePerMonth1.year = AllYear.year AND
        DriverMilePerMonth1.month = AllMonth.month);



-- total mileage per month, for all drivers
CREATE VIEW DriverMilePerMonth AS
(SELECT * FROM DriverMilePerMonth1) UNION (SELECT * FROM DriverMilePerMonth2);



-- total bills per month, for those have bills
CREATE VIEW DriverBilledPerMonth1 AS

SELECT driver_id, 
    SUM(amount) AS total_billed,
    year, 
    month

FROM AllBills

GROUP BY driver_id, year, month;



-- total bills per month, for those have no bills
CREATE VIEW DriverBilledPerMonth2 AS

SELECT driver_id,
    0 AS total_billed,
    year, 
    month

FROM AllDriver, AllYear, AllMonth

WHERE NOT EXISTS(
    SELECT *
    FROM DriverBilledPerMonth1
    WHERE DriverBilledPerMonth1.driver_id = AllDriver.driver_id AND
        DriverBilledPerMonth1.year = AllYear.year AND
        DriverBilledPerMonth1.month = AllMonth.month);



-- total billed per month, for all drivers
CREATE VIEW DriverBilledPerMonth AS
(SELECT * FROM DriverBilledPerMonth1) UNION (SELECT * FROM DriverBilledPerMonth2);


-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q10

SELECT AllDriver.driver_id AS driver_id,  
    AllMonth.month AS month,  
    m20.total_mileage AS mileage_2020,  
    b20.total_billed AS billings_2020,  
    m21.total_mileage AS mileage_2021,  
    b21.total_billed AS billings_2021,  
    m21.total_mileage - m20.total_mileage AS mileage_increase,  
    b21.total_billed - b20.total_billed AS billings_increase  
  
FROM AllDriver,   
    AllMonth,  
    DriverMilePerMonth m20,  
    DriverMilePerMonth m21,  
    DriverBilledPerMonth b20,  
    DriverBilledPerMonth b21  
  
WHERE AllDriver.driver_id = m20.driver_id AND  
    AllDriver.driver_id = m21.driver_id AND  
    AllDriver.driver_id = b20.driver_id AND  
    AllDriver.driver_id = b21.driver_id AND  
    m20.year = to_char(2020, '0909') AND
    m21.year = to_char(2021, '0909') AND
    b20.year = to_char(2020, '0909') AND
    b21.year = to_char(2021, '0909') AND 
    m20.month = AllMonth.month AND  
    m21.month = AllMonth.month AND  
    b20.month = AllMonth.month AND  
    b21.month = AllMonth.month

ORDER BY driver_id, month;