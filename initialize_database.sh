#!/bin/bash
# Kenya Airways Database Initialization Script

# Set variables
DB_NAME="kenya_airways"
DB_USER="postgres"  # Default PostgreSQL superuser

# Display welcome message
echo "====================================================="
echo "Kenya Airways Database System - Initialization Script"
echo "====================================================="
echo

# Check if PostgreSQL is installed
if ! command -v psql &> /dev/null; then
    echo "Error: PostgreSQL is not installed or not in PATH."
    echo "Please install PostgreSQL and try again."
    exit 1
fi

# Check if database already exists
if PGPASSWORD="" psql -U postgres -lqt | cut -d \| -f 1 | grep -qw "$DB_NAME"; then
    echo "Warning: Database '$DB_NAME' already exists."
    read -p "Do you want to drop and recreate it? (y/n): " confirm
    if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
        echo "Dropping existing database..."
        PGPASSWORD="" dropdb -U postgres "$DB_NAME"
    else
        echo "Initialization cancelled."
        exit 0
    fi
fi

# Create database
echo "Creating database '$DB_NAME'..."
PGPASSWORD="" createdb -U postgres "$DB_NAME"

if [ $? -ne 0 ]; then
    echo "Error: Failed to create database."
    exit 1
fi

# Run schema script
echo "Creating database schema..."
PGPASSWORD="" psql -U postgres -d "$DB_NAME" -f schema.sql

if [ $? -ne 0 ]; then
    echo "Warning: There were errors while creating the schema."
    read -p "Do you want to continue? (y/n): " confirm
    if [[ $confirm != [yY] && $confirm != [yY][eE][sS] ]]; then
        echo "Initialization cancelled."
        exit 1
    fi
fi

# Run procedures script
echo "Creating stored procedures and functions..."
PGPASSWORD="" psql -U postgres -d "$DB_NAME" -f procedures.sql

if [ $? -ne 0 ]; then
    echo "Warning: There were errors while creating stored procedures."
    read -p "Do you want to continue? (y/n): " confirm
    if [[ $confirm != [yY] && $confirm != [yY][eE][sS] ]]; then
        echo "Initialization cancelled."
        exit 1
    fi
fi

# Ask if sample data should be loaded
read -p "Do you want to load sample data? (y/n): " load_sample
if [[ $load_sample == [yY] || $load_sample == [yY][eE][sS] ]]; then
    echo "Loading sample data (this may take a few minutes)..."
    
    echo "Loading core data..."
    PGPASSWORD="" psql -U postgres -d "$DB_NAME" -f sample_data.sql
    
    echo "Loading employee and crew data..."
    PGPASSWORD="" psql -U postgres -d "$DB_NAME" -f sample_data_part2.sql
    
    echo "Loading operational and financial data..."
    PGPASSWORD="" psql -U postgres -d "$DB_NAME" -f sample_data_part3.sql
    
    if [ $? -ne 0 ]; then
        echo "Warning: There were errors while loading sample data."
        echo "The database may be partially populated."
    else
        echo "Sample data loaded successfully."
    fi
fi

# Create database user (optional)
read -p "Do you want to create a dedicated database user? (y/n): " create_user
if [[ $create_user == [yY] || $create_user == [yY][eE][sS] ]]; then
    read -p "Enter username: " username
    read -s -p "Enter password: " password
    echo
    
    echo "Creating user '$username'..."
    PGPASSWORD="" psql -U postgres -d "$DB_NAME" -c "CREATE USER $username WITH PASSWORD '$password';"
    
    echo "Granting privileges..."
    PGPASSWORD="" psql -U postgres -d "$DB_NAME" -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $username;"
    PGPASSWORD="" psql -U postgres -d "$DB_NAME" -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA core, customer, employee, operations, finance TO $username;"
    PGPASSWORD="" psql -U postgres -d "$DB_NAME" -c "GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA core, customer, employee, operations, finance TO $username;"
    PGPASSWORD="" psql -U postgres -d "$DB_NAME" -c "GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA core, customer, employee, operations, finance TO $username;"
fi

# Display connection information
echo
echo "====================================================="
echo "Database initialization completed successfully!"
echo "====================================================="
echo
echo "Connection Information:"
echo "  Database: $DB_NAME"
echo "  Host: localhost"
echo "  Port: 5432"
echo "  User: postgres (or your custom user if created)"
echo
echo "To connect to the database:"
echo "  psql -U postgres -d $DB_NAME"
echo
echo "For more information, see the README.md file."
echo "====================================================="
