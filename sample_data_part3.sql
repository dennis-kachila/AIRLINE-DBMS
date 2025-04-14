-- Kenya Airways Database - Sample Data (Part 3)
-- PostgreSQL implementation

-- Complete the Bookings and Tickets section from sample_data_part2.sql
DO $$
DECLARE
    v_booking_record RECORD;
    v_booking_id INT;
    v_passenger_id INT;
    v_flight_id INT;
    v_ticket_class VARCHAR(20);
    v_fare_amount DECIMAL(10, 2);
    v_fare_basis VARCHAR(10);
    v_baggage_allowance INT;
    v_ticket_number VARCHAR(20);
BEGIN
    -- For each booking
    FOR v_booking_record IN SELECT booking_id, passenger_id FROM customer.bookings WHERE booking_status IN ('Confirmed', 'Completed') LOOP
        v_booking_id := v_booking_record.booking_id;
        v_passenger_id := v_booking_record.passenger_id;
        
        -- Add 1-3 tickets to each booking
        FOR j IN 1..floor(random() * 3) + 1 LOOP
            -- Select a random flight
            SELECT flight_id INTO v_flight_id
            FROM core.flights
            WHERE scheduled_departure > CURRENT_TIMESTAMP
            ORDER BY random()
            LIMIT 1;
            
            -- Skip if no flight found
            CONTINUE WHEN v_flight_id IS NULL;
            
            -- Determine ticket class and fare
            v_ticket_class := CASE floor(random() * 4)
                WHEN 0 THEN 'Economy'
                WHEN 1 THEN 'Premium Economy'
                WHEN 2 THEN 'Business'
                WHEN 3 THEN 'First'
            END;
            
            v_fare_amount := CASE v_ticket_class
                WHEN 'Economy' THEN (floor(random() * 50000) + 5000)::decimal(10,2)
                WHEN 'Premium Economy' THEN (floor(random() * 70000) + 30000)::decimal(10,2)
                WHEN 'Business' THEN (floor(random() * 100000) + 80000)::decimal(10,2)
                WHEN 'First' THEN (floor(random() * 150000) + 120000)::decimal(10,2)
            END;
            
            v_fare_basis := CASE v_ticket_class
                WHEN 'Economy' THEN 'YBASE'
                WHEN 'Premium Economy' THEN 'WBASE'
                WHEN 'Business' THEN 'JBASE'
                WHEN 'First' THEN 'FBASE'
            END;
            
            v_baggage_allowance := CASE v_ticket_class
                WHEN 'Economy' THEN 23
                WHEN 'Premium Economy' THEN 32
                WHEN 'Business' THEN 46
                WHEN 'First' THEN 64
            END;
            
            -- Generate ticket number
            v_ticket_number := '074' || LPAD(FLOOR(RANDOM() * 10000000000)::TEXT, 10, '0');
            
            -- Insert ticket
            INSERT INTO customer.tickets (
                booking_id,
                flight_id,
                passenger_id,
                ticket_number,
                ticket_class,
                seat_number,
                fare_amount,
                fare_basis,
                baggage_allowance_kg,
                checked_in,
                check_in_time
            ) VALUES (
                v_booking_id,
                v_flight_id,
                v_passenger_id,
                v_ticket_number,
                v_ticket_class,
                CASE 
                    WHEN random() < 0.7 THEN -- 70% chance of having a seat assigned
                        CASE v_ticket_class
                            WHEN 'Economy' THEN 'Y' || (floor(random() * 30) + 1)::text || chr(floor(random() * 6) + 65)
                            WHEN 'Premium Economy' THEN 'W' || (floor(random() * 5) + 1)::text || chr(floor(random() * 6) + 65)
                            WHEN 'Business' THEN 'C' || (floor(random() * 10) + 1)::text || chr(floor(random() * 6) + 65)
                            WHEN 'First' THEN 'F' || (floor(random() * 5) + 1)::text || chr(floor(random() * 6) + 65)
                        END
                    ELSE NULL
                END,
                v_fare_amount,
                v_fare_basis,
                v_baggage_allowance,
                CASE 
                    WHEN random() < 0.5 THEN TRUE -- 50% chance of being checked in
                    ELSE FALSE
                END,
                CASE 
                    WHEN random() < 0.5 THEN CURRENT_TIMESTAMP - (random() * INTERVAL '2 days') -- 50% chance of check-in time
                    ELSE NULL
                END
            );
            
            -- Add special requests for some tickets (20% chance)
            IF random() < 0.2 THEN
                INSERT INTO customer.special_requests (
                    ticket_id,
                    request_type,
                    request_details,
                    status
                ) VALUES (
                    currval('customer.tickets_ticket_id_seq'),
                    CASE floor(random() * 7)
                        WHEN 0 THEN 'Wheelchair'
                        WHEN 1 THEN 'Special Meal'
                        WHEN 2 THEN 'Extra Legroom'
                        WHEN 3 THEN 'Bassinet'
                        WHEN 4 THEN 'Unaccompanied Minor'
                        WHEN 5 THEN 'Medical Assistance'
                        WHEN 6 THEN 'Other'
                    END,
                    CASE floor(random() * 7)
                        WHEN 0 THEN 'Passenger requires wheelchair assistance'
                        WHEN 1 THEN 'Vegetarian meal requested'
                        WHEN 2 THEN 'Passenger requests extra legroom seat'
                        WHEN 3 THEN 'Infant traveling, bassinet needed'
                        WHEN 4 THEN 'Child traveling alone, requires assistance'
                        WHEN 5 THEN 'Passenger requires medical oxygen'
                        WHEN 6 THEN 'Other special request'
                    END,
                    CASE floor(random() * 4)
                        WHEN 0 THEN 'Requested'
                        WHEN 1 THEN 'Confirmed'
                        WHEN 2 THEN 'Fulfilled'
                        WHEN 3 THEN 'Denied'
                    END
                );
            END IF;
        END LOOP;
    END LOOP;
