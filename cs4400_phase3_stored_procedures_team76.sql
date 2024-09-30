-- CS4400: Introduction to Database Systems: Tuesday, September 12, 2023
-- Simple Airline Management System Course Project Mechanics [TEMPLATE] (v0)
-- Views, Functions & Stored Procedures

/* This is a standard preamble for most of our scripts.  The intent is to establish
a consistent environment for the database behavior. */
set global transaction isolation level serializable;
set global SQL_MODE = 'ANSI,TRADITIONAL';
set names utf8mb4;
set SQL_SAFE_UPDATES = 0;

set @thisDatabase = 'flight_tracking';
use flight_tracking;
-- -----------------------------------------------------------------------------
-- stored procedures and views
-- -----------------------------------------------------------------------------
/* Standard Procedure: If one or more of the necessary conditions for a procedure to
be executed is false, then simply have the procedure halt execution without changing
the database state. Do NOT display any error messages, etc. */

-- [_] supporting functions, views and stored procedures
-- -----------------------------------------------------------------------------
/* Helpful library capabilities to simplify the implementation of the required
views and procedures. */
-- -----------------------------------------------------------------------------
drop function if exists leg_time;
delimiter //
create function leg_time (ip_distance integer, ip_speed integer)
	returns time reads sql data
begin
	declare total_time decimal(10,2);
    declare hours, minutes integer default 0;
    set total_time = ip_distance / ip_speed;
    set hours = truncate(total_time, 0);
    set minutes = truncate((total_time - hours) * 60, 0);
    return maketime(hours, minutes, 0);
end //
delimiter ;

-- [1] add_airplane()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new airplane.  A new airplane must be sponsored
by an existing airline, and must have a unique tail number for that airline.
username.  An airplane must also have a non-zero seat capacity and speed. An airplane
might also have other factors depending on it's type, like skids or some number
of engines.  Finally, an airplane must have a new and database-wide unique location
since it will be used to carry passengers. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_airplane;
delimiter //
create procedure add_airplane (in ip_airlineID varchar(50), in ip_tail_num varchar(50),
	in ip_seat_capacity integer, in ip_speed integer, in ip_locationID varchar(50),
    in ip_plane_type varchar(100), in ip_skids boolean, in ip_propellers integer,
    in ip_jet_engines integer)
sp_main: begin
	-- checks if airline exists
	if ip_airlineID not in (select airlineID from airline) 
	then leave sp_main; end if;
    
    -- checks if tail num is unique
	if ip_tail_num in (select tail_num from airplane)
	then leave sp_main; end if;
    
    -- checks if non-zero seat capacity or non-zero speed
	if (ip_seat_capacity = 0) or (ip_speed = 0) 
    then leave sp_main; end if;
    
	insert into location values (ip_locationID);
	insert into airplane values (ip_airlineID, ip_tail_num, ip_seat_capacity,ip_speed,
		ip_locationID,ip_plane_type,ip_skids,ip_propellers,ip_jet_engines);
end //
delimiter ;

-- [2] add_airport()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new airport.  A new airport must have a unique
identifier along with a new and database-wide unique location if it will be used
to support airplane takeoffs and landings.  An airport may have a longer, more
descriptive name.  An airport must also have a city, state, and country designation. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_airport;
delimiter //
create procedure add_airport (in ip_airportID char(3), in ip_airport_name varchar(200),
    in ip_city varchar(100), in ip_state varchar(100), in ip_country char(3), in ip_locationID varchar(50))
sp_main: begin
	-- Leave if airport already exists
	if ip_airportID in (select airportID from airport)
		then 
        leave sp_main; 
	end if;
    
    -- Leave if location already exists
    if ip_locationID in (select locationID from airport)
		then 
        leave sp_main; 
	end if;
    
    -- Leave if city, state, or country is null
    if (ip_city is null) or (ip_state is null) or (ip_country is null)
		then 
        leave sp_main; 
	end if;
    
    insert into location values (ip_locationID);
    insert into airport values(ip_airportID, ip_airport_name, ip_city, ip_state, ip_country, ip_locationID);
