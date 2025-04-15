-- Kenya Airways Database - Sample Data (Part 2)
-- PostgreSQL implementation

-- Complete the Employees data (continuing from sample_data.sql)
INSERT INTO employee.employees (employee_number, first_name, last_name, date_of_birth, gender, nationality, passport_number, passport_expiry, email, phone, address, hire_date, position_id, salary, status)
SELECT
    'EMP' || LPAD((i + 50)::text, 5, '0'),
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
    (CURRENT_DATE - (random() * 365 * 40)::integer),
    CASE floor(random() * 3)
        WHEN 0 THEN 'Male'
        WHEN 1 THEN 'Female'
        WHEN 2 THEN 'Other'
    END,
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
    'employee' || (i + 50) || '@kenyaairways.com',
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
    END,
    (CURRENT_DATE - (random() * 365 * 10)::integer),
    floor(random() * 50) + 1,
    (floor(random() * 150000) + 50000)::decimal(10, 2),
    CASE floor(random() * 4)
        WHEN 0 THEN 'Active'
        WHEN 1 THEN 'On Leave'
        WHEN 2 THEN 'Suspended'
        WHEN 3 THEN 'Terminated'
    END
FROM generate_series(1, 50) i;

-- Crew (50 crew members)
INSERT INTO employee.crew (employee_id, crew_type, qualifications, license_number, license_type, certification_date, medical_expiry)
SELECT
    employee_id,
    CASE 
        WHEN position_id IN (8, 9) THEN 
            CASE floor(random() * 2)
                WHEN 0 THEN 'Pilot'
                WHEN 1 THEN 'Co-Pilot'
            END
        WHEN position_id = 10 THEN 'Flight Engineer'
        WHEN position_id IN (13, 14) THEN 
            CASE floor(random() * 2)
                WHEN 0 THEN 'Cabin Crew'
                WHEN 1 THEN 'Purser'
            END
        ELSE 'Cabin Crew'
    END,
    CASE floor(random() * 3)
        WHEN 0 THEN 'Type Rating A320, B737'
        WHEN 1 THEN 'Type Rating B787, B777'
        WHEN 2 THEN 'Type Rating E190, CRJ'
    END,
    'LIC' || floor(random() * 1000000)::text,
    CASE floor(random() * 3)
        WHEN 0 THEN 'ATPL'
        WHEN 1 THEN 'CPL'
        WHEN 2 THEN 'Cabin Crew License'
    END,
    (CURRENT_DATE - (random() * 365 * 5)::integer),
    (CURRENT_DATE + (random() * 365 * 2)::integer)
FROM employee.employees
WHERE position_id IN (8, 9, 10, 13, 14, 15)
LIMIT 50;

-- Crew Assignments (for the next 7 days)
INSERT INTO employee.crew_assignments (crew_id, flight_id, role, report_time)
SELECT
    c.crew_id,
    f.flight_id,
    CASE c.crew_type
        WHEN 'Pilot' THEN 'Captain'
        WHEN 'Co-Pilot' THEN 'First Officer'
        WHEN 'Flight Engineer' THEN 'Flight Engineer'
        WHEN 'Purser' THEN 'Chief Purser'
        WHEN 'Cabin Crew' THEN 'Flight Attendant'
    END,
    f.scheduled_departure - INTERVAL '2 hours'
FROM
    core.flights f,
    employee.crew c
WHERE
    f.flight_date BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '7 days'
    AND f.status = 'Scheduled'
    AND c.crew_id <= 50
ORDER BY
    random()
LIMIT 80;

-- Create bookings and tickets
DO $$
DECLARE
    v_booking_id INT;
    v_booking_reference VARCHAR(10);
    v_passenger_id INT;
    v_flight_id INT;
    v_ticket_class VARCHAR(20);
    v_fare_amount DECIMAL(10, 2);
    v_fare_basis VARCHAR(10);
    v_baggage_allowance INT;
    v_ticket_number VARCHAR(20);
    v_payment_id INT;
