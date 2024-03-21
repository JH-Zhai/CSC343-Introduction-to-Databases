--for each owner, how many venues they own
CREATE VIEW Q2Report AS
SELECT owner_name, 
	phone, 
	COUNT(venue_id) AS venue_number
FROM Own 
	NATURAL JOIN Venue
GROUP BY owner_name, phone;

SELECT * FROM Q2Report;

DROP VIEW Q2Report;