-- Kenya Airways Database - Sample Data
-- PostgreSQL implementation

-- Core Schema Data

-- Airports
INSERT INTO core.airports (iata_code, name, city, country, latitude, longitude, timezone_offset) VALUES
('NBO', 'Jomo Kenyatta International Airport', 'Nairobi', 'Kenya', -1.319167, 36.927778, 3),
('MBA', 'Moi International Airport', 'Mombasa', 'Kenya', -4.034833, 39.594333, 3),
('KIS', 'Kisumu International Airport', 'Kisumu', 'Kenya', -0.086139, 34.728889, 3),
('ELD', 'Eldoret International Airport', 'Eldoret', 'Kenya', 0.404458, 35.238928, 3),
('JRO', 'Kilimanjaro International Airport', 'Arusha', 'Tanzania', -3.429406, 37.074461, 3),
('DAR', 'Julius Nyerere International Airport', 'Dar es Salaam', 'Tanzania', -6.878111, 39.202625, 3),
('EBB', 'Entebbe International Airport', 'Entebbe', 'Uganda', 0.042386, 32.443501, 3),
('ADD', 'Bole International Airport', 'Addis Ababa', 'Ethiopia', 8.977889, 38.799139, 3),
('JNB', 'O.R. Tambo International Airport', 'Johannesburg', 'South Africa', -26.139167, 28.246111, 2),
('CPT', 'Cape Town International Airport', 'Cape Town', 'South Africa', -33.964806, 18.601667, 2),
('LHR', 'Heathrow Airport', 'London', 'United Kingdom', 51.470020, -0.454295, 0),
('CDG', 'Charles de Gaulle Airport', 'Paris', 'France', 49.009722, 2.547778, 1),
('AMS', 'Amsterdam Schiphol Airport', 'Amsterdam', 'Netherlands', 52.308056, 4.764167, 1),
('DXB', 'Dubai International Airport', 'Dubai', 'United Arab Emirates', 25.252778, 55.364444, 4),
('BKK', 'Suvarnabhumi Airport', 'Bangkok', 'Thailand', 13.681108, 100.747283, 7),
('HKG', 'Hong Kong International Airport', 'Hong Kong', 'China', 22.308889, 113.914444, 8),
('JFK', 'John F. Kennedy International Airport', 'New York', 'United States', 40.639722, -73.778889, -5),
('GRU', 'São Paulo–Guarulhos International Airport', 'São Paulo', 'Brazil', -23.435556, -46.473056, -3),
('LAD', 'Quatro de Fevereiro Airport', 'Luanda', 'Angola', -8.858375, 13.231178, 1),
('LOS', 'Murtala Muhammed International Airport', 'Lagos', 'Nigeria', 6.577369, 3.321156, 1);

-- Aircraft Types
INSERT INTO core.aircraft_types (model, manufacturer, capacity_economy, capacity_business, capacity_first, cargo_capacity_kg, range_km) VALUES
('Boeing 787-8', 'Boeing', 204, 30, 0, 12000, 13620),
('Boeing 787-9', 'Boeing', 234, 30, 0, 14000, 14140),
('Boeing 737-800', 'Boeing', 144, 16, 0, 2500, 5765),
('Boeing 737-700', 'Boeing', 114, 16, 0, 2000, 6370),
('Embraer E190', 'Embraer', 96, 12, 0, 1000, 4537),
('Bombardier Q400', 'Bombardier', 78, 0, 0, 500, 2040);

