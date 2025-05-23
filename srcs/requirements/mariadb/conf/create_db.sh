#!/bin/sh

# Check if the MySQL system database directory does not exist
# This indicates that the database has not been initialized
if [ ! -d "/var/lib/mysql/mysql" ]; then

    # Set ownership of the MySQL data directory to the 'mysql' user and group
    # This ensures the MySQL process has the necessary permissions to write data
    chown -R mysql:mysql /var/lib/mysql

    # Initialize the MySQL database
    # --basedir=/usr: Specifies the MySQL installation directory
    # --datadir=/var/lib/mysql: Specifies the data directory for database files
    # --user=mysql: Runs the initialization as the 'mysql' user
    # --rpm: Ensures compatibility with RPM-based initialization (used for Alpine compatibility)
    mysql_install_db --basedir=/usr --datadir=/var/lib/mysql --user=mysql --rpm

    # Create a temporary file to store SQL commands
    # mktemp generates a unique temporary file name
    tfile=`mktemp`
    # Check if the temporary file was created successfully
    if [ ! -f "$tfile" ]; then
        # Exit with an error code if the file could not be created
        return 1
    fi
fi

# Check if the WordPress database directory does not exist
# This indicates that the specific WordPress database has not been created
if [ ! -d "/var/lib/mysql/wordpress" ]; then

    # Create an SQL script in /tmp/create_db.sql to initialize the database
    # The script sets up the database, user, and permissions
    cat << EOF > /tmp/create_db.sql
# Switch to the MySQL system database to manage users and privileges
USE mysql;
# Clear any cached privileges to ensure changes take effect
FLUSH PRIVILEGES;
# Remove anonymous users for security
DELETE FROM mysql.user WHERE User='';
# Drop the default 'test' database if it exists
DROP DATABASE test;
# Remove any privileges associated with the 'test' database
DELETE FROM mysql.db WHERE Db='test';
# Remove root user access from non-localhost hosts for security
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
# Set the root user password using the provided DB_ROOT environment variable
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT}';
# Create the WordPress database with UTF-8 character set for compatibility
CREATE DATABASE ${DB_NAME} CHARACTER SET utf8 COLLATE utf8_general_ci;
# Create a new user for WordPress with the provided DB_USER and DB_PASS
CREATE USER '${DB_USER}'@'%' IDENTIFIED by '${DB_PASS}';
# Grant all privileges on the WordPress database to the new user
# The '%' wildcard allows the user to connect from any host
GRANT ALL PRIVILEGES ON wordpress.* TO '${DB_USER}'@'%';
# Ensure all privilege changes are applied
FLUSH PRIVILEGES;
EOF

    # Run the SQL script to initialize the database
    # --user=mysql: Runs mysqld as the 'mysql' user
    # --bootstrap: Executes SQL commands without starting the full server
    /usr/bin/mysqld --user=mysql --bootstrap < /tmp/create_db.sql

    # Remove the temporary SQL file to clean up
    rm -f /tmp/create_db.sql
fi