-- Kenya Airways Database - Sample Queries
-- This file contains sample queries to demonstrate the capabilities of the Kenya Airways database

-- 1. Flight Information
-- Get flight status for a specific date
SELECT 
    fs.flight_number,
    a_origin.iata_code AS origin,
    a_dest.iata_code AS destination,
    f.scheduled_departure,
    f.scheduled_arrival,
    f.status,
    ac.registration_number AS aircraft
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
WHERE 
    f.flight_date = CURRENT_DATE
ORDER BY 
    f.scheduled_departure;

-- 2. Passenger Bookings
-- Find all bookings for a specific passenger
SELECT 
    p.first_name,
    p.last_name,
    b.booking_reference,
    b.booking_date,
    b.booking_status,
    b.total_amount,
    b.payment_status,
    COUNT(t.ticket_id) AS ticket_count
FROM 
    customer.bookings b
JOIN 
    customer.passengers p ON b.passenger_id = p.passenger_id
LEFT JOIN 
    customer.tickets t ON b.booking_id = t.booking_id
WHERE 
    p.passenger_id = 1  -- Change this to a valid passenger_id
GROUP BY 
    p.first_name, p.last_name, b.booking_id, b.booking_reference, b.booking_date, b.booking_status, b.total_amount, b.payment_status
ORDER BY 
    b.booking_date DESC;

-- 3. Flight Load Factor
-- Calculate load factor for flights today
SELECT 
    fs.flight_number,
    f.flight_date,
    a_origin.iata_code AS origin,
    a_dest.iata_code AS destination,
    COUNT(t.ticket_id) AS passenger_countments,
    AVG(EXTRACT(EPOCH FROM (COALESCE(f.actual_arrival, f.scheduled_arrival) - COALESCE(f.actual_departure, f.scheduled_departure)))/3600) AS avg_flight_duration_hours,
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
WHERE 
    f.flight_date BETWEEN CURRENT_DATE - INTERVAL '30 days' AND CURRENT_DATE
GROUP BY 
    r.route_id, a_origin.iata_code, a_dest.iata_code, a_origin.city, a_dest.city
ORDER BY 
    profit DESC;

-- 5. Aircraft Utilization
-- Track aircraft utilization for the last 30 days
SELECT 
    ac.registration_number,
    act.manufacturer || ' ' || act.model AS aircraft_type,
    COUNT(f.flight_id) AS total_flights,
    SUM(r.distance_km) AS total_distance_flown,
    SUM(EXTRACT(EPOCH FROM (COALESCE(f.actual_arrival, f.scheduled_arrival) - COALESCE(f.actual_departure, f.scheduled_departure)))/3600) AS total_flight_hours,
    COUNT(DISTINCT f.flight_date) AS days_in_service,
    (SELECT COUNT(*) FROM operations.maintenance m WHERE m.aircraft_id = ac.aircraft_id AND m.start_time BETWEEN CURRENT_DATE - INTERVAL '30 days' AND CURRENT_DATE) AS maintenance_events
FROM 
    core.aircraft ac
JOIN 
    core.aircraft_types act ON ac.aircraft_type_id = act.aircraft_type_id
LEFT JOIN 
    core.flights f ON ac.aircraft_id = f.aircraft_id AND f.flight_date BETWEEN CURRENT_DATE - INTERVAL '30 days' AND CURRENT_DATE
LEFT JOIN 
    core.flight_schedules fs ON f.schedule_id = fs.schedule_id
LEFT JOIN 
    core.routes r ON fs.route_id = r.route_id
GROUP BY 
    ac.aircraft_id, ac.registration_number, act.manufacturer, act.model
ORDER BY 
    total_flight_hours DESC;

