CREATE DATABASE DDIBProject;
USE DDIBProject;

CREATE TABLE Provinces (
ProvinceID DECIMAL(2) NOT NULL PRIMARY KEY,
ProvinceName VARCHAR(25) NOT NULL);

CREATE TABLE Patient (
HCN DECIMAL(10) NOT NULL PRIMARY KEY,
ProvinceID DECIMAL(2) NOT NULL,
FirstName VARCHAR(255) NOT NULL,
LastName VARCHAR(255) NOT NULL,
Gender CHAR(1) NOT NULL,
DOB DATE NOT NULL,
GeneralNotes VARCHAR(MAX) NOT NULL,
RXFilled VARCHAR(1000) NOT NULL,
FamilyHistory VARCHAR(MAX) NOT NULL,
FOREIGN KEY (ProvinceID) REFERENCES Provinces(ProvinceID));

CREATE TABLE Physician (
PhysicianID DECIMAL(12) NOT NULL PRIMARY KEY,
FirstName VARCHAR(255),
LastName VARCHAR(255),
ProvinceID DECIMAL(2) NOT NULL,
Specialty VARCHAR(32) NOT NULL,
FOREIGN KEY (ProvinceID) REFERENCES Provinces(ProvinceID));

CREATE TABLE DocVisit (
DocVisitID DECIMAL(12) NOT NULL PRIMARY KEY,
HCN DECIMAL (10) NOT NULL,
PhysicianID DECIMAL(12) NOT NULL,
VisitDate DATE NOT NULL,
Notes VARCHAR(MAX),
FOREIGN KEY (HCN) REFERENCES Patient(HCN),
FOREIGN KEY (PhysicianID) REFERENCES Physician(PhysicianID));

CREATE TABLE Pharmacy (
PharmacyID DECIMAL(12) NOT NULL PRIMARY KEY,
ProvinceID DECIMAL(2) NOT NULL,
FOREIGN KEY (ProvinceID) REFERENCES Provinces(ProvinceID));

CREATE TABLE PharmVisit (
PharmVisitID DECIMAL(12) NOT NULL PRIMARY KEY,
HCN DECIMAL(10) NOT NULL,
PharmacyID DECIMAL(12) NOT NULL,
VisitDate DATE NOT NULL,
FOREIGN KEY (HCN) REFERENCES Patient(HCN),
FOREIGN KEY (PharmacyID) REFERENCES Pharmacy(PharmacyID));

CREATE TABLE Prescriptions (
RXID DECIMAL(5) NOT NULL PRIMARY KEY,
RXName VARCHAR(32) NOT NULL);

CREATE TABLE RXLink (
RXID DECIMAL(5) NOT NULL,
HCN DECIMAL(10) NOT NULL,
PharmVisitID DECIMAL(12) NOT NULL,
FOREIGN KEY (RXID) REFERENCES Prescriptions(RXID),
FOREIGN KEY (HCN) REFERENCES Patient(HCN),
FOREIGN KEY (PharmVisitID) REFERENCES PharmVisit(PharmVisitID));

CREATE TABLE GP (
PhysicianID DECIMAL(12) NOT NULL PRIMARY KEY,
FOREIGN KEY (PhysicianID) REFERENCES Physician(PhysicianID));

CREATE TABLE Internist (
PhysicianID DECIMAL(12) NOT NULL PRIMARY KEY,
FOREIGN KEY (PhysicianID) REFERENCES Physician(PhysicianID));

CREATE TABLE Pediatrician (
PhysicianID DECIMAL(12) NOT NULL PRIMARY KEY,
FOREIGN KEY (PhysicianID) REFERENCES Physician(PhysicianID));

CREATE TABLE Male (
HCN DECIMAL(10) NOT NULL PRIMARY KEY,
FOREIGN KEY (HCN) REFERENCES Patient(HCN));

CREATE TABLE Female (
HCN DECIMAL(10) NOT NULL PRIMARY KEY,
FOREIGN KEY (HCN) REFERENCES Patient(HCN));

CREATE TABLE Intersex (
HCN DECIMAL(10) NOT NULL PRIMARY KEY,
FOREIGN KEY (HCN) REFERENCES Patient(HCN));

CREATE TABLE RXHistory (
RXChangeID DECIMAL(10) NOT NULL PRIMARY KEY,
HCN DECIMAL(10) NOT NULL,
PastRXs VARCHAR(1000) NOT NULL,
NewRXs VARCHAR(1000) NOT NULL,
FillDate DATE NOT NULL,
FOREIGN KEY (HCN) REFERENCES Patient(HCN));

-- History Table (in the future: maybe add support for RX fills)
CREATE TABLE PatientHistory (
HistoryChangeID DECIMAL(12) NOT NULL PRIMARY KEY,
HCN DECIMAL(10) NOT NULL,
PastNotes VARCHAR(MAX) NOT NULL,
NewNotes VARCHAR(MAX) NOT NULL,
ChangeDate DATE NOT NULL,
FOREIGN KEY (HCN) REFERENCES Patient(HCN));

CREATE TRIGGER PatientHistoryTrigger
ON Patient
AFTER UPDATE
AS
BEGIN
	DECLARE @PastNotes VARCHAR(MAX) = (SELECT GeneralNotes FROM DELETED);
	DECLARE @NewNotes VARCHAR(MAX) = (SELECT GeneralNotes FROM INSERTED);

	IF UPDATE(GeneralNotes)
		INSERT INTO PatientHistory(HistoryChangeID, HCN, PastNotes, NewNotes, ChangeDate)
		VALUES(ISNULL((SELECT MAX(HistoryChangeID)+1 FROM PatientHistory), 1), (SELECT HCN FROM INSERTED),
			   @PastNotes, @NewNotes, GETDATE());
END;

CREATE INDEX PatientProvinceIdx
ON Patient(ProvinceID);

CREATE INDEX PhysicianProvinceIdx
ON Physician(ProvinceID);

CREATE INDEX DocVisitHCNIdx
ON DocVisit(HCN);

CREATE INDEX DocVisitPhysicianIdx
ON DocVisit(PhysicianID);

CREATE INDEX PharmacyProvinceIdx
ON Pharmacy(ProvinceID);

CREATE INDEX PharmVisitHCNIdx
ON PharmVisit(HCN);

CREATE INDEX PharmVisitPharmacyIdx
ON PharmVisit(PharmacyID);

CREATE INDEX RXLinkRXIdx
ON RXLink(RXID);

CREATE INDEX RXLinkHCNIdx
ON RXLink(HCN);

CREATE INDEX RXLinkPharmVisitIdx
ON RXLink(PharmVisitID);

CREATE INDEX PhysicianSpecialtyIdx
ON Physician(Specialty);

CREATE INDEX DocVisitDateIdx
ON DocVisit(VisitDate);

CREATE INDEX PharmVisitDateIdx
ON PharmVisit(VisitDate);