-- Aircraft
INSERT INTO core.aircraft (registration_number, aircraft_type_id, manufacture_date, last_maintenance_date, next_maintenance_date, status) VALUES
('5Y-KZA', 1, '2014-04-15', '2023-10-10', '2024-04-10', 'Active'),
('5Y-KZB', 1, '2014-06-20', '2023-11-15', '2024-05-15', 'Active'),
('5Y-KZC', 2, '2015-03-10', '2023-09-05', '2024-03-05', 'Active'),
('5Y-KZD', 2, '2015-05-22', '2023-12-01', '2024-06-01', 'Active'),
('5Y-KZE', 3, '2016-02-18', '2023-10-20', '2024-04-20', 'Active'),
('5Y-KZF', 3, '2016-04-30', '2023-11-25', '2024-05-25', 'Active'),
('5Y-KZG', 3, '2017-01-12', '2023-08-15', '2024-02-15', 'Maintenance'),
('5Y-KZH', 4, '2017-03-25', '2023-09-30', '2024-03-30', 'Active'),
('5Y-KZI', 4, '2018-02-05', '2023-10-05', '2024-04-05', 'Active'),
('5Y-KZJ', 5, '2018-05-17', '2023-11-10', '2024-05-10', 'Active'),
('5Y-KZK', 5, '2019-01-20', '2023-12-15', '2024-06-15', 'Active'),
('5Y-KZL', 6, '2019-04-10', '2023-09-20', '2024-03-20', 'Active'),
('5Y-KZM', 6, '2020-02-15', '2023-10-25', '2024-04-25', 'Standby');

-- Routes
INSERT INTO core.routes (origin_airport_id, destination_airport_id, distance_km, estimated_duration_minutes) VALUES
(1, 2, 440, 60), -- NBO-MBA
(2, 1, 440, 60), -- MBA-NBO
(1, 3, 270, 45), -- NBO-KIS
(3, 1, 270, 45), -- KIS-NBO
(1, 4, 312, 50), -- NBO-ELD
(4, 1, 312, 50), -- ELD-NBO
(1, 5, 273, 45), -- NBO-JRO
(5, 1, 273, 45), -- JRO-NBO
(1, 6, 680, 80), -- NBO-DAR
(6, 1, 680, 80), -- DAR-NBO
(1, 7, 500, 65), -- NBO-EBB
(7, 1, 500, 65), -- EBB-NBO
(1, 8, 1160, 120), -- NBO-ADD
(8, 1, 1160, 120), -- ADD-NBO
(1, 9, 3140, 240), -- NBO-JNB
(9, 1, 3140, 240), -- JNB-NBO
(1, 10, 3810, 270), -- NBO-CPT
(10, 1, 3810, 270), -- CPT-NBO
(1, 11, 6820, 510), -- NBO-LHR
(11, 1, 6820, 510), -- LHR-NBO
(1, 12, 6370, 480), -- NBO-CDG
(12, 1, 6370, 480), -- CDG-NBO
(1, 13, 6550, 495), -- NBO-AMS
(13, 1, 6550, 495), -- AMS-NBO
(1, 14, 3520, 300), -- NBO-DXB
(14, 1, 3520, 300), -- DXB-NBO
(1, 15, 7210, 540), -- NBO-BKK
(15, 1, 7210, 540), -- BKK-NBO
(1, 16, 8120, 600), -- NBO-HKG
(16, 1, 8120, 600), -- HKG-NBO
(1, 17, 11760, 840), -- NBO-JFK
(17, 1, 11760, 840), -- JFK-NBO
(1, 18, 10370, 780), -- NBO-GRU
(18, 1, 10370, 780), -- GRU-NBO
(1, 19, 2950, 225), -- NBO-LAD
(19, 1, 2950, 225), -- LAD-NBO
(1, 20, 3670, 270), -- NBO-LOS
(20, 1, 3670, 270); -- LOS-NBO