-- 6. Crew Duty Hours
-- Monitor crew duty hours for the last 30 days
SELECT 
    e.first_name || ' ' || e.last_name AS crew_name,
    c.crew_type,
    COUNT(ca.assignment_id) AS flights_assigned,
    SUM(EXTRACT(EPOCH FROM (COALESCE(f.actual_arrival, f.scheduled_arrival) - ca.report_time))/3600) AS duty_hours,
    SUM(EXTRACT(EPOCH FROM (COALESCE(f.actual_arrival, f.scheduled_arrival) - COALESCE(f.actual_departure, f.scheduled_departure)))/3600) AS flight_hours
FROM 
    employee.crew c
JOIN 
    employee.employees e ON c.employee_id = e.employee_id
JOIN 
    employee.crew_assignments ca ON c.crew_id = ca.crew_id
JOIN 
    core.flights f ON ca.flight_id = f.flight_id
WHERE 
    f.flight_date BETWEEN CURRENT_DATE - INTERVAL '30 days' AND CURRENT_DATE
GROUP BY 
    e.employee_id, e.first_name, e.last_name, c.crew_type
ORDER BY 
    duty_hours DESC
LIMIT 20;

-- 7. Passenger Manifest for a Flight
-- Generate a passenger manifest for a specific flight
SELECT 
    t.ticket_number,
    p.title || ' ' || p.first_name || ' ' || p.last_name AS passenger_name,
    t.ticket_class,
    t.seat_number,
    t.checked_in,
    lp.membership_level AS loyalty_status,
    sr.request_type AS special_request,
    sr.request_details
FROM 
    core.flights f
JOIN 
    core.flight_schedules fs ON f.schedule_id = fs.schedule_id
JOIN 
    customer.tickets t ON f.flight_id = t.flight_id
JOIN 
    customer.passengers p ON t.passenger_id = p.passenger_id
LEFT JOIN 
    customer.loyalty_program lp ON p.passenger_id = lp.passenger_id
LEFT JOIN 
    customer.special_requests sr ON t.ticket_id = sr.ticket_id
WHERE 
    fs.flight_number = 'KQ100' AND f.flight_date = CURRENT_DATE  -- Change to a valid flight number and date
ORDER BY 
    t.ticket_class, t.seat_number;

-- 8. Revenue by Flight
-- Calculate revenue by flight for today
SELECT 
    fs.flight_number,
    a_origin.iata_code || '-' || a_dest.iata_code AS route,
    f.flight_date,
    COUNT(t.ticket_id) AS passenger_count,
    SUM(CASE WHEN t.ticket_class = 'Economy' THEN t.fare_amount ELSE 0 END) AS economy_revenue,
    SUM(CASE WHEN t.ticket_class = 'Business' THEN t.fare_amount ELSE 0 END) AS business_revenue,
    SUM(CASE WHEN t.ticket_class = 'First' THEN t.fare_amount ELSE 0 END) AS first_revenue,
    SUM(t.fare_amount) AS total_ticket_revenue,
    SUM(c.charge_amount) AS cargo_revenue,
    SUM(t.fare_amount) + SUM(c.charge_amount) AS total_revenue
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
WHERE 
    f.flight_date = CURRENT_DATE
GROUP BY 
    fs.flight_number, a_origin.iata_code, a_dest.iata_code, f.flight_date
ORDER BY 
    total_revenue DESC;

-- 9. Baggage Statistics
-- Get baggage statistics by flight
SELECT 
    fs.flight_number,
    a_origin.iata_code || '-' || a_dest.iata_code AS route,
    f.flight_date,
    COUNT(b.baggage_id) AS total_bags,
    AVG(b.weight_kg) AS avg_weight,
    SUM(b.weight_kg) AS total_weight,
    COUNT(CASE WHEN b.status = 'Lost' THEN 1 ELSE NULL END) AS lost_bags,
    COUNT(CASE WHEN b.status = 'Damaged' THEN 1 ELSE NULL END) AS damaged_bags
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
JOIN 
    customer.tickets t ON f.flight_id = t.flight_id
LEFT JOIN 
    operations.baggage b ON t.ticket_id = b.ticket_id