-- Populating Provinces table
INSERT INTO Provinces VALUES(01, 'British Columbia')
INSERT INTO Provinces VALUES(02, 'Alberta')
INSERT INTO Provinces VALUES(03, 'Saskatchewan')
INSERT INTO Provinces VALUES(04, 'Manitoba')
INSERT INTO Provinces VALUES(05, 'Ontario')
INSERT INTO Provinces VALUES(06, 'Quebec')
INSERT INTO Provinces VALUES(07, 'New Brunswick')
INSERT INTO Provinces VALUES(08, 'Prince Edward Island')
INSERT INTO Provinces VALUES(09, 'Nova Scotia')
INSERT INTO Provinces VALUES(10, 'Newfoundland and Labrador')
INSERT INTO Provinces VALUES(11, 'Yukon')
INSERT INTO Provinces VALUES(12, 'Northwest Territories')
INSERT INTO Provinces VALUES(13, 'Nunavut')

-- Populating Physician table using Mockaroo
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (1, 'Lem', 'Savil', 1, 'GP');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (2, 'Enid', 'Shill', 2, 'Internist');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (3, 'Leia', 'Copcote', 3, 'Pediatrician');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (4, 'Noll', 'Brilleman', 4, 'GP');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (5, 'Verena', 'Medforth', 5, 'Internist');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (6, 'Esme', 'Tamas', 6, 'Pediatrician');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (7, 'Stan', 'Joddins', 7, 'GP');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (8, 'Tessa', 'Sheerin', 8, 'Internist');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (9, 'Valenka', 'Peskin', 9, 'Pediatrician');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (10, 'Ario', 'Cota', 10, 'GP');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (11, 'Nancey', 'Landy', 11, 'Internist');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (12, 'Sherm', 'Hadley', 12, 'Pediatrician');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (13, 'Carol', 'Sedgeman', 13, 'GP');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (14, 'Ibbie', 'Berdale', 1, 'Internist');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (15, 'Erl', 'Osborn', 2, 'Pediatrician');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (16, 'Willie', 'Esley', 3, 'GP');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (17, 'Thatcher', 'Treacy', 4, 'Internist');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (18, 'Morten', 'Treverton', 5, 'Pediatrician');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (19, 'Kanya', 'Schooling', 6, 'GP');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (20, 'Rhea', 'Rosenthaler', 7, 'Internist');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (21, 'Uri', 'Ottey', 8, 'Pediatrician');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (22, 'Bradney', 'Albinson', 9, 'GP');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (23, 'Nerte', 'Hatzar', 10, 'Internist');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (24, 'Casandra', 'Gianiello', 11, 'Pediatrician');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (25, 'Ellswerth', 'Beggan', 12, 'GP');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (26, 'Fionna', 'Stiff', 13, 'Internist');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (27, 'Rolfe', 'Moncreif', 1, 'Pediatrician');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (28, 'Maud', 'MacMeeking', 2, 'GP');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (29, 'Edgard', 'Gasnoll', 3, 'Internist');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (30, 'Annadiane', 'Josupeit', 4, 'Pediatrician');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (31, 'Sileas', 'Wannes', 5, 'GP');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (32, 'Carly', 'Arkin', 6, 'Internist');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (33, 'Lesli', 'Seivwright', 7, 'Pediatrician');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (34, 'Boot', 'Tomczykowski', 8, 'GP');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (35, 'Chaim', 'Meijer', 9, 'Internist');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (36, 'Felice', 'Walwood', 10, 'Pediatrician');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (37, 'Dirk', 'Badsworth', 11, 'GP');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (38, 'Selma', 'Windmill', 12, 'Internist');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (39, 'Ryley', 'Kaasmann', 13, 'Pediatrician');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (40, 'Candie', 'Yendall', 1, 'GP');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (41, 'Amargo', 'Howlings', 2, 'Internist');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (42, 'Teresina', 'Bestwick', 3, 'Pediatrician');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (43, 'Thaddus', 'Dioniso', 4, 'GP');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (44, 'Sidonia', 'Tilson', 5, 'Internist');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (45, 'Tessi', 'Renny', 6, 'Pediatrician');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (46, 'Brand', 'Mourant', 7, 'GP');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (47, 'Darn', 'Rubinowitsch', 8, 'Internist');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (48, 'Gloriana', 'Bollans', 9, 'Pediatrician');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (49, 'Katusha', 'Temlett', 10, 'GP');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (50, 'Flossi', 'Hayselden', 11, 'Internist');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (51, 'Martica', 'Pettie', 12, 'Pediatrician');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (52, 'Mark', 'Downing', 13, 'GP');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (53, 'Shelia', 'Davis', 1, 'Internist');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (54, 'Felisha', 'Thrustle', 2, 'Pediatrician');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (55, 'Brett', 'Hearmon', 3, 'GP');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (56, 'Veronika', 'Silveston', 4, 'Internist');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (57, 'Arlina', 'Bales', 5, 'Pediatrician');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (58, 'Dare', 'Scholl', 6, 'GP');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (59, 'Kile', 'Birchall', 7, 'Internist');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (60, 'Pippo', 'Brummell', 8, 'Pediatrician');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (61, 'Charity', 'McManamon', 9, 'GP');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (62, 'Moina', 'Duesbury', 10, 'Internist');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (63, 'Marlowe', 'Cathersides', 11, 'Pediatrician');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (64, 'Cirilo', 'Pallant', 12, 'GP');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (65, 'Montgomery', 'Kaasmann', 13, 'Internist');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (66, 'Alvinia', 'Puddicombe', 1, 'Pediatrician');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (67, 'Nadya', 'Shelliday', 2, 'GP');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (68, 'Caryn', 'Horstead', 3, 'Internist');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (69, 'Terry', 'Unwin', 4, 'Pediatrician');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (70, 'Eddy', 'Souttar', 5, 'GP');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (71, 'Orbadiah', 'Paireman', 6, 'Internist');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (72, 'Findley', 'McHugh', 7, 'Pediatrician');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (73, 'Violette', 'Meardon', 8, 'GP');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (74, 'Winn', 'Kohneke', 9, 'Internist');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (75, 'Ulick', 'Halley', 10, 'Pediatrician');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (76, 'Othilia', 'Bowkett', 11, 'GP');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (77, 'Winnifred', 'Darth', 12, 'Internist');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (78, 'Malinde', 'Warke', 13, 'Pediatrician');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (79, 'Mada', 'Hebburn', 1, 'GP');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (80, 'Faydra', 'Minall', 2, 'Internist');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (81, 'Nicky', 'Cardoo', 3, 'Pediatrician');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (82, 'Kassia', 'Purvess', 4, 'GP');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (83, 'Keefer', 'Rawll', 5, 'Internist');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (84, 'Rickey', 'Handlin', 6, 'Pediatrician');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (85, 'Piggy', 'Rizzardi', 7, 'GP');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (86, 'Gretta', 'Nulty', 8, 'Internist');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (87, 'Talyah', 'Sherringham', 9, 'Pediatrician');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (88, 'Natalie', 'Feige', 10, 'GP');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (89, 'Karlotte', 'Shackesby', 11, 'Internist');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (90, 'Denys', 'Wickling', 12, 'Pediatrician');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (91, 'Riobard', 'Antley', 13, 'GP');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (92, 'Krissy', 'Onslow', 1, 'Internist');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (93, 'Loy', 'Bull', 2, 'Pediatrician');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (94, 'Marcelo', 'Bithell', 3, 'GP');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (95, 'Zach', 'Joist', 4, 'Internist');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (96, 'Dianna', 'Haffner', 5, 'Pediatrician');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (97, 'Marcelle', 'Magovern', 6, 'GP');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (98, 'Addi', 'Wickerson', 7, 'Internist');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (99, 'Pattin', 'Clopton', 8, 'Pediatrician');
insert into Physician (PhysicianID, FirstName, LastName, ProvinceId, Specialty) values (100, 'Maggi', 'Barbrook', 9, 'GP');

