# ✈️ Simple Airline Management System (SAMS)
 
This system is designed to simulate and manage a simplified commercial airline operation, including flights, passengers, pilots, and airports across a multi-airport region.

---

## 📌 Project Overview

SAMS enables the tracking and management of:

- Airplanes (jets, propeller-driven, and experimental)
- Airports (with locations and standardized codes)
- Flights (including legs, routes, distances, and schedules)
- Pilots (licenses, experience, and tax identifiers)
- Passengers (destinations, funds, miles)
- Airlines (fleet, revenue, and operations)

---

## 💡 Motivation

Real-world disruptions in the airline industry highlight the importance of robust, well-structured systems for managing flights and passenger logistics. SAMS simulates such systems with an emphasis on:

- Accurate flight routing and scheduling  
- Valid passenger boarding based on funds and destination  
- Simulation of aircraft movements and boarding/deboarding logic  
- Enforcement of safety constraints (pilot requirements, airplane capacity)  
- Support for frequent flyer mile tracking and experience updates

---

## 🗂️ Key Features

- **Entity Tracking**: Keep track of people (pilots and passengers), airplanes, airports, airlines, and flights.
- **Flight Simulation Engine**: Progresses through scheduled events (takeoffs, landings, boarding).
- **Data Constraints**: Ensures valid flight staffing, capacity limits, and financial transactions.
- **Status Management**: Tracks location and state of all planes and people.
- **Leg & Route Management**: Flights may have multiple legs, tracked in sequence.
- **Frequent Flyer System**: Updates passenger miles based on travel.
- **Pilot Experience Logging**: Tracks pilot experience per flight leg.

---

## 🧱 Data Model Includes:

- `Airline(airline_id, name, revenue)`
- `Airport(airport_id, name, city, state, country)`
- `Airplane(tail_num, airline_id, type, speed, capacity)`
- `Pilot(pilot_id, first_name, last_name, tax_id, experience)`
- `License(pilot_id, license_type)`
- `Passenger(passenger_id, first_name, last_name, miles, funds)`
- `Flight(flight_id, airline_id, plane_tail_num)`
- `Route(flight_id, sequence_num, leg_id)`
- `Leg(leg_id, from_airport, to_airport, distance)`
- `FlightStatus(flight_id, current_leg, state, next_time)`
- `Ticket(passenger_id, flight_id, destination_airport, cost)`
- `Location(person_id, type, location_id)`

---

## 📊 Sample Simulation Logic

- Airplanes start **on_ground**, depart when `next_time` arrives.
- Pilots must be assigned:  
  - 1 for propeller flights  
  - 2 for jet flights
- Passengers board if:
  - Enough funds to pay
  - Destination matches a flight leg
  - Plane has available seats
- Passengers deplane at their ticketed destination.
- Pilots and passengers gain experience/miles per completed leg.

---

## 📚 Sample Scenario

- Celia & Jason at FSL Airport board AirAces Flight 2340.
- Jet departs to SCA, then BGP, then OTC.
- System updates:
  - Flight status to `in_flight`
  - Passenger miles
  - Pilot experience
  - Plane location and state

---

## 🛠 Technologies

- **MySQL / PostgreSQL** (or any RDBMS)
- **SQL / EERD design**
- **Python** (optional, for simulation scripting)

