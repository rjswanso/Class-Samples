-- Group By with Aggregate Functions
SELECT 
    Year, COUNT(ID)
FROM
    Movie
GROUP BY Year;

-- Left Join Note: Don't include right table in FROM statement
SELECT Title,Year,Description 
FROM Movie
LEFT JOIN Rating
ON RatingCode = Code;

-- self inner join w/ aliases and renaming column headers
SELECT A.FirstName AS Employee, B.FirstName AS Manager
FROM Employee A
INNER JOIN Employee B
ON B.ID = A.ManagerID
ORDER BY Employee;

-- Order by multiple columns:
SELECT LessonDateTime,HorseID,FirstName,LastName
FROM LessonSchedule,Student
WHERE StudentID = ID
ORDER BY LessonDateTime,HorseID;

-- Multiple Joins. NOTE the WHERE clause location
SELECT LessonDateTime,FirstName,LastName,RegisteredName
FROM LessonSchedule
LEFT JOIN Student ON StudentID = Student.ID
LEFT JOIN Horse ON HorseID = Horse.ID
WHERE LessonDateTime LIKE '2020-02-01%'
ORDER BY LessonDateTime,RegisteredName;

-- Nested Queries
SELECT RegisteredName,Height FROM Horse
WHERE Height > (SELECT AVG(Height) FROM Horse)
ORDER BY Height;
  
  -- Alter Table Columns Name and Type
ALTER TABLE Movie ADD Producer VARCHAR(50);
ALTER TABLE Movie DROP Genre;
ALTER TABLE Movie CHANGE Year ReleaseYear SMALLINT;

-- Insert w/ multiple rows and a null value (Note Null value)
INSERT INTO Horse (RegisteredName,Breed,Height,BirthDate)
VALUES 
('Babe','Quarter Horse',15.3,'2015-02-10'),
('Independence','Holsteiner',16.0,'2017-03-13'),
('Ellie','Saddlebred',15.0,'2016-12-22'),
(NULL,'Egyptian Arab',14.9,'2019-10-12');

-- Update Cells
UPDATE Horse SET Height = 15.6 WHERE ID = 2; 
UPDATE Horse SET RegisteredName = 'Lady Luck',BirthDate = '2015-05-01' WHERE ID = 4;
UPDATE Horse SET Breed = NULL WHERE BirthDate >= '2016-12-22';

-- Delete Rows
Delete FROM Horse WHERE ID = 5;
Delete FROM Horse WHERE Breed = 'Holsteiner' OR Breed = 'Paint';
Delete FROM Horse WHERE BirthDate < '2013-03-13';

-- Between statement:
SELECT RegisteredName,Height,BirthDate FROM Horse
WHERE Height BETWEEN 15.0 AND 16.0 
OR BirthDate >= '2020-01-01';

-- Create Table / Notice Using small int unsigned
CREATE TABLE Movie (
ID SMALLINT UNSIGNED check(ID <= 50000),
Title VARCHAR(50),
Rating CHAR(4),
ReleaseDate DATE,
Budget DECIMAL(8,2));

-- Create table PRIMARY KEY / UNIQUE / NOT NULL / DEFAULT
CREATE TABLE Student (
ID smallint unsigned AUTO_INCREMENT PRIMARY KEY,
FirstName VARCHAR(20) NOT NULL,
LastName VARCHAR(30) NOT NULL,
Street VARCHAR(50) NOT NULL,
City VARCHAR(20) NOT NULL,
State CHAR(2) NOT NULL DEFAULT 'TX',
Zip mediumint unsigned NOT NULL,
Phone CHAR(10) NOT NULL,
Email VARCHAR(30) UNIQUE );

-- CREATE TAble with IN statement and CHECKS
CREATE TABLE Horse (
ID smallint unsigned auto_increment PRIMARY KEY,
RegisteredName VARCHAR(15) NOT NULL,
Breed VARCHAR(20) CHECK(Breed IN ('Egyptian Arab', 'Holsteiner', 'Quarter Horse', 'Paint', 'Saddlebred')),
Height DECIMAL(3,1) CHECK(Height BETWEEN 10.0 AND 20.0),
BirthDate date CHECK(BirthDate >= '2015-01-01'));

-- Create Table Primary/Foreign KEy and ON DELETE
CREATE TABLE LessonSchedule (
HorseID smallint unsigned NOT NULL,
StudentID smallint unsigned,
LessonDateTime datetime NOT NULL,
PRIMARY KEY (HorseID, LessonDateTime),
FOREIGN KEY (HorseID) REFERENCES Horse(ID)
ON DELETE CASCADE,
FOREIGN KEY (StudentID) REFERENCES Student(ID)
ON DELETE SET NULL);

-- Createa nd view VIEW TABLE w/ optional column names 
CREATE VIEW MyMovies (col1,col2,col3) 
AS SELECT Title,Genre,Year FROM Movie;
-- SELECT * FROM MyMovies; <-- queries view table
DROP VIEW MyMovies; -- Drops view table
