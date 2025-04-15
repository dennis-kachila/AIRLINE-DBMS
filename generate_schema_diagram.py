#!/usr/bin/env python3
"""
Kenya Airways Database - Schema Diagram Generator

This script generates a Mermaid diagram of the Kenya Airways database schema,
showing tables and their relationships.

Requirements:
- Python 3.6+
- psycopg2 (pip install psycopg2-binary)
"""

import sys
import psycopg2
from psycopg2 import sql
from collections import defaultdict

# Database connection parameters
DB_NAME = "kenya_airways"
DB_USER = "postgres"  # Default PostgreSQL superuser
DB_PASSWORD = "postgres"  # Standard default password for development environments
DB_HOST = "localhost"
DB_PORT = "5432"

# Colors for different schemas
SCHEMA_COLORS = {
    "core": "#CCEEFF",
    "customer": "#FFDDCC",
    "employee": "#DDFFCC",
    "operations": "#FFCCDD",
    "finance": "#DDCCFF"
}

def connect_to_db():
    """Connect to the PostgreSQL database server using various authentication methods"""
    # Try different connection methods
    connection_errors = []
    
    # Method 1: Try with default password
    try:
        conn = psycopg2.connect(
            dbname=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD,
            host=DB_HOST,
            port=DB_PORT
        )
        return conn
    except (Exception, psycopg2.DatabaseError) as error:
        connection_errors.append(f"Password authentication failed: {error}")
    
    # Method 2: Try peer authentication (Unix socket)
    try:
        conn = psycopg2.connect(
            dbname=DB_NAME,
            user=DB_USER
        )
        return conn
    except (Exception, psycopg2.DatabaseError) as error:
        connection_errors.append(f"Peer authentication failed: {error}")
    
    # Method 3: Try with no password
    try:
        conn = psycopg2.connect(
            dbname=DB_NAME,
            user=DB_USER,
            password="",
            host=DB_HOST,
            port=DB_PORT
        )
        return conn
    except (Exception, psycopg2.DatabaseError) as error:
        connection_errors.append(f"No password authentication failed: {error}")
    
    # If all methods fail, print errors and exit
    for err in connection_errors:
        print(err)
    
    print("\nCould not connect to the database. Please check your PostgreSQL configuration.")
    print("You might need to modify the database connection parameters in the script.")
    
    # Create a fake HTML file with error message
    create_error_html(connection_errors)
    
    sys.exit(1)

def create_error_html(errors):
    """Create an HTML file with error information"""
    html = [
        "<!DOCTYPE html>",
        "<html>",
        "<head>",
        "    <meta charset=\"UTF-8\">",
        "    <title>Kenya Airways Database Schema - Error</title>",
        "    <style>",
        "        body { font-family: Arial, sans-serif; margin: 20px; }",
        "        h1 { color: #cc0000; }",
        "        .error { background-color: #ffeeee; padding: 10px; border: 1px solid #cc0000; margin: 10px 0; }",
        "        pre { background-color: #f5f5f5; padding: 10px; overflow: auto; }",
        "    </style>",
        "</head>",
        "<body>",
        "    <h1>Error Connecting to Database</h1>",
        "    <p>The schema diagram generator could not connect to the database. Please check your PostgreSQL configuration.</p>",
        "    <h2>Error Details</h2>"
    ]
    
    for i, error in enumerate(errors):
        html.append(f"    <div class=\"error\">")
        html.append(f"        <h3>Connection Method {i+1}</h3>")
        html.append(f"        <pre>{error}</pre>")
        html.append(f"    </div>")
    
    html.extend([
        "    <h2>Possible Solutions</h2>",
        "    <ol>",
        "        <li>Ensure PostgreSQL is running</li>",
        "        <li>Check that the database 'kenya_airways' exists</li>", 
        "        <li>Update the PostgreSQL connection parameters in generate_schema_diagram.py</li>",
        "        <li>Set the correct password for the postgres user</li>",
        "    </ol>",
        "</body>",
        "</html>"
    ])
    
    with open("kenya_airways_schema.html", "w") as f:
        f.write("\n".join(html))