end //
delimiter ;

-- [3] add_person()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new person.  A new person must reference a unique
identifier along with a database-wide unique location used to determine where the
person is currently located: either at an airport, or on an airplane, at any given
time.  A person must have a first name, and might also have a last name.

A person can hold a pilot role or a passenger role (exclusively).  As a pilot,
a person must have a tax identifier to receive pay, and an experience level.  As a
passenger, a person will have some amount of frequent flyer miles, along with a
certain amount of funds needed to purchase tickets for flights. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_person;
delimiter //
create procedure add_person (in ip_personID varchar(50), in ip_first_name varchar(100),
    in ip_last_name varchar(100), in ip_locationID varchar(50), in ip_taxID varchar(50),
    in ip_experience integer, in ip_miles integer, in ip_funds integer)
sp_main: begin
	if ip_personID in (select personID from person) 
	then leave sp_main; end if;
    
	if ip_locationID not in (select locationID from location) 
	then leave sp_main; end if;
    
	if ip_first_name is null 
	then leave sp_main; end if;
    
    insert into person values (ip_personID, ip_first_name, ip_last_name, ip_locationID);
    
	if (ip_taxID is null) and (ip_experience is null)
		then insert into passenger values (ip_personID, ip_miles, ip_funds);
	else
		insert into pilot values (ip_personID, ip_taxID, ip_experience, (select flight.flightID from flight
        right join (SELECT airplane.airlineID, airplane.locationID
	FROM airplane
	RIGHT JOIN location ON airplane.locationID = location.locationID) as
    clara on flight.support_airline = clara.airlineID where ip_locationID = clara.locationID)); end if;
end //
delimiter ;

-- [4] grant_or_revoke_pilot_license()
-- -----------------------------------------------------------------------------
/* This stored procedure inverts the status of a pilot license.  If the license
doesn't exist, it must be created; and, if it laready exists, then it must be removed. */
-- -----------------------------------------------------------------------------
drop procedure if exists grant_or_revoke_pilot_license;
delimiter //
create procedure grant_or_revoke_pilot_license (in ip_personID varchar(50), in ip_license varchar(100))
sp_main: begin
	if ip_personID not in (select personID from pilot_licenses)
		then insert into pilot_licenses values (ip_personID,ip_license); 
	end if;
    
    DELETE FROM pilot_licenses		
    WHERE ip_personID = personID;
end //
delimiter ;

-- [5] offer_flight()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new flight.  The flight can be defined before
an airplane has been assigned for support, but it must have a valid route.  And
the airplane, if designated, must not be in use by another flight.  The flight
can be started at any valid location along the route except for the final stop,
and it will begin on the ground.  You must also include when the flight will
takeoff along with its cost. */
-- -----------------------------------------------------------------------------
drop procedure if exists offer_flight;
delimiter //
create procedure offer_flight (in ip_flightID varchar(50), in ip_routeID varchar(50),
    in ip_support_airline varchar(50), in ip_support_tail varchar(50), in ip_progress integer,
    in ip_next_time time, in ip_cost integer)
sp_main: begin
	-- Leave if the plane is used by another flight
	if exists (select * from flight
		where support_tail = ip_support_tail) 
		then 
        leave sp_main; 
	end if;
        
	-- Leave if the route doesn't exist
	if not exists (select * from route
		where routeID = ip_routeID) 
        then leave sp_main; 
	end if;
            
	-- Leave if the starting route is at the final stop
	if exists (select routeID, max(sequence) 
		from route_path group by routeID 
		having routeID = ip_routeID and max(sequence) = ip_progress)
        then leave sp_main; 
	end if; 
            
	-- Leave if takeoff time and cost are included
	if ip_next_time is null or ip_cost <= 0
		then leave sp_main; 
	end if;
	
    insert into flight values (ip_flightID, ip_routeID, ip_support_airline, ip_support_tail,
		ip_progress, 'on_ground', ip_next_time, ip_cost);