-- Populating Pharmacy table using Mockaroo
insert into Pharmacy (PharmacyID, ProvinceID) values (1, 1);
insert into Pharmacy (PharmacyID, ProvinceID) values (2, 2);
insert into Pharmacy (PharmacyID, ProvinceID) values (3, 3);
insert into Pharmacy (PharmacyID, ProvinceID) values (4, 4);
insert into Pharmacy (PharmacyID, ProvinceID) values (5, 5);
insert into Pharmacy (PharmacyID, ProvinceID) values (6, 6);
insert into Pharmacy (PharmacyID, ProvinceID) values (7, 7);
insert into Pharmacy (PharmacyID, ProvinceID) values (8, 8);
insert into Pharmacy (PharmacyID, ProvinceID) values (9, 9);
insert into Pharmacy (PharmacyID, ProvinceID) values (10, 10);
insert into Pharmacy (PharmacyID, ProvinceID) values (11, 11);
insert into Pharmacy (PharmacyID, ProvinceID) values (12, 12);
insert into Pharmacy (PharmacyID, ProvinceID) values (13, 13);
insert into Pharmacy (PharmacyID, ProvinceID) values (14, 1);
insert into Pharmacy (PharmacyID, ProvinceID) values (15, 2);
insert into Pharmacy (PharmacyID, ProvinceID) values (16, 3);
insert into Pharmacy (PharmacyID, ProvinceID) values (17, 4);
insert into Pharmacy (PharmacyID, ProvinceID) values (18, 5);
insert into Pharmacy (PharmacyID, ProvinceID) values (19, 6);
insert into Pharmacy (PharmacyID, ProvinceID) values (20, 7);
insert into Pharmacy (PharmacyID, ProvinceID) values (21, 8);
insert into Pharmacy (PharmacyID, ProvinceID) values (22, 9);
insert into Pharmacy (PharmacyID, ProvinceID) values (23, 10);
insert into Pharmacy (PharmacyID, ProvinceID) values (24, 11);
insert into Pharmacy (PharmacyID, ProvinceID) values (25, 12);
insert into Pharmacy (PharmacyID, ProvinceID) values (26, 13);
insert into Pharmacy (PharmacyID, ProvinceID) values (27, 1);
insert into Pharmacy (PharmacyID, ProvinceID) values (28, 2);
insert into Pharmacy (PharmacyID, ProvinceID) values (29, 3);
insert into Pharmacy (PharmacyID, ProvinceID) values (30, 4);
insert into Pharmacy (PharmacyID, ProvinceID) values (31, 5);
insert into Pharmacy (PharmacyID, ProvinceID) values (32, 6);
insert into Pharmacy (PharmacyID, ProvinceID) values (33, 7);
insert into Pharmacy (PharmacyID, ProvinceID) values (34, 8);
insert into Pharmacy (PharmacyID, ProvinceID) values (35, 9);
insert into Pharmacy (PharmacyID, ProvinceID) values (36, 10);
insert into Pharmacy (PharmacyID, ProvinceID) values (37, 11);
insert into Pharmacy (PharmacyID, ProvinceID) values (38, 12);
insert into Pharmacy (PharmacyID, ProvinceID) values (39, 13);
insert into Pharmacy (PharmacyID, ProvinceID) values (40, 1);
insert into Pharmacy (PharmacyID, ProvinceID) values (41, 2);
insert into Pharmacy (PharmacyID, ProvinceID) values (42, 3);
insert into Pharmacy (PharmacyID, ProvinceID) values (43, 4);
insert into Pharmacy (PharmacyID, ProvinceID) values (44, 5);
insert into Pharmacy (PharmacyID, ProvinceID) values (45, 6);
insert into Pharmacy (PharmacyID, ProvinceID) values (46, 7);
insert into Pharmacy (PharmacyID, ProvinceID) values (47, 8);
insert into Pharmacy (PharmacyID, ProvinceID) values (48, 9);
insert into Pharmacy (PharmacyID, ProvinceID) values (49, 10);
insert into Pharmacy (PharmacyID, ProvinceID) values (50, 11);
insert into Pharmacy (PharmacyID, ProvinceID) values (51, 12);
insert into Pharmacy (PharmacyID, ProvinceID) values (52, 13);
insert into Pharmacy (PharmacyID, ProvinceID) values (53, 1);
insert into Pharmacy (PharmacyID, ProvinceID) values (54, 2);
insert into Pharmacy (PharmacyID, ProvinceID) values (55, 3);
insert into Pharmacy (PharmacyID, ProvinceID) values (56, 4);
insert into Pharmacy (PharmacyID, ProvinceID) values (57, 5);
insert into Pharmacy (PharmacyID, ProvinceID) values (58, 6);
insert into Pharmacy (PharmacyID, ProvinceID) values (59, 7);
insert into Pharmacy (PharmacyID, ProvinceID) values (60, 8);
insert into Pharmacy (PharmacyID, ProvinceID) values (61, 9);
insert into Pharmacy (PharmacyID, ProvinceID) values (62, 10);
insert into Pharmacy (PharmacyID, ProvinceID) values (63, 11);
insert into Pharmacy (PharmacyID, ProvinceID) values (64, 12);
insert into Pharmacy (PharmacyID, ProvinceID) values (65, 13);
insert into Pharmacy (PharmacyID, ProvinceID) values (66, 1);
insert into Pharmacy (PharmacyID, ProvinceID) values (67, 2);
insert into Pharmacy (PharmacyID, ProvinceID) values (68, 3);
insert into Pharmacy (PharmacyID, ProvinceID) values (69, 4);
insert into Pharmacy (PharmacyID, ProvinceID) values (70, 5);
insert into Pharmacy (PharmacyID, ProvinceID) values (71, 6);
insert into Pharmacy (PharmacyID, ProvinceID) values (72, 7);
insert into Pharmacy (PharmacyID, ProvinceID) values (73, 8);
insert into Pharmacy (PharmacyID, ProvinceID) values (74, 9);
insert into Pharmacy (PharmacyID, ProvinceID) values (75, 10);
insert into Pharmacy (PharmacyID, ProvinceID) values (76, 11);
insert into Pharmacy (PharmacyID, ProvinceID) values (77, 12);
insert into Pharmacy (PharmacyID, ProvinceID) values (78, 13);
insert into Pharmacy (PharmacyID, ProvinceID) values (79, 1);
insert into Pharmacy (PharmacyID, ProvinceID) values (80, 2);
insert into Pharmacy (PharmacyID, ProvinceID) values (81, 3);
insert into Pharmacy (PharmacyID, ProvinceID) values (82, 4);
insert into Pharmacy (PharmacyID, ProvinceID) values (83, 5);
insert into Pharmacy (PharmacyID, ProvinceID) values (84, 6);
insert into Pharmacy (PharmacyID, ProvinceID) values (85, 7);
insert into Pharmacy (PharmacyID, ProvinceID) values (86, 8);
insert into Pharmacy (PharmacyID, ProvinceID) values (87, 9);
insert into Pharmacy (PharmacyID, ProvinceID) values (88, 10);
insert into Pharmacy (PharmacyID, ProvinceID) values (89, 11);
insert into Pharmacy (PharmacyID, ProvinceID) values (90, 12);
insert into Pharmacy (PharmacyID, ProvinceID) values (91, 13);
insert into Pharmacy (PharmacyID, ProvinceID) values (92, 1);
insert into Pharmacy (PharmacyID, ProvinceID) values (93, 2);
insert into Pharmacy (PharmacyID, ProvinceID) values (94, 3);
insert into Pharmacy (PharmacyID, ProvinceID) values (95, 4);
insert into Pharmacy (PharmacyID, ProvinceID) values (96, 5);
insert into Pharmacy (PharmacyID, ProvinceID) values (97, 6);
insert into Pharmacy (PharmacyID, ProvinceID) values (98, 7);
insert into Pharmacy (PharmacyID, ProvinceID) values (99, 8);
insert into Pharmacy (PharmacyID, ProvinceID) values (100, 9);

