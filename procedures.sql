-- Kenya Airways Database - Stored Procedures and Functions
-- PostgreSQL implementation

-- Procedure to create a new booking
CREATE OR REPLACE FUNCTION customer.create_booking(
    p_passenger_id INT,
    p_booking_channel VARCHAR(20),
    p_total_amount DECIMAL(10, 2),
    p_currency VARCHAR(3),
    p_contact_email VARCHAR(100),
    p_contact_phone VARCHAR(20)
) RETURNS VARCHAR(10) AS $$
DECLARE
    v_booking_id INT;
    v_booking_reference VARCHAR(10);
BEGIN
    -- Generate a unique booking reference
    v_booking_reference := 'KQ' || LPAD(FLOOR(RANDOM() * 1000000)::TEXT, 6, '0');
    
    -- Insert new booking
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
        p_passenger_id,
        CURRENT_TIMESTAMP,
        p_booking_channel,
        'Pending',
        p_total_amount,
        p_currency,
        'Unpaid',
        p_contact_email,
        p_contact_phone
    ) RETURNING booking_id INTO v_booking_id;
    
    RETURN v_booking_reference;
END;
$$ LANGUAGE plpgsql;

-- Procedure to add a ticket to a booking
CREATE OR REPLACE FUNCTION customer.add_ticket_to_booking(
    p_booking_id INT,
    p_flight_id INT,
    p_passenger_id INT,
    p_ticket_class VARCHAR(20),
    p_fare_amount DECIMAL(10, 2),
    p_fare_basis VARCHAR(10),
    p_baggage_allowance_kg INT
) RETURNS VARCHAR(20) AS $$
DECLARE
    v_ticket_id INT;
    v_ticket_number VARCHAR(20);
BEGIN
    -- Generate a unique ticket number
    v_ticket_number := '074' || LPAD(FLOOR(RANDOM() * 10000000000)::TEXT, 10, '0');
    
    -- Insert new ticket
    INSERT INTO customer.tickets (
        booking_id,
        flight_id,
        passenger_id,
        ticket_number,
        ticket_class,
        fare_amount,
        fare_basis,
        baggage_allowance_kg
    ) VALUES (
        p_booking_id,
        p_flight_id,
        p_passenger_id,
        v_ticket_number,
        p_ticket_class,
        p_fare_amount,
        p_fare_basis,
        p_baggage_allowance_kg
    ) RETURNING ticket_id INTO v_ticket_id;
    
    RETURN v_ticket_number;
END;
$$ LANGUAGE plpgsql;

-- Procedure to check in a passenger
CREATE OR REPLACE FUNCTION customer.check_in_passenger(
    p_ticket_number VARCHAR(20),
    p_seat_number VARCHAR(5)
) RETURNS BOOLEAN AS $$
DECLARE
    v_ticket_id INT;
    v_flight_id INT;
    v_flight_status VARCHAR(20);
BEGIN
    -- Get ticket details
    SELECT ticket_id, flight_id INTO v_ticket_id, v_flight_id
    FROM customer.tickets
    WHERE ticket_number = p_ticket_number;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Ticket with number % not found', p_ticket_number;
    END IF;
    
    -- Check if flight is available for check-in
    SELECT status INTO v_flight_status
    FROM core.flights
    WHERE flight_id = v_flight_id;
    
    IF v_flight_status IN ('Departed', 'In Air', 'Landed', 'Arrived', 'Cancelled', 'Diverted') THEN
        RAISE EXCEPTION 'Check-in not available for flight with status: %', v_flight_status;
    END IF;
    
    -- Update ticket with check-in information
    UPDATE customer.tickets
    SET 
        checked_in = TRUE,
        check_in_time = CURRENT_TIMESTAMP,
        seat_number = p_seat_number
    WHERE ticket_id = v_ticket_id;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Procedure to update flight status