end //
delimiter ;


-- [6] flight_landing()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for a flight landing at the next airport
along it's route.  The time for the flight should be moved one hour into the future
to allow for the flight to be checked, refueled, restocked, etc. for the next leg
of travel.  Also, the pilots of the flight should receive increased experience, and
the passengers should have their frequent flyer miles updated. */
-- -----------------------------------------------------------------------------
drop procedure if exists flight_landing;
delimiter //
create procedure flight_landing (in ip_flightID varchar(50))
sp_main: begin
	declare plane_status varchar(100);

	-- checks input flight in flight table
    if ip_flightID not in (select flightID from flight)
    then leave sp_main; end if;
    
    -- checks if plane is already on ground or not
    set plane_status = (select airplane_status from flight where flightID = ip_flightID);
    
    if plane_status = 'on_ground'
    then leave sp_main; end if;
    
    -- updates passengers
	update passenger 
	set miles = miles + (select distance from airplane join(
		select leg.legID,routeID,flightID,distance,support_airline from leg join 
		(select route_path.routeID,legID,flightID,support_airline from route_path join flight on route_path.routeID = flight.routeID and route_path.sequence = flight.progress) 
		as a 
		on leg.legID = a.legID) as b
		on b.support_airline = airplane.airlineID group by flightID having ip_flightID = flightID)
        
		where passenger.personID 
        in (select personID from person join (
		select flight.flightID,ex.locationID from flight right join (SELECT airplane.airlineID, airplane.locationID
		FROM airplane
		RIGHT JOIN location ON airplane.locationID = location.locationID) as ex on flight.support_airline = ex.airlineID 
		) as a on person.locationID = a.locationID where ip_flightID = flightID);
    
    -- updates flight table
    update flight set next_time = ADDTIME(next_time,'1:00'),airplane_status='on_ground' where ip_flightID = flight.flightID;
	
    -- updates pilots of the flight
    update pilot set experience = experience + 1 where ip_flightID = pilot.commanding_flight;
end //
delimiter ;

-- [7] flight_takeoff()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for a flight taking off from its current
airport towards the next airport along it's route.  The time for the next leg of
the flight must be calculated based on the distance and the speed of the airplane.
And we must also ensure that propeller driven planes have at least one pilot
assigned, while jets must have a minimum of two pilots. If the flight cannot take
off because of a pilot shortage, then the flight must be delayed for 30 minutes. */
-- -----------------------------------------------------------------------------
drop procedure if exists flight_takeoff;
delimiter //
create procedure flight_takeoff (in ip_flightID varchar(50))
sp_main: begin
	declare current_route varchar(50);
	declare plane_status varchar(100);
	declare plane_speed integer;
    declare flight_distance integer;
    declare plane_type varchar(100);
    declare num_pilots integer;
    declare current_progress integer;

	if not exists (select *
		from flight
        where ip_flightID = flightID)
        then
        leave sp_main;
	end if;
    
    set plane_status = (select airplane_status from flight
		where flightID = ip_flightID);
        
	if plane_status = 'in_flight'
		then leave sp_main;
	end if;
    
    set current_route = (select routeID 
		from flight
        where flightID = ip_flightID);
        
	set current_progress = (select progress
		from flight
        where flightID = ip_flightID);
        
    -- Leave if the plane is at the end
    if exists (select routeID, max(sequence) 
		from route_path group by routeID 
		having routeID = current_route and 
			(max(sequence) = current_progress))
        then 
        leave sp_main; 
	end if;
    
    set flight_distance = (select distance from flight join (
		select distance, routeID, sequence from leg
		join route_path on leg.legID = route_path.legID)
		as combined
		on progress = sequence and flight.routeID = combined.routeID
		where flightID = ip_flightID);
    
    set plane_speed = (select speed from flight join airplane
		on support_tail = tail_num
        where flightID = ip_flightID);
        
	set plane_type = (select plane_type 
		from flight join airplane 
        on support_tail = tail_num
        where flightID = ip_flightID);
        
	set num_pilots = (select count(*) from flight
		join pilot on flightID = commanding_flight
		group by flightID
        having flightID = ip_flightID);
        
	if (plane_type = 'prop' and num_pilots < 1) 
    or (plane_type = 'jet' and num_pilots < 2)
		then 
		update flight
        set next_time = ADDTIME(next_time, "00:30:00");
        leave sp_main;
	end if;
    
    update flight 
    set next_time = ADDTIME(next_time, leg_time(flight_distance, plane_speed)), 
		progress = progress + 1,
        airplane_status = 'in_flight'
	where flight.flightID = ip_flightID; 
