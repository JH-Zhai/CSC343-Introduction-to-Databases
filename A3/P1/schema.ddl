-- Could not: 
--      1. Every venue has at least 10 seats.
--      2. Price of Ticket depends the concert and the section in which
--           the seat is located in the venue.
--
-- Did not: 
--      1. For every sections in the same venue, their names are unique
--          to enforce this, I need an extra table called "section" in  
--          which I give every section an id, and a corresponding venue_id,  
--          but this is tedious and not much helpful. So I made it an assumption.   
--
-- Extra Constraints:
--      1. In table Venue, (venue_name, city, street_address) is set to unique. 
--          Because, this make sure no such mistake that input 2 venues 
--          with same location will occur.
--      2. In table Ticket, (concert_id, section, identifier) is set to unique.
--          Because, this make sure no such mistake that sell the same seat 
--          of one concert multiple times will occur.
--
-- Assumption:
--      1. When inserting value into Tickets, section, indentifier do exist in 
--          the venue of that concert_id.
--      2. inserting value into seat, every sections in the same venue, their 
--          names are unique, do not make mistake here.



DROP SCHEMA IF EXISTS ticketchema cascade;
CREATE SCHEMA ticketchema;
SET search_path TO ticketchema;


-- store all conertname
CREATE TABLE ConcertName (
    concert_name varchar(55) NOT NULL,
    PRIMARY KEY (concert_name)
);


-- venue owner, and their phone number
CREATE TABLE Own (
    owner_name varchar(55) NOT NULL,
    phone bigint NOT NULL,
    PRIMARY KEY (phone)
);


-- for each venue, their name, loc, venue_id and owner's phone
CREATE TABLE Venue (
    venue_name varchar(55) NOT NULL,
    city varchar(30) NOT NULL,
    street_address varchar(30) NOT NULL,
    phone bigint NOT NULL REFERENCES Own,
    venue_id integer NOT NULL,
    UNIQUE (venue_name, city, street_address),
    PRIMARY KEY (venue_id)
);


-- for each concert, their name, holding venue, time and concert_id
CREATE TABLE Concert (
    concert_name varchar(55) NOT NULL REFERENCES ConcertName,
    venue_id integer NOT NULL REFERENCES Venue,
    date date NOT NULL,
    time time NOT NULL,
    concert_id integer NOT NULL,
    UNIQUE (concert_name, venue_id, date, time),
    UNIQUE (venue_id, date, time),
    PRIMARY KEY (concert_id)
);


-- for each seat, their loc and whether accessible
CREATE TABLE Seat (
    venue_id integer NOT NULL REFERENCES Venue,
    section varchar(25) NOT NULL,
    identifier varchar(25) NOT NULL,
    accessible boolean NOT NULL DEFAULT false,
    PRIMARY KEY (venue_id, section, identifier)
);


-- for each user, their user name
CREATE TABLE Users (
    username varchar(40) NOT NULL,
    PRIMARY KEY (username)
);


-- for each concert and section, the corresponding price
CREATE TABLE Price (
    concert_id integer NOT NULL REFERENCES Concert,
    section varchar(25) NOT NULL,
    money numeric NOT NULL,
    PRIMARY KEY (concert_id, section)
);


-- for each ticket, who bought it, which concert, which seat, 
-- and purchase time.
CREATE TABLE Ticket (
    username varchar(30) NOT NULL REFERENCES Users,
    concert_id integer NOT NULL REFERENCES Concert,
    section varchar(25) NOT NULL,
    identifier varchar(25) NOT NULL,
    date date NOT NULL,
    time time NOT NULL,
    UNIQUE (concert_id, section, identifier),
    PRIMARY KEY (username, concert_id, section, identifier)
);