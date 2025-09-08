<?php
// Data.php
// Central place for application configuration values.
// This file reads sensitive values from environment variables so secrets are not stored in the repo.
// For local development you can create a `.env` file (not committed) and use a loader like phpdotenv,
// or set environment variables in your web server / platform.

// Database connection (used throughout the app as globals)
$DatabaseServer   = getenv('DB_HOST') !== false ? getenv('DB_HOST') : 'localhost';
$DatabasePort     = getenv('DB_PORT') !== false ? getenv('DB_PORT') : '3306';
$DatabaseUsername = getenv('DB_USER') !== false ? getenv('DB_USER') : '';
$DatabasePassword = getenv('DB_PASS') !== false ? getenv('DB_PASS') : '';
$DatabaseName     = getenv('DB_NAME') !== false ? getenv('DB_NAME') : '';
$DatabaseType     = 'mysqli';

// Application-level optional values
$openSISTitle = getenv('OPEN_SIS_TITLE') !== false ? getenv('OPEN_SIS_TITLE') : 'GS Student Portal';
$openSISNotifyAddress = getenv('OPEN_SIS_NOTIFY') !== false ? getenv('OPEN_SIS_NOTIFY') : '';

// If you need other defaults for local development, set them here or provide environment variables.

?>