WHERE 
    f.flight_date BETWEEN CURRENT_DATE - INTERVAL '30 days' AND CURRENT_DATE
GROUP BY 
    fs.flight_number, a_origin.iata_code, a_dest.iata_code, f.flight_date
ORDER BY 
    f.flight_date DESC, fs.flight_number;

-- 10. Maintenance Schedule
-- View upcoming maintenance schedule
SELECT 
    ac.registration_number,
    act.manufacturer || ' ' || act.model AS aircraft_type,
    m.maintenance_type,
    m.start_time,
    m.end_time,
    m.description,
    m.status,
    e.first_name || ' ' || e.last_name AS performed_by
FROM 
    operations.maintenance m
JOIN 
    core.aircraft ac ON m.aircraft_id = ac.aircraft_id
JOIN 
    core.aircraft_types act ON ac.aircraft_type_id = act.aircraft_type_id
LEFT JOIN 
    employee.employees e ON m.performed_by = e.employee_id
WHERE 
    m.start_time >= CURRENT_DATE
    AND m.status IN ('Scheduled', 'In Progress')
ORDER BY 
    m.start_time;

-- 11. Loyalty Program Statistics
-- Get loyalty program statistics
SELECT 
    membership_level,
    COUNT(*) AS member_count,
    AVG(points_balance) AS avg_points,
    MIN(points_balance) AS min_points,
    MAX(points_balance) AS max_points,
    AVG(EXTRACT(EPOCH FROM (expiry_date - join_date))/86400/365) AS avg_membership_years
FROM 
    customer.loyalty_program
GROUP BY 
    membership_level
ORDER BY 
    CASE 
        WHEN membership_level = 'Platinum' THEN 1
        WHEN membership_level = 'Gold' THEN 2
        WHEN membership_level = 'Silver' THEN 3
        WHEN membership_level = 'Blue' THEN 4
        ELSE 5
    END;

-- 12. Incident Report
-- Get incident reports for the last 90 days
SELECT 
    i.incident_id,
    i.incident_time,
    i.incident_type,
    i.location,
    i.description,
    i.severity,
    fs.flight_number,
    a_origin.iata_code || '-' || a_dest.iata_code AS route,
    ac.registration_number AS aircraft,
    e.first_name || ' ' || e.last_name AS reported_by,
    i.resolution,
    i.resolution_time,
    CASE 
        WHEN i.resolution IS NOT NULL THEN 'Resolved'
        ELSE 'Unresolved'
    END AS status
FROM 
    operations.incidents i
LEFT JOIN 
    core.flights f ON i.flight_id = f.flight_id
LEFT JOIN 
    core.flight_schedules fs ON f.schedule_id = fs.schedule_id
LEFT JOIN 
    core.routes r ON fs.route_id = r.route_id
LEFT JOIN 
    core.airports a_origin ON r.origin_airport_id = a_origin.airport_id
LEFT JOIN 
    core.airports a_dest ON r.destination_airport_id = a_dest.airport_id
LEFT JOIN 
    core.aircraft ac ON i.aircraft_id = ac.aircraft_id
LEFT JOIN 
    employee.employees e ON i.reported_by = e.employee_id
WHERE 
    i.incident_time BETWEEN CURRENT_DATE - INTERVAL '90 days' AND CURRENT_DATE
ORDER BY 
    i.incident_time DESC;

-- 13. Using Stored Procedures and Functions

-- Calculate load factor for a specific flight
SELECT core.calculate_load_factor(1) AS load_factor;  -- Change 1 to a valid flight_id

-- Get available seats for a flight
SELECT * FROM customer.get_available_seats(1, 'Economy');  -- Change 1 to a valid flight_id

-- Generate flight manifest
SELECT * FROM core.generate_flight_manifest(1);  -- Change 1 to a valid flight_id

-- Calculate route profitability
SELECT * FROM finance.calculate_route_profitability(1, CURRENT_DATE - INTERVAL '30 days', CURRENT_DATE);  -- Change 1 to a valid route_id