CREATE OR REPLACE FUNCTION core.update_flight_status(
    p_flight_id INT,
    p_status VARCHAR(20),
    p_actual_departure TIMESTAMP DEFAULT NULL,
    p_actual_arrival TIMESTAMP DEFAULT NULL,
    p_gate_departure VARCHAR(10) DEFAULT NULL,
    p_gate_arrival VARCHAR(10) DEFAULT NULL,
    p_baggage_claim VARCHAR(10) DEFAULT NULL
) RETURNS VOID AS $$
BEGIN
    -- Update flight status
    UPDATE core.flights
    SET 
        status = p_status,
        actual_departure = COALESCE(p_actual_departure, actual_departure),
        actual_arrival = COALESCE(p_actual_arrival, actual_arrival),
        gate_departure = COALESCE(p_gate_departure, gate_departure),
        gate_arrival = COALESCE(p_gate_arrival, gate_arrival),
        baggage_claim = COALESCE(p_baggage_claim, baggage_claim),
        updated_at = CURRENT_TIMESTAMP
    WHERE flight_id = p_flight_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Flight with ID % not found', p_flight_id;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Procedure to assign crew to a flight
CREATE OR REPLACE FUNCTION employee.assign_crew_to_flight(
    p_crew_id INT,
    p_flight_id INT,
    p_role VARCHAR(20),
    p_report_time TIMESTAMP
) RETURNS INT AS $$
DECLARE
    v_assignment_id INT;
    v_crew_type VARCHAR(20);
    v_flight_departure TIMESTAMP;
BEGIN
    -- Get crew type
    SELECT crew_type INTO v_crew_type
    FROM employee.crew
    WHERE crew_id = p_crew_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Crew with ID % not found', p_crew_id;
    END IF;
    
    -- Get flight departure time
    SELECT scheduled_departure INTO v_flight_departure
    FROM core.flights
    WHERE flight_id = p_flight_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Flight with ID % not found', p_flight_id;
    END IF;
    
    -- Validate role against crew type
    IF (v_crew_type = 'Pilot' AND p_role NOT IN ('Captain', 'First Officer')) OR
       (v_crew_type = 'Co-Pilot' AND p_role NOT IN ('First Officer', 'Second Officer')) OR
       (v_crew_type = 'Cabin Crew' AND p_role NOT IN ('Flight Attendant', 'Senior Flight Attendant')) OR
       (v_crew_type = 'Purser' AND p_role NOT IN ('Chief Purser', 'Purser')) THEN
        RAISE EXCEPTION 'Role % is not valid for crew type %', p_role, v_crew_type;
    END IF;
    
    -- Validate report time
    IF p_report_time > v_flight_departure THEN
        RAISE EXCEPTION 'Report time cannot be after flight departure';
    END IF;
    
    -- Insert crew assignment
    INSERT INTO employee.crew_assignments (
        crew_id,
        flight_id,
        role,
        report_time
    ) VALUES (
        p_crew_id,
        p_flight_id,
        p_role,
        p_report_time
    ) RETURNING assignment_id INTO v_assignment_id;
    
    RETURN v_assignment_id;
END;
$$ LANGUAGE plpgsql;

-- Procedure to schedule maintenance for an aircraft
CREATE OR REPLACE FUNCTION operations.schedule_maintenance(
    p_aircraft_id INT,
    p_maintenance_type VARCHAR(50),
    p_start_time TIMESTAMP,
    p_end_time TIMESTAMP,
    p_description TEXT,
    p_performed_by INT
) RETURNS INT AS $$
DECLARE
    v_maintenance_id INT;
    v_conflicting_flights INT;
