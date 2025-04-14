#!/bin/bash
# Kenya Airways Database - Run Sample Queries Script

# Set variables
DB_NAME="kenya_airways"
DB_USER="postgres"  # Default PostgreSQL superuser
QUERIES_FILE="sample_queries.sql"

# Display welcome message
echo "====================================================="
echo "Kenya Airways Database - Sample Queries Runner"
echo "====================================================="
echo

# Check if PostgreSQL is installed
if ! command -v psql &> /dev/null; then
    echo "Error: PostgreSQL is not installed or not in PATH."
    echo "Please install PostgreSQL and try again."
    exit 1
fi

# Check if database exists
if ! PGPASSWORD="" psql -U postgres -lqt | cut -d \| -f 1 | grep -qw "$DB_NAME"; then
    echo "Error: Database '$DB_NAME' does not exist."
    echo "Please run the initialize_database.sh script first."
    exit 1
fi

# Check if sample_queries.sql exists
if [ ! -f "$QUERIES_FILE" ]; then
    echo "Error: Sample queries file '$QUERIES_FILE' not found."
    exit 1
fi

# Display menu
echo "This script will help you run sample queries against the Kenya Airways database."
echo "You can run individual queries or all queries at once."
echo

# Function to run a specific query
run_query() {
    local query_number=$1
    local query_name=$2
    local start_line=$3
    local end_line=$4
    
    echo "====================================================="
    echo "Running Query $query_number: $query_name"
    echo "====================================================="
    
    # Extract and run the query
    sed -n "${start_line},${end_line}p" "$QUERIES_FILE" | PGPASSWORD="" psql -U postgres -d "$DB_NAME" -X
    
    echo
    read -p "Press Enter to continue..."
    echo
}

# Main menu
while true; do
    clear
    echo "====================================================="
    echo "Kenya Airways Database - Sample Queries"
    echo "====================================================="
    echo
    echo "Available Queries:"
    echo "1. Flight Information - Get flight status for a specific date"
    echo "2. Passenger Bookings - Find all bookings for a specific passenger"
    echo "3. Flight Load Factor - Calculate load factor for flights today"
    echo "4. Route Profitability - Analyze route profitability for the last 30 days"
    echo "5. Aircraft Utilization - Track aircraft utilization for the last 30 days"
    echo "6. Crew Duty Hours - Monitor crew duty hours for the last 30 days"
    echo "7. Passenger Manifest - Generate a passenger manifest for a specific flight"
    echo "8. Revenue by Flight - Calculate revenue by flight for today"
    echo "9. Baggage Statistics - Get baggage statistics by flight"
    echo "10. Maintenance Schedule - View upcoming maintenance schedule"
    echo "11. Loyalty Program Statistics - Get loyalty program statistics"
    echo "12. Incident Report - Get incident reports for the last 90 days"
    echo "13. Using Stored Procedures and Functions - Examples of using stored procedures"
    echo "14. Run All Queries"
    echo "0. Exit"
    echo
    read -p "Enter your choice (0-14): " choice
    echo
    
    case $choice in
        1) run_query 1 "Flight Information" 4 24 ;;
        2) run_query 2 "Passenger Bookings" 27 49 ;;
        3) run_query 3 "Flight Load Factor" 52 79 ;;
        4) run_query 4 "Route Profitability" 82 112 ;;
        5) run_query 5 "Aircraft Utilization" 115 140 ;;
        6) run_query 6 "Crew Duty Hours" 143 166 ;;
        7) run_query 7 "Passenger Manifest" 169 193 ;;
        8) run_query 8 "Revenue by Flight" 196 225 ;;
        9) run_query 9 "Baggage Statistics" 228 257 ;;
        10) run_query 10 "Maintenance Schedule" 260 282 ;;
        11) run_query 11 "Loyalty Program Statistics" 285 307 ;;
        12) run_query 12 "Incident Report" 310 347 ;;
        13) run_query 13 "Using Stored Procedures and Functions" 350 361 ;;
        14)
            echo "Running all queries..."
            PGPASSWORD="" psql -U postgres -d "$DB_NAME" -f "$QUERIES_FILE"
            echo
            read -p "Press Enter to continue..."
            ;;
        0)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid choice. Please try again."
            read -p "Press Enter to continue..."
            ;;
    esac
done
