--for each user, how many tickets they bought
CREATE VIEW UserTicketCount AS
SELECT Users.username AS username, 
	COALESCE(COUNT(concert_id), 0) AS count
FROM Users 
	LEFT JOIN Ticket ON Users.username = Ticket.username
GROUP BY Users.username;

--SELECT * FROM UserTicketCount;


--username of the user(s) who bought most ticket
CREATE VIEW Q4Report AS
SELECT username
FROM UserTicketCount
WHERE count = 
	(SELECT MAX(count) FROM UserTicketCount);


SELECT * FROM Q4Report;

DROP VIEW Q4Report;
DROP VIEW UserTicketCount;