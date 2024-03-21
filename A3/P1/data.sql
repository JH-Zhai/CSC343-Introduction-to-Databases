INSERT INTO Own VALUES 
('The Corporation of Massey Hall and Roy Thomson Hall', 12345),
('Maple Leaf Sports & Entertainment', 67890);


INSERT INTO Venue VALUES 
('Massey Hall', 'Toronto', '178 Victoria Street', 12345, 01),
('Roy Thomson Hall', 'Toronto', '60 Simcoe St', 12345, 02),
('ScotiaBank Arena', 'Toronto', '40 Bay St', 67890, 03);

INSERT INTO Seat VALUES 
(01, 'floor', 'A1', true),
(01, 'floor', 'A2', true),
(01, 'floor', 'A3', true),
(01, 'floor', 'A4', false),
(01, 'floor', 'A5', false),
(01, 'floor', 'A6', false),
(01, 'floor', 'A7', false),
(01, 'floor', 'A8', true),
(01, 'floor', 'A9', true),
(01, 'floor', 'A10', true),
(01, 'floor', 'B1', false),
(01, 'floor', 'B2', false),
(01, 'floor', 'B3', false),
(01, 'floor', 'B4', false),
(01, 'floor', 'B5', false),
(01, 'floor', 'B6', false),
(01, 'floor', 'B7', false),
(01, 'floor', 'B8', false),
(01, 'floor', 'B9', false),
(01, 'floor', 'B10', false),
(01, 'balcony', 'C1', false),
(01, 'balcony', 'C2', false),
(01, 'balcony', 'C3', false),
(01, 'balcony', 'C4', false),
(01, 'balcony', 'C5', false),
(02, 'main hall', 'AA1', false),
(02, 'main hall', 'AA2', false),
(02, 'main hall', 'AA3', false),
(02, 'main hall', 'BB1', false),
(02, 'main hall', 'BB2', false),
(02, 'main hall', 'BB3', false),
(02, 'main hall', 'BB4', false),
(02, 'main hall', 'BB5', false),
(02, 'main hall', 'BB6', false),
(02, 'main hall', 'BB7', false),
(02, 'main hall', 'BB8', false),
(02, 'main hall', 'CC1', false),
(02, 'main hall', 'CC2', false),
(02, 'main hall', 'CC3', false),
(02, 'main hall', 'CC4', false),
(02, 'main hall', 'CC5', false),
(02, 'main hall', 'CC6', false),
(02, 'main hall', 'CC7', false),
(02, 'main hall', 'CC8', false),
(02, 'main hall', 'CC9', false),
(02, 'main hall', 'CC10', false),
(03, '100', 'row 1, seat 1', true),
(03, '100', 'row 1, seat 2', true),
(03, '100', 'row 1, seat 3', true),
(03, '100', 'row 1, seat 4', true),
(03, '100', 'row 1, seat 5', true),
(03, '100', 'row 2, seat 1', true),
(03, '100', 'row 2, seat 2', true),
(03, '100', 'row 2, seat 3', true),
(03, '100', 'row 2, seat 4', true),
(03, '100', 'row 2, seat 5', true),
(03, '200', 'row 1, seat 1', false),
(03, '200', 'row 1, seat 2', false),
(03, '200', 'row 1, seat 3', false),
(03, '200', 'row 1, seat 4', false),
(03, '200', 'row 1, seat 5', false),
(03, '200', 'row 2, seat 1', false),
(03, '200', 'row 2, seat 2', false),
(03, '200', 'row 2, seat 3', false),
(03, '200', 'row 2, seat 4', false),
(03, '200', 'row 2, seat 5', false),
(03, '300', 'row 1, seat 1', false),
(03, '300', 'row 1, seat 2', false),
(03, '300', 'row 1, seat 3', false),
(03, '300', 'row 1, seat 4', false),
(03, '300', 'row 1, seat 5', false),
(03, '300', 'row 2, seat 1', false),
(03, '300', 'row 2, seat 2', false),
(03, '300', 'row 2, seat 3', false),
(03, '300', 'row 2, seat 4', false),
(03, '300', 'row 2, seat 5', false);


INSERT INTO ConcertName VALUES 
('Ron Sexsmith'),
('Women''s Blues Review'),
('Mariah Carey - Merry Christmas to all'),
('TSO - Elf in Concert');


INSERT INTO Concert VALUES 
('Ron Sexsmith', 01, '2022-12-03', '19:30', 11),
('Women''s Blues Review', 01, '2022-11-25', '20:00', 22 ),
('Mariah Carey - Merry Christmas to all', 03, '2022-12-09', '20:00', 33),
('Mariah Carey - Merry Christmas to all', 03, '2022-12-11', '20:00', 44),
('TSO - Elf in Concert', 02, '2022-12-09', '19:30', 55),
('TSO - Elf in Concert', 02, '2022-12-10', '14:30', 66),
('TSO - Elf in Concert', 02, '2022-12-10', '19:30', 77);


INSERT INTO Price VALUES 
(11, 'floor', 130),
(11, 'balcony', 99),
(22, 'floor', 150),
(22, 'balcony', 125),
(33, '100', 986),
(33, '200', 244),
(33, '300', 176),
(44, '100', 936),
(44, '200', 194),
(44, '300', 126),
(55, 'main hall', 159),
(66, 'main hall', 159),
(77, 'main hall', 159);


INSERT INTO Users VALUES 
('ahightower'),
('d_targaryen'),
('cristonc');


INSERT INTO Ticket VALUES 
('ahightower', 22, 'floor', 'A5', '2022-10-15', '10:30'),
('ahightower', 22, 'balcony', 'C2', '2022-10-15', '10:30'),
('d_targaryen', 11, 'floor', 'B3', '2022-10-15', '10:30'),
('d_targaryen', 77, 'main hall', 'BB7', '2022-10-15', '10:30'),
('cristonc', 33, '100', 'row 1, seat 3', '2022-10-15', '10:30'),
('cristonc', 44, '200', 'row 2, seat 3', '2022-10-15', '10:30'),
('cristonc', 44, '200', 'row 2, seat 4', '2022-10-15', '10:30');