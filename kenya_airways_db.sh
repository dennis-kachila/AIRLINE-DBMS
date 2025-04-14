#!/bin/bash
# Kenya Airways Database - Main Menu Script

# Display welcome message
clear
echo "====================================================="
echo "Kenya Airways Database System"
echo "====================================================="
echo

# Check if PostgreSQL is installed
if ! command -v psql &> /dev/null; then
    echo "Warning: PostgreSQL is not installed or not in PATH."
    echo "Database operations will not work until PostgreSQL is installed."
    echo "You can still view the README and examine the SQL scripts."
    echo
    POSTGRES_AVAILABLE=false
else
    POSTGRES_AVAILABLE=true
fi

# Check if Python is installed (for schema diagram)
if ! command -v python3 &> /dev/null; then
    echo "Warning: Python 3 is not installed or not in PATH."
    echo "The schema diagram generator will not work without Python 3."
    echo
    PYTHON_AVAILABLE=false
else
    PYTHON_AVAILABLE=true
fi

# Function to check if a script is executable and make it executable if not
check_executable() {
    if [ ! -x "$1" ]; then
        echo "Making $1 executable..."
        chmod +x "$1"
    fi
}

# Check and make scripts executable
check_executable "initialize_database.sh"
check_executable "run_sample_queries.sh"
check_executable "generate_schema_diagram.py"

# Function to view a SQL file
view_sql_file() {
    local file=$1
    echo "Displaying $file..."
    echo
    if command -v less &> /dev/null; then
        less "$file"
    else
        cat "$file"
    fi
    echo
    read -p "Press Enter to return to the previous menu..."
}

# Main menu
while true; do
    clear
    echo "====================================================="
    echo "Kenya Airways Database System"
    echo "====================================================="
    echo
    if [ "$POSTGRES_AVAILABLE" = false ]; then
        echo "WARNING: PostgreSQL is not installed. Database operations will not work."
        echo "Please install PostgreSQL to use all features."
        echo
    fi
    
    echo "Please select an option:"
    echo "1. Initialize Database (Create schema and load data)"
    echo "2. Run Sample Queries"
    echo "3. Generate Schema Diagram"
    echo "4. View README"
    echo "5. View SQL Scripts"
    echo "0. Exit"
    echo
    read -p "Enter your choice (0-5): " choice
    echo
    
    case $choice in
        1)
            if [ "$POSTGRES_AVAILABLE" = true ]; then
                echo "Running database initialization script..."
                ./initialize_database.sh
            else
                echo "Error: PostgreSQL is not installed or not in PATH."
                echo "Please install PostgreSQL to initialize the database."
            fi
            echo
            read -p "Press Enter to return to the main menu..."
            ;;
        2)
            if [ "$POSTGRES_AVAILABLE" = true ]; then
                echo "Running sample queries script..."
                ./run_sample_queries.sh
            else
                echo "Error: PostgreSQL is not installed or not in PATH."
                echo "Please install PostgreSQL to run sample queries."
            fi
            ;;
        3)
            if [ "$POSTGRES_AVAILABLE" = true ] && [ "$PYTHON_AVAILABLE" = true ]; then
                echo "Generating schema diagram..."
                # Check if psycopg2 is installed
                if python3 -c "import psycopg2" &> /dev/null; then
                    ./generate_schema_diagram.py
                    echo
                    echo "Schema diagram generated as 'kenya_airways_schema.html'"
                    echo "Please open this file in a web browser to view the diagram."
                else
                    echo "Error: The psycopg2 Python package is not installed."
                    echo "Please install it with: pip install psycopg2-binary"
                fi
            else
                if [ "$POSTGRES_AVAILABLE" = false ]; then
                    echo "Error: PostgreSQL is not installed or not in PATH."
                    echo "Please install PostgreSQL to generate the schema diagram."
                fi
                if [ "$PYTHON_AVAILABLE" = false ]; then
                    echo "Error: Python 3 is not installed or not in PATH."
                    echo "Please install Python 3 to generate the schema diagram."
                fi
            fi
            echo
            read -p "Press Enter to return to the main menu..."
            ;;
        4)
            echo "Displaying README..."
            echo
            if command -v less &> /dev/null; then
                less README.md
            else
                cat README.md
            fi
            echo
            read -p "Press Enter to return to the main menu..."
            ;;
        5)
            # SQL Scripts submenu
            while true; do
                clear
                echo "====================================================="
                echo "Kenya Airways Database - SQL Scripts"
                echo "====================================================="
                echo
                echo "Please select a script to view:"
                echo "1. schema.sql (Database Schema Definition)"
                echo "2. procedures.sql (Stored Procedures and Functions)"
                echo "3. sample_data.sql (Sample Data - Part 1)"
                echo "4. sample_data_part2.sql (Sample Data - Part 2)"
                echo "5. sample_data_part3.sql (Sample Data - Part 3)"
                echo "6. sample_queries.sql (Example Queries)"
                echo "0. Return to Main Menu"
                echo
                read -p "Enter your choice (0-6): " sql_choice
                echo
                
                case $sql_choice in
                    1) view_sql_file "schema.sql" ;;
                    2) view_sql_file "procedures.sql" ;;
                    3) view_sql_file "sample_data.sql" ;;
                    4) view_sql_file "sample_data_part2.sql" ;;
                    5) view_sql_file "sample_data_part3.sql" ;;
                    6) view_sql_file "sample_queries.sql" ;;
                    0) break ;;
                    *) 
                        echo "Invalid choice. Please try again."
                        read -p "Press Enter to continue..."
                        ;;
                esac
            done
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
