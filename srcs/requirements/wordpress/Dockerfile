FROM alpine:3.20

# Define build-time arguments for PHP version and database configuration
# PHP_VERSION defaults to 83 (PHP 8.3); DB_NAME, DB_USER, DB_PASS are for WordPress
ARG PHP_VERSION=83 \
    DB_NAME \
    DB_USER \
    DB_PASS

# Update package index, upgrade existing packages, and install required PHP packages and tools
# Install PHP 8.3 and extensions needed for WordPress, along with wget and unzip for downloading WordPress
# --no-cache ensures the package index is not stored, reducing image size
RUN apk update && apk upgrade && apk add --no-cache \
    php${PHP_VERSION} \
    php${PHP_VERSION}-fpm \
    php${PHP_VERSION}-mysqli \
    php${PHP_VERSION}-json \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-dom \
    php${PHP_VERSION}-exif \
    php${PHP_VERSION}-fileinfo \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-openssl \
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-zip \
    php${PHP_VERSION}-pecl-redis \
    wget \
    unzip && \
    # Configure PHP-FPM to listen on port 9000 for all interfaces (not just localhost)
    sed -i "s|listen = 127.0.0.1:9000|listen = 9000|g" \
        /etc/php${PHP_VERSION}/php-fpm.d/www.conf && \
    # Set PHP-FPM to run as the 'nobody' user for security
    sed -i "s|;listen.owner = nobody|listen.owner = nobody|g" \
        /etc/php${PHP_VERSION}/php-fpm.d/www.conf && \
    # Set PHP-FPM to run as the 'nobody' group for security
    sed -i "s|;listen.group = nobody|listen.group = nobody|g" \
        /etc/php${PHP_VERSION}/php-fpm.d/www.conf && \
    # Remove cached package files to reduce image size
    rm -f /var/cache/apk/*

# Set the working directory to /var/www, where WordPress files will be installed
WORKDIR /var/www

# Download and install the latest WordPress version
# - Download the WordPress zip file
# - Unzip it and move contents to the working directory
# - Remove the zip file and temporary WordPress directory to keep the image clean
RUN wget https://wordpress.org/latest.zip && \
    unzip latest.zip && \
    cp -rf wordpress/* . && \
    rm -rf wordpress latest.zip

# Copy the WordPress configuration script into the container
COPY ./requirements/wordpress/conf/wp-config-create.sh .

# Execute the configuration script to create wp-config.php with provided database credentials
# Remove the script after execution for cleanliness
# Set permissions on wp-content to 0777 to allow uploads and modifications
RUN sh wp-config-create.sh && rm wp-config-create.sh && \
    chmod -R 0777 wp-content/

# Define the default command to start PHP-FPM in foreground mode
# -F ensures PHP-FPM runs in the foreground, suitable for Docker
CMD ["/usr/sbin/php-fpm83", "-F"]