end //
delimiter ;

create or replace view qualified_passenger (flightID, airplane_status, departure, arrival,
	cost, personID, curr_location, destination, funds) as
select * from
(select flightID, airplane_status, departure, arrival, cost from flight
join route_path on flight.routeID = route_path.routeID
join leg on route_path.legID = leg.legID
where airplane_status = 'on_ground' and progress = sequence
union
select flightID, airplane_status, departure, arrival, cost from flight
join route_path on flight.routeID = route_path.routeID
join leg on route_path.legID = leg.legID
where progress = 0 and progress + 1 = sequence) as available_flight join 
(select person.personID, airport.airportID as curr_location, 
passenger_vacations.airportID as destination,
funds from passenger_vacations
join person on passenger_vacations.personID = person.personID 
join passenger on passenger_vacations.personID = passenger.personID
join airport on person.locationID = airport.locationID
where person.locationID like 'port%' and sequence = 1) as potential_passenger
on (departure = curr_location and arrival = destination)
where funds >= cost;

-- [8] passengers_board()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for passengers getting on a flight at
its current airport.  The passengers must be at the same airport as the flight,
and the flight must be heading towards that passenger's desired destination.
Also, each passenger must have enough funds to cover the flight.  Finally, there
must be enough seats to accommodate all boarding passengers. */
-- -----------------------------------------------------------------------------
drop procedure if exists passengers_board;
delimiter //
create procedure passengers_board (in ip_flightID varchar(50))
sp_main: begin
	declare num_passengers integer;
    declare num_seats integer;
    declare current_route varchar(50);
    declare current_progress integer;

	-- Leave if the flight doesn't exist
	if ip_flightID not in (select flightID from flight)
		then 
        leave sp_main; 
	end if;
    
    -- Leave if it's currently in-flight
    if exists (select airplane_status from flight
    where ip_flightID = flightID and airplane_status = 'in_flight')
		then 
        leave sp_main; 
	end if;
    
    set current_route = (select routeID from flight
		where flightID = ip_flightID);
        
	set current_progress = (select progress from flight
		where flightID = ip_flightID);
    
    -- Leave if the plane is at the end
    if not exists (select routeID, max(sequence) 
		from route_path group by routeID 
		having routeID = current_route and 
			(max(sequence) = current_progress))
        then 
        leave sp_main; 
	end if;
    
    -- matching locations
    
    set num_seats = (select seat_capacity from airplane join flight on tail_num = support_tail
		where ip_flightID = flightID);
        
    set num_passengers = (select count(distinct personID) from qualified_passenger
		group by flightID);
        
	-- Leave if passengers count exceed number of seats
	if num_passengers > num_seats
		then leave sp_main;
	end if;
    
    update person p
    set p.locationID = (select locationID from qualified_passenger where flightID = ip_flightID) 
    where p.personID in (select passenger_vacations.personID from passenger_vacations  
	join (select * from person) as a on passenger_vacations.personID= a.personID where locationID 
    in (select locationID from flight join airplane where flightID=ip_flightID and support_tail=tail_num));