-- Flight Schedules
INSERT INTO core.flight_schedules (route_id, flight_number, departure_time, arrival_time, days_of_operation, effective_from, effective_to) VALUES
(1, 'KQ100', '07:00', '08:00', '1234567', '2023-01-01', '2023-12-31'), -- NBO-MBA daily 7am
(2, 'KQ101', '09:30', '10:30', '1234567', '2023-01-01', '2023-12-31'), -- MBA-NBO daily 9:30am
(1, 'KQ102', '14:00', '15:00', '1234567', '2023-01-01', '2023-12-31'), -- NBO-MBA daily 2pm
(2, 'KQ103', '16:30', '17:30', '1234567', '2023-01-01', '2023-12-31'), -- MBA-NBO daily 4:30pm
(3, 'KQ200', '08:00', '08:45', '1234567', '2023-01-01', '2023-12-31'), -- NBO-KIS daily 8am
(4, 'KQ201', '10:00', '10:45', '1234567', '2023-01-01', '2023-12-31'), -- KIS-NBO daily 10am
(5, 'KQ300', '09:00', '09:50', '1234567', '2023-01-01', '2023-12-31'), -- NBO-ELD daily 9am
(6, 'KQ301', '11:30', '12:20', '1234567', '2023-01-01', '2023-12-31'), -- ELD-NBO daily 11:30am
(7, 'KQ400', '10:00', '10:45', '1357', '2023-01-01', '2023-12-31'), -- NBO-JRO Mon, Wed, Fri, Sun 10am
(8, 'KQ401', '12:00', '12:45', '1357', '2023-01-01', '2023-12-31'), -- JRO-NBO Mon, Wed, Fri, Sun 12pm
(9, 'KQ500', '11:00', '12:20', '1234567', '2023-01-01', '2023-12-31'), -- NBO-DAR daily 11am
(10, 'KQ501', '14:00', '15:20', '1234567', '2023-01-01', '2023-12-31'), -- DAR-NBO daily 2pm
(11, 'KQ600', '08:30', '09:35', '1234567', '2023-01-01', '2023-12-31'), -- NBO-EBB daily 8:30am
(12, 'KQ601', '11:00', '12:05', '1234567', '2023-01-01', '2023-12-31'), -- EBB-NBO daily 11am
(13, 'KQ700', '10:30', '12:30', '246', '2023-01-01', '2023-12-31'), -- NBO-ADD Tue, Thu, Sat 10:30am
(14, 'KQ701', '14:00', '16:00', '246', '2023-01-01', '2023-12-31'), -- ADD-NBO Tue, Thu, Sat 2pm
(15, 'KQ800', '09:00', '13:00', '1234567', '2023-01-01', '2023-12-31'), -- NBO-JNB daily 9am
(16, 'KQ801', '15:00', '19:00', '1234567', '2023-01-01', '2023-12-31'), -- JNB-NBO daily 3pm
(17, 'KQ900', '10:00', '14:30', '246', '2023-01-01', '2023-12-31'), -- NBO-CPT Tue, Thu, Sat 10am
(18, 'KQ901', '16:30', '21:00', '246', '2023-01-01', '2023-12-31'), -- CPT-NBO Tue, Thu, Sat 4:30pm
(19, 'KQ1000', '23:30', '06:30', '1357', '2023-01-01', '2023-12-31'), -- NBO-LHR Mon, Wed, Fri, Sun 11:30pm
(20, 'KQ1001', '09:00', '20:00', '2468', '2023-01-01', '2023-12-31'), -- LHR-NBO Tue, Thu, Sat, Sun 9am
(21, 'KQ1100', '22:45', '05:45', '246', '2023-01-01', '2023-12-31'), -- NBO-CDG Tue, Thu, Sat 10:45pm
(22, 'KQ1101', '08:30', '19:00', '357', '2023-01-01', '2023-12-31'), -- CDG-NBO Wed, Fri, Sun 8:30am
(23, 'KQ1200', '23:00', '06:15', '135', '2023-01-01', '2023-12-31'), -- NBO-AMS Mon, Wed, Fri 11pm
(24, 'KQ1201', '09:00', '19:45', '246', '2023-01-01', '2023-12-31'), -- AMS-NBO Tue, Thu, Sat 9am
(25, 'KQ1300', '23:45', '05:45', '1234567', '2023-01-01', '2023-12-31'), -- NBO-DXB daily 11:45pm
(26, 'KQ1301', '08:00', '14:00', '1234567', '2023-01-01', '2023-12-31'), -- DXB-NBO daily 8am
(27, 'KQ1400', '22:30', '12:30', '357', '2023-01-01', '2023-12-31'), -- NBO-BKK Wed, Fri, Sun 10:30pm
(28, 'KQ1401', '14:30', '20:30', '146', '2023-01-01', '2023-12-31'), -- BKK-NBO Mon, Thu, Sat 2:30pm
(29, 'KQ1500', '22:00', '14:00', '26', '2023-01-01', '2023-12-31'), -- NBO-HKG Tue, Sat 10pm
(30, 'KQ1501', '16:00', '22:00', '37', '2023-01-01', '2023-12-31'), -- HKG-NBO Wed, Sun 4pm
(31, 'KQ1600', '22:00', '08:00', '37', '2023-01-01', '2023-12-31'), -- NBO-JFK Wed, Sun 10pm
(32, 'KQ1601', '11:00', '05:00', '15', '2023-01-01', '2023-12-31'), -- JFK-NBO Mon, Fri 11am
(33, 'KQ1700', '21:00', '05:00', '4', '2023-01-01', '2023-12-31'), -- NBO-GRU Thu 9pm
(34, 'KQ1701', '08:00', '22:00', '6', '2023-01-01', '2023-12-31'), -- GRU-NBO Sat 8am
(35, 'KQ1800', '10:00', '13:45', '135', '2023-01-01', '2023-12-31'), -- NBO-LAD Mon, Wed, Fri 10am
(36, 'KQ1801', '15:30', '19:15', '135', '2023-01-01', '2023-12-31'), -- LAD-NBO Mon, Wed, Fri 3:30pm
(37, 'KQ1900', '09:30', '13:00', '246', '2023-01-01', '2023-12-31'), -- NBO-LOS Tue, Thu, Sat 9:30am
(38, 'KQ1901', '15:00', '18:30', '246', '2023-01-01', '2023-12-31'); -- LOS-NBO Tue, Thu, Sat 3pm