BEGIN
    -- Create 200 bookings
    FOR i IN 1..200 LOOP
        -- Select a random passenger
        SELECT passenger_id INTO v_passenger_id
        FROM customer.passengers
        ORDER BY random()
        LIMIT 1;
        
        -- Create booking
        v_booking_reference := 'KQ' || LPAD(FLOOR(RANDOM() * 1000000)::TEXT, 6, '0');
        
        INSERT INTO customer.bookings (
            booking_reference,
            passenger_id,
            booking_date,
            booking_channel,
            booking_status,
            total_amount,
            currency,
            payment_status,
            contact_email,
            contact_phone
        ) VALUES (
            v_booking_reference,
            v_passenger_id,
            CURRENT_TIMESTAMP - (random() * INTERVAL '30 days'),
            CASE floor(random() * 5)
                WHEN 0 THEN 'Website'
                WHEN 1 THEN 'Mobile App'
                WHEN 2 THEN 'Call Center'
                WHEN 3 THEN 'Travel Agent'
                WHEN 4 THEN 'Airport Counter'
            END,
            CASE floor(random() * 4)
                WHEN 0 THEN 'Confirmed'
                WHEN 1 THEN 'Pending'
                WHEN 2 THEN 'Cancelled'
                WHEN 3 THEN 'Completed'
            END,
            (floor(random() * 200000) + 10000)::decimal(10, 2),
            'KES',
            CASE floor(random() * 4)
                WHEN 0 THEN 'Paid'
                WHEN 1 THEN 'Partially Paid'
                WHEN 2 THEN 'Unpaid'
                WHEN 3 THEN 'Refunded'
            END,
            'contact' || i || '@example.com',
            '+254' || (floor(random() * 10000000) + 700000000)::text
        ) RETURNING booking_id INTO v_booking_id;
        
        -- Add payment for the booking
        IF (SELECT payment_status FROM customer.bookings WHERE booking_id = v_booking_id) IN ('Paid', 'Partially Paid') THEN
            INSERT INTO finance.payments (
                booking_id,
                amount,
                currency,
                payment_date,
                payment_method,
                transaction_id,
                status
            ) VALUES (
                v_booking_id,
                CASE
                    WHEN (SELECT payment_status FROM customer.bookings WHERE booking_id = v_booking_id) = 'Paid'
                    THEN (SELECT total_amount FROM customer.bookings WHERE booking_id = v_booking_id)
                    ELSE (SELECT total_amount * 0.5 FROM customer.bookings WHERE booking_id = v_booking_id)
                END,
                'KES',
                (SELECT booking_date FROM customer.bookings WHERE booking_id = v_booking_id) + INTERVAL '1 hour',
                CASE floor(random() * 6)
                    WHEN 0 THEN 'Credit Card'
                    WHEN 1 THEN 'Debit Card'
                    WHEN 2 THEN 'Bank Transfer'
                    WHEN 3 THEN 'Cash'
                    WHEN 4 THEN 'Mobile Money'
                    WHEN 5 THEN 'Loyalty Points'
                END,
                'TXN' || floor(random() * 1000000)::text,
                'Completed'
            ) RETURNING payment_id INTO v_payment_id;
        END IF;
        
        -- Add 1-3 tickets to each booking
        FOR j IN 1..floor(random() * 3) + 1 LOOP
            -- Select a random flight
            SELECT flight_id INTO v_flight_id
            FROM core.flights
            WHERE scheduled_departure > CURRENT_TIMESTAMP
            ORDER BY random()
            LIMIT 1;
            
            -- Determine ticket class and fare
            v_ticket_class := CASE floor(random() * 4)
                WHEN 0 THEN 'Economy'
                WHEN 1 THEN 'Premium Economy'
                WHEN 2 THEN 'Business'
                WHEN 3 THEN 'First'
            END;
            
            v_fare_amount := CASE v_ticket_class
                WHEN 'Economy' THEN (floor(random() * 50000) + 5000)::decimal(10, 2)
                WHEN 'Premium Economy' THEN (floor(random() * 70000) + 30000)::decimal(10, 2)
                WHEN 'Business' THEN (floor(random() * 100000) + 80000)::decimal(10, 2)
                WHEN 'First' THEN (floor(random() * 150000) + 120000)::decimal(10, 2)
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
                checked_in
            ) VALUES (
                v_booking_id,
                v_flight_id,
                v_passenger_id,
                v_ticket_number,
                v_ticket_class,
                NULL, -- Seat will be assigned at check-in
                v_fare_amount,
                v_fare_basis,
                v_baggage_allowance,
                FALSE
            );
            
            -- Add special request for some tickets (20% chance)
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
                    'Special request for passenger',
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


-- End of Part 2
-- From here, the continuation is in Part 3, located in the file: sample_data_part3.sql