end //
delimiter ;

-- call passengers_board('am_86');

-- [9] passengers_disembark()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for passengers getting off of a flight
at its current airport.  The passengers must be on that flight, and the flight must
be located at the destination airport as referenced by the ticket. */
-- -----------------------------------------------------------------------------
drop procedure if exists passengers_disembark;
delimiter //
create procedure passengers_disembark (in ip_flightID varchar(50))
sp_main: begin
	if (ip_flightID in (select flightID from flight where airplane_status="on_ground"))
then 
update person p 
set p.locationID = (select airport.locationID from airport where airport.airportID in (select arrival from flight,airplane,route_path,leg
 where flightID = ip_flightID and support_tail=tail_num and route_path.routeID=flight.routeID and progress=sequence and 
 leg.legID=route_path.legID))
where p.personID in (select passenger_vacations.personID from passenger_vacations  
join (select * from person) as a on passenger_vacations.personID= a.personID where locationID 
in (select locationID  from flight  join airplane where flightID=ip_flightID and support_tail=tail_num) and airportID in
 (select arrival from flight,leg,route_path where flightID=ip_flightID and flight.routeID=route_path.routeID
 and progress=sequence and leg.legID=route_path.legID));
 
update passenger_vacations pv
set pv.sequence = pv.sequence-1
where pv.personID in (select person.personID from (select * from passenger_vacations) as a
join  person on person.personID= a.personID where locationID 
in (select locationID  from flight  join airplane where flightID=ip_flightID and support_tail=tail_num) and airportID in
 (select arrival from flight,leg,route_path where flightID=ip_flightID and flight.routeID=route_path.routeID
 and progress=sequence and leg.legID=route_path.legID)) and pv.sequence>1;
 
delete from passenger_vacations pv
where pv.personID in (select person.personID from (select * from passenger_vacations) as a
join  person on person.personID= a.personID where locationID 
in (select locationID  from flight  join airplane where flightID=ip_flightID and support_tail=tail_num) and airportID in
 (select arrival from flight,leg,route_path where flightID=ip_flightID and flight.routeID=route_path.routeID
 and progress=sequence and leg.legID=route_path.legID) and pv.sequence=1);
 

end if;
end //
delimiter ;

-- [10] assign_pilot()
-- -----------------------------------------------------------------------------
/* This stored procedure assigns a pilot as part of the flight crew for a given
flight.  The pilot being assigned must have a license for that type of airplane,
and must be at the same location as the flight.  Also, a pilot can only support
one flight (i.e. one airplane) at a time.  The pilot must be assigned to the flight
and have their location updated for the appropriate airplane. */
-- -----------------------------------------------------------------------------
drop procedure if exists assign_pilot;
delimiter //
create procedure assign_pilot (in ip_flightID varchar(50), ip_personID varchar(50))
sp_main: begin
	declare current_pilot_license varchar(100);
    declare current_plane_type varchar(100);
    declare current_pilot_location varchar(50);
    declare current_plane_location varchar(50);

	-- Leave if flight doesn't exist
	if not exists (select * from flight
		where ip_flightID = flightID)
        then
        leave sp_main;
	end if;
    
    -- Leave if person doesn't exist
    if not exists (select * from person
		where personID = ip_personID)
        then
        leave sp_main;
	end if;
    
    set current_pilot_license = (select license from pilot_licenses 
		where personID = ip_personID);
        
	set current_plane_type = (select concat(airplane.plane_type, "s") from flight
		left outer join airplane
		on support_tail = tail_num
		where flightID = ip_flightID);
        
	-- Leave if pilot's license is not compatible with plane type
	if current_plane_type != current_pilot_license
		then leave sp_main; end if;
        
    set current_pilot_location = (select locationID from person
		where personID = ip_personID);
        
	set current_plane_location = (select airplane.locationID from flight
		left outer join airplane
		on support_tail = tail_num
		where flightID = ip_flightID);
    
    update pilot pi
    set pi.commanding_flight = ip_flightID
    where pi.commanding_flight = ip_flightID;
