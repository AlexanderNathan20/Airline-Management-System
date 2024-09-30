-- CS4400: Introduction to Database Systems: Monday, September 11, 2023
-- Simple Airline Management System Course Project Database TEMPLATE (v0)

/* This is a standard preamble for most of our scripts.  The intent is to establish
a consistent environment for the database behavior. */
set global transaction isolation level serializable;
set global SQL_MODE = 'ANSI,TRADITIONAL';
set names utf8mb4;
set SQL_SAFE_UPDATES = 0;

set @thisDatabase = 'flight_tracking';
drop database if exists flight_tracking;
create database if not exists flight_tracking;
use flight_tracking;

-- Please enter your team number and names here
/* Team 76
- Rafy Akbar
- Christiana Clara
- Alexander Nathan
- Chrystabel Sunata
- Samuel Tedjasukmana
 */

-- Define the database structures
/* You must enter your tables definitions, along with your primary, unique and foreign key
declarations, and data insertion statements here.  You may sequence them in any order that
works for you.  When executed, your statements must create a functional database that contains
all of the data, and supports as many of the constraints as reasonably possible. */
DROP TABLE IF EXISTS airline;
CREATE TABLE airline (
	airlineID varchar(50) NOT NULL,
    revenue numeric(6,0) NOT NULL,
    PRIMARY KEY (airlineID)
) ENGINE=InnoDB;

insert into airline values
('Delta', 53000),
('United', 48000),
('British Airways', 24000),
('Lufthansa', 35000),
('Air_France', 29000),
('KLM', 29000),
('Ryanair', 10000),
('Japan Airlines', 9000),
('China Southern Airlines', 14000),
('Korean Air Lines', 10000),
('American', 52000);

DROP TABLE IF EXISTS location;
CREATE TABLE location (
    locID varchar(50) NOT NULL,
    PRIMARY KEY (locID)
) ENGINE=InnoDB;

insert into location values
('port_1'),('port_2'),('port_3'),('port_10'),
('port_17'),('plane_1'),('plane_5'),('plane_8'),
('plane_13'),('plane_20'),('port_12'),('port_14'),
('port_15'),('port_20'),('port_4'),('port_16'),
('port_11'),('port_23'),('port_7'),('port_6'),
('port_13'),('port_21'),('port_18'),('port_22'),
('plane_6'),('plane_18'),('plane_7');

DROP TABLE IF EXISTS airport;
CREATE TABLE airport (
	airportID char(3) NOT NULL,
    airport_name varchar(100) NOT NULL,
    city varchar(40) NOT NULL,
    state varchar(40) NOT NULL,
    country char(3) NOT NULL,
    airport_locID varchar(50),
    PRIMARY KEY (airportID),
    CONSTRAINT fk1 FOREIGN KEY (airport_locID) REFERENCES location (locID)
) ENGINE=InnoDB;

insert into airport values
('ATL', 'Atlanta Hartsfield_Jackson International', 'Atlanta', 'Georgia', 'ISA','port_1'),
('DXB', 'Dubai International','Dubai','Al Garhoud','UAE','port_2'),
('HND',	'Tokyo International Haneda','Ota City','Tokyo','JPN','port_3'),
('LHR','London Heathrow','London','England','GBR','port_4'),
('IST','Istanbul International','Arnavutkoy','Istanbul','TUR',NULL),
('DFW','Dallas_Fort Worth International','Dallas','Texas','USA','port_6'),
('CAN','Guangzhou International','Guangzhou','Guangdong','CHN','port_7'),
('DEN','Denver International','Denver','Colorado','USA'	,NULL),
('LAX','Los Angeles International','Los Angeles','California','USA',NULL),
('ORD','O_Hare International','Chicago','Illinois','USA','port_10'),
('AMS','Amsterdam Schipol International','Amsterdam','Haarlemmermeer','NLD','port_11'),
('CDG','Paris Charles de Gaulle','Roissy_en_France','Paris','FRA','port_12'),
('FRA','Frankfurt International','Frankfurt','Frankfurt_Rhine_Main','DEU','port_13'),
('MAD','Madrid Adolfo Suarez_Barajas','Madrid','Barajas','ESP','port_14'),
('BCN','Barcelona International','Barcelona','Catalonia','ESP','port_15'),
('FCO','Rome Fiumicino','Fiumicino','Lazio','ITA','port_16'),
('LGW','London Gatwick','London','England','GBR','port_17'),
('MUC','Munich International','Munich','Bavaria','DEU','port_18'),
('MDW','Chicago Midway International','Chicago','Illinois','USA',NULL),
('IAH','George Bush Intercontinental','Houston','Texas','USA','port_20'),
('HOU','William P_Hobby International','Houston','Texas','USA','port_21'),
('NRT','Narita International','Narita','Chiba','JPN','port_22'),
('BER','Berlin Brandenburg Willy Brandt International','Berlin','Schonefeld','DEU','port_23');

