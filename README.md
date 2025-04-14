# Kenya Airways Database System

A comprehensive SQL database system for Kenya Airways airline operations, designed to manage all aspects of the airline business including flight operations, customer management, employee management, and financial tracking.

## Project Files

This project includes the following files:

- **schema.sql**: The main database schema definition with tables, indexes, and views
- **procedures.sql**: Stored procedures and functions for common operations
- **sample_data.sql**, **sample_data_part2.sql**, **sample_data_part3.sql**: Sample data for testing
- **initialize_database.sh**: Script to set up the database and load data
- **run_sample_queries.sh**: Interactive script to run example queries
- **sample_queries.sql**: Collection of example queries demonstrating database capabilities
- **generate_schema_diagram.py**: Python script to generate a visual diagram of the database schema

## Database Overview

This database system is built using PostgreSQL and is organized into five main schemas:

1. **Core Schema**: Contains fundamental airline operations data
2. **Customer Schema**: Manages passenger information and bookings
3. **Employee Schema**: Handles staff records and crew assignments
4. **Operations Schema**: Tracks operational aspects like maintenance and cargo
5. **Finance Schema**: Records financial transactions, revenue, and expenses

## Entity Relationship Diagram

The database consists of the following key entities and their relationships:

### Core Entities
- Airports
- Aircraft Types
- Aircraft
- Routes
- Flight Schedules
- Flights

### Customer Entities
- Passengers
- Loyalty Program
- Bookings
- Tickets
- Special Requests

### Employee Entities
- Departments
- Positions
- Employees
- Crew
- Crew Assignments

### Operational Entities
- Maintenance
- Cargo
- Baggage
- Catering
- Incidents

### Financial Entities
- Payments
- Refunds
- Expenses
- Revenue

## Getting Started

### Prerequisites
- PostgreSQL 12 or higher
- At least 100MB of disk space
- Python 3.6+ (for schema diagram generation)
- psycopg2 Python package (for schema diagram generation)

### Quick Setup

The easiest way to set up the database is to use the provided initialization script:

```bash
# Make the script executable (if not already)
chmod +x initialize_database.sh

# Run the initialization script
./initialize_database.sh
```

This script will:
1. Create the Kenya Airways database
2. Create the schema (tables, indexes, views)
3. Create stored procedures and functions
4. Optionally load sample data
5. Optionally create a dedicated database user

### Manual Setup

If you prefer to set up the database manually:

1. Create a new PostgreSQL database:
```sql
CREATE DATABASE kenya_airways;
```

2. Connect to the database:
```sql
\c kenya_airways
```

3. Run the schema creation script:
```bash
psql -d kenya_airways -f schema.sql
```

4. Run the stored procedures script:
```bash
psql -d kenya_airways -f procedures.sql
```

5. (Optional) Load sample data:
```bash
psql -d kenya_airways -f sample_data.sql
psql -d kenya_airways -f sample_data_part2.sql
psql -d kenya_airways -f sample_data_part3.sql
```

## Key Features

### Flight Operations Management
- Schedule and track flights
- Assign aircraft and crew
- Monitor flight status and delays
- Generate flight manifests

### Customer Management
- Store passenger information
- Process bookings and issue tickets
- Handle check-ins and seat assignments
- Manage loyalty program memberships

### Employee and Crew Management
- Maintain employee records
- Track crew certifications and qualifications
- Schedule crew assignments
- Monitor duty hours and compliance

### Aircraft and Maintenance
- Track aircraft details and status
- Schedule and record maintenance activities
- Monitor aircraft utilization
- Ensure regulatory compliance

### Financial Tracking
- Record revenue from tickets, cargo, and ancillary services
- Track expenses by category
- Process payments and refunds
- Generate financial reports

## Common Queries

### Flight Information

Get flight status for a specific date:
```sql
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
    f.flight_date = '2023-05-01'
ORDER BY 
    f.scheduled_departure;
```

### Passenger Bookings

Find all bookings for a specific passenger:
```sql
SELECT 
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
    p.email = 'john.smith@example.com'
GROUP BY 
    b.booking_id, b.booking_reference, b.booking_date, b.booking_status, b.total_amount, b.payment_status
ORDER BY 
    b.booking_date DESC;
```

### Flight Load Factor

