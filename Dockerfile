###############################
# Student Portal PHP Dockerfile
# Base: Official PHP 8.1 + Apache image
# Target platform: Render.com (Docker web service)
# Render will detect the exposed port (80) and route external traffic.
###############################

FROM php:8.1-apache

## (Optional) Set timezone (uncomment & adjust if needed)
# ENV TZ=UTC

## Copy application source (use a .dockerignore to shrink context)
COPY . /var/www/html/
WORKDIR /var/www/html/

## Install required PHP extensions
# - mysqli: database connectivity (used throughout the codebase)
# - exif: for exif_imagetype() used in HTMLPurifier & image validation
# - bcmath: leveraged optionally by HTMLPurifier for precision math
RUN docker-php-ext-install mysqli exif bcmath

## (Optional) Uncomment to install GD if later image manipulation is added
# RUN apt-get update \
#     && apt-get install -y --no-install-recommends libjpeg-dev libpng-dev libfreetype6-dev \
#     && docker-php-ext-configure gd --with-jpeg --with-freetype \
#     && docker-php-ext-install gd \
#     && rm -rf /var/lib/apt/lists/*

## Harden & tune PHP (upload sizes can be adjusted if large imports needed)
RUN set -eux; \
		{ \
			echo 'memory_limit=256M'; \
			echo 'upload_max_filesize=32M'; \
			echo 'post_max_size=32M'; \
			echo 'max_execution_time=120'; \
			echo 'expose_php=0'; \
			echo 'session.cookie_httponly=1'; \
			echo 'session.use_strict_mode=1'; \
		} > /usr/local/etc/php/conf.d/zzz-custom.ini

## Apache tweaks: enable useful modules
RUN a2enmod headers expires rewrite

## Install curl for healthcheck (minimal layer)
RUN apt-get update \
	&& apt-get install -y --no-install-recommends curl \
	&& rm -rf /var/lib/apt/lists/*

## Fix ownership & reasonable default permissions
RUN chown -R www-data:www-data /var/www/html \
		&& find /var/www/html -type f -exec chmod 0644 {} \; \
		&& find /var/www/html -type d -exec chmod 0755 {} \;

## Healthcheck file already exists at /var/www/html/health.php
HEALTHCHECK --interval=30s --timeout=5s --retries=5 CMD curl -fsS http://localhost/health.php || exit 1

## Expose port 80 (Render will map this to its managed endpoint)
EXPOSE 80

## NOTE: No CMD override needed — base image starts Apache (apache2-foreground)

## For local testing build & run:
# docker build -t student-portal .
# docker run -p 8080:80 --env DB_HOST=host.docker.internal --env DB_NAME=... --env DB_USER=... --env DB_PASS=... student-portal
