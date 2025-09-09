#!/usr/bin/env bash
set -euo pipefail

# This entrypoint supports TWO modes:
# 1. External DB (preferred): Provide DB_HOST / DB_USER / DB_PASS / DB_NAME (or DB_URL). No internal MySQL started.
# 2. Internal ephemeral MariaDB: Provide MYSQL_ROOT_PASSWORD (and optional MYSQL_DATABASE, MYSQL_USER, MYSQL_PASSWORD).
#    A Render disk can be mounted at /var/lib/mysql for persistence. Not recommended for production scaling.

: "${PORT:=8080}"
export PORT

APACHE_CONF_PORT_FILE=/etc/apache2/ports.conf
VHOST_FILE=/etc/apache2/sites-available/000-default.conf

# Reassert dynamic port at runtime in case environment differs from build
if grep -q "Listen 80" "$APACHE_CONF_PORT_FILE"; then
  sed -ri "s/Listen 80/Listen ${PORT}/" "$APACHE_CONF_PORT_FILE"
fi
sed -ri "s/:80>/:${PORT}>/g" "$VHOST_FILE" || true

# If MYSQL_ROOT_PASSWORD is set we assume internal DB should run
if [[ -n "${MYSQL_ROOT_PASSWORD:-}" ]]; then
  echo "[entrypoint] Internal MariaDB mode enabled.";
  chown -R mysql:mysql /var/lib/mysql
  if [ ! -d /var/lib/mysql/mysql ]; then
    echo "[entrypoint] Initializing MariaDB data directory...";
    mysql_install_db --user=mysql --ldata=/var/lib/mysql > /dev/null
    INIT_NEW=1
  else
    INIT_NEW=0
  fi

  echo "[entrypoint] Starting MariaDB...";
  /usr/bin/mysqld_safe --datadir=/var/lib/mysql --nowatch > /dev/null 2>&1 &

  for i in {1..60}; do
    if mysqladmin ping --silent; then
      break
    fi
    sleep 1
  done
  if ! mysqladmin ping --silent; then
    echo "MariaDB failed to start" >&2
    exit 1
  fi

  if [ "$INIT_NEW" = "1" ]; then
    echo "[entrypoint] Securing root user...";
    mysql -uroot <<SQL
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
SQL
    if [[ -n "${MYSQL_DATABASE:-}" ]]; then
      mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" -e "CREATE DATABASE \`${MYSQL_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    fi
    if [[ -n "${MYSQL_USER:-}" && -n "${MYSQL_PASSWORD:-}" ]]; then
      mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" <<SQL
CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE:-*}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
SQL
    fi
  fi
else
  echo "[entrypoint] External DB mode (no internal MariaDB started).";
fi

# Basic PHP runtime flags for debugging (optional)
if [[ "${DEBUG:-0}" = "1" ]]; then
  echo "[entrypoint] DEBUG=1 -> enabling display_errors";
  { 
    echo 'display_errors=On';
    echo 'error_reporting=E_ALL';
  } > /usr/local/etc/php/conf.d/debug.ini
fi

# Start Apache (foreground)
exec "$@"