Calculate load factor for a specific flight:
```sql
SELECT 
    fs.flight_number,
    f.flight_date,
    a_origin.iata_code AS origin,
    a_dest.iata_code AS destination,
    COUNT(t.ticket_id) AS passenger_count,
    (at.capacity_economy + at.capacity_business + at.capacity_first) AS total_capacity,
    (COUNT(t.ticket_id)::DECIMAL / (at.capacity_economy + at.capacity_business + at.capacity_first)::DECIMAL) * 100 AS load_factor
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
    core.aircraft ac ON f.aircraft_id = ac.aircraft_id
JOIN 
    core.aircraft_types at ON ac.aircraft_type_id = at.aircraft_type_id
LEFT JOIN 
    customer.tickets t ON f.flight_id = t.flight_id
WHERE 
    fs.flight_number = 'KQ100' AND f.flight_date = '2023-05-01'
GROUP BY 
    fs.flight_number, f.flight_date, a_origin.iata_code, a_dest.iata_code, at.capacity_economy, at.capacity_business, at.capacity_first;
```

### Route Profitability

Analyze route profitability for a specific period:
```sql
SELECT 
    a_origin.iata_code || '-' || a_dest.iata_code AS route,
    a_origin.city AS origin_city,
    a_dest.city AS destination_city,
    COUNT(f.flight_id) AS total_flights,
    SUM(t.fare_amount) AS ticket_revenue,
    SUM(c.charge_amount) AS cargo_revenue,
    (SELECT SUM(amount) FROM finance.expenses WHERE flight_id IN (SELECT f2.flight_id FROM core.flights f2 JOIN core.flight_schedules fs2 ON f2.schedule_id = fs2.schedule_id WHERE fs2.route_id = r.route_id AND f2.flight_date BETWEEN '2023-01-01' AND '2023-03-31')) AS total_expenses,
    SUM(t.fare_amount) + SUM(c.charge_amount) - (SELECT COALESCE(SUM(amount), 0) FROM finance.expenses WHERE flight_id IN (SELECT f2.flight_id FROM core.flights f2 JOIN core.flight_schedules fs2 ON f2.schedule_id = fs2.schedule_id WHERE fs2.route_id = r.route_id AND f2.flight_date BETWEEN '2023-01-01' AND '2023-03-31')) AS profit
FROM 
    core.routes r
JOIN 
    core.airports a_origin ON r.origin_airport_id = a_origin.airport_id
JOIN 
    core.airports a_dest ON r.destination_airport_id = a_dest.airport_id
JOIN 
    core.flight_schedules fs ON r.route_id = fs.route_id
JOIN 
    core.flights f ON fs.schedule_id = f.schedule_id
LEFT JOIN 
    customer.tickets t ON f.flight_id = t.flight_id
LEFT JOIN 
    operations.cargo c ON f.flight_id = c.flight_id
WHERE 
    f.flight_date BETWEEN '2023-01-01' AND '2023-03-31'
GROUP BY 
    r.route_id, a_origin.iata_code, a_dest.iata_code, a_origin.city, a_dest.city
ORDER BY 
    profit DESC;
```

### Aircraft Utilization

Track aircraft utilization:
```sql
SELECT 
    ac.registration_number,
    act.manufacturer || ' ' || act.model AS aircraft_type,
    COUNT(f.flight_id) AS total_flights,
    SUM(r.distance_km) AS total_distance_flown,
    SUM(EXTRACT(EPOCH FROM (f.actual_arrival - f.actual_departure))/3600) AS total_flight_hours,
    COUNT(DISTINCT f.flight_date) AS days_in_service,
    (SELECT COUNT(*) FROM operations.maintenance m WHERE m.aircraft_id = ac.aircraft_id) AS maintenance_events
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
WHERE 
    f.flight_date BETWEEN '2023-01-01' AND '2023-03-31'
GROUP BY 
    ac.aircraft_id, ac.registration_number, act.manufacturer, act.model
ORDER BY 
    total_flight_hours DESC;
```

### Crew Duty Hours

Monitor crew duty hours:
```sql
SELECT 
    e.first_name || ' ' || e.last_name AS crew_name,
    c.crew_type,
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
WHERE 
    f.flight_date BETWEEN '2023-04-01' AND '2023-04-30'
GROUP BY 
    e.employee_id, e.first_name, e.last_name, c.crew_type
ORDER BY 
    duty_hours DESC;
```

## Stored Procedures and Functions

The database includes several stored procedures and functions to simplify common operations:

### Flight Operations
- `core.schedule_flight(p_schedule_id, p_flight_date, p_aircraft_id)`: Creates a new flight based on a schedule
- `core.update_flight_status(p_flight_id, p_status, ...)`: Updates flight status and related information
- `core.calculate_load_factor(p_flight_id)`: Calculates the load factor for a flight
- `core.generate_flight_manifest(p_flight_id)`: Generates a passenger manifest for a flight