-- Sample Flights (for the next 7 days)
DO $$
DECLARE
    v_schedule RECORD;
    v_flight_date DATE;
    v_aircraft_id INT;
    v_scheduled_departure TIMESTAMP;
    v_scheduled_arrival TIMESTAMP;
    v_status VARCHAR(20);
BEGIN
    -- Set start date to today
    v_flight_date := CURRENT_DATE;
    
    -- Create flights for the next 7 days
    FOR i IN 0..6 LOOP
        -- For each schedule
        FOR v_schedule IN SELECT * FROM core.flight_schedules LOOP
            -- Check if flight operates on this day of week
            IF position(EXTRACT(DOW FROM v_flight_date + i)::text in v_schedule.days_of_operation) > 0 THEN
                -- Calculate departure and arrival times
                v_scheduled_departure := (v_flight_date + i) + v_schedule.departure_time;
                v_scheduled_arrival := (v_flight_date + i) + v_schedule.arrival_time;
                
                -- If arrival is before departure (overnight flight), add a day
                IF v_scheduled_arrival < v_scheduled_departure THEN
                    v_scheduled_arrival := v_scheduled_arrival + INTERVAL '1 day';
                END IF;
                
                -- Assign aircraft (simplified - in reality would be more complex)
                SELECT aircraft_id INTO v_aircraft_id 
                FROM core.aircraft 
                WHERE status = 'Active' 
                ORDER BY random() 
                LIMIT 1;
                
                -- Set status based on departure time
                IF v_scheduled_departure < CURRENT_TIMESTAMP THEN
                    IF v_scheduled_arrival < CURRENT_TIMESTAMP THEN
                        v_status := 'Arrived';
                    ELSE
                        v_status := 'In Air';
                    END IF;
                ELSE
                    v_status := 'Scheduled';
                END IF;
                
                -- Insert flight
                INSERT INTO core.flights (
                    schedule_id,
                    aircraft_id,
                    flight_date,
                    scheduled_departure,
                    scheduled_arrival,
                    actual_departure,
                    actual_arrival,
                    status,
                    gate_departure,
                    gate_arrival
                ) VALUES (
                    v_schedule.schedule_id,
                    v_aircraft_id,
                    v_flight_date + i,
                    v_scheduled_departure,
                    v_scheduled_arrival,
                    CASE WHEN v_status IN ('In Air', 'Arrived') THEN v_scheduled_departure + (random() * INTERVAL '20 minutes') ELSE NULL END,
                    CASE WHEN v_status = 'Arrived' THEN v_scheduled_arrival + (random() * INTERVAL '30 minutes') ELSE NULL END,
                    v_status,
                    'G' || (floor(random() * 20) + 1)::text,
                    'G' || (floor(random() * 20) + 1)::text
                );
            END IF;
        END LOOP;
    END LOOP;