BEGIN
    -- Check for conflicting flights
    SELECT COUNT(*) INTO v_conflicting_flights
    FROM core.flights
    WHERE aircraft_id = p_aircraft_id
    AND (
        (scheduled_departure BETWEEN p_start_time AND p_end_time) OR
        (scheduled_arrival BETWEEN p_start_time AND p_end_time) OR
        (p_start_time BETWEEN scheduled_departure AND scheduled_arrival) OR
        (p_end_time BETWEEN scheduled_departure AND scheduled_arrival)
    );
    
    IF v_conflicting_flights > 0 THEN
        RAISE EXCEPTION 'Maintenance schedule conflicts with % existing flights', v_conflicting_flights;
    END IF;
    
    -- Insert maintenance record
    INSERT INTO operations.maintenance (
        aircraft_id,
        maintenance_type,
        start_time,
        end_time,
        description,
        performed_by,
        status
    ) VALUES (
        p_aircraft_id,
        p_maintenance_type,
        p_start_time,
        p_end_time,
        p_description,
        p_performed_by,
        'Scheduled'
    ) RETURNING maintenance_id INTO v_maintenance_id;
    
    -- Update aircraft status
    UPDATE core.aircraft
    SET 
        status = 'Maintenance',
        next_maintenance_date = p_end_time::DATE
    WHERE aircraft_id = p_aircraft_id;
    
    RETURN v_maintenance_id;
END;
$$ LANGUAGE plpgsql;

-- Procedure to process payment for a booking
CREATE OR REPLACE FUNCTION finance.process_payment(
    p_booking_id INT,
    p_amount DECIMAL(10, 2),
    p_currency VARCHAR(3),
    p_payment_method VARCHAR(20),
    p_transaction_id VARCHAR(50)
) RETURNS INT AS $$
DECLARE
    v_payment_id INT;
    v_booking_total DECIMAL(10, 2);
    v_current_paid DECIMAL(10, 2);
    v_new_status VARCHAR(20);
BEGIN
    -- Get booking total amount
    SELECT total_amount INTO v_booking_total
    FROM customer.bookings
    WHERE booking_id = p_booking_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Booking with ID % not found', p_booking_id;
    END IF;
    
    -- Calculate current paid amount
    SELECT COALESCE(SUM(amount), 0) INTO v_current_paid
    FROM finance.payments
    WHERE booking_id = p_booking_id AND status = 'Completed';
    
    -- Insert payment record
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
    
    -- Determine new payment status
    IF v_current_paid + p_amount >= v_booking_total THEN
        v_new_status := 'Paid';
    ELSIF v_current_paid + p_amount > 0 THEN
        v_new_status := 'Partially Paid';
    ELSE
        v_new_status := 'Unpaid';
    END IF;
    
    -- Update booking payment status
    UPDATE customer.bookings
    SET 
        payment_status = v_new_status,
        booking_status = CASE WHEN v_new_status = 'Paid' THEN 'Confirmed' ELSE booking_status END,
        updated_at = CURRENT_TIMESTAMP
    WHERE booking_id = p_booking_id;
    
    RETURN v_payment_id;
END;
$$ LANGUAGE plpgsql;

-- Procedure to add loyalty points for a flight
CREATE OR REPLACE FUNCTION customer.add_loyalty_points(
    p_ticket_id INT,
    p_points INT
) RETURNS INT AS $$
DECLARE
    v_passenger_id INT;
    v_loyalty_id INT;
    v_new_balance INT;
BEGIN
    -- Get passenger ID from ticket
    SELECT passenger_id INTO v_passenger_id
    FROM customer.tickets
    WHERE ticket_id = p_ticket_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Ticket with ID % not found', p_ticket_id;
    END IF;
    
    -- Get loyalty program ID
    SELECT loyalty_id INTO v_loyalty_id
    FROM customer.loyalty_program
    WHERE passenger_id = v_passenger_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Passenger with ID % is not enrolled in loyalty program', v_passenger_id;
    END IF;
    
    -- Update loyalty points
    UPDATE customer.loyalty_program
    SET 
        points_balance = points_balance + p_points,
        tier_qualification_points = tier_qualification_points + p_points,
        updated_at = CURRENT_TIMESTAMP
    WHERE loyalty_id = v_loyalty_id
    RETURNING points_balance INTO v_new_balance;
    
    -- Update membership level based on tier qualification points
    UPDATE customer.loyalty_program
    SET 
        membership_level = CASE 
            WHEN tier_qualification_points >= 100000 THEN 'Platinum'
            WHEN tier_qualification_points >= 50000 THEN 'Gold'
            WHEN tier_qualification_points >= 25000 THEN 'Silver'
            ELSE 'Blue'
        END
    WHERE loyalty_id = v_loyalty_id;
    
    RETURN v_new_balance;