def get_tables(conn):
    """Get all tables from the database"""
    tables = []
    try:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT 
                table_schema, 
                table_name 
            FROM 
                information_schema.tables 
            WHERE 
                table_schema IN ('core', 'customer', 'employee', 'operations', 'finance')
                AND table_type = 'BASE TABLE'
            ORDER BY 
                table_schema, 
                table_name
        """)
        tables = cursor.fetchall()
        cursor.close()
        return tables
    except (Exception, psycopg2.DatabaseError) as error:
        print(f"Error getting tables: {error}")
        return []

def get_columns(conn, schema, table):
    """Get all columns for a table"""
    columns = []
    try:
        cursor = conn.cursor()
        # Simplified query that doesn't use the @> array operator
        cursor.execute("""
            SELECT 
                column_name, 
                data_type,
                is_nullable,
                column_default,
                CASE WHEN EXISTS (
                    SELECT 1
                    FROM pg_catalog.pg_constraint con
                    JOIN pg_catalog.pg_class rel ON rel.oid = con.conrelid
                    JOIN pg_catalog.pg_namespace nsp ON nsp.oid = rel.relnamespace
                    JOIN pg_catalog.pg_attribute att ON att.attrelid = rel.oid
                    WHERE con.contype = 'p' 
                      AND rel.relname = %s
                      AND nsp.nspname = %s
                      AND att.attname = c.column_name
                      AND att.attnum = ANY(con.conkey)
                ) THEN 'PRIMARY KEY' ELSE NULL END AS primary_key
            FROM 
                information_schema.columns c
            WHERE 
                table_schema = %s 
                AND table_name = %s
            ORDER BY 
                ordinal_position
        """, (table, schema, schema, table))
        columns = cursor.fetchall()
        cursor.close()
        return columns
    except (Exception, psycopg2.DatabaseError) as error:
        print(f"Error getting columns for {schema}.{table}: {error}")
        return []

def get_foreign_keys(conn):
    """Get all foreign key relationships"""
    foreign_keys = []
    try:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT
                tc.table_schema AS schema_name,
                tc.table_name,
                kcu.column_name,
                ccu.table_schema AS foreign_schema_name,
                ccu.table_name AS foreign_table_name,
                ccu.column_name AS foreign_column_name
            FROM
                information_schema.table_constraints AS tc
                JOIN information_schema.key_column_usage AS kcu
                    ON tc.constraint_name = kcu.constraint_name
                    AND tc.table_schema = kcu.table_schema
                JOIN information_schema.constraint_column_usage AS ccu
                    ON ccu.constraint_name = tc.constraint_name
                    AND ccu.table_schema = tc.table_schema
            WHERE
                tc.constraint_type = 'FOREIGN KEY'
                AND tc.table_schema IN ('core', 'customer', 'employee', 'operations', 'finance')
            ORDER BY
                tc.table_schema,
                tc.table_name
        """)
        foreign_keys = cursor.fetchall()
        cursor.close()
        return foreign_keys
    except (Exception, psycopg2.DatabaseError) as error:
        print(f"Error getting foreign keys: {error}")
        return []

def generate_mermaid_diagram(tables, columns_dict, foreign_keys):
    """Generate a Mermaid diagram of the database schema"""
    mermaid = ["```mermaid", "erDiagram"]
    
    # Add tables and columns
    for schema, table in tables:
        table_id = f"{schema}_{table}"
        mermaid.append(f"    {table_id} {{")
        
        for column in columns_dict.get((schema, table), []):
            column_name, data_type, is_nullable, default, pk = column
            pk_marker = "PK" if pk else ""
            nullable = "NOT NULL" if is_nullable == 'NO' else ""
            mermaid.append(f"        {data_type} {column_name} {pk_marker} {nullable}")
        
        mermaid.append("    }")
    
    # Add relationships
    for fk in foreign_keys:
        schema, table, column, f_schema, f_table, f_column = fk
        source = f"{schema}_{table}"
        target = f"{f_schema}_{f_table}"
        mermaid.append(f"    {source} ||--o{{ {target} : \"references\"")
    
    mermaid.append("```")
    
    return "\n".join(mermaid)