END $$;

-- Customer Schema Data

-- Passengers (100 sample passengers)
INSERT INTO customer.passengers (title, first_name, last_name, date_of_birth, nationality, passport_number, passport_expiry, email, phone, address)
SELECT
    CASE floor(random() * 4)
        WHEN 0 THEN 'Mr'
        WHEN 1 THEN 'Mrs'
        WHEN 2 THEN 'Ms'
        WHEN 3 THEN 'Dr'
    END,
    CASE floor(random() * 20)
        WHEN 0 THEN 'John'
        WHEN 1 THEN 'Mary'
        WHEN 2 THEN 'James'
        WHEN 3 THEN 'Patricia'
        WHEN 4 THEN 'Robert'
        WHEN 5 THEN 'Jennifer'
        WHEN 6 THEN 'Michael'
        WHEN 7 THEN 'Linda'
        WHEN 8 THEN 'William'
        WHEN 9 THEN 'Elizabeth'
        WHEN 10 THEN 'David'
        WHEN 11 THEN 'Barbara'
        WHEN 12 THEN 'Richard'
        WHEN 13 THEN 'Susan'
        WHEN 14 THEN 'Joseph'
        WHEN 15 THEN 'Jessica'
        WHEN 16 THEN 'Thomas'
        WHEN 17 THEN 'Sarah'
        WHEN 18 THEN 'Charles'
        WHEN 19 THEN 'Karen'
    END,
    CASE floor(random() * 20)
        WHEN 0 THEN 'Smith'
        WHEN 1 THEN 'Johnson'
        WHEN 2 THEN 'Williams'
        WHEN 3 THEN 'Jones'
        WHEN 4 THEN 'Brown'
        WHEN 5 THEN 'Davis'
        WHEN 6 THEN 'Miller'
        WHEN 7 THEN 'Wilson'
        WHEN 8 THEN 'Moore'
        WHEN 9 THEN 'Taylor'
        WHEN 10 THEN 'Anderson'
        WHEN 11 THEN 'Thomas'
        WHEN 12 THEN 'Jackson'
        WHEN 13 THEN 'White'
        WHEN 14 THEN 'Harris'
        WHEN 15 THEN 'Martin'
        WHEN 16 THEN 'Thompson'
        WHEN 17 THEN 'Garcia'
        WHEN 18 THEN 'Martinez'
        WHEN 19 THEN 'Robinson'
    END,
    (CURRENT_DATE - (random() * 365 * 60)::integer),
    CASE floor(random() * 10)
        WHEN 0 THEN 'Kenyan'
        WHEN 1 THEN 'Tanzanian'
        WHEN 2 THEN 'Ugandan'
        WHEN 3 THEN 'Ethiopian'
        WHEN 4 THEN 'South African'
        WHEN 5 THEN 'British'
        WHEN 6 THEN 'American'
        WHEN 7 THEN 'French'
        WHEN 8 THEN 'Chinese'
        WHEN 9 THEN 'Nigerian'
    END,
    'P' || floor(random() * 10000000)::text,
    (CURRENT_DATE + (random() * 365 * 5)::integer),
    'passenger' || i || '@example.com',
    '+' || (floor(random() * 999) + 1)::text || (floor(random() * 10000000) + 1000000)::text,
    floor(random() * 1000)::text || ' ' ||
    CASE floor(random() * 10)
        WHEN 0 THEN 'Main Street'
        WHEN 1 THEN 'High Street'
        WHEN 2 THEN 'Park Avenue'
        WHEN 3 THEN 'Oak Road'
        WHEN 4 THEN 'Maple Drive'
        WHEN 5 THEN 'Cedar Lane'
        WHEN 6 THEN 'Pine Street'
        WHEN 7 THEN 'Elm Avenue'
        WHEN 8 THEN 'River Road'
        WHEN 9 THEN 'Lake Drive'
    END || ', ' ||
    CASE floor(random() * 10)
        WHEN 0 THEN 'Nairobi'
        WHEN 1 THEN 'Mombasa'
        WHEN 2 THEN 'Dar es Salaam'
        WHEN 3 THEN 'Kampala'
        WHEN 4 THEN 'Addis Ababa'
        WHEN 5 THEN 'Johannesburg'
        WHEN 6 THEN 'London'
        WHEN 7 THEN 'New York'
        WHEN 8 THEN 'Paris'
        WHEN 9 THEN 'Dubai'
    END
