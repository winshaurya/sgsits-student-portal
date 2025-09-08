# Simple Dockerfile for running the PHP app
FROM php:8.1-apache

COPY . /var/www/html/
WORKDIR /var/www/html/

# Enable mysqli extension
RUN docker-php-ext-install mysqli

# Ensure files are readable
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80