DROP TABLE IF EXISTS leg;
CREATE TABLE leg (
	legID varchar(50) NOT NULL,
    distance varchar(40),
    departure_airport char(3) NOT NULL,
    arrival_airport char(3) NOT NULL,
    PRIMARY KEY (legID),
    CONSTRAINT fk2 FOREIGN KEY (departure_airport) REFERENCES airport (airportID),
    CONSTRAINT fk3 FOREIGN KEY (arrival_airport) REFERENCES airport (airportID)
) ENGINE=InnoDB;

insert into leg values
('leg_1', '400mi', 'AMS', 'BER'),
('leg_2', '3900mi', 'ATL', 'AMS'),
('leg_3', '3700mi', 'ATL', 'LHR'),
('leg_4', '600mi', 'ATL', 'ORD'),
('leg_5', '500mi', 'BCN', 'CDG'),
('leg_6', '300mi', 'BCN', 'MAD'),
('leg_7', '4700mi', 'BER', 'CAN'),
('leg_8', '600mi', 'BER', 'LGW'),
('leg_9', '300mi', 'BER', 'MUC'),
('leg_10', '1600mi', 'CAN', 'HND'),
('leg_11', '500mi', 'CDG', 'BCN'),
('leg_12', '600mi', 'CDG', 'FCO'),
('leg_13', '200mi', 'CDG', 'LHR'),
('leg_14', '400mi', 'CDG', 'MUC'),
('leg_15' , '200mi', 'DFW', 'IAH'),
('leg_16','800mi', 'FCO', 'MAD'), 
('leg_17', '300mi', 'FRA', 'BER'),
('leg_18', '100mi', 'HND', 'NRT'),
('leg_19', '300mi', 'HOU', 'DFW'),
('leg_20', '100mi', 'IAH', 'HOU'),
('leg_21', '600mi', 'LGW', 'BER'),
('leg_22', '600mi', 'LHR', 'BER'),
('leg_23','500mi','LHR','MUC'),
('leg_24','300mi','MAD','BCN'),
('leg_25','600mi','MAD','CDG'),
('leg_26','800mi','MAD','FCO'),
('leg_27','300mi','MUC','BER'),
('leg_28','400mi','MUC','CDG'),
('leg_29','400mi','MUC','FCO'),
('leg_30','200mi','MUC','FRA');

DROP TABLE IF EXISTS route;
CREATE TABLE route (
	routeID varchar(50) NOT NULL,
    PRIMARY KEY (routeID)
) ENGINE=InnoDB;

insert into route values
('americas_hub_exchange'),
('americas_one'),
('americas_three'),
('americas_two'),
('big_europe_loop'),
('euro_north'),
('euro_south'),
('germany_local'),
('pacific_rim_tour'),
('south_euro_loop'),
('texas_local');

DROP TABLE IF EXISTS airplane;
CREATE TABLE airplane (
	airlineID varchar(50) NOT NULL,
    tail_num varchar(40) NOT NULL,
	seat_cap numeric(2,0) NOT NULL,
    speed numeric(4,0) NOT NULL,
    airplane_locID varchar(50),
    PRIMARY KEY (airlineID, tail_num),
    CONSTRAINT fk4 FOREIGN KEY (airlineID) REFERENCES airline (airlineID),
    CONSTRAINT fk5 FOREIGN KEY (airplane_locID) REFERENCES location (locID)
) ENGINE=InnoDB;