-- Populating Patient table using Mockaroo
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (2, 1, 'Rubi', 'Gulberg', 'F', '1957-11-04', 'random GeneralNotes 887530', 'random FamilyHistory 019812');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (3, 2, 'Lorrie', 'Faldoe', 'F', '1978-11-16', 'random GeneralNotes 559721', 'random FamilyHistory 415700');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (4, 3, 'Rafi', 'Gorst', 'M', '1964-11-27', 'random GeneralNotes 115076', 'random FamilyHistory 107534');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (5, 4, 'Leann', 'Winchcum', 'F', '2018-12-02', 'random GeneralNotes 356037', 'random FamilyHistory 925113');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (6, 5, 'Andras', 'Crich', 'M', '1999-06-09', 'random GeneralNotes 547122', 'random FamilyHistory 292040');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (7, 6, 'Theo', 'Eyer', 'F', '1962-07-24', 'random GeneralNotes 233700', 'random FamilyHistory 861475');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (8, 7, 'Almeria', 'Patise', 'F', '1999-01-06', 'random GeneralNotes 217277', 'random FamilyHistory 172177');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (9, 8, 'Henrietta', 'Tern', 'F', '1995-11-17', 'random GeneralNotes 120559', 'random FamilyHistory 115945');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (10, 9, 'Eberto', 'Ogilby', 'M', '1948-11-18', 'random GeneralNotes 898319', 'random FamilyHistory 590463');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (11, 10, 'Adrien', 'Gibbie', 'M', '1947-05-12', 'random GeneralNotes 175325', 'random FamilyHistory 522523');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (12, 11, 'Evangeline', 'Revill', 'F', '1973-07-29', 'random GeneralNotes 358196', 'random FamilyHistory 498954');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (13, 12, 'Jess', 'Hustings', 'M', '1948-03-29', 'random GeneralNotes 493795', 'random FamilyHistory 276322');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (14, 13, 'Trev', 'Cruce', 'M', '1997-09-08', 'random GeneralNotes 695936', 'random FamilyHistory 803137');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (15, 1, 'Brandy', 'Fullegar', 'F', '2001-08-18', 'random GeneralNotes 903634', 'random FamilyHistory 234978');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (16, 2, 'Maude', 'Lahiff', 'F', '1980-12-31', 'random GeneralNotes 085619', 'random FamilyHistory 644390');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (17, 3, 'Waverly', 'Voaden', 'M', '1959-09-07', 'random GeneralNotes 323645', 'random FamilyHistory 448821');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (18, 4, 'Jaymie', 'Durden', 'M', '2001-07-03', 'random GeneralNotes 376252', 'random FamilyHistory 786948');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (19, 5, 'Sari', 'Peterkin', 'F', '1987-02-16', 'random GeneralNotes 923304', 'random FamilyHistory 227912');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (20, 6, 'Gusty', 'Normington', 'F', '1987-06-08', 'random GeneralNotes 894501', 'random FamilyHistory 842050');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (21, 7, 'Amalee', 'Skellorne', 'F', '1970-10-08', 'random GeneralNotes 180859', 'random FamilyHistory 961239');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (22, 8, 'Vyky', 'Chetham', 'F', '1964-05-22', 'random GeneralNotes 332970', 'random FamilyHistory 199543');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (23, 9, 'Goober', 'Mintram', 'M', '1983-07-08', 'random GeneralNotes 178248', 'random FamilyHistory 899242');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (24, 10, 'Sonni', 'Lathwell', 'F', '2010-02-09', 'random GeneralNotes 364112', 'random FamilyHistory 251570');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (25, 11, 'Cassy', 'Bartelot', 'F', '2013-04-08', 'random GeneralNotes 610835', 'random FamilyHistory 254741');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (26, 12, 'Bernadette', 'Swayland', 'F', '1982-01-20', 'random GeneralNotes 990661', 'random FamilyHistory 657320');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (27, 13, 'Tait', 'Greet', 'M', '1949-10-11', 'random GeneralNotes 985714', 'random FamilyHistory 446834');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (28, 1, 'Janene', 'Jakubowski', 'F', '1985-11-09', 'random GeneralNotes 765576', 'random FamilyHistory 383153');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (29, 2, 'Minnaminnie', 'Griswaite', 'F', '1973-10-23', 'random GeneralNotes 716762', 'random FamilyHistory 030178');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (30, 3, 'Syman', 'Emmott', 'M', '2011-12-19', 'random GeneralNotes 266159', 'random FamilyHistory 649970');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (31, 4, 'Lexine', 'Gouly', 'F', '1986-09-25', 'random GeneralNotes 668573', 'random FamilyHistory 069799');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (32, 5, 'Batholomew', 'Chennells', 'M', '1963-11-11', 'random GeneralNotes 526804', 'random FamilyHistory 219324');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (33, 6, 'Ryley', 'Cashford', 'M', '1992-05-29', 'random GeneralNotes 672550', 'random FamilyHistory 994774');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (34, 7, 'Violette', 'Blackmore', 'F', '1968-07-30', 'random GeneralNotes 275419', 'random FamilyHistory 080841');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (35, 8, 'Isobel', 'Rubertis', 'F', '1952-02-17', 'random GeneralNotes 567019', 'random FamilyHistory 521668');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (36, 9, 'Rhys', 'Gaskoin', 'M', '2021-07-30', 'random GeneralNotes 443625', 'random FamilyHistory 970900');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (37, 10, 'Sanderson', 'Schurig', 'M', '2005-04-20', 'random GeneralNotes 751742', 'random FamilyHistory 831798');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (38, 11, 'Annabel', 'Saunt', 'F', '1956-03-20', 'random GeneralNotes 899939', 'random FamilyHistory 640809');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (39, 12, 'Talbert', 'Aldersley', 'M', '1964-02-17', 'random GeneralNotes 630592', 'random FamilyHistory 834707');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (40, 13, 'Lita', 'Melanaphy', 'F', '2018-09-26', 'random GeneralNotes 642643', 'random FamilyHistory 918951');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (41, 1, 'Hurlee', 'Buddle', 'M', '1964-02-24', 'random GeneralNotes 153725', 'random FamilyHistory 536679');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (42, 2, 'Odell', 'Wimbridge', 'M', '1982-11-07', 'random GeneralNotes 347651', 'random FamilyHistory 033118');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (43, 3, 'Chane', 'Caramuscia', 'M', '2017-12-30', 'random GeneralNotes 859125', 'random FamilyHistory 236663');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (44, 4, 'Mort', 'Rozzell', 'M', '2021-03-03', 'random GeneralNotes 628757', 'random FamilyHistory 950454');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (45, 5, 'Gerick', 'Lendrem', 'M', '1966-05-26', 'random GeneralNotes 476883', 'random FamilyHistory 878802');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (46, 6, 'Rebekkah', 'Houchin', 'F', '1952-12-11', 'random GeneralNotes 154910', 'random FamilyHistory 127178');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (47, 7, 'Jobie', 'Noury', 'F', '2001-04-14', 'random GeneralNotes 847810', 'random FamilyHistory 543439');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (48, 8, 'Darwin', 'Warrior', 'M', '1982-05-19', 'random GeneralNotes 895723', 'random FamilyHistory 412707');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (49, 9, 'Roosevelt', 'Matteris', 'M', '1986-11-29', 'random GeneralNotes 822630', 'random FamilyHistory 494091');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (50, 10, 'Garfield', 'Wield', 'M', '1997-09-12', 'random GeneralNotes 861752', 'random FamilyHistory 722055');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (51, 11, 'Zaria', 'Possell', 'F', '1953-02-15', 'random GeneralNotes 667713', 'random FamilyHistory 979437');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (52, 12, 'Markos', 'Clohissy', 'M', '1965-06-24', 'random GeneralNotes 914124', 'random FamilyHistory 004824');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (53, 13, 'Lilia', 'Nassey', 'F', '2022-09-13', 'random GeneralNotes 856039', 'random FamilyHistory 737892');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (54, 1, 'Melicent', 'Jobson', 'F', '2012-03-12', 'random GeneralNotes 668802', 'random FamilyHistory 756672');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (55, 2, 'Donavon', 'Jaycox', 'M', '1977-02-16', 'random GeneralNotes 436951', 'random FamilyHistory 210466');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (56, 3, 'Adiana', 'Jacobowicz', 'F', '1963-03-20', 'random GeneralNotes 749659', 'random FamilyHistory 902178');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (57, 4, 'Fifine', 'Hansom', 'F', '1992-02-14', 'random GeneralNotes 258855', 'random FamilyHistory 755270');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (58, 5, 'Dorothea', 'Butter', 'F', '1985-11-27', 'random GeneralNotes 724774', 'random FamilyHistory 511001');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (59, 6, 'Ursola', 'Morteo', 'F', '1985-04-28', 'random GeneralNotes 803850', 'random FamilyHistory 541551');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (60, 7, 'Kele', 'Vreiberg', 'M', '1999-01-02', 'random GeneralNotes 480676', 'random FamilyHistory 047498');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (61, 8, 'Val', 'Arnet', 'M', '1994-05-16', 'random GeneralNotes 744506', 'random FamilyHistory 455096');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (62, 9, 'Ede', 'Odgaard', 'F', '2018-10-26', 'random GeneralNotes 730526', 'random FamilyHistory 513218');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (63, 10, 'Egor', 'Roiz', 'M', '2010-12-09', 'random GeneralNotes 992602', 'random FamilyHistory 980322');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (64, 11, 'Nicholle', 'Rideout', 'F', '1975-06-18', 'random GeneralNotes 017406', 'random FamilyHistory 985803');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (65, 12, 'Burr', 'Batcheldor', 'M', '1999-06-09', 'random GeneralNotes 414839', 'random FamilyHistory 000576');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (66, 13, 'Ivar', 'Mullen', 'M', '2010-08-17', 'random GeneralNotes 470536', 'random FamilyHistory 603111');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (67, 1, 'Ky', 'Streetfield', 'M', '1944-01-09', 'random GeneralNotes 843138', 'random FamilyHistory 870226');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (68, 2, 'Patin', 'Bartosek', 'M', '1967-05-08', 'random GeneralNotes 729723', 'random FamilyHistory 004948');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (69, 3, 'Berti', 'Schonfeld', 'M', '1943-05-15', 'random GeneralNotes 166322', 'random FamilyHistory 547132');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (70, 4, 'Kaiser', 'Spellworth', 'M', '2005-06-07', 'random GeneralNotes 386428', 'random FamilyHistory 508468');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (71, 5, 'Korrie', 'Connikie', 'F', '2010-12-29', 'random GeneralNotes 573096', 'random FamilyHistory 511073');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (72, 6, 'Nicoline', 'Chicchelli', 'F', '1997-01-20', 'random GeneralNotes 575531', 'random FamilyHistory 368335');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (73, 7, 'Farrel', 'Lenz', 'M', '1941-01-09', 'random GeneralNotes 696240', 'random FamilyHistory 793030');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (74, 8, 'Stesha', 'Camplen', 'F', '1995-08-27', 'random GeneralNotes 879501', 'random FamilyHistory 685748');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (75, 9, 'Corbie', 'Brenston', 'M', '2016-09-22', 'random GeneralNotes 700166', 'random FamilyHistory 988589');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (76, 10, 'Hermia', 'Soulsby', 'F', '2000-09-26', 'random GeneralNotes 645660', 'random FamilyHistory 194478');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (77, 11, 'Cassandry', 'Iacovone', 'F', '1988-03-11', 'random GeneralNotes 137879', 'random FamilyHistory 895403');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (78, 12, 'Kerby', 'Eccott', 'M', '1949-12-17', 'random GeneralNotes 955347', 'random FamilyHistory 133089');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (79, 13, 'Irina', 'Floch', 'F', '2021-05-09', 'random GeneralNotes 627300', 'random FamilyHistory 167795');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (80, 1, 'Lyell', 'McCurlye', 'M', '1981-04-02', 'random GeneralNotes 818071', 'random FamilyHistory 374535');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (81, 2, 'Stoddard', 'Foord', 'F', '1960-01-31', 'random GeneralNotes 254884', 'random FamilyHistory 548996');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (82, 3, 'Romona', 'Godsell', 'F', '1988-09-19', 'random GeneralNotes 948593', 'random FamilyHistory 405391');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (83, 4, 'Adria', 'Di Meo', 'F', '2011-01-10', 'random GeneralNotes 494230', 'random FamilyHistory 821256');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (84, 5, 'Grannie', 'Kirkam', 'M', '2018-12-29', 'random GeneralNotes 566075', 'random FamilyHistory 236424');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (85, 6, 'Gearard', 'Casaro', 'M', '2010-04-08', 'random GeneralNotes 583687', 'random FamilyHistory 208364');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (86, 7, 'Mario', 'Mannagh', 'M', '1960-07-06', 'random GeneralNotes 491330', 'random FamilyHistory 498528');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (87, 8, 'Martelle', 'Pithie', 'F', '1953-11-09', 'random GeneralNotes 490221', 'random FamilyHistory 729750');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (88, 9, 'Olly', 'Rosenblum', 'F', '1958-08-26', 'random GeneralNotes 071052', 'random FamilyHistory 147385');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (89, 10, 'Ogdon', 'Quigley', 'M', '1942-01-30', 'random GeneralNotes 324524', 'random FamilyHistory 914656');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (90, 11, 'Arni', 'Scholtis', 'M', '1992-07-25', 'random GeneralNotes 105252', 'random FamilyHistory 739554');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (91, 12, 'Lizette', 'Claiden', 'F', '1986-03-22', 'random GeneralNotes 707619', 'random FamilyHistory 434814');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (92, 13, 'Harvey', 'Feighry', 'M', '2018-04-12', 'random GeneralNotes 047178', 'random FamilyHistory 675721');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (93, 1, 'Renee', 'Jodlowski', 'F', '1953-07-16', 'random GeneralNotes 543521', 'random FamilyHistory 238928');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (94, 2, 'Koenraad', 'Sisneros', 'M', '2015-05-12', 'random GeneralNotes 847733', 'random FamilyHistory 620970');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (95, 3, 'Elysia', 'Esmond', 'F', '1946-01-19', 'random GeneralNotes 763606', 'random FamilyHistory 742897');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (96, 4, 'Janice', 'Rigby', 'F', '1990-06-14', 'random GeneralNotes 753839', 'random FamilyHistory 506646');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (97, 5, 'Filmore', 'Helian', 'M', '1983-07-17', 'random GeneralNotes 886715', 'random FamilyHistory 482191');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (98, 6, 'Patrice', 'Rebillard', 'M', '1972-07-03', 'random GeneralNotes 828594', 'random FamilyHistory 187292');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (99, 7, 'Kari', 'Franca', 'F', '1953-12-31', 'random GeneralNotes 275710', 'random FamilyHistory 095101');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (100, 8, 'Henka', 'Loudiane', 'F', '1992-02-11', 'random GeneralNotes 959109', 'random FamilyHistory 521205');
insert into Patient (HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory) values (101, 9, 'Gayel', 'Gowler', 'F', '1997-09-22', 'random GeneralNotes 915212', 'random FamilyHistory 779529');