end //
delimiter ;

-- [11] recycle_crew()
-- -----------------------------------------------------------------------------
/* This stored procedure releases the assignments for a given flight crew.  The
flight must have ended, and all passengers must have disembarked. */
-- -----------------------------------------------------------------------------
drop procedure if exists recycle_crew;
delimiter //
create procedure recycle_crew (in ip_flightID varchar(50))
sp_main: begin
	if (ip_flightID in (select flightID 
		from flight where airplane_status="on_ground" 
		and routeID in (
			select flight.routeID 
            from flight join (SELECT routeID,count(sequence) 
            as s FROM route_path group by routeId ) as ABC
		where flight.routeID=ABC.routeID and ABC.s=progress) ))
		then
		update person p
        
		set p.locationID = 
			(select airport.locationID from airport join (select * from leg where legID in 
			(select legID from route_path JOIN 
			(select routeID,progress from flight where flightID = ip_flightID) as B where
				B.routeID= route_path.routeID and sequence=B.progress)) as BH on airport.airportID = BH.arrival)
				where p.locationID in (select airplane.locationID from airplane join (select * from flight where flightID=ip_flightID) as d 
				on airplane.airlineID=d.support_airline and airplane.tail_num= d.support_tail);
    
		update pilot pi
		set pi.commanding_flight = null
		where pi.commanding_flight = ip_flightID;
    end if;
end //
delimiter ;

-- [12] retire_flight()
-- -----------------------------------------------------------------------------
/* This stored procedure removes a flight that has ended from the system.  The
flight must be on the ground, and either be at the start its route, or at the
end of its route.  And the flight must be empty - no pilots or passengers. */
-- -----------------------------------------------------------------------------
drop procedure if exists retire_flight;
delimiter //
create procedure retire_flight (in ip_flightID varchar(50))
sp_main: begin
	declare current_route varchar(50);
    declare current_progress integer;
    declare current_tail varchar(50);
    
	-- Leave if flight doesn't exist
	if not exists (
		select * from flight
		where flightID = ip_flightID)
		then
        leave sp_main;
	end if;
    
    set current_route = (select routeID from flight
		where flightID = ip_flightID);
        
	set current_progress = (select progress from flight
		where flightID = ip_flightID);
        
	set current_tail = (select support_tail from flight
		where flightID = ip_flightID);
    
    -- Leave if the plane is at the start or at the end
    if not exists (select routeID, max(sequence) 
		from route_path group by routeID 
		having routeID = current_route and 
			(max(sequence) = current_progress or current_progress = 0))
        then 
        leave sp_main; 
	end if;
    
    -- Leave if the plane is not empty
    if exists (select distinct airplane.tail_num 
		from person left outer join airplane
		on person.locationID = airplane.locationID
		where airplane.tail_num = current_tail)
        then
        leave sp_main;
	end if;
    
    delete from flight where flightID = ip_flightID;
end //
delimiter;

-- [13] simulation_cycle()
-- -----------------------------------------------------------------------------
/* This stored procedure executes the next step in the simulation cycle.  The flight
with the smallest next time in chronological order must be identified and selected.
If multiple flights have the same time, then flights that are landing should be
preferred over flights that are taking off.  Similarly, flights with the lowest
identifier in alphabetical order should also be preferred.

If an airplane is in flight and waiting to land, then the flight should be allowed
to land, passengers allowed to disembark, and the time advanced by one hour until
the next takeoff to allow for preparations.

If an airplane is on the ground and waiting to takeoff, then the passengers should
be allowed to board, and the time should be advanced to represent when the airplane
will land at its next location based on the leg distance and airplane speed.

If an airplane is on the ground and has reached the end of its route, then the
flight crew should be recycled to allow rest, and the flight itself should be
retired from the system. */
-- -----------------------------------------------------------------------------
drop procedure if exists simulation_cycle;
delimiter //
create procedure simulation_cycle ()
sp_main: begin
	declare current_flight varchar(100);
	set current_flight = (select flightID from flight order by next_time asc, airplane_status desc, flightID asc limit 1);
	call flight_takeoff(current_flight);
    call passengers_board(current_flight);
    call flight_landing(current_flight);
    call passengers_disembark(current_flight);
    call recycle_crew(current_flight);
    call retire_flight(current_flight); 

    
