-- Rest bylaw.

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber, public;
DROP TABLE IF EXISTS q3 CASCADE;

CREATE TABLE q3(
    driver_id INTEGER,
    start DATE,
    driving INTERVAL,
    breaks INTERVAL
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS AllInfo CASCADE;
DROP VIEW IF EXISTS EachDuration CASCADE;
DROP VIEW IF EXISTS TotalDuration CASCADE;
DROP VIEW IF EXISTS LongWorkDay CASCADE;
DROP VIEW IF EXISTS EachBreak1 CASCADE;
DROP VIEW IF EXISTS EachBreak2 CASCADE;
DROP VIEW IF EXISTS EachBreak CASCADE;
DROP VIEW IF EXISTS LessBreakDay CASCADE;
DROP VIEW IF EXISTS HardDay CASCADE;

-- Define views for your intermediate steps here:


-- All info I need to solve this problem
CREATE VIEW AllInfo AS
SELECT driver_id, 
    Pickup.datetime AS pickup_time, 
    Dropoff.datetime AS dropoff_time, 
    Dispatch.request_id AS request_id
FROM ClockedIn, Dispatch, Pickup, Dropoff
WHERE ClockedIn.shift_id = Dispatch.shift_id AND
    Dispatch.request_id = Pickup.request_id AND
    Pickup.request_id = Dropoff.request_id;



-- Specify all valid durations
CREATE VIEW EachDuration AS
SELECT driver_id, 
    dropoff_time - pickup_time AS duration, 
    DATE(pickup_time) AS date
FROM AllInfo
WHERE DATE(pickup_time) = DATE(dropoff_time);



-- Each driver on each day's total duration
CREATE VIEW TotalDuration AS
SELECT driver_id, sum(duration) AS total_duration, date
FROM EachDuration
GROUP BY driver_id, date;



-- Date that the driver's total duration over 12 hours
CREATE VIEW LongWorkDay AS
SELECT driver_id, total_duration, date
FROM TotalDuration
WHERE total_duration >= (INTERVAL '12 hours'); 



-- Each breaks for those had at least 1 break on the day
CREATE VIEW EachBreak1 AS
SELECT a1.driver_id AS driver_id,
    MIN(a2.pickup_time) - a1.dropoff_time AS break,
    DATE(a1.dropoff_time) AS date
FROM AllInfo a1, AllInfo a2
WHERE a1.driver_id = a2.driver_id AND
    a1.request_id != a2.request_id AND
    a1.dropoff_time <= a2.pickup_time AND
    DATE(a1.dropoff_time) = DATE(a2.pickup_time)
GROUP BY a1.driver_id, a1.request_id, a1.dropoff_time;



-- 0 minutes for those had no break on the day
CREATE VIEW EachBreak2 AS 
SELECT driver_id, 
    (INTERVAL '0 minutes' ) AS break, 
    DATE(AllInfo.pickup_time) AS date
FROM AllInfo
WHERE NOT EXISTS(
    SELECT * 
    FROM EachBreak1
    WHERE AllInfo.driver_id = EachBreak1.driver_id AND
        DATE(AllInfo.pickup_time) = DATE(AllInfo.dropoff_time) AND
        DATE(AllInfo.dropoff_time) = EachBreak1.date);



-- All breaks for each driver on each day
CREATE VIEW EachBreak AS
(SELECT * FROM EachBreak1)
UNION
(SELECT * FROM EachBreak2);



-- Drives who not have any break longer than 15 minutes. 
CREATE VIEW LessBreakDay AS
SELECT driver_id, SUM(break) AS total_break, date
FROM EachBreak
GROUP BY driver_id, date
HAVING MAX(break) <= (INTERVAL '15 minutes');



-- Drivers on which day they had total duration of 12 h or more and
-- no break more than 15 min
CREATE VIEW HardDay AS
SELECT LongWorkDay.driver_id AS driver_id,
    total_duration, 
    total_break,
    LongWorkDay.date AS date
FROM LongWorkDay, LessBreakDay
WHERE LongWorkDay.driver_id = LessBreakDay.driver_id AND
    LongWorkDay.date = LessBreakDay.date;



-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q3
SELECT h0.driver_id AS driver_id, 
    h0.date AS start, 

    h0.total_duration + (
        SELECT total_duration
        FROM HardDay h3
        WHERE h0.driver_id = h3.driver_id AND (h0.date + (INTERVAL '1 day')) = h3.date
    ) + (
        SELECT total_duration
        FROM HardDay h4
        WHERE h0.driver_id = h4.driver_id AND (h0.date + (INTERVAL '2 day')) = h4.date
    ) AS driving, 

    h0.total_break + (
        SELECT total_break
        FROM HardDay h5
        WHERE h0.driver_id = h5.driver_id AND (h0.date + (INTERVAL '1 day')) = h5.date
    ) + (
        SELECT total_break
        FROM HardDay h6
        WHERE h0.driver_id = h6.driver_id AND (h0.date + (INTERVAL '2 day')) = h6.date
    )AS breaks

FROM HardDay h0
WHERE (h0.driver_id, DATE(h0.date + (INTERVAL '1 day'))) IN (
    SELECT h1.driver_id, h1.date
    FROM HardDay h1)
    AND
    (h0.driver_id, DATE(h0.date + (INTERVAL '2 day'))) IN (
    SELECT h2.driver_id, h2.date
    FROM HardDay h2);