def generate_html_diagram(tables, columns_dict, foreign_keys):
    """Generate an HTML file with the Mermaid diagram"""
    # Group tables by schema
    schema_tables = defaultdict(list)
    for schema, table in tables:
        schema_tables[schema].append(table)
    
    # Create HTML content
    html = [
        "<!DOCTYPE html>",
        "<html>",
        "<head>",
        "    <meta charset=\"UTF-8\">",
        "    <title>Kenya Airways Database Schema</title>",
        "    <script src=\"https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js\"></script>",
        "    <style>",
        "        body { font-family: Arial, sans-serif; margin: 20px; }",
        "        h1 { color: #003366; }",
        "        h2 { color: #0066cc; margin-top: 30px; }",
        "        .mermaid { margin: 20px 0; }",
        "        .schema-container { margin-bottom: 50px; }",
        "        table { border-collapse: collapse; width: 100%; margin-bottom: 20px; }",
        "        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }",
        "        th { background-color: #f2f2f2; }",
        "        tr:nth-child(even) { background-color: #f9f9f9; }",
        "        .schema-core { background-color: #CCEEFF; }",
        "        .schema-customer { background-color: #FFDDCC; }",
        "        .schema-employee { background-color: #DDFFCC; }",
        "        .schema-operations { background-color: #FFCCDD; }",
        "        .schema-finance { background-color: #DDCCFF; }",
        "    </style>",
        "</head>",
        "<body>",
        "    <h1>Kenya Airways Database Schema</h1>",
        "    <p>This diagram shows the tables and relationships in the Kenya Airways database.</p>"
    ]
    
    # Add schema sections
    for schema in sorted(schema_tables.keys()):
        html.append(f"    <div class=\"schema-container\">")
        html.append(f"    <h2>Schema: {schema}</h2>")
        
        # Add tables for this schema
        for table in sorted(schema_tables[schema]):
            html.append(f"    <h3>Table: {table}</h3>")
            html.append(f"    <table>")
            html.append(f"        <tr><th>Column</th><th>Data Type</th><th>Nullable</th><th>Default</th><th>Constraints</th></tr>")
            
            for column in columns_dict.get((schema, table), []):
                column_name, data_type, is_nullable, default, pk = column
                nullable = "No" if is_nullable == 'NO' else "Yes"
                constraints = "Primary Key" if pk else ""
                
                # Check if this column is a foreign key
                for fk in foreign_keys:
                    if fk[0] == schema and fk[1] == table and fk[2] == column_name:
                        if constraints:
                            constraints += ", "
                        constraints += f"Foreign Key to {fk[3]}.{fk[4]}({fk[5]})"
                
                html.append(f"        <tr><td>{column_name}</td><td>{data_type}</td><td>{nullable}</td><td>{default or ''}</td><td>{constraints}</td></tr>")
            
            html.append(f"    </table>")
        
        # Add Mermaid diagram for this schema
        schema_tables_list = [(schema, table) for table in schema_tables[schema]]
        schema_fks = [fk for fk in foreign_keys if fk[0] == schema]
        
        html.append(f"    <div class=\"mermaid\">")
        html.append(f"erDiagram")
        
        # Add tables and columns
        for _, table in schema_tables_list:
            table_id = f"{table}"
            html.append(f"    {table_id} {{")
            
            for column in columns_dict.get((schema, table), []):
                column_name, data_type, is_nullable, default, pk = column
                pk_marker = "PK" if pk else ""
                nullable = "NOT NULL" if is_nullable == 'NO' else ""
                html.append(f"        {data_type} {column_name} {pk_marker} {nullable}")
            
            html.append(f"    }}")
        
        # Add relationships within this schema
        for fk in schema_fks:
            _, table, column, f_schema, f_table, f_column = fk
            if f_schema == schema:  # Only show relationships within this schema
                source = f"{table}"
                target = f"{f_table}"
                html.append(f"    {source} ||--o{{ {target} : \"references\"")
        
        html.append(f"    </div>")
        html.append(f"    </div>")
    
    # Add full database diagram
    html.append(f"    <h2>Full Database Diagram</h2>")
    html.append(f"    <div class=\"mermaid\">")
    html.append(f"erDiagram")
    
    # Add tables and columns (simplified for full diagram)
    for schema, table in tables:
        table_id = f"{schema}_{table}"
        html.append(f"    {table_id} {{")
        
        # Only show primary keys and a few important columns
        important_columns = []
        for column in columns_dict.get((schema, table), []):
            column_name, data_type, is_nullable, default, pk = column
            if pk or column_name.endswith('_id') or len(important_columns) < 3:
                pk_marker = "PK" if pk else ""
                html.append(f"        {data_type} {column_name} {pk_marker}")
                important_columns.append(column_name)
        
        if len(columns_dict.get((schema, table), [])) > len(important_columns):
            html.append(f"        ... ... ...")
        
        html.append(f"    }}")
    
    # Add relationships
    for fk in foreign_keys:
        schema, table, column, f_schema, f_table, f_column = fk
        source = f"{schema}_{table}"
        target = f"{f_schema}_{f_table}"
        html.append(f"    {source} ||--o{{ {target} : \"references\"")
    
    html.append(f"    </div>")
    
    # Close HTML
    html.extend([
        "    <script>",
        "        mermaid.initialize({ startOnLoad: true, theme: 'default', securityLevel: 'loose', er: { useMaxWidth: false } });",
        "    </script>",
        "</body>",
        "</html>"
    ])
    
    return "\n".join(html)

def main():
    """Main function"""
    print("Connecting to database...")
    conn = connect_to_db()
    
    print("Getting tables...")
    tables = get_tables(conn)
    
    print("Getting columns...")
    columns_dict = {}
    for schema, table in tables:
        columns_dict[(schema, table)] = get_columns(conn, schema, table)
    
    print("Getting foreign keys...")
    foreign_keys = get_foreign_keys(conn)
    
    print("Generating HTML diagram...")
    html_diagram = generate_html_diagram(tables, columns_dict, foreign_keys)
    
    # Write HTML to file
    with open("kenya_airways_schema.html", "w") as f:
        f.write(html_diagram)
    
    print("Schema diagram generated as 'kenya_airways_schema.html'")
    print("Open this file in a web browser to view the database schema.")
    
    conn.close()

if __name__ == "__main__":
    main()
