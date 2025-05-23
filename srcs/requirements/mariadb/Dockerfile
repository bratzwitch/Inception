FROM alpine:3.20

# Define build-time arguments for database configuration
# These will be passed via docker-compose or build command
ARG DB_NAME \
    DB_USER \
    DB_PASS

# Update package index and install MariaDB server and client
# --no-cache ensures the package index is not stored, reducing image size
RUN apk update && apk add --no-cache mariadb mariadb-client

# Create the MySQL runtime directory and configure MariaDB settings
# - Create /var/run/mysqld for the MySQL daemon's socket
# - Set permissions to 777 to ensure the mysql user can access it
# - Create a custom MariaDB configuration file to disable host cache and name resolution
# - Enable binding to all network interfaces (0.0.0.0)
# - Disable skip-networking to allow remote connections
RUN mkdir /var/run/mysqld; \
    chmod 777 /var/run/mysqld; \
    { echo '[mysqld]'; \
      echo 'skip-host-cache'; \
      echo 'skip-name-resolve'; \
      echo 'bind-address=0.0.0.0'; \
    } | tee /etc/my.cnf.d/docker.cnf; \
    sed -i "s|skip-networking|skip-networking=0|g" \
      /etc/my.cnf.d/mariadb-server.cnf

# Initialize the MariaDB database
# --user=mysql: Runs the initialization as the mysql user
# --datadir=/var/lib/mysql: Specifies the data directory for database files
RUN mysql_install_db --user=mysql --datadir=/var/lib/mysql

# Expose port 3306 for MySQL client connections
EXPOSE 3306

# Copy the database initialization script into the container
COPY requirements/mariadb/conf/create_db.sh .

# Execute the initialization script to create the database and users
# Remove the script after execution to keep the image clean
RUN sh create_db.sh && rm create_db.sh

# Switch to the mysql user for running the MariaDB daemon
# This enhances security by avoiding running as root
USER mysql

# Define the default command to start the MariaDB server
# --skip-log-error suppresses error logging to stderr for cleaner output
CMD ["/usr/bin/mysqld", "--skip-log-error"]


