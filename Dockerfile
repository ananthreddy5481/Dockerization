# syntax=docker/dockerfile:1
FROM php:8.3-apache

# PHP mysqli + MariaDB (MySQL-compatible) inside the same image
RUN docker-php-ext-install mysqli \
    && apt-get update \
    && apt-get install -y --no-install-recommends mariadb-server \
    && rm -rf /var/lib/apt/lists/*

# let PHP's "localhost" connection use MariaDB's socket
RUN echo "mysqli.default_socket = /run/mysqld/mysqld.sock" > /usr/local/etc/php/conf.d/zz-mysqli-socket.ini

# buffer PHP output so stray blank lines/spaces in any .php file can never
# cause "headers already sent" errors on redirects
RUN echo "output_buffering = 4096" > /usr/local/etc/php/conf.d/zz-output-buffering.ini

# silence the Apache "ServerName" warning
RUN echo "ServerName localhost" > /etc/apache2/conf-available/servername.conf \
    && a2enconf servername

# database setup, run once on the first start of each container
COPY <<'EOF' /docker-init.sql
CREATE DATABASE IF NOT EXISTS site CHARACTER SET utf8mb4;
CREATE USER IF NOT EXISTS 'database_user'@'localhost' IDENTIFIED BY 'Database_5481';
GRANT ALL PRIVILEGES ON site.* TO 'database_user'@'localhost';
FLUSH PRIVILEGES;
USE site;
CREATE TABLE IF NOT EXISTS users (
    s_no     INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50)  NOT NULL UNIQUE,
    email    VARCHAR(100) NOT NULL,
    password VARCHAR(255) NOT NULL,
    role     VARCHAR(20)  NOT NULL DEFAULT 'user',
    file     VARCHAR(255) DEFAULT NULL
);
EOF

# startup script: start database, create it on first run, then start Apache
COPY <<'EOF' /entrypoint.sh
#!/bin/bash
set -e
DATADIR=/var/lib/mysql
mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

# the apt install already creates the system tables; only create them if missing
if [ ! -d "$DATADIR/mysql" ]; then
    mariadb-install-db --user=mysql --datadir="$DATADIR" --skip-test-db > /dev/null
fi

# first start of this container = our "site" database does not exist yet
FIRST_RUN=0
if [ ! -d "$DATADIR/site" ]; then
    FIRST_RUN=1
fi

mariadbd --user=mysql --datadir="$DATADIR" &

for i in $(seq 1 30); do
    if mariadb-admin ping --silent 2>/dev/null; then break; fi
    sleep 1
done

if [ "$FIRST_RUN" = "1" ]; then
    mariadb -u root < /docker-init.sql
fi

apache2-foreground &
APACHE_PID=$!
trap 'kill $APACHE_PID 2>/dev/null; mariadb-admin shutdown 2>/dev/null; exit 0' TERM INT
wait $APACHE_PID
mariadb-admin shutdown 2>/dev/null || true
EOF
RUN chmod +x /entrypoint.sh

# your website files (everything in the folder next to this Dockerfile)
COPY . /var/www/html/

# uploads folder writable by Apache
RUN mkdir -p /var/www/html/uploads \
    && chown -R www-data:www-data /var/www/html/uploads \
    && rm -f /var/www/html/Dockerfile

EXPOSE 80
CMD ["/entrypoint.sh"]