-- Stored Procedure: Adding male patients
CREATE PROCEDURE AddMalePatient @HCN DECIMAL(10), @ProvinceID DECIMAL(2), @FirstName VARCHAR(255), @LastName VARCHAR(255),
	@DOB DATE, @GeneralNotes VARCHAR(MAX), @FamilyHistory VARCHAR(MAX)
AS
BEGIN
    INSERT INTO Patient(HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory)
	VALUES(@HCN, @ProvinceID, @FirstName, @LastName, 'M', CAST(@DOB AS DATE), @GeneralNotes, @FamilyHistory);

	INSERT INTO Male(HCN)
	VALUES(@HCN)
END;
GO

-- Stored Procedure: Adding female patients
CREATE PROCEDURE AddFemalePatient @HCN DECIMAL(10), @ProvinceID DECIMAL(2), @FirstName VARCHAR(255), @LastName VARCHAR(255),
	@DOB DATE, @GeneralNotes VARCHAR(MAX), @FamilyHistory VARCHAR(MAX)
AS
BEGIN
    INSERT INTO Patient(HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory)
	VALUES(@HCN, @ProvinceID, @FirstName, @LastName, 'F', CAST(@DOB AS DATE), @GeneralNotes, @FamilyHistory);

	INSERT INTO Female(HCN)
	VALUES(@HCN)