end //
delimiter ;

-- [14] flights_in_the_air()
-- -----------------------------------------------------------------------------
/* This view describes where flights that are currently airborne are located. */
-- -----------------------------------------------------------------------------
create or replace view flights_in_the_air (departing_from, arriving_at, num_flights,
	flight_list, earliest_arrival, latest_arrival, airplane_list) as
select leg.departure as departing_from, leg.arrival as arriving_at,
count( distinct flightID) as num_flights,group_concat(distinct flightID) as flight_list,
min(next_time) as earliest_arrival,max(next_time) as latest_arrival, 
group_concat( distinct airplane.locationID) as airplane_list
from flight,airplane,route_path,leg where airplane_status='in_flight'
and airplane.tail_num = flight.support_tail and route_path.routeID=flight.routeID 
and flight.support_airline = airplane.airlineID and leg.legID=route_path.legID 
and route_path.sequence=flight.progress
group by flight.flightID;

-- [15] flights_on_the_ground()
-- -----------------------------------------------------------------------------
/* This view describes where flights that are currently on the ground are located. */
-- -----------------------------------------------------------------------------
create or replace view flights_on_the_ground (departing_from, num_flights,
	flight_list, earliest_arrival, latest_arrival, airplane_list) as 
select leg.arrival as departing_from, count( distinct flightID) as num_flights,
	group_concat( distinct flightID) as flight_list, min(next_time) as earliest_arrival,
    max(next_time) as latest_arrival, group_concat( distinct airplane.locationID) as airplane_list
from flight,airplane,route_path,leg 
where airplane_status='on_ground' and airplane.tail_num = flight.support_tail 
	and route_path.routeID=flight.routeID and flight.support_airline = airplane.airlineID
    and leg.legID=route_path.legID  and route_path.sequence=flight.progress
group by departing_from
union
select leg.departure as departing_from, count( distinct flightID) as num_flights,
	group_concat( distinct flightID) as flight_list, min(next_time) as earliest_arrival,
    max(next_time) as latest_arrival, group_concat( distinct airplane.locationID) as airplane_list
from flight,airplane,(select * from route_path where sequence = 1) as t, leg where airplane_status='on_ground'
	and airplane.tail_num = flight.support_tail and t.routeID=flight.routeID 
    and flight.support_airline = airplane.airlineID and leg.legID=t.legID and flight.progress=0
group by departing_from;

-- [16] people_in_the_air()
-- -----------------------------------------------------------------------------
/* This view describes where people who are currently airborne are located. */
-- -----------------------------------------------------------------------------
create or replace view people_in_the_air (departing_from, arriving_at, num_airplanes,
	airplane_list, flight_list, earliest_arrival, latest_arrival, num_pilots,
	num_passengers, joint_pilots_passengers, person_list) as
select first.departure, first.arrival, fifth.amount as num_airplanes, 
	first.locationID as airplane_list,
    first.flightID as flight_list, second.early as earliest_arrival,
	second.late as latest_arrival, fourth.amount as num_pilots,
    third.amount as num_passengers, fourth.amount + third.amount as joint_pilot_passengers,
    sixth.person_list
from (
select leg.departure, leg.arrival, airplane.locationID, flight.flightID
from flight, route_path, leg, airplane
where airplane_status='in_flight' and route_path.routeID=flight.routeID 
	and leg.legID=route_path.legID and route_path.sequence=flight.progress
	and airplane.tail_num = flight.support_tail) as first
join

