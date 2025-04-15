#!/bin/bash
# Kenya Airways Database - Run Sample Queries Script

# Set variables
DB_NAME="kenya_airways"
DB_USER="postgres"  # Default PostgreSQL superuser
QUERIES_FILE="sample_queries.sql"
TEMP_QUERY_FILE="/tmp/temp_query.sql"

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

# Function to run a specific query by comment marker
run_query_by_marker() {
    local query_number=$1
    local query_name=$2
    local marker="-- $query_number. $query_name"
    local next_marker="-- $(($query_number + 1))."
    
    echo "====================================================="
    echo "Running Query $query_number: $query_name"
    echo "====================================================="
    
    # Find the query by its marker and extract until the next marker
    # First grep finds the line number of our marker
    start_line=$(grep -n "^$marker" "$QUERIES_FILE" | cut -d: -f1)
    
    if [ -z "$start_line" ]; then
        echo "Error: Could not find query marker '$marker' in the file."
        return
    fi
    
    # Extract the query to a temporary file
    start_line=$((start_line + 1))  # Skip the marker line
    
    # Find the next marker or EOF
    if grep -q "^-- $(($query_number + 1))." "$QUERIES_FILE"; then
        end_line=$(grep -n "^-- $(($query_number + 1))." "$QUERIES_FILE" | cut -d: -f1)
        end_line=$((end_line - 1))
    else
        # If it's the last query, go to the end of file
        end_line=$(wc -l "$QUERIES_FILE" | awk '{print $1}')
    fi
    
    # Extract the query to temp file
    sed -n "${start_line},${end_line}p" "$QUERIES_FILE" > "$TEMP_QUERY_FILE"
    
    # Run the query
    PGPASSWORD="" psql -U postgres -d "$DB_NAME" -f "$TEMP_QUERY_FILE" -X
    
    # Clean up
    rm -f "$TEMP_QUERY_FILE"
    
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
        1) run_query_by_marker 1 "Flight Information" ;;
        2) run_query_by_marker 2 "Passenger Bookings" ;;
        3) run_query_by_marker 3 "Flight Load Factor" ;;
        4) run_query_by_marker 4 "Route Profitability" ;;
        5) run_query_by_marker 5 "Aircraft Utilization" ;;
        6) run_query_by_marker 6 "Crew Duty Hours" ;;
        7) run_query_by_marker 7 "Passenger Manifest" ;;
        8) run_query_by_marker 8 "Revenue by Flight" ;;
        9) run_query_by_marker 9 "Baggage Statistics" ;;
        10) run_query_by_marker 10 "Maintenance Schedule" ;;
        11) run_query_by_marker 11 "Loyalty Program Statistics" ;;
        12) run_query_by_marker 12 "Incident Report" ;;
        13) run_query_by_marker 13 "Using Stored Procedures and Functions" ;;
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