insert into airplane values
('Delta', 'n106js', 4, 800, 'plane_1'),
('Delta', 'n110jn', 5, 800, null),
('Delta', 'n127js', 4, 600, null),
('United', 'n330ss', 4, 800, null),
('United', 'n380sd', 5, 400, 'plane_5'),
('British Airways', 'n616lt', 7, 600, 'plane_6'),
('British Airways', 'n517ly', 4, 600, 'plane_7'),
('Lufthansa', 'n620la', 4, 800, 'plane_8'),
('Lufthansa', 'n401fj', 4, 300, null),
('Lufthansa', 'n653fk', 6, 600, null),
('Air_France', 'n118fm', 4, 400, null),
('Air_France', 'n815pw', 3, 400, null),
('KLM', 'n161fk', 4, 600, 'plane_13'),
('KLM', 'n337as', 5, 400, null),
('KLM', 'n256ap', 4, 300, null),
('Ryanair', 'n156sq', 8, 600, null),
('Ryanair', 'n451fi', 5, 600, null),
('Ryanair', 'n341eb', 4, 400, 'plane_18'),
('Ryanair', 'n353kz', 4, 400, null),
('Japan Airlines', 'n305fv', 6, 400, 'plane_20'),
('Japan Airlines', 'n443wu', 4, 800, null),
('China Southern Airlines', 'n454qq', 3, 400, null),
('China Southern Airlines', 'n249yk', 4, 400, null),
('Korean Air lines', 'n180co', 5, 600, null),
('American', 'n448cs', 4, 400, null),
('American', 'n225sb', 8, 800, null),
('American', 'n553qn', 5, 800, null);

DROP TABLE IF EXISTS flight;
CREATE TABLE flight (
	flightID varchar(50) NOT NULL,
    cost numeric(4,0) NOT NULL,
    flight_routeID varchar(40) NOT NULL,
    progress integer NOT NULL,
    status varchar(40) NOT NULL,
    next_time varchar(40) NOT NULL,
    airlineID varchar(50) NOT NULL,
    tail_num varchar(40) NOT NULL,
    PRIMARY KEY (flightID),
    CONSTRAINT fk6 FOREIGN KEY (flight_routeID) REFERENCES route (routeID),
    CONSTRAINT fk7 FOREIGN KEY (airlineID, tail_num) REFERENCES airplane (airlineID, tail_num)
) ENGINE=InnoDB;

insert into flight values
('dl_10', 200, 'americas_one', 1, 'in_flight', '08:00:00', 'Delta', 'n106js'),
('un_38', 200, 'americas_three', 2, 'in_flight', '14:30:00', 'United', 'n380sd'),
('ba_61', 200, 'americas_two', 0, 'on_ground', '09:30:00', 'British Airways', 'n616lt'),
('lf_20', 300, 'euro_north', 3, 'in_flight', '11:00:00', 'Lufthansa', 'n620la'),
('km_16', 400, 'euro_south', 6, 'in_flight', '14:00:00', 'KLM', 'n161fk'),
('ba_51', 100, 'big_europe_loop', 0, 'on_ground', '11:30:00', 'British Airways', 'n517ly'),
('ja_35', 300, 'pacific_rim_tour', 1, 'in_flight', '09:30:00', 'Japan Airlines', 'n305fv'),
('ry_34', 100, 'germany_local', 0, 'in_flight', '15:00:00', 'Ryanair', 'n341eb');

# PERSON TABLE CREATION AND INSERT
DROP TABLE IF EXISTS person;
CREATE TABLE person (
	personID varchar(50) NOT NULL,
    firstName varchar(100) NOT NULL,
    lastName varchar(100) DEFAULT NULL,
    person_locID varchar(50) NOT NULL,
    PRIMARY KEY (personID),
    CONSTRAINT fk8 FOREIGN KEY (person_locID) REFERENCES location (locID)
) ENGINE=InnoDB;