FROM generate_series(1, 100) i;

-- Loyalty Program (50% of passengers)
INSERT INTO customer.loyalty_program (passenger_id, membership_number, membership_level, points_balance, tier_qualification_points, join_date, expiry_date)
SELECT
    passenger_id,
    'KQ' || LPAD(passenger_id::text, 8, '0'),
    CASE floor(random() * 4)
        WHEN 0 THEN 'Blue'
        WHEN 1 THEN 'Silver'
        WHEN 2 THEN 'Gold'
        WHEN 3 THEN 'Platinum'
    END,
    floor(random() * 100000),
    floor(random() * 150000),
    CURRENT_DATE - (random() * 365 * 3)::integer,
    CURRENT_DATE + (random() * 365 * 2)::integer
FROM customer.passengers
WHERE passenger_id <= 50;

-- Employee Schema Data

-- Departments
INSERT INTO employee.departments (department_name, department_code, parent_department_id) VALUES
('Executive', 'EXEC', NULL),
('Flight Operations', 'FLOPS', 1),
('Cabin Services', 'CABIN', 1),
('Engineering & Maintenance', 'ENGMT', 1),
('Ground Operations', 'GROPS', 1),
('Commercial', 'COMML', 1),
('Finance', 'FINAC', 1),
('Human Resources', 'HURES', 1),
('Information Technology', 'INFOT', 1),
('Safety & Security', 'SAFSC', 1);

-- Positions
INSERT INTO employee.positions (position_name, department_id) VALUES
('Chief Executive Officer', 1),
('Chief Operations Officer', 1),
('Chief Financial Officer', 1),
('Chief Commercial Officer', 1),
('Chief Information Officer', 1),
('Director of Flight Operations', 2),
('Chief Pilot', 2),
('Pilot', 2),
('First Officer', 2),
('Flight Engineer', 2),
('Director of Cabin Services', 3),
('Cabin Services Manager', 3),
('Purser', 3),
('Senior Flight Attendant', 3),
('Flight Attendant', 3),
('Director of Engineering', 4),
('Chief Engineer', 4),
('Aircraft Maintenance Engineer', 4),
('Maintenance Technician', 4),
('Quality Assurance Engineer', 4),
('Director of Ground Operations', 5),
('Station Manager', 5),
('Ground Handling Supervisor', 5),
('Check-in Agent', 5),
('Ramp Agent', 5),
('Director of Commercial', 6),
('Sales Manager', 6),
('Marketing Manager', 6),
('Revenue Management Specialist', 6),
('Customer Service Representative', 6),
('Director of Finance', 7),
('Financial Controller', 7),
('Accountant', 7),
('Financial Analyst', 7),
('Payroll Specialist', 7),
('Director of HR', 8),
('HR Manager', 8),
('Recruitment Specialist', 8),
('Training Coordinator', 8),
('Employee Relations Specialist', 8),
('Director of IT', 9),
('IT Manager', 9),
('Systems Administrator', 9),
('Network Engineer', 9),
('Software Developer', 9),
('Director of Safety & Security', 10),
('Safety Manager', 10),
('Security Manager', 10),
('Safety Officer', 10),
('Security Officer', 10);

-- Note: Employee data is continued in sample_data_part2.sql