END;
$$ LANGUAGE plpgsql;

-- Function to calculate flight load factor
CREATE OR REPLACE FUNCTION core.calculate_load_factor(
    p_flight_id INT
) RETURNS DECIMAL(5, 2) AS $$
DECLARE
    v_passenger_count INT;
    v_aircraft_id INT;
    v_total_capacity INT;
BEGIN
    -- Get passenger count
    SELECT COUNT(*) INTO v_passenger_count
    FROM customer.tickets
    WHERE flight_id = p_flight_id;
    
    -- Get aircraft capacity
    SELECT f.aircraft_id INTO v_aircraft_id
    FROM core.flights f
    WHERE f.flight_id = p_flight_id;
    
    IF v_aircraft_id IS NULL THEN
        RETURN 0;
    END IF;
    
    SELECT (at.capacity_economy + at.capacity_business + at.capacity_first) INTO v_total_capacity
    FROM core.aircraft a
    JOIN core.aircraft_types at ON a.aircraft_type_id = at.aircraft_type_id
    WHERE a.aircraft_id = v_aircraft_id;
    
    IF v_total_capacity = 0 THEN
        RETURN 0;
    END IF;
    
    -- Calculate and return load factor
    RETURN (v_passenger_count::DECIMAL / v_total_capacity::DECIMAL) * 100;
END;
$$ LANGUAGE plpgsql;

-- Function to get available seats for a flight
CREATE OR REPLACE FUNCTION customer.get_available_seats(
    p_flight_id INT,
    p_ticket_class VARCHAR(20)
) RETURNS TABLE (
    seat_number VARCHAR(5)
) AS $$
DECLARE
    v_aircraft_id INT;
    v_aircraft_type_id INT;
    v_capacity INT;
    v_seat_prefix CHAR(1);
BEGIN
    -- Get aircraft details
    SELECT f.aircraft_id, a.aircraft_type_id 
    INTO v_aircraft_id, v_aircraft_type_id
    FROM core.flights f
    JOIN core.aircraft a ON f.aircraft_id = a.aircraft_id
    WHERE f.flight_id = p_flight_id;
    
    IF v_aircraft_id IS NULL THEN
        RAISE EXCEPTION 'Flight with ID % has no assigned aircraft', p_flight_id;
    END IF;
    
    -- Determine capacity and seat prefix based on ticket class
    IF p_ticket_class = 'Economy' THEN
        SELECT capacity_economy INTO v_capacity
        FROM core.aircraft_types
        WHERE aircraft_type_id = v_aircraft_type_id;
        v_seat_prefix := 'Y';
    ELSIF p_ticket_class = 'Business' THEN
        SELECT capacity_business INTO v_capacity
        FROM core.aircraft_types
        WHERE aircraft_type_id = v_aircraft_type_id;
        v_seat_prefix := 'C';
    ELSIF p_ticket_class = 'First' THEN
        SELECT capacity_first INTO v_capacity
        FROM core.aircraft_types
        WHERE aircraft_type_id = v_aircraft_type_id;
        v_seat_prefix := 'F';
    ELSE
        RAISE EXCEPTION 'Invalid ticket class: %', p_ticket_class;
    END IF;
    
    -- Generate all possible seats for the class
    RETURN QUERY
    WITH all_seats AS (
        SELECT 
            v_seat_prefix || row_number || col_letter AS seat
        FROM 
            generate_series(1, CEIL(v_capacity::DECIMAL / 6)::INT) AS row_number,
            (SELECT unnest(ARRAY['A', 'B', 'C', 'D', 'E', 'F']) AS col_letter) AS cols
        WHERE 
            (row_number - 1) * 6 + CASE 
                WHEN col_letter = 'A' THEN 1
                WHEN col_letter = 'B' THEN 2
                WHEN col_letter = 'C' THEN 3
                WHEN col_letter = 'D' THEN 4
                WHEN col_letter = 'E' THEN 5
                WHEN col_letter = 'F' THEN 6
            END <= v_capacity
    ),
    occupied_seats AS (
        SELECT seat_number
        FROM customer.tickets
        WHERE flight_id = p_flight_id
        AND ticket_class = p_ticket_class
        AND seat_number IS NOT NULL
    )
    SELECT seat AS seat_number
    FROM all_seats
    WHERE seat NOT IN (SELECT seat_number FROM occupied_seats);