insert into person values
('p1', 'Jeanne', 'Nelson', 'port_1'), 
('p10', 'Lawrence', 'Morgan', 'port_3'), 
('p11', 'Sandra', 'Cruz', 'port_3'), 
('p12', 'Dan', 'Ball', 'port_3'), 
('p13', 'Bryant', 'Figueroa', 'port_3'), 
('p14', 'Dana', 'Perry', 'port_3'), (
'p15', 'Matt', 'Hunt', 'port_10'), 
('p16', 'Edna', 'Brown', 'port_10'), 
('p17', 'Ruby', 'Burgess', 'port_10'), 
('p18', 'Esther', 'Pittman', 'port_10'), 
('p19', 'Doug', 'Fowler', 'port_17'), 
('p2', 'Roxanne', 'Byrd', 'port_1'), 
('p20', 'Thomas', 'Olson', 'port_17'), 
('p21', 'Mona', 'Harrison', 'plane_1'), 
('p22', 'Arlene', 'Massey', 'plane_1'), 
('p23', 'Judith', 'Patrick', 'plane_1'), 
('p24', 'Reginald', 'Rhodes', 'plane_5'), 
('p25', 'Vincent', 'Garcia', 'plane_5'), 
('p26', 'Cheryl', 'Moore', 'plane_5'), 
('p27', 'Michael', 'Rivera', 'plane_8'), 
('p28', 'Luther', 'Matthews', 'plane_8'), 
('p29', 'Moses', 'Parks', 'plane_13'), 
('p3', 'Tanya', 'Nguyen', 'port_1'), 
('p30', 'Ora', 'Steele', 'plane_13'), 
('p31', 'Antonio', 'Flores', 'plane_13'), 
('p32', 'Glenn', 'Ross', 'plane_13'), 
('p33', 'Irma', 'Thomas', 'plane_20'), 
('p34', 'Ann', 'Maldonado', 'plane_20'), 
('p35', 'Jeffrey', 'Cruz', 'port_12'), 
('p36', 'Sonya', 'Price', 'port_12'), 
('p37', 'Tracy', 'Hale', 'port_12'), 
('p38', 'Albert', 'Simmons', 'port_14'), 
('p39', 'Karen', 'Terry', 'port_15'), 
('p4', 'Kendra', 'Jacobs', 'port_1'), 
('p40', 'Glen', 'Kelley', 'port_20'), 
('p41', 'Brooke', 'Little', 'port_3'),
('p42', 'Daryl', 'Nguyen', 'port_4'), 
('p43', 'Judy', 'Willis', 'port_14'), 
('p44', 'Marco', 'Klein', 'port_15'), 
('p45', 'Angelica', 'Hampton', 'port_16'), 
('p5', 'Jeff', 'Burton', 'port_1'), 
('p6', 'Randal', 'Parks', 'port_1'), 
('p7', 'Sonya', 'Owens', 'port_2'), 
('p8', 'Bennie', 'Palmer', 'port_2'), 
('p9', 'Marlene', 'Warner', 'port_3');

DROP TABLE IF EXISTS pilot;
CREATE TABLE pilot (
	personID varchar(50) NOT NULL,
    taxID varchar(40) NOT NULL,
    experience numeric(3, 0) NOT NULL,
    commanding_flightID varchar(40),
    PRIMARY KEY (personID),
    UNIQUE KEY (taxID),
    CONSTRAINT fk9 FOREIGN KEY (personID) REFERENCES person (personID),
    CONSTRAINT fk10 FOREIGN KEY (commanding_flightID) REFERENCES flight (flightID)
) ENGINE=InnoDB;