-- time
(select flightID, min(next_time) as early, max(next_time) as late
from flight group by flightID) as second
on first.flightID = second.flightID
join

-- passenger count
(select flight.flightID, count(distinct passenger.personID) as amount
from person, passenger, airplane, flight
where person.locationID = airplane.locationID and person.personID = passenger.personID
	and flight.support_tail = airplane.tail_num
group by flight.flightID) as third
on first.flightID = third.flightID
join

-- pilot count
(select flightID, count(distinct personID) as amount 
from pilot, flight
where commanding_flight = flightID
group by flightID) as fourth
on first.flightID = fourth.flightID
join

-- plane amount
(select flightID, count(support_tail) as amount from flight
group by flightID) as fifth
on first.flightID = fifth.flightID
join

-- person list
(select flight.flightID, group_concat(distinct person.personID) as person_list
from person, airplane, flight
where person.locationID = airplane.locationID
	and flight.support_tail = airplane.tail_num
group by flight.flightID) as sixth
on first.flightID = sixth.flightID;

-- [17] people_on_the_ground()
-- -----------------------------------------------------------------------------
/* This view describes where people who are currently on the ground are located. */
-- -----------------------------------------------------------------------------
create or replace view people_on_the_ground (departing_from, airport, airport_name,
	city, state, country, num_pilots, num_passengers, joint_pilots_passengers, person_list) as
select airportID as departing_form,locationID,airport_name,city,state,country,count(case when role = 'Pilot' then 1 else null end) as num_pilots,count(case when role = 'Passenger' then 1 else null end) as num_passengers,count(*) as joint_pilots_passengers,group_concat(a.personID order by a.personID asc) as person_list
from (select 'Passenger' as role, personID
from passenger
union all
select 'Pilot' as role, personID
from pilot) as a 
join (
select airportID, airport_name,city,state,country,airport.locationID,personID from airport 
join (select * from person where locationID like 'port%') 
as people 
on airport.locationID = people.locationID) as b on a.personID = b.personID
group by airportID;	

-- [18] route_summary()
-- -----------------------------------------------------------------------------
/* This view describes how the routes are being utilized by different flights. */
-- -----------------------------------------------------------------------------
create or replace view route_summary (route, num_legs, leg_sequence, route_length,
	num_flights, flight_list, airport_sequence) as
select T.routeID as route, count( distinct leg.legID) as num_legs, group_concat(distinct leg.legID order by sequence) as leg_sequence,
 sum( distinct distance ) as route_length,count( distinct flightID) as num_flights, group_concat(distinct flightID) as flight_list,
 group_concat( distinct departure,'->',arrival order by sequence) as airport_sequence
 from leg,(select flightID,route_path.routeID,legID ,sequence from route_path LEFT join flight on route_path.routeID = flight.routeID) as T
 where T.legID=leg.legID group by T.routeID having count(distinct flightID)>1
 union
 select T.routeID as route, count( distinct leg.legID) as num_legs, group_concat(distinct leg.legID order by sequence) as leg_sequence,
 sum( distance ) as route_length,count( distinct flightID) as num_flights, group_concat(distinct flightID) as flight_list,
 group_concat( distinct departure,'->',arrival order by sequence) as airport_sequence
 from leg,(select flightID,route_path.routeID,legID ,sequence from route_path LEFT join flight on route_path.routeID = flight.routeID) as T
 where T.legID=leg.legID group by T.routeID having count(distinct flightID)<=1;

-- [19] alternative_airports()
-- -----------------------------------------------------------------------------
/* This view displays airports that share the same city and state. */
-- -----------------------------------------------------------------------------
create or replace view alternative_airports (city, state, country, num_airports,
	airport_code_list, airport_name_list) as
SELECT city, state, country, count(airportID) as num_airports, 
	group_concat(airportID) as airport_code_list, group_concat(airport_name) as airport_name_list 
FROM airport group by city, state, country having count( airportID) > 1;