END;
$$ LANGUAGE plpgsql;

-- Function to calculate route profitability
CREATE OR REPLACE FUNCTION finance.calculate_route_profitability(
    p_route_id INT,
    p_start_date DATE,
    p_end_date DATE
) RETURNS TABLE (
    total_flights INT,
    total_passengers INT,
    total_revenue DECIMAL(12, 2),
    total_expenses DECIMAL(12, 2),
    profit DECIMAL(12, 2),
    profit_per_flight DECIMAL(12, 2),
    profit_margin DECIMAL(5, 2)
) AS $$
BEGIN
    RETURN QUERY
    WITH flight_data AS (
        SELECT 
            f.flight_id,
            COUNT(t.ticket_id) AS passengers,
            SUM(t.fare_amount) AS ticket_revenue,
            SUM(c.charge_amount) AS cargo_revenue,
            (SELECT COALESCE(SUM(amount), 0) FROM finance.revenue WHERE flight_id = f.flight_id) AS other_revenue,
            (SELECT COALESCE(SUM(amount), 0) FROM finance.expenses WHERE flight_id = f.flight_id) AS flight_expenses
        FROM 
            core.flights f
        JOIN 
            core.flight_schedules fs ON f.schedule_id = fs.schedule_id
        LEFT JOIN 
            customer.tickets t ON f.flight_id = t.flight_id
        LEFT JOIN 
            operations.cargo c ON f.flight_id = c.flight_id
        WHERE 
            fs.route_id = p_route_id
            AND f.flight_date BETWEEN p_start_date AND p_end_date
        GROUP BY 
            f.flight_id
    )
    SELECT 
        COUNT(*)::INT AS total_flights,
        SUM(passengers)::INT AS total_passengers,
        SUM(ticket_revenue + cargo_revenue + other_revenue) AS total_revenue,
        SUM(flight_expenses) AS total_expenses,
        SUM(ticket_revenue + cargo_revenue + other_revenue - flight_expenses) AS profit,
        CASE 
            WHEN COUNT(*) > 0 THEN SUM(ticket_revenue + cargo_revenue + other_revenue - flight_expenses) / COUNT(*)
            ELSE 0
        END AS profit_per_flight,
        CASE 
            WHEN SUM(ticket_revenue + cargo_revenue + other_revenue) > 0 
            THEN (SUM(ticket_revenue + cargo_revenue + other_revenue - flight_expenses) / SUM(ticket_revenue + cargo_revenue + other_revenue)) * 100
            ELSE 0
        END AS profit_margin
    FROM 
        flight_data;
END;
$$ LANGUAGE plpgsql;

