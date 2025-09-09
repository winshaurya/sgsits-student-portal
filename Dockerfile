# Dockerfile for Apache + PHP + (optional internal MariaDB) deployment on Render
# If you plan to use an external managed MySQL (recommended), you may omit the MariaDB server
# installation section below.

FROM php:8.2-apache

LABEL maintainer="student-portal" \
      org.opencontainers.image.source="https://render.com" \
      org.opencontainers.image.description="SGSITS Student Portal (openSIS based)"

ENV DEBIAN_FRONTEND=noninteractive \
    PHP_OPCACHE_VALIDATE_TIMESTAMPS=1 \
    PHP_MEMORY_LIMIT=256M \
    PORT=8080

# System packages & MariaDB (can be removed if using external DB only)
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       mariadb-server mariadb-client \
       gosu curl ca-certificates nano vim less git unzip \
    && docker-php-ext-install mysqli pdo pdo_mysql \
    && a2enmod rewrite headers expires \
    && rm -rf /var/lib/apt/lists/*

# Copy source
WORKDIR /var/www/html
COPY . /var/www/html

# Ensure proper ownership (www-data for Apache)
RUN chown -R www-data:www-data /var/www/html

# Tune Apache to use PORT (Render provides dynamic $PORT)
RUN sed -ri 's/Listen 80/Listen ${PORT}/' /etc/apache2/ports.conf \
 && sed -ri 's/:80>/:${PORT}>/g' /etc/apache2/sites-available/000-default.conf || true

# Add entrypoint script for optional internal MariaDB initialization
COPY scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Healthcheck: verifies both DB (if internal) and HTTP reachability
HEALTHCHECK --interval=30s --timeout=5s --retries=5 CMD bash -c '[[ -z "$MYSQL_ROOT_PASSWORD" ]] || mysqladmin ping -uroot -p"$MYSQL_ROOT_PASSWORD" >/dev/null 2>&1; curl -fsS http://127.0.0.1:${PORT}/health.php >/dev/null || exit 1'

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]
