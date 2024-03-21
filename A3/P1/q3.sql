--for each venue, percentage of accessible seats
CREATE VIEW Q3Report AS 
SELECT venue_id, 
	venue_name, 
	COUNT(*) FILTER (WHERE accessible IS TRUE ) AS acc_count, 
	COUNT(*) AS seat_count, 
	CONCAT
	(((COUNT(*) FILTER (WHERE accessible IS TRUE))::numeric/COUNT(*)::numeric)* 100, '%')
	AS percentage
FROM Venue NATURAL JOIN Seat
GROUP BY venue_id, venue_name
ORDER BY venue_id;

SELECT * FROM Q3Report;

DROP VIEW Q3Report;