### Customer Management
- `customer.create_booking(p_passenger_id, ...)`: Creates a new booking
- `customer.add_ticket_to_booking(p_booking_id, ...)`: Adds a ticket to an existing booking
- `customer.check_in_passenger(p_ticket_number, p_seat_number)`: Processes passenger check-in
- `customer.add_loyalty_points(p_ticket_id, p_points)`: Adds points to a passenger's loyalty account
- `customer.get_available_seats(p_flight_id, p_ticket_class)`: Lists available seats for a flight

### Employee Management
- `employee.assign_crew_to_flight(p_crew_id, p_flight_id, ...)`: Assigns crew members to a flight

### Operations Management
- `operations.schedule_maintenance(p_aircraft_id, ...)`: Schedules maintenance for an aircraft

### Financial Management
- `finance.process_payment(p_booking_id, ...)`: Processes a payment for a booking
- `finance.calculate_route_profitability(p_route_id, ...)`: Calculates profitability for a route

## Views

The database includes several views to simplify reporting:

- `core.flight_status_view`: Provides detailed flight status information
- `customer.passenger_booking_view`: Shows passenger booking details
- `finance.flight_revenue_view`: Displays revenue information by flight
- `operations.aircraft_utilization_view`: Shows aircraft utilization metrics
- `employee.crew_duty_hours_view`: Displays crew duty hours
- `core.route_performance_view`: Shows performance metrics by route

## Security and Access Control

The database is designed with security in mind, with separate schemas for different functional areas. In a production environment, you should implement role-based access control to restrict access to sensitive data.

Example roles:
- `flight_ops_user`: Access to core flight operations data
- `customer_service_user`: Access to customer and booking information
- `crew_scheduler`: Access to employee and crew assignment data
- `finance_user`: Access to financial data
- `admin_user`: Full access to all schemas

## Maintenance and Backup

Regular maintenance and backups are essential for database health:

1. Schedule regular backups:
```bash
pg_dump -d kenya_airways -f kenya_airways_backup_$(date +%Y%m%d).sql
```

2. Implement a retention policy for backups

3. Schedule regular database maintenance:
```sql
VACUUM ANALYZE;
```

4. Monitor database size and performance:
```sql
SELECT pg_size_pretty(pg_database_size('kenya_airways'));
```

## Exploring the Database

### Running Sample Queries

To explore the database functionality, use the sample queries script:

```bash
# Make the script executable (if not already)
chmod +x run_sample_queries.sh

# Run the sample queries script
./run_sample_queries.sh
```

This interactive script allows you to:
- Run individual queries to see specific database features
- Explore different aspects of the airline operations
- See examples of how to query the database effectively

### Generating a Schema Diagram

To visualize the database structure, use the schema diagram generator:

```bash
# Install required Python package (if not already installed)
pip install psycopg2-binary

# Make the script executable (if not already)
chmod +x generate_schema_diagram.py

# Run the diagram generator
./generate_schema_diagram.py
```

This will create an HTML file (`kenya_airways_schema.html`) that you can open in any web browser to see:
- Tables and their columns
- Relationships between tables
- Detailed information about each schema

## Database Structure

The database is organized into five main schemas, each focusing on a specific aspect of airline operations:

### Core Schema
Contains fundamental airline operations data including airports, aircraft, routes, and flights.

### Customer Schema
Manages passenger information, bookings, tickets, and the loyalty program.

### Employee Schema
Handles staff records, crew information, and crew assignments.

### Operations Schema
Tracks operational aspects like maintenance, cargo, baggage, and incidents.

### Finance Schema
Records financial transactions, revenue, and expenses.

## Development and Extension

### Adding New Features

To extend the database with new features:

1. Identify the appropriate schema for your new tables
2. Add table definitions to schema.sql
3. Create any necessary stored procedures in procedures.sql
4. Add appropriate indexes for performance
5. Update views if needed

### Performance Considerations

The database includes indexes on commonly queried columns to ensure good performance. When adding new queries or features, consider:

- Adding indexes for columns used in WHERE clauses or joins
- Using appropriate data types for columns
- Creating views for complex, frequently-used queries
- Using the EXPLAIN command to analyze query performance

## License

This database schema is provided under the MIT License.

## Contributors

- Dennis Kachila (Lead Developer)
- [Your Name] (Contributor)
- [Your Name] (Contributor)

## Contact

For questions or support, please contact denniskachila4332@gmail.com