insert into pilot values
('p1', '330-12-6907', 31.0, 'dl_10'),
 ('p10', '769-60-1266', 15.0, 'lf_20'),
 ('p11', '369-22-9505', 22.0, 'km_16'),
 ('p12', '680-92-5329', 24.0, 'ry_34'),
 ('p13', '513-40-4168', 24.0, 'km_16'),
 ('p14', '454-71-7847', 13.0, 'km_16'),
 ('p15', '153-47-8101', 30.0, 'ja_35'),
 ('p16', '598-47-5172', 28.0, 'ja_35'),
 ('p17', '865-71-6800', 36.0, null),
 ('p18', '250-86-2784', 23.0, null),
 ('p19', '386-39-7881', 2.0, null),
 ('p2', '842-88-1257', 9.0, 'dl_10'),
 ('p20', '522-44-3098', 28.0, null),
 ('p3', '750-24-7616', 11.0, 'un_38'),
 ('p4', '776-21-8098', 24.0, 'un_38'),
 ('p5', '933-93-2165', 27.0, 'ba_61'),
 ('p6', '707-84-4555', 38.0, 'ba_61'),
 ('p7', '450-25-5617', 13.0, 'lf_20'),
 ('p8', '701-38-2179', 12.0, 'ry_34'),
 ('p9', '936-44-6941', 13.0, 'lf_20');

DROP TABLE IF EXISTS pilot_license;
CREATE TABLE pilot_license (
    pilot_personID varchar(50) NOT NULL,
    license_types varchar(40) NOT NULL,
    PRIMARY KEY (license_types, pilot_personID),
    CONSTRAINT fk11 FOREIGN KEY (pilot_personID) REFERENCES pilot (personID)
) ENGINE=InnoDB;

insert into pilot_license values
 ('p1', 'jets'),
 ('p10', 'jets'),
 ('p11', 'jets'),
 ('p11', 'props'),
 ('p12', 'props'),
 ('p13', 'jets'),
 ('p14', 'jets'),
 ('p15', 'jets'),
 ('p15', 'props'),
 ('p15', 'testing'),
 ('p16', 'jets'),
 ('p17', 'jets'),
 ('p17', 'props'),
 ('p18', 'jets'),
 ('p19', 'jets'),
 ('p2', 'jets'),
 ('p2', 'props'),
 ('p20', 'jets'),
 ('p3', 'jets'),
 ('p4', 'jets'),
 ('p4', 'props'),
 ('p5', 'jets'),
 ('p6', 'jets'),
 ('p6', 'props'),
 ('p7', 'jets'),
 ('p8', 'props'),
 ('p9', 'jets'),
 ('p9', 'props'),
 ('p9', 'testing');

DROP TABLE IF EXISTS passenger;
CREATE TABLE passenger (
	personID varchar(50) NOT NULL,
    miles numeric(4,0),
    funds numeric(4,0), 
    PRIMARY KEY (personID),
    CONSTRAINT fk12 FOREIGN KEY (personID) REFERENCES person (personID)
) ENGINE=InnoDB;

insert into passenger values
 ('p21', 771.0, 700.0),
 ('p22', 374.0, 200.0),
 ('p23', 414.0, 400.0),
 ('p24', 292.0, 500.0),
 ('p25', 390.0, 300.0),
 ('p26', 302.0, 600.0),
 ('p27', 470.0, 400.0),
 ('p28', 208.0, 400.0),
 ('p29', 292.0, 700.0),
 ('p30', 686.0, 500.0),
 ('p31', 547.0, 400.0),
 ('p32', 257.0, 500.0),
 ('p33', 564.0, 600.0),
 ('p34', 211.0, 200.0),
 ('p35', 233.0, 500.0),
 ('p36', 293.0, 400.0),
 ('p37', 552.0, 700.0),
 ('p38', 812.0, 700.0),
 ('p39', 541.0, 400.0),
 ('p40', 441.0, 700.0),
 ('p41', 875.0, 300.0),
 ('p42', 691.0, 500.0),
 ('p43', 572.0, 300.0),
 ('p44', 572.0, 500.0),
 ('p45', 663.0, 500.0);

DROP TABLE IF EXISTS vacation;
CREATE TABLE vacation (
	personID varchar(50) NOT NULL,
    destination varchar(20),
    sequence varchar(20),
    PRIMARY KEY (personID, destination, sequence),
    CONSTRAINT fk13 FOREIGN KEY (personID) REFERENCES person (personID)
) ENGINE=InnoDB;