END $$;

-- Add baggage records for checked-in passengers
INSERT INTO operations.baggage (ticket_id, weight_kg, tag_number, status, handling_instructions)
SELECT 
    t.ticket_id,
    floor(random() * (t.baggage_allowance_kg - 5) + 5)::decimal(5,2), -- Random weight within allowance
    'KQ' || LPAD(t.ticket_id::text, 8, '0') || 'B' || floor(random() * 10)::text,
    CASE floor(random() * 7)
        WHEN 0 THEN 'Checked'
        WHEN 1 THEN 'Loaded'
        WHEN 2 THEN 'In Transit'
        WHEN 3 THEN 'Arrived'
        WHEN 4 THEN 'Claimed'
        WHEN 5 THEN 'Lost'
        WHEN 6 THEN 'Damaged'
    END,
    CASE 
        WHEN random() < 0.1 THEN 'Fragile'
        WHEN random() < 0.2 THEN 'Heavy'
        ELSE NULL
    END
FROM 
    customer.tickets t
WHERE 
    t.checked_in = TRUE;

-- Add cargo records for flights
INSERT INTO operations.cargo (flight_id, weight_kg, volume_cubic_meters, content_type, handling_instructions, shipper_name, shipper_contact, recipient_name, recipient_contact, charge_amount, status)
SELECT
    f.flight_id,
    floor(random() * 5000 + 100)::decimal(10,2),
    floor(random() * 50 + 1)::decimal(10,2),
    CASE floor(random() * 5)
        WHEN 0 THEN 'General Cargo'
        WHEN 1 THEN 'Perishable Goods'
        WHEN 2 THEN 'Dangerous Goods'
        WHEN 3 THEN 'Live Animals'
        WHEN 4 THEN 'Valuable Items'
    END,
    CASE floor(random() * 5)
        WHEN 0 THEN 'Handle with care'
        WHEN 1 THEN 'Keep refrigerated'
        WHEN 2 THEN 'Hazardous material'
        WHEN 3 THEN 'Live animals - provide ventilation'
        WHEN 4 THEN 'High value - secure handling'
    END,
    CASE floor(random() * 5)
        WHEN 0 THEN 'Global Shipping Ltd'
        WHEN 1 THEN 'Fast Freight Services'
        WHEN 2 THEN 'Kenya Export Company'
        WHEN 3 THEN 'African Logistics'
        WHEN 4 THEN 'International Cargo Express'
    END,
    '+254' || (floor(random() * 10000000) + 700000000)::text,
    CASE floor(random() * 5)
        WHEN 0 THEN 'Destination Imports Inc'
        WHEN 1 THEN 'City Distributors'
        WHEN 2 THEN 'Regional Warehouse Ltd'
        WHEN 3 THEN 'National Supply Chain'
        WHEN 4 THEN 'Continental Receivers'
    END,
    '+' || (floor(random() * 999) + 1)::text || (floor(random() * 10000000) + 1000000)::text,
    floor(random() * 500000 + 50000)::decimal(10,2),
    CASE floor(random() * 6)
        WHEN 0 THEN 'Booked'
        WHEN 1 THEN 'Received'
        WHEN 2 THEN 'Loaded'
        WHEN 3 THEN 'In Transit'
        WHEN 4 THEN 'Delivered'
        WHEN 5 THEN 'Returned'
    END