END;
GO

-- Stored Procedure: Adding intersex patients
CREATE PROCEDURE AddIntersexPatient @HCN DECIMAL(10), @ProvinceID DECIMAL(2), @FirstName VARCHAR(255), @LastName VARCHAR(255),
	@DOB DATE, @GeneralNotes VARCHAR(MAX), @FamilyHistory VARCHAR(MAX)
AS
BEGIN
    INSERT INTO Patient(HCN, ProvinceID, FirstName, LastName, Gender, DOB, GeneralNotes, FamilyHistory)
	VALUES(@HCN, @ProvinceID, @FirstName, @LastName, 'I', CAST(@DOB AS DATE), @GeneralNotes, @FamilyHistory);

	INSERT INTO Intersex(HCN)
	VALUES(@HCN)
END;
GO

--Stored Procedure: Adding Physician (GP)
CREATE PROCEDURE AddGP @PhysicianID DECIMAL(12), @FirstName VARCHAR(255), @LastName VARCHAR(255), @ProvinceID DECIMAL(2)
AS
BEGIN
	INSERT INTO Physician(PhysicianID, FirstName, LastName, ProvinceID, Specialty)
	VALUES(@PhysicianID, @FirstName, @LastName, @ProvinceID, 'GP');

	INSERT INTO GP(PhysicianID)
	VALUES(@PhysicianID)
END;
GO

--Stored Procedure: Adding Physician (Internist)
CREATE PROCEDURE AddInternist @PhysicianID DECIMAL(12), @FirstName VARCHAR(255), @LastName VARCHAR(255), @ProvinceID DECIMAL(2)
AS
BEGIN
	INSERT INTO Physician(PhysicianID, FirstName, LastName, ProvinceID, Specialty)
	VALUES(@PhysicianID, @FirstName, @LastName, @ProvinceID, 'Internist');

	INSERT INTO Internist(PhysicianID)
	VALUES(@PhysicianID)