insert into vacation values
('p21', 'AMS', 1),
('p22', 'AMS', 1),
('p23', 'BER', 1),
('p24', 'CDG', 1),
('p24', 'MUC', 2),
('p25', 'MUC', 1),
('p26', 'MUC', 1),
('p27', 'BER', 1),
('p28', 'LGW', 1),
('p29', 'FCO', 1),
('p29', 'LHR', 2),
('p30', 'MAD', 1),
('p30', 'FCO', 2),
('p31', 'FCO', '1'),
('p32', 'FCO', '1'),
('p33', 'CAN', '1'),
('p34', 'HND', '1'),
('p35', 'LGW', '1'),
('p36', 'FCO', '1'),
('p37', 'FCO', 1),
('p37', 'LGW', 2),
('p37', 'CDG', 3),
('p38', 'MUC', '1'),
('p39', 'MUC', '1'),
('p40', 'HND', '1');

DROP TABLE IF EXISTS prop;
CREATE TABLE prop (
    airlineID varchar(50) NOT NULL,
    tail_num varchar(40) NOT NULL,
    skids boolean,
    props numeric(2,0),
    PRIMARY KEY (airlineID, tail_num),
    CONSTRAINT fk14 FOREIGN KEY (airlineID, tail_num) REFERENCES airplane (airlineID,tail_num)
) ENGINE=InnoDB;

insert into prop values
('Delta', 'n106js',null,null),
('Delta', 'n110jn',null,null),
('Delta', 'n127js',null,null),
('United', 'n330ss',null,null),
('United', 'n380sd',null,null),
('British Airways', 'n616lt',null,null),
('British Airways', 'n517ly',null,null),
('Lufthansa', 'n620la',null,null),
('Lufthansa', 'n401fj',null,null),
('Lufthansa', 'n653fk',null,null),
('Air_France', 'n118fm',FALSE,2),
('Air_France', 'n815pw',null,null),
('KLM', 'n161fk',null,null),
('KLM', 'n337as',null,null),
('KLM', 'n256ap',FALSE,2),
('Ryanair', 'n156sq',null,null),
('Ryanair', 'n451fi',null,null),
('Ryanair', 'n341eb',TRUE,2),
('Ryanair', 'n353kz',TRUE,2),
('Japan Airlines', 'n305fv',null,null),
('Japan Airlines', 'n443wu',null,null),
('China Southern Airlines', 'n454qq',null,null),
('China Southern Airlines', 'n249yk',FALSE,2),
('Korean Air lines', 'n180co',null,null),
('American', 'n448cs',TRUE,2),
('American', 'n225sb',null,null),
('American', 'n553qn',null,null);

DROP TABLE IF EXISTS jet;
CREATE TABLE jet (
    airlineID varchar(50) NOT NULL,
    tail_num varchar(40) NOT NULL,
    num_engines numeric(2,0),
    PRIMARY KEY (airlineID, tail_num),
    CONSTRAINT fk15 FOREIGN KEY (airlineID, tail_num) REFERENCES airplane (airlineID, tail_num)
) ENGINE=InnoDB;

insert into jet values
('Delta', 'n106js',2),
('Delta', 'n110jn', 2),
('Delta', 'n127js',4),
('United', 'n330ss',2),
('United', 'n380sd',2),
('British Airways','n616lt',2),
('British Airways', 'n517ly',2),
('Lufthansa', 'n620la',4),
('Lufthansa', 'n401fj',null),
('Lufthansa', 'n653fk', 2),
('Air_France', 'n118fm',null),
('Air_France', 'n815pw',2),
('KLM', 'n161fk', 4),
('KLM', 'n337as',2),
('KLM', 'n256ap',null),
('Ryanair', 'n156sq', 2),
('Ryanair', 'n451fi',4),
('Ryanair', 'n341eb',null),
('Ryanair', 'n353kz',null),
('Japan Airlines', 'n305fv',2),
('Japan Airlines', 'n443wu',4),
('China Southern Airlines', 'n454qq',null),
('China Southern Airlines', 'n249yk',null),
('Korean Air lines', 'n180co',2),
('American', 'n448cs',null),
('American', 'n225sb',2),
('American', 'n553qn', 2);