-- Function to generate flight manifest
CREATE OR REPLACE FUNCTION core.generate_flight_manifest(
    p_flight_id INT
) RETURNS TABLE (
    ticket_number VARCHAR(20),
    passenger_name TEXT,
    ticket_class VARCHAR(20),
    seat_number VARCHAR(5),
    special_requests TEXT,
    checked_in BOOLEAN,
    loyalty_level VARCHAR(20)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.ticket_number,
        p.title || ' ' || p.first_name || ' ' || p.last_name AS passenger_name,
        t.ticket_class,
        t.seat_number,
        (SELECT string_agg(request_type || ': ' || request_details, ', ') 
         FROM customer.special_requests sr 
         WHERE sr.ticket_id = t.ticket_id) AS special_requests,
        t.checked_in,
        lp.membership_level
    FROM 
        customer.tickets t
    JOIN 
        customer.passengers p ON t.passenger_id = p.passenger_id
    LEFT JOIN 
        customer.loyalty_program lp ON p.passenger_id = lp.passenger_id
    WHERE 
        t.flight_id = p_flight_id
    ORDER BY 
        t.ticket_class, t.seat_number;
END;
$$ LANGUAGE plpgsql;

-- Triggers

-- Trigger to update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply the trigger to all tables with updated_at column
DO $$
DECLARE
    v_schema_name TEXT;
    v_table_name TEXT;
BEGIN
    FOR v_schema_name, v_table_name IN
        SELECT table_schema, table_name
        FROM information_schema.columns
        WHERE column_name = 'updated_at'
        AND table_schema IN ('core', 'customer', 'employee', 'operations', 'finance')
    LOOP
        EXECUTE format('
            CREATE TRIGGER update_timestamp
            BEFORE UPDATE ON %I.%I
            FOR EACH ROW
            EXECUTE FUNCTION update_timestamp();
        ', v_schema_name, v_table_name);
    END LOOP;
END;
$$;

-- Trigger to update aircraft status when maintenance is completed
CREATE OR REPLACE FUNCTION operations.update_aircraft_after_maintenance()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'Completed' AND OLD.status != 'Completed' THEN
        UPDATE core.aircraft
        SET 
            status = 'Active',
            last_maintenance_date = NEW.end_time::DATE
        WHERE aircraft_id = NEW.aircraft_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER maintenance_completed
AFTER UPDATE ON operations.maintenance
FOR EACH ROW
WHEN (NEW.status = 'Completed' AND OLD.status != 'Completed')
EXECUTE FUNCTION operations.update_aircraft_after_maintenance();

-- Trigger to validate seat assignment
CREATE OR REPLACE FUNCTION customer.validate_seat_assignment()
RETURNS TRIGGER AS $$
DECLARE
    v_seat_count INT;
BEGIN
    -- Check if seat is already assigned
    IF NEW.seat_number IS NOT NULL THEN
        SELECT COUNT(*) INTO v_seat_count
        FROM customer.tickets
        WHERE flight_id = NEW.flight_id
        AND seat_number = NEW.seat_number
        AND ticket_id != NEW.ticket_id;
        
        IF v_seat_count > 0 THEN
            RAISE EXCEPTION 'Seat % is already assigned on this flight', NEW.seat_number;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_seat_assignment
BEFORE INSERT OR UPDATE ON customer.tickets
FOR EACH ROW
WHEN (NEW.seat_number IS NOT NULL)
EXECUTE FUNCTION customer.validate_seat_assignment();

-- Trigger to record revenue when a ticket is issued
CREATE OR REPLACE FUNCTION finance.record_ticket_revenue()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO finance.revenue (
        flight_id,
        revenue_type,
        amount,
        currency,
        entry_date,
        description
    ) VALUES (
        NEW.flight_id,
        'Ticket Sales',
        NEW.fare_amount,
        (SELECT currency FROM customer.bookings WHERE booking_id = NEW.booking_id),
        CURRENT_TIMESTAMP,
        'Ticket ' || NEW.ticket_number || ' - ' || NEW.ticket_class || ' class'
    );
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ticket_revenue
AFTER INSERT ON customer.tickets
FOR EACH ROW
EXECUTE FUNCTION finance.record_ticket_revenue();

-- Trigger to record cargo revenue
CREATE OR REPLACE FUNCTION finance.record_cargo_revenue()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO finance.revenue (
        flight_id,
        revenue_type,
        amount,
        currency,
        entry_date,
        description
    ) VALUES (
        NEW.flight_id,
        'Cargo',
        NEW.charge_amount,
        'KES', -- Assuming Kenya Shillings as default
        CURRENT_TIMESTAMP,
        'Cargo shipment - ' || NEW.content_type || ' (' || NEW.weight_kg || 'kg)'
    );
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER cargo_revenue
AFTER INSERT ON operations.cargo
FOR EACH ROW
EXECUTE FUNCTION finance.record_cargo_revenue();