END;
GO

--Stored Procedure: Adding Physician (Pediatrician)
CREATE PROCEDURE AddPediatrician @PhysicianID DECIMAL(12), @FirstName VARCHAR(255), @LastName VARCHAR(255), @ProvinceID DECIMAL(2)
AS
BEGIN
	INSERT INTO Physician(PhysicianID, FirstName, LastName, ProvinceID, Specialty)
	VALUES(@PhysicianID, @FirstName, @LastName, @ProvinceID, 'Pediatrician');

	INSERT INTO Pediatrician(PhysicianID)
	VALUES(@PhysicianID)
END;
GO

-- Stored Procedure: Adding DocVisit events
CREATE PROCEDURE AddDocVisit @DocVisitID DECIMAL(12), @HCN DECIMAL(10), @PhysicianID DECIMAL(12), @Notes VARCHAR(MAX)
AS
BEGIN
	INSERT INTO DocVisit(DocVisitID, HCN, PhysicianID, VisitDate, Notes)
	VALUES(@DocVisitID, @HCN, @PhysicianID, GETDATE(), @Notes);

	UPDATE Patient
	SET GeneralNotes = @Notes
	WHERE HCN = @HCN;
END;
GO

-- Sample male patient addition
BEGIN TRANSACTION AddMalePatient;
EXECUTE AddMalePatient 1, 01, 'John', 'Doe', '04-JUL-1973', 'This patient has asthma and is allergic 
to peanuts.', 'The patients maternal grandfather has Alzheimers Disease.';
COMMIT TRANSACTION AddMalePatient;

-- Sample GP addition
BEGIN TRANSACTION AddGP;
EXECUTE AddGP 101, 'Sebastian', 'Jurga', 9;
COMMIT TRANSACTION AddGP;

-- Sample DocVisit addition 1
BEGIN TRANSACTION AddDocVisit;
EXECUTE AddDocVisit 1, 1, 1, 'Patient has no further updates on his asthma and should continue normal puffer dosing.';
COMMIT TRANSACTION AddDocVisit;

-- Sample DocVisit addition 2
BEGIN TRANSACTION AddDocVisit;
EXECUTE AddDocVisit 2, 1, 1, 'Patient had an asthma attack immediately after his last visit and came back but is now stable';
COMMIT TRANSACTION AddDocVisit;

SELECT *
FROM PatientHistory





-- FROM HERE DOWNWARD, REFINE BEFORE USING FOR FURTHER DEVELOPMENT





-- Sample query 1
SELECT Doc.PhysicianID, Doc.FirstName, Doc.LastName, Doc.Specialty, COUNT(DV.DocVisitID) AS TotalVisits
FROM Physician AS Doc
LEFT JOIN DocVisit AS DV ON Doc.PhysicianID = DV.PhysicianID
WHERE Doc.ProvinceID = 9
GROUP BY Doc.PhysicianID, Doc.FirstName, Doc.LastName, Doc.Specialty
ORDER BY TotalVisits DESC;

-- Sample query 2
SELECT P.FirstName, P.LastName, DV.VisitDate, DV.Notes, VisitCountPerPatient.VisitCount
FROM Patient AS P
JOIN DocVisit AS DV ON P.HCN = DV.HCN
LEFT JOIN (SELECT HCN, COUNT(*) AS VisitCount
           FROM DocVisit
           GROUP BY HCN) AS VisitCountPerPatient ON P.HCN = VisitCountPerPatient.HCN
WHERE DV.PhysicianID = 1
ORDER BY VisitDate DESC;

-- Sample query 3
WITH RecentVisitCounts AS (SELECT DV.HCN, DV.PhysicianID, COUNT(*) AS TotalVisits
                           FROM DocVisit AS DV
                           WHERE DV.VisitDate >= DATEADD(MONTH, -3, GETDATE())
                           GROUP BY DV.HCN, DV.PhysicianID)
SELECT P.HCN, P.FirstName AS PatientFirstName, P.LastName AS PatientLastName, RVC.PhysicianID,
    Doc.FirstName AS PhysicianFirstName, Doc.LastName AS PhysicianLastName, RVC.TotalVisits,
    PH.PastNotes, PH.NewNotes, PH.ChangeDate
FROM (SELECT HCN, PhysicianID, TotalVisits, ROW_NUMBER() OVER (ORDER BY TotalVisits DESC) AS VisitRank
      FROM RecentVisitCounts) AS RVC
JOIN Patient AS P ON RVC.HCN = P.HCN
JOIN Physician AS Doc ON RVC.PhysicianID = Doc.PhysicianID
LEFT JOIN PatientHistory AS PH ON P.HCN = PH.HCN
WHERE RVC.VisitRank <= 10;

insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (3, 1, 1, '2006-05-23', 'random VisitNotes 595935');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (4, 2, 2, '2021-11-07', 'random VisitNotes 554848');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (5, 3, 3, '1998-02-03', 'random VisitNotes 586298');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (6, 4, 4, '2022-12-01', 'random VisitNotes 797587');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (7, 5, 5, '2005-03-17', 'random VisitNotes 214926');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (8, 6, 6, '2005-08-12', 'random VisitNotes 898913');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (9, 7, 7, '2017-06-16', 'random VisitNotes 128595');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (10, 8, 8, '2005-08-19', 'random VisitNotes 998217');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (11, 9, 9, '1998-07-15', 'random VisitNotes 994711');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (12, 10, 10, '2014-07-01', 'random VisitNotes 427528');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (13, 11, 11, '2013-12-09', 'random VisitNotes 615924');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (14, 12, 12, '2003-02-11', 'random VisitNotes 907468');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (15, 13, 1, '2019-06-21', 'random VisitNotes 568144');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (16, 14, 2, '2012-04-06', 'random VisitNotes 606838');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (17, 15, 3, '2000-07-02', 'random VisitNotes 282476');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (18, 16, 4, '2000-06-01', 'random VisitNotes 883281');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (19, 17, 5, '2023-01-15', 'random VisitNotes 684528');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (20, 18, 6, '2002-11-15', 'random VisitNotes 602890');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (21, 1, 7, '2016-05-26', 'random VisitNotes 355409');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (22, 2, 8, '2004-09-24', 'random VisitNotes 495948');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (23, 3, 9, '2023-06-19', 'random VisitNotes 423090');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (24, 4, 10, '2006-03-21', 'random VisitNotes 362265');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (25, 5, 11, '2001-04-18', 'random VisitNotes 203701');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (26, 6, 12, '2012-10-16', 'random VisitNotes 665809');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (27, 7, 1, '2007-11-09', 'random VisitNotes 079769');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (28, 8, 2, '2005-04-11', 'random VisitNotes 674999');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (29, 9, 3, '1998-10-29', 'random VisitNotes 730085');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (30, 10, 4, '2006-05-05', 'random VisitNotes 857824');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (31, 11, 5, '2019-10-19', 'random VisitNotes 542872');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (32, 12, 6, '1998-07-12', 'random VisitNotes 595995');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (33, 13, 7, '2017-07-17', 'random VisitNotes 499965');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (34, 14, 8, '1999-12-23', 'random VisitNotes 032586');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (35, 15, 9, '2016-06-07', 'random VisitNotes 019230');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (36, 16, 10, '2007-02-17', 'random VisitNotes 104813');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (37, 17, 11, '2006-07-01', 'random VisitNotes 680507');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (38, 18, 12, '2013-04-01', 'random VisitNotes 094376');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (39, 1, 1, '2009-07-28', 'random VisitNotes 446451');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (40, 2, 2, '2012-02-16', 'random VisitNotes 665488');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (41, 3, 3, '2021-02-04', 'random VisitNotes 497846');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (42, 4, 4, '2000-09-13', 'random VisitNotes 471176');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (43, 5, 5, '2006-12-29', 'random VisitNotes 304902');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (44, 6, 6, '2021-07-18', 'random VisitNotes 716218');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (45, 7, 7, '2000-12-01', 'random VisitNotes 255183');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (46, 8, 8, '2015-05-10', 'random VisitNotes 825446');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (47, 9, 9, '2014-08-08', 'random VisitNotes 379600');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (48, 10, 10, '1998-11-22', 'random VisitNotes 951481');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (49, 11, 11, '1998-07-21', 'random VisitNotes 934657');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (50, 12, 12, '2004-02-01', 'random VisitNotes 721334');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (51, 13, 1, '2006-06-01', 'random VisitNotes 721331');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (52, 14, 2, '2019-09-05', 'random VisitNotes 387339');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (53, 15, 3, '2008-05-17', 'random VisitNotes 284352');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (54, 16, 4, '2001-02-24', 'random VisitNotes 297748');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (55, 17, 5, '2005-01-23', 'random VisitNotes 938310');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (56, 18, 6, '2005-07-24', 'random VisitNotes 088680');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (57, 1, 7, '2012-03-20', 'random VisitNotes 815833');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (58, 2, 8, '2014-04-27', 'random VisitNotes 731340');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (59, 3, 9, '2010-10-16', 'random VisitNotes 494073');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (60, 4, 10, '2000-07-14', 'random VisitNotes 260828');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (61, 5, 11, '2001-10-05', 'random VisitNotes 892752');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (62, 6, 12, '2006-09-24', 'random VisitNotes 007969');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (63, 7, 1, '2020-06-07', 'random VisitNotes 527953');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (64, 8, 2, '2008-08-12', 'random VisitNotes 335884');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (65, 9, 3, '2002-10-16', 'random VisitNotes 300479');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (66, 10, 4, '2003-12-18', 'random VisitNotes 749587');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (67, 11, 5, '2020-08-25', 'random VisitNotes 304940');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (68, 12, 6, '1998-07-05', 'random VisitNotes 904435');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (69, 13, 7, '2002-10-21', 'random VisitNotes 696516');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (70, 14, 8, '2002-06-26', 'random VisitNotes 812606');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (71, 15, 9, '2005-03-31', 'random VisitNotes 413994');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (72, 16, 10, '2002-12-11', 'random VisitNotes 244188');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (73, 17, 11, '2001-10-24', 'random VisitNotes 645774');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (74, 18, 12, '2008-04-13', 'random VisitNotes 501386');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (75, 1, 1, '2007-01-31', 'random VisitNotes 210721');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (76, 2, 2, '2022-01-23', 'random VisitNotes 308455');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (77, 3, 3, '2011-10-27', 'random VisitNotes 113033');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (78, 4, 4, '2008-04-10', 'random VisitNotes 396536');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (79, 5, 5, '2023-05-13', 'random VisitNotes 180132');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (80, 6, 6, '1999-03-13', 'random VisitNotes 830336');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (81, 7, 7, '2009-05-18', 'random VisitNotes 773356');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (82, 8, 8, '2013-09-24', 'random VisitNotes 217442');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (83, 9, 9, '2009-12-10', 'random VisitNotes 301633');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (84, 10, 10, '2015-09-04', 'random VisitNotes 698163');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (85, 11, 11, '2002-05-16', 'random VisitNotes 765677');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (86, 12, 12, '2019-05-01', 'random VisitNotes 835878');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (87, 13, 1, '1998-02-19', 'random VisitNotes 449567');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (88, 14, 2, '2023-02-01', 'random VisitNotes 109173');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (89, 15, 3, '2017-05-09', 'random VisitNotes 529203');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (90, 16, 4, '1998-06-02', 'random VisitNotes 474070');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (91, 17, 5, '2000-05-17', 'random VisitNotes 888486');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (92, 18, 6, '2001-03-31', 'random VisitNotes 622580');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (93, 1, 7, '2013-10-04', 'random VisitNotes 424517');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (94, 2, 8, '2020-08-05', 'random VisitNotes 396864');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (95, 3, 9, '2008-02-27', 'random VisitNotes 628575');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (96, 4, 10, '2015-09-05', 'random VisitNotes 308780');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (97, 5, 11, '2007-04-21', 'random VisitNotes 450374');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (98, 6, 12, '2005-08-24', 'random VisitNotes 192972');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (99, 7, 1, '2020-03-28', 'random VisitNotes 675962');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (100, 8, 2, '2020-10-27', 'random VisitNotes 171221');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (101, 9, 3, '2003-06-03', 'random VisitNotes 764960');
insert into DocVisit (DocVisitID, HCN, PhysicianID, VisitDate, Notes) values (102, 10, 4, '2020-07-18', 'random VisitNotes 138332');



UPDATE Patient
SET GeneralNotes = 'random VisitNotes 797587'
WHERE HCN = 4;

UPDATE Patient
SET GeneralNotes = 'random VisitNotes 128595'
WHERE HCN = 7;

UPDATE Patient
SET GeneralNotes = 'random VisitNotes 883281'
WHERE HCN = 4;

UPDATE Patient
SET GeneralNotes = 'random VisitNotes 355409'
WHERE HCN = 7;

UPDATE Patient
SET GeneralNotes = 'random VisitNotes 857824'
WHERE HCN = 4;

UPDATE Patient
SET GeneralNotes = 'random VisitNotes 499965'
WHERE HCN = 7;

UPDATE Patient
SET GeneralNotes = 'random VisitNotes 471176'
WHERE HCN = 4;

UPDATE Patient
SET GeneralNotes = 'random VisitNotes 255183'
WHERE HCN = 7;

UPDATE Patient
SET GeneralNotes = 'random VisitNotes 297748'
WHERE HCN = 4;

UPDATE Patient
SET GeneralNotes = 'random VisitNotes 696516'
WHERE HCN = 7;
