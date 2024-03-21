--This includes all tickets with thier price
CREATE VIEW TicketPrice AS
SELECT username, 
	Ticket.concert_id AS concert_id, 
	Ticket.section AS section, 
	identifier, 
	money
FROM Ticket, Price
WHERE Ticket.concert_id = Price.concert_id AND 
	Ticket.section = Price.section;

--SELECT * FROM TicketPrice;


--For each concert, how many money get from ticket
CREATE VIEW AllSoldPrice AS
SELECT Concert.concert_id AS concert_id, 
	Concert.concert_name AS concert_name, 
	COALESCE(SUM(money), 0) AS total_sold
FROM Concert 
	LEFT JOIN TicketPrice ON Concert.concert_id = TicketPrice.concert_id
GROUP BY Concert.concert_id, Concert.concert_name;

--SELECT * FROM AllSoldPrice;

--how many seats in each venue
CREATE VIEW SeatCount AS
SELECT Venue.venue_id AS venue_id, 
	COUNT(*) AS seat_count
FROM Venue 
	NATURAL JOIN Seat
GROUP BY Venue.venue_id;

--SELECT * FROM SeatCount;

--for each concert, the holding venue and how many ticket sold
CREATE VIEW TicketCount AS
SELECT Concert.concert_id AS concert_id, 
	Concert.concert_name AS concert_name, 
	venue_id, 
	COALESCE(COUNT(Ticket.username), 0) AS ticket_count
FROM Concert 
	LEFT JOIN Ticket ON Concert.concert_id = Ticket.concert_id
GROUP BY Concert.concert_id, Concert.concert_name;

--SELECT * FROM TicketCount;

--for each concert, total_sold: total value of all tickets sold, 
--percentage: percentage of the venue that was sold
CREATE VIEW Q1Report AS
SELECT AllSoldPrice.concert_id AS concert_id, 
	AllSoldPrice.concert_name AS concert_name, 
	total_sold, 
	ticket_count, 
	seat_count, 
	CONCAT((ticket_count::numeric/seat_count::numeric) * 100, '%') AS percentage
FROM AllSoldPrice, TicketCount, SeatCount
WHERE AllSoldPrice.concert_id = TicketCount.concert_id AND
	TicketCount.venue_id = SeatCount.venue_id
ORDER BY AllSoldPrice.concert_id;

SELECT * FROM Q1Report;

DROP VIEW Q1Report;
DROP VIEW TicketCount;
DROP VIEW SeatCount;
DROP VIEW AllSoldPrice;
DROP VIEW TicketPrice;