FROM
    core.flights f
WHERE
    f.scheduled_departure > CURRENT_TIMESTAMP
    AND f.status = 'Scheduled'
ORDER BY
    random()
LIMIT 100;

-- Add catering records for flights
INSERT INTO operations.catering (flight_id, supplier_name, meal_types, meal_count_economy, meal_count_business, meal_count_first, special_meals, cost, delivery_time)
SELECT
    f.flight_id,
    CASE floor(random() * 3)
        WHEN 0 THEN 'Kenya Airways Catering'
        WHEN 1 THEN 'NAS Servair'
        WHEN 2 THEN 'Newrest Catering'
    END,
    CASE floor(random() * 3)
        WHEN 0 THEN 'Standard meals, Vegetarian, Halal'
        WHEN 1 THEN 'African cuisine, International options'
        WHEN 2 THEN 'Breakfast, Lunch, Dinner options'
    END,
    floor(random() * 200 + 50),
    floor(random() * 30 + 10),
    floor(random() * 10 + 5),
    floor(random() * 20 + 5),
    floor(random() * 100000 + 20000)::decimal(10,2),
    f.scheduled_departure - INTERVAL '3 hours'
FROM
    core.flights f
WHERE
    f.scheduled_departure > CURRENT_TIMESTAMP
    AND f.status = 'Scheduled'
ORDER BY
    random()
LIMIT 100;

-- Add maintenance records
INSERT INTO operations.maintenance (aircraft_id, maintenance_type, start_time, end_time, description, performed_by, status, cost)
SELECT
    a.aircraft_id,
    CASE floor(random() * 5)
        WHEN 0 THEN 'Routine Check'
        WHEN 1 THEN 'A Check'
        WHEN 2 THEN 'B Check'
        WHEN 3 THEN 'C Check'
        WHEN 4 THEN 'D Check'
    END,
    CURRENT_TIMESTAMP - (random() * INTERVAL '90 days'),
    CASE 
        WHEN random() < 0.8 THEN CURRENT_TIMESTAMP - (random() * INTERVAL '80 days') -- 80% completed
        ELSE NULL -- 20% still in progress
    END,
    CASE floor(random() * 5)
        WHEN 0 THEN 'Regular maintenance check as per schedule'
        WHEN 1 THEN 'Engine inspection and servicing'
        WHEN 2 THEN 'Avionics systems check and calibration'
        WHEN 3 THEN 'Structural inspection and repairs'
        WHEN 4 THEN 'Major overhaul including all systems'
    END,
    (SELECT employee_id FROM employee.employees WHERE position_id IN (17, 18, 19) ORDER BY random() LIMIT 1),
    CASE 
        WHEN random() < 0.8 THEN 
            CASE floor(random() * 3)
                WHEN 0 THEN 'Completed'
                WHEN 1 THEN 'Scheduled'
                WHEN 2 THEN 'Deferred'
            END
        ELSE 'In Progress'
    END,
    CASE floor(random() * 5)
        WHEN 0 THEN floor(random() * 50000 + 10000)::decimal(10,2)
        WHEN 1 THEN floor(random() * 100000 + 50000)::decimal(10,2)
        WHEN 2 THEN floor(random() * 200000 + 100000)::decimal(10,2)
        WHEN 3 THEN floor(random() * 500000 + 200000)::decimal(10,2)
        WHEN 4 THEN floor(random() * 2000000 + 500000)::decimal(10,2)
    END
FROM
    core.aircraft a
ORDER BY
    random()
LIMIT 50;

