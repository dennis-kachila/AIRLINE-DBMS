-- Kenya Airways Database Schema
-- PostgreSQL implementation

-- Drop database if it exists (for development purposes)
-- DROP DATABASE IF EXISTS kenya_airways;

-- Create database
-- CREATE DATABASE kenya_airways;

-- Connect to database
-- \c kenya_airways

-- Enable UUID extension (for generating unique identifiers)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create schemas for organization
CREATE SCHEMA IF NOT EXISTS core;
CREATE SCHEMA IF NOT EXISTS customer;
CREATE SCHEMA IF NOT EXISTS employee;
CREATE SCHEMA IF NOT EXISTS operations;
CREATE SCHEMA IF NOT EXISTS finance;

-- Core Entities

-- Airports
CREATE TABLE core.airports (
    airport_id SERIAL PRIMARY KEY,
    iata_code CHAR(3) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    country VARCHAR(50) NOT NULL,
    latitude DECIMAL(10, 6),
    longitude DECIMAL(10, 6),
    timezone_offset INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Aircraft Types
CREATE TABLE core.aircraft_types (
    aircraft_type_id SERIAL PRIMARY KEY,
    model VARCHAR(50) NOT NULL,
    manufacturer VARCHAR(50) NOT NULL,
    capacity_economy INT NOT NULL,
    capacity_business INT NOT NULL,
    capacity_first INT NOT NULL,
    cargo_capacity_kg INT NOT NULL,
    range_km INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Aircraft
CREATE TABLE core.aircraft (
    aircraft_id SERIAL PRIMARY KEY,
    registration_number VARCHAR(20) UNIQUE NOT NULL,
    aircraft_type_id INT NOT NULL REFERENCES core.aircraft_types(aircraft_type_id),
    manufacture_date DATE NOT NULL,
    last_maintenance_date DATE,
    next_maintenance_date DATE,
    status VARCHAR(20) CHECK (status IN ('Active', 'Maintenance', 'Retired', 'Standby')) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Routes
CREATE TABLE core.routes (
    route_id SERIAL PRIMARY KEY,
    origin_airport_id INT NOT NULL REFERENCES core.airports(airport_id),
    destination_airport_id INT NOT NULL REFERENCES core.airports(airport_id),
    distance_km INT NOT NULL,
    estimated_duration_minutes INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT different_airports CHECK (origin_airport_id != destination_airport_id)
);

-- Flight Schedules
CREATE TABLE core.flight_schedules (
    schedule_id SERIAL PRIMARY KEY,
    route_id INT NOT NULL REFERENCES core.routes(route_id),
    flight_number VARCHAR(10) NOT NULL,
    departure_time TIME NOT NULL,
    arrival_time TIME NOT NULL,
    days_of_operation VARCHAR(7) NOT NULL, -- e.g., '1234567' for every day, '135' for Mon, Wed, Fri
    effective_from DATE NOT NULL,
    effective_to DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Flights
CREATE TABLE core.flights (
    flight_id SERIAL PRIMARY KEY,
    schedule_id INT NOT NULL REFERENCES core.flight_schedules(schedule_id),
    aircraft_id INT REFERENCES core.aircraft(aircraft_id),
    flight_date DATE NOT NULL,
    scheduled_departure TIMESTAMP NOT NULL,
    scheduled_arrival TIMESTAMP NOT NULL,
    actual_departure TIMESTAMP,
    actual_arrival TIMESTAMP,
    status VARCHAR(20) CHECK (status IN ('Scheduled', 'Boarding', 'Departed', 'In Air', 'Landed', 'Arrived', 'Delayed', 'Cancelled', 'Diverted')) NOT NULL,
    gate_departure VARCHAR(10),
    gate_arrival VARCHAR(10),
    baggage_claim VARCHAR(10),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Customer Entities

-- Passengers
CREATE TABLE customer.passengers (
    passenger_id SERIAL PRIMARY KEY,
    title VARCHAR(10),
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE,
    nationality VARCHAR(50),
    passport_number VARCHAR(20),
    passport_expiry DATE,
    email VARCHAR(100),
    phone VARCHAR(20),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Loyalty Program
CREATE TABLE customer.loyalty_program (
    loyalty_id SERIAL PRIMARY KEY,
    passenger_id INT NOT NULL REFERENCES customer.passengers(passenger_id),
    membership_number VARCHAR(20) UNIQUE NOT NULL,
    membership_level VARCHAR(20) CHECK (membership_level IN ('Blue', 'Silver', 'Gold', 'Platinum')) NOT NULL,
    points_balance INT NOT NULL DEFAULT 0,
    tier_qualification_points INT NOT NULL DEFAULT 0,
    join_date DATE NOT NULL,
    expiry_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bookings
CREATE TABLE customer.bookings (
    booking_id SERIAL PRIMARY KEY,
    booking_reference VARCHAR(10) UNIQUE NOT NULL,
    passenger_id INT NOT NULL REFERENCES customer.passengers(passenger_id),
    booking_date TIMESTAMP NOT NULL,
    booking_channel VARCHAR(20) CHECK (booking_channel IN ('Website', 'Mobile App', 'Call Center', 'Travel Agent', 'Airport Counter')) NOT NULL,
    booking_status VARCHAR(20) CHECK (booking_status IN ('Confirmed', 'Pending', 'Cancelled', 'Completed')) NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(3) NOT NULL,
    payment_status VARCHAR(20) CHECK (payment_status IN ('Paid', 'Partially Paid', 'Unpaid', 'Refunded')) NOT NULL,
    contact_email VARCHAR(100) NOT NULL,
    contact_phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tickets
CREATE TABLE customer.tickets (
    ticket_id SERIAL PRIMARY KEY,
    booking_id INT NOT NULL REFERENCES customer.bookings(booking_id),
    flight_id INT NOT NULL REFERENCES core.flights(flight_id),
    passenger_id INT NOT NULL REFERENCES customer.passengers(passenger_id),
    ticket_number VARCHAR(20) UNIQUE NOT NULL,
    ticket_class VARCHAR(20) CHECK (ticket_class IN ('Economy', 'Premium Economy', 'Business', 'First')) NOT NULL,
    seat_number VARCHAR(5),
    fare_amount DECIMAL(10, 2) NOT NULL,
    fare_basis VARCHAR(10) NOT NULL,
    baggage_allowance_kg INT NOT NULL,
    checked_in BOOLEAN DEFAULT FALSE,
    check_in_time TIMESTAMP,
    boarding_time TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Special Requests
CREATE TABLE customer.special_requests (
    request_id SERIAL PRIMARY KEY,
    ticket_id INT NOT NULL REFERENCES customer.tickets(ticket_id),
    request_type VARCHAR(50) CHECK (request_type IN ('Wheelchair', 'Special Meal', 'Extra Legroom', 'Bassinet', 'Unaccompanied Minor', 'Medical Assistance', 'Other')) NOT NULL,
    request_details TEXT,
    status VARCHAR(20) CHECK (status IN ('Requested', 'Confirmed', 'Fulfilled', 'Denied')) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Employee Entities

-- Departments
CREATE TABLE employee.departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(50) NOT NULL,
    department_code VARCHAR(10) NOT NULL,
    parent_department_id INT REFERENCES employee.departments(department_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Positions
CREATE TABLE employee.positions (
    position_id SERIAL PRIMARY KEY,
    position_name VARCHAR(50) NOT NULL,
    department_id INT NOT NULL REFERENCES employee.departments(department_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Employees
CREATE TABLE employee.employees (
    employee_id SERIAL PRIMARY KEY,
    employee_number VARCHAR(20) UNIQUE NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender VARCHAR(10) CHECK (gender IN ('Male', 'Female', 'Other', 'Prefer not to say')) NOT NULL,
    nationality VARCHAR(50) NOT NULL,
    passport_number VARCHAR(20),
    passport_expiry DATE,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    address TEXT NOT NULL,
    hire_date DATE NOT NULL,
    position_id INT NOT NULL REFERENCES employee.positions(position_id),
    salary DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20) CHECK (status IN ('Active', 'On Leave', 'Suspended', 'Terminated')) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Crew
CREATE TABLE employee.crew (
    crew_id SERIAL PRIMARY KEY,
    employee_id INT NOT NULL REFERENCES employee.employees(employee_id),
    crew_type VARCHAR(20) CHECK (crew_type IN ('Pilot', 'Co-Pilot', 'Flight Engineer', 'Cabin Crew', 'Purser')) NOT NULL,
    qualifications TEXT,
    license_number VARCHAR(20),
    license_type VARCHAR(50),
    certification_date DATE,
    medical_expiry DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Crew Assignments
CREATE TABLE employee.crew_assignments (
    assignment_id SERIAL PRIMARY KEY,
    crew_id INT NOT NULL REFERENCES employee.crew(crew_id),
    flight_id INT NOT NULL REFERENCES core.flights(flight_id),
    role VARCHAR(20) NOT NULL,
    report_time TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Operational Entities

-- Maintenance Records
CREATE TABLE operations.maintenance (
    maintenance_id SERIAL PRIMARY KEY,
    aircraft_id INT NOT NULL REFERENCES core.aircraft(aircraft_id),
    maintenance_type VARCHAR(50) NOT NULL,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP,
    description TEXT NOT NULL,
    performed_by INT REFERENCES employee.employees(employee_id),
    status VARCHAR(20) CHECK (status IN ('Scheduled', 'In Progress', 'Completed', 'Deferred')) NOT NULL,
    cost DECIMAL(10, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Cargo
CREATE TABLE operations.cargo (
    cargo_id SERIAL PRIMARY KEY,
    flight_id INT NOT NULL REFERENCES core.flights(flight_id),
    weight_kg DECIMAL(10, 2) NOT NULL,
    volume_cubic_meters DECIMAL(10, 2),
    content_type VARCHAR(50) NOT NULL,
    handling_instructions TEXT,
    shipper_name VARCHAR(100) NOT NULL,
    shipper_contact VARCHAR(100) NOT NULL,
    recipient_name VARCHAR(100) NOT NULL,
    recipient_contact VARCHAR(100) NOT NULL,
    charge_amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20) CHECK (status IN ('Booked', 'Received', 'Loaded', 'In Transit', 'Delivered', 'Returned')) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Baggage
CREATE TABLE operations.baggage (
    baggage_id SERIAL PRIMARY KEY,
    ticket_id INT NOT NULL REFERENCES customer.tickets(ticket_id),
    weight_kg DECIMAL(5, 2) NOT NULL,
    tag_number VARCHAR(20) UNIQUE NOT NULL,
    status VARCHAR(20) CHECK (status IN ('Checked', 'Loaded', 'In Transit', 'Arrived', 'Claimed', 'Lost', 'Damaged')) NOT NULL,
    handling_instructions TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Catering
CREATE TABLE operations.catering (
    catering_id SERIAL PRIMARY KEY,
    flight_id INT NOT NULL REFERENCES core.flights(flight_id),
    supplier_name VARCHAR(100) NOT NULL,
    meal_types TEXT NOT NULL,
    meal_count_economy INT NOT NULL,
    meal_count_business INT NOT NULL,
    meal_count_first INT NOT NULL,
    special_meals INT NOT NULL,
    cost DECIMAL(10, 2) NOT NULL,
    delivery_time TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Incidents
CREATE TABLE operations.incidents (
    incident_id SERIAL PRIMARY KEY,
    flight_id INT REFERENCES core.flights(flight_id),
    aircraft_id INT REFERENCES core.aircraft(aircraft_id),
    incident_time TIMESTAMP NOT NULL,
    incident_type VARCHAR(50) NOT NULL,
    location VARCHAR(100),
    description TEXT NOT NULL,
    severity VARCHAR(20) CHECK (severity IN ('Minor', 'Moderate', 'Major', 'Critical')) NOT NULL,
    reported_by INT REFERENCES employee.employees(employee_id),
    resolution TEXT,
    resolution_time TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Financial Entities

-- Payments
CREATE TABLE finance.payments (
    payment_id SERIAL PRIMARY KEY,
    booking_id INT NOT NULL REFERENCES customer.bookings(booking_id),
    amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(3) NOT NULL,
    payment_date TIMESTAMP NOT NULL,
    payment_method VARCHAR(20) CHECK (payment_method IN ('Credit Card', 'Debit Card', 'Bank Transfer', 'Cash', 'Mobile Money', 'Loyalty Points')) NOT NULL,
    transaction_id VARCHAR(50),
    status VARCHAR(20) CHECK (status IN ('Pending', 'Completed', 'Failed', 'Refunded')) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Refunds
CREATE TABLE finance.refunds (
    refund_id SERIAL PRIMARY KEY,
    payment_id INT NOT NULL REFERENCES finance.payments(payment_id),
    amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(3) NOT NULL,
    refund_date TIMESTAMP NOT NULL,
    reason TEXT NOT NULL,
    approved_by INT REFERENCES employee.employees(employee_id),
    status VARCHAR(20) CHECK (status IN ('Pending', 'Approved', 'Processed', 'Rejected')) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Expenses
CREATE TABLE finance.expenses (
    expense_id SERIAL PRIMARY KEY,
    expense_type VARCHAR(50) NOT NULL,
    flight_id INT REFERENCES core.flights(flight_id),
    aircraft_id INT REFERENCES core.aircraft(aircraft_id),
    amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(3) NOT NULL,
    expense_date TIMESTAMP NOT NULL,
    description TEXT NOT NULL,
    approved_by INT REFERENCES employee.employees(employee_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Revenue
CREATE TABLE finance.revenue (
    revenue_id SERIAL PRIMARY KEY,
    flight_id INT REFERENCES core.flights(flight_id),
    revenue_type VARCHAR(50) CHECK (revenue_type IN ('Ticket Sales', 'Cargo', 'Excess Baggage', 'In-flight Services', 'Other')) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(3) NOT NULL,
    entry_date TIMESTAMP NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for performance optimization

-- Core schema indexes
CREATE INDEX idx_airports_iata ON core.airports(iata_code);
CREATE INDEX idx_aircraft_registration ON core.aircraft(registration_number);
CREATE INDEX idx_aircraft_status ON core.aircraft(status);
CREATE INDEX idx_routes_airports ON core.routes(origin_airport_id, destination_airport_id);
CREATE INDEX idx_flight_schedules_route ON core.flight_schedules(route_id);
CREATE INDEX idx_flight_schedules_days ON core.flight_schedules(days_of_operation);
CREATE INDEX idx_flights_schedule ON core.flights(schedule_id);
CREATE INDEX idx_flights_aircraft ON core.flights(aircraft_id);
CREATE INDEX idx_flights_dates ON core.flights(flight_date);
CREATE INDEX idx_flights_status ON core.flights(status);

-- Customer schema indexes
CREATE INDEX idx_passengers_name ON customer.passengers(last_name, first_name);
CREATE INDEX idx_passengers_passport ON customer.passengers(passport_number);
CREATE INDEX idx_loyalty_passenger ON customer.loyalty_program(passenger_id);
CREATE INDEX idx_loyalty_level ON customer.loyalty_program(membership_level);
CREATE INDEX idx_bookings_reference ON customer.bookings(booking_reference);
CREATE INDEX idx_bookings_passenger ON customer.bookings(passenger_id);
CREATE INDEX idx_bookings_status ON customer.bookings(booking_status);
CREATE INDEX idx_tickets_booking ON customer.tickets(booking_id);
CREATE INDEX idx_tickets_flight ON customer.tickets(flight_id);
CREATE INDEX idx_tickets_passenger ON customer.tickets(passenger_id);
CREATE INDEX idx_tickets_number ON customer.tickets(ticket_number);

-- Employee schema indexes
CREATE INDEX idx_employees_number ON employee.employees(employee_number);
CREATE INDEX idx_employees_name ON employee.employees(last_name, first_name);
CREATE INDEX idx_employees_position ON employee.employees(position_id);
CREATE INDEX idx_crew_employee ON employee.crew(employee_id);
CREATE INDEX idx_crew_type ON employee.crew(crew_type);
CREATE INDEX idx_crew_assignments_flight ON employee.crew_assignments(flight_id);
CREATE INDEX idx_crew_assignments_crew ON employee.crew_assignments(crew_id);

-- Operations schema indexes
CREATE INDEX idx_maintenance_aircraft ON operations.maintenance(aircraft_id);
CREATE INDEX idx_maintenance_status ON operations.maintenance(status);
CREATE INDEX idx_cargo_flight ON operations.cargo(flight_id);
CREATE INDEX idx_baggage_ticket ON operations.baggage(ticket_id);
CREATE INDEX idx_baggage_tag ON operations.baggage(tag_number);
CREATE INDEX idx_catering_flight ON operations.catering(flight_id);
CREATE INDEX idx_incidents_flight ON operations.incidents(flight_id);
CREATE INDEX idx_incidents_aircraft ON operations.incidents(aircraft_id);

-- Finance schema indexes
CREATE INDEX idx_payments_booking ON finance.payments(booking_id);
CREATE INDEX idx_payments_status ON finance.payments(status);
CREATE INDEX idx_refunds_payment ON finance.refunds(payment_id);
CREATE INDEX idx_expenses_flight ON finance.expenses(flight_id);
CREATE INDEX idx_expenses_aircraft ON finance.expenses(aircraft_id);
CREATE INDEX idx_revenue_flight ON finance.revenue(flight_id);
CREATE INDEX idx_revenue_type ON finance.revenue(revenue_type);

-- Create views for common reporting needs

-- Flight Status View
CREATE OR REPLACE VIEW core.flight_status_view AS
SELECT 
    f.flight_id,
    fs.flight_number,
    a_origin.iata_code AS origin,
    a_dest.iata_code AS destination,
    f.scheduled_departure,
    f.scheduled_arrival,
    f.actual_departure,
    f.actual_arrival,
    f.status,
    ac.registration_number AS aircraft,
    act.model AS aircraft_model,
    CASE 
        WHEN f.actual_departure IS NOT NULL THEN 
            EXTRACT(EPOCH FROM (f.actual_departure - f.scheduled_departure))/60 
        ELSE NULL 
    END AS departure_delay_minutes,
    CASE 
        WHEN f.actual_arrival IS NOT NULL THEN 
            EXTRACT(EPOCH FROM (f.actual_arrival - f.scheduled_arrival))/60 
        ELSE NULL 
    END AS arrival_delay_minutes
FROM 
    core.flights f
JOIN 
    core.flight_schedules fs ON f.schedule_id = fs.schedule_id
JOIN 
    core.routes r ON fs.route_id = r.route_id
JOIN 
    core.airports a_origin ON r.origin_airport_id = a_origin.airport_id
JOIN 
    core.airports a_dest ON r.destination_airport_id = a_dest.airport_id
LEFT JOIN 
    core.aircraft ac ON f.aircraft_id = ac.aircraft_id
LEFT JOIN 
    core.aircraft_types act ON ac.aircraft_type_id = act.aircraft_type_id;

-- Passenger Booking View
CREATE OR REPLACE VIEW customer.passenger_booking_view AS
SELECT 
    p.passenger_id,
    p.first_name,
    p.last_name,
    p.email,
    p.phone,
    b.booking_id,
    b.booking_reference,
    b.booking_date,
    b.booking_status,
    b.total_amount,
    b.currency,
    b.payment_status,
    COUNT(t.ticket_id) AS ticket_count
FROM 
    customer.passengers p
JOIN 
    customer.bookings b ON p.passenger_id = b.passenger_id
LEFT JOIN 
    customer.tickets t ON b.booking_id = t.booking_id
GROUP BY 
    p.passenger_id, p.first_name, p.last_name, p.email, p.phone,
    b.booking_id, b.booking_reference, b.booking_date, b.booking_status,
    b.total_amount, b.currency, b.payment_status;

-- Flight Revenue View
CREATE OR REPLACE VIEW finance.flight_revenue_view AS
SELECT 
    f.flight_id,
    fs.flight_number,
    f.flight_date,
    a_origin.iata_code AS origin,
    a_dest.iata_code AS destination,
    COUNT(t.ticket_id) AS passenger_count,
    SUM(CASE WHEN t.ticket_class = 'Economy' THEN 1 ELSE 0 END) AS economy_passengers,
    SUM(CASE WHEN t.ticket_class = 'Business' THEN 1 ELSE 0 END) AS business_passengers,
    SUM(CASE WHEN t.ticket_class = 'First' THEN 1 ELSE 0 END) AS first_passengers,
    SUM(t.fare_amount) AS ticket_revenue,
    SUM(c.charge_amount) AS cargo_revenue,
    (SELECT SUM(amount) FROM finance.revenue WHERE flight_id = f.flight_id AND revenue_type = 'Excess Baggage') AS baggage_revenue,
    (SELECT SUM(amount) FROM finance.revenue WHERE flight_id = f.flight_id AND revenue_type = 'In-flight Services') AS inflight_revenue,
    (SELECT SUM(amount) FROM finance.expenses WHERE flight_id = f.flight_id) AS total_expenses,
    SUM(t.fare_amount) + 
    SUM(c.charge_amount) + 
    COALESCE((SELECT SUM(amount) FROM finance.revenue WHERE flight_id = f.flight_id AND revenue_type = 'Excess Baggage'), 0) +
    COALESCE((SELECT SUM(amount) FROM finance.revenue WHERE flight_id = f.flight_id AND revenue_type = 'In-flight Services'), 0) -
    COALESCE((SELECT SUM(amount) FROM finance.expenses WHERE flight_id = f.flight_id), 0) AS profit
FROM 
    core.flights f
JOIN 
    core.flight_schedules fs ON f.schedule_id = fs.schedule_id
JOIN 
    core.routes r ON fs.route_id = r.route_id
JOIN 
    core.airports a_origin ON r.origin_airport_id = a_origin.airport_id
JOIN 
    core.airports a_dest ON r.destination_airport_id = a_dest.airport_id
LEFT JOIN 
    customer.tickets t ON f.flight_id = t.flight_id
LEFT JOIN 
    operations.cargo c ON f.flight_id = c.flight_id
GROUP BY 
    f.flight_id, fs.flight_number, f.flight_date, a_origin.iata_code, a_dest.iata_code;

-- Aircraft Utilization View
CREATE OR REPLACE VIEW operations.aircraft_utilization_view AS
SELECT 
    ac.aircraft_id,
    ac.registration_number,
    act.model,
    act.manufacturer,
    COUNT(f.flight_id) AS total_flights,
    SUM(r.distance_km) AS total_distance_flown,
    SUM(EXTRACT(EPOCH FROM (f.actual_arrival - f.actual_departure))/3600) AS total_flight_hours,
    COUNT(DISTINCT f.flight_date) AS days_in_service,
    (SELECT COUNT(*) FROM operations.maintenance m WHERE m.aircraft_id = ac.aircraft_id) AS maintenance_events,
    (SELECT SUM(EXTRACT(EPOCH FROM (m.end_time - m.start_time))/3600) FROM operations.maintenance m WHERE m.aircraft_id = ac.aircraft_id) AS maintenance_hours
FROM 
    core.aircraft ac
JOIN 
    core.aircraft_types act ON ac.aircraft_type_id = act.aircraft_type_id
LEFT JOIN 
    core.flights f ON ac.aircraft_id = f.aircraft_id AND f.actual_departure IS NOT NULL AND f.actual_arrival IS NOT NULL
LEFT JOIN 
    core.flight_schedules fs ON f.schedule_id = fs.schedule_id
LEFT JOIN 
    core.routes r ON fs.route_id = r.route_id
GROUP BY 
    ac.aircraft_id, ac.registration_number, act.model, act.manufacturer;

-- Crew Duty Hours View
CREATE OR REPLACE VIEW employee.crew_duty_hours_view AS
SELECT 
    c.crew_id,
    e.employee_id,
    e.first_name,
    e.last_name,
    c.crew_type,
    f.flight_date,
    COUNT(ca.assignment_id) AS flights_assigned,
    SUM(EXTRACT(EPOCH FROM (f.actual_arrival - ca.report_time))/3600) AS duty_hours,
    SUM(EXTRACT(EPOCH FROM (f.actual_arrival - f.actual_departure))/3600) AS flight_hours
FROM 
    employee.crew c
JOIN 
    employee.employees e ON c.employee_id = e.employee_id
JOIN 
    employee.crew_assignments ca ON c.crew_id = ca.crew_id
JOIN 
    core.flights f ON ca.flight_id = f.flight_id AND f.actual_departure IS NOT NULL AND f.actual_arrival IS NOT NULL
GROUP BY 
    c.crew_id, e.employee_id, e.first_name, e.last_name, c.crew_type, f.flight_date;

-- Route Performance View
CREATE OR REPLACE VIEW core.route_performance_view AS
SELECT 
    r.route_id,
    a_origin.iata_code AS origin,
    a_origin.city AS origin_city,
    a_dest.iata_code AS destination,
    a_dest.city AS destination_city,
    r.distance_km,
    COUNT(f.flight_id) AS total_flights,
    AVG(EXTRACT(EPOCH FROM (f.actual_arrival - f.actual_departure))/60) AS avg_flight_duration_minutes,
    AVG(CASE WHEN f.actual_departure IS NOT NULL THEN EXTRACT(EPOCH FROM (f.actual_departure - f.scheduled_departure))/60 ELSE NULL END) AS avg_departure_delay_minutes,
    AVG(CASE WHEN f.actual_arrival IS NOT NULL THEN EXTRACT(EPOCH FROM (f.actual_arrival - f.scheduled_arrival))/60 ELSE NULL END) AS avg_arrival_delay_minutes,
    COUNT(CASE WHEN f.status = 'Cancelled' THEN 1 ELSE NULL END) AS cancelled_flights,
    COUNT(CASE WHEN f.status = 'Diverted' THEN 1 ELSE NULL END) AS diverted_flights,
    AVG(frv.passenger_count) AS avg_passengers,
    AVG(frv.ticket_revenue) AS avg_ticket_revenue,
    AVG(frv.profit) AS avg_profit
FROM 
    core.routes r
JOIN 
    core.airports a_origin ON r.origin_airport_id = a_origin.airport_id
JOIN 
    core.airports a_dest ON r.destination_airport_id = a_dest.airport_id
LEFT JOIN 
    core.flight_schedules fs ON r.route_id = fs.route_id
LEFT JOIN 
    core.flights f ON fs.schedule_id = f.schedule_id
LEFT JOIN 
    finance.flight_revenue_view frv ON f.flight_id = frv.flight_id
GROUP BY 
    r.route_id, a_origin.iata_code, a_origin.city, a_dest.iata_code, a_dest.city, r.distance_km;

-- Create stored procedures for common operations

-- Procedure to schedule a new flight
CREATE OR REPLACE FUNCTION core.schedule_flight(
    p_schedule_id INT,
    p_flight_date DATE,
    p_aircraft_id INT
) RETURNS INT AS $$
DECLARE
    v_flight_id INT;
    v_schedule RECORD;
    v_scheduled_departure TIMESTAMP;
    v_scheduled_arrival TIMESTAMP;
BEGIN
    -- Get schedule details
    SELECT * INTO v_schedule FROM core.flight_schedules WHERE schedule_id = p_schedule_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Schedule with ID % not found', p_schedule_id;
    END IF;
    
    -- Calculate scheduled departure and arrival times
    v_scheduled_departure := p_flight_date + v_schedule.departure_time;
    v_scheduled_arrival := p_flight_date + v_schedule.arrival_time;
    
    -- If arrival is before departure (overnight flight), add a day
    IF v_scheduled_arrival < v_scheduled_departure THEN
        v_scheduled_arrival := v_scheduled_arrival + INTERVAL '1 day';
    END IF;
    
    -- Insert new flight
    INSERT INTO core.flights (
        schedule_id,
        aircraft_id,
        flight_date,
        scheduled_departure,
        scheduled_arrival,
        status
    ) VALUES (
        p_schedule_id,
        p_aircraft_id,
        p_flight_date,
        v_scheduled_departure,
        v_scheduled_arrival,
        'Scheduled'
    ) RETURNING flight_id INTO v_flight_id;
    
    RETURN v_flight_id;
END;
$$ LANGUAGE plpgsql;


-- Procedure to create a new booking
CREATE OR REPLACE FUNCTION customer.create_booking(
    p_passenger_id INT,
    p_booking_reference VARCHAR,
    p_booking_channel VARCHAR,
    p_total_amount DECIMAL,
    p_currency VARCHAR,
    p_contact_email VARCHAR,
    p_contact_phone VARCHAR
) RETURNS INT AS $$ 

DECLARE
    v_booking_id INT;
BEGIN
    -- Insert new booking
    INSERT INTO customer.bookings (
        passenger_id,
        booking_reference,
        booking_date,
        booking_channel,
        booking_status,
        total_amount,
        currency,
        payment_status,
        contact_email,
        contact_phone
    ) VALUES (
        p_passenger_id,
        p_booking_reference,
        CURRENT_TIMESTAMP,
        p_booking_channel,
        'Confirmed',
        p_total_amount,
        p_currency,
        'Paid',
        p_contact_email,
        p_contact_phone
    ) RETURNING booking_id INTO v_booking_id;
    
    RETURN v_booking_id;
END;
$$ LANGUAGE plpgsql;
-- Procedure to check-in a passenger
CREATE OR REPLACE FUNCTION customer.check_in_passenger(
    p_ticket_id INT,
    p_check_in_time TIMESTAMP,
    p_boarding_time TIMESTAMP
) RETURNS VOID AS $$
BEGIN
    -- Update ticket status to checked-in
    UPDATE customer.tickets
    SET checked_in = TRUE,
        check_in_time = p_check_in_time,
        boarding_time = p_boarding_time,
        updated_at = CURRENT_TIMESTAMP
    WHERE ticket_id = p_ticket_id;
    
    -- Optionally, you can also update the flight status if needed
    -- UPDATE core.flights SET status = 'Boarding' WHERE flight_id = (SELECT flight_id FROM customer.tickets WHERE ticket_id = p_ticket_id);
END;
$$ LANGUAGE plpgsql;
-- Procedure to process a payment
CREATE OR REPLACE FUNCTION finance.process_payment(
    p_booking_id INT,
    p_amount DECIMAL,
    p_currency VARCHAR,
    p_payment_method VARCHAR,
    p_transaction_id VARCHAR
) RETURNS VOID AS $$
DECLARE
    v_payment_id INT;
BEGIN
    -- Insert new payment
    INSERT INTO finance.payments (
        booking_id,
        amount,
        currency,
        payment_date,
        payment_method,
        transaction_id,
        status
    ) VALUES (
        p_booking_id,
        p_amount,
        p_currency,
        CURRENT_TIMESTAMP,
        p_payment_method,
        p_transaction_id,
        'Completed'
    ) RETURNING payment_id INTO v_payment_id;
    
    -- Update booking status to paid
    UPDATE customer.bookings
    SET payment_status = 'Paid',
        updated_at = CURRENT_TIMESTAMP
    WHERE booking_id = p_booking_id;
END;
$$ LANGUAGE plpgsql;
-- Procedure to issue a refund
CREATE OR REPLACE FUNCTION finance.issue_refund(
    p_payment_id INT,
    p_amount DECIMAL,
    p_currency VARCHAR,
    p_reason TEXT
) RETURNS VOID AS $$
DECLARE
    v_refund_id INT;
BEGIN
    -- Insert new refund
    INSERT INTO finance.refunds (
        payment_id,
        amount,
        currency,
        refund_date,
        reason,
        approved_by,
        status
    ) VALUES (
        p_payment_id,
        p_amount,
        p_currency,
        CURRENT_TIMESTAMP,
        p_reason,
        NULL, -- Approved by can be set later
        'Pending'
    ) RETURNING refund_id INTO v_refund_id;
    
    -- Update payment status to refunded
    UPDATE finance.payments
    SET status = 'Refunded',
        updated_at = CURRENT_TIMESTAMP
    WHERE payment_id = p_payment_id;
END;
$$ LANGUAGE plpgsql;
-- Procedure to add a new aircraft