-- Add incident records
INSERT INTO operations.incidents (flight_id, aircraft_id, incident_time, incident_type, location, description, severity, reported_by, resolution, resolution_time)
SELECT
    CASE 
        WHEN random() < 0.7 THEN (SELECT flight_id FROM core.flights ORDER BY random() LIMIT 1)
        ELSE NULL
    END,
    CASE 
        WHEN random() < 0.3 THEN (SELECT aircraft_id FROM core.aircraft ORDER BY random() LIMIT 1)
        ELSE NULL
    END,
    CURRENT_TIMESTAMP - (random() * INTERVAL '180 days'),
    CASE floor(random() * 5)
        WHEN 0 THEN 'Delay'
        WHEN 1 THEN 'Technical Issue'
        WHEN 2 THEN 'Weather Related'
        WHEN 3 THEN 'Security Incident'
        WHEN 4 THEN 'Medical Emergency'
    END,
    CASE floor(random() * 5)
        WHEN 0 THEN 'In Flight'
        WHEN 1 THEN 'At Gate'
        WHEN 2 THEN 'On Runway'
        WHEN 3 THEN 'Terminal'
        WHEN 4 THEN 'Maintenance Hangar'
    END,
    CASE floor(random() * 5)
        WHEN 0 THEN 'Flight delayed due to late arrival of aircraft'
        WHEN 1 THEN 'Minor technical issue with navigation system'
        WHEN 2 THEN 'Flight diverted due to severe weather conditions'
        WHEN 3 THEN 'Security alert requiring additional screening'
        WHEN 4 THEN 'Passenger medical emergency requiring assistance'
    END,
    CASE floor(random() * 4)
        WHEN 0 THEN 'Minor'
        WHEN 1 THEN 'Moderate'
        WHEN 2 THEN 'Major'
        WHEN 3 THEN 'Critical'
    END,
    (SELECT employee_id FROM employee.employees ORDER BY random() LIMIT 1),
    CASE 
        WHEN random() < 0.8 THEN -- 80% resolved
            CASE floor(random() * 5)
                WHEN 0 THEN 'Delay communicated to passengers, flight rescheduled'
                WHEN 1 THEN 'Technical issue resolved by maintenance team'
                WHEN 2 THEN 'Flight resumed after weather conditions improved'
                WHEN 3 THEN 'Security all-clear given after investigation'
                WHEN 4 THEN 'Medical assistance provided, passenger stabilized'
            END
        ELSE NULL -- 20% unresolved
    END,
    CASE 
        WHEN random() < 0.8 THEN CURRENT_TIMESTAMP - (random() * INTERVAL '170 days') -- 80% have resolution time
        ELSE NULL -- 20% no resolution time
    END
FROM
    generate_series(1, 30);

-- Add expense records
INSERT INTO finance.expenses (expense_type, flight_id, aircraft_id, amount, currency, expense_date, description, approved_by)
SELECT
    CASE floor(random() * 5)
        WHEN 0 THEN 'Fuel'
        WHEN 1 THEN 'Airport Fees'
        WHEN 2 THEN 'Crew Expenses'
        WHEN 3 THEN 'Maintenance'
        WHEN 4 THEN 'Catering'
    END,
    CASE 
        WHEN random() < 0.7 THEN (SELECT flight_id FROM core.flights ORDER BY random() LIMIT 1)
        ELSE NULL
    END,
    CASE 
        WHEN random() < 0.3 THEN (SELECT aircraft_id FROM core.aircraft ORDER BY random() LIMIT 1)
        ELSE NULL
    END,
    floor(random() * 1000000 + 10000)::decimal(10,2),
    'KES',
    CURRENT_TIMESTAMP - (random() * INTERVAL '90 days'),
    CASE floor(random() * 5)
        WHEN 0 THEN 'Jet fuel purchase for international routes'
        WHEN 1 THEN 'Landing and parking fees at international airports'
        WHEN 2 THEN 'Crew accommodation and per diem for layovers'
        WHEN 3 THEN 'Routine maintenance parts and labor'
        WHEN 4 THEN 'In-flight meals and beverages'
    END,
    (SELECT employee_id FROM employee.employees WHERE position_id IN (1, 2, 3, 4, 5) ORDER BY random() LIMIT 1)
FROM
    generate_series(1, 100);

-- Add revenue records (beyond ticket and cargo revenue that's added by triggers)
INSERT INTO finance.revenue (flight_id, revenue_type, amount, currency, entry_date, description)
SELECT
    f.flight_id,
    CASE floor(random() * 3)
        WHEN 0 THEN 'Excess Baggage'
        WHEN 1 THEN 'In-flight Services'
        WHEN 2 THEN 'Other'
    END,
    floor(random() * 50000 + 1000)::decimal(10,2),
    'KES',
    f.scheduled_departure - (random() * INTERVAL '10 days'),
    CASE floor(random() * 3)
        WHEN 0 THEN 'Excess baggage fees collected'
        WHEN 1 THEN 'In-flight duty-free sales'
        WHEN 2 THEN 'Seat selection and other ancillary fees'
    END
FROM
    core.flights f
ORDER BY
    random()
LIMIT 200;

-- Update README.md with database information
UPDATE pg_catalog.pg_database
SET datistemplate = FALSE
WHERE datname = 'template1';
