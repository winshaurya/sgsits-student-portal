<?php
// Data.php
// Central place for application configuration values.
// This file reads sensitive values from environment variables so secrets are not stored in the repo.
// For local development you can create a `.env` file (not committed) and use a loader like phpdotenv,
// or set environment variables in your web server / platform.

// Database connection (used throughout the app as globals)
// Support either discrete env vars OR a single MySQL style URL placed in DB_HOST (or DB_URL)
// Examples supported:
//  1) DB_HOST=shortline.proxy.rlwy.net  DB_PORT=40234 DB_USER=root DB_PASS=secret DB_NAME=railway
//  2) DB_HOST="mysql://root:secret@shortline.proxy.rlwy.net:40234/railway"
//  3) DB_URL  ="mysql://root:secret@shortline.proxy.rlwy.net:40234/railway"

$rawHost = getenv('DB_HOST') !== false ? getenv('DB_HOST') : '';
$rawUrl  = getenv('DB_URL') !== false ? getenv('DB_URL') : '';

if ($rawUrl && !$rawHost) {
	$rawHost = $rawUrl; // allow DB_URL alias
}

// Defaults
$DatabaseServer   = 'localhost';
$DatabasePort     = '3306';
$DatabaseUsername = '';
$DatabasePassword = '';
$DatabaseName     = '';

// If DB_HOST provided and looks like a full DSN, parse it
if (preg_match('/^mysql:\/\//i', $rawHost)) {
	$parts = parse_url($rawHost);
	if ($parts !== false) {
		if (!empty($parts['host'])) $DatabaseServer = $parts['host'];
		if (!empty($parts['port'])) $DatabasePort = (string)$parts['port'];
		if (!empty($parts['user'])) $DatabaseUsername = $parts['user'];
		if (!empty($parts['pass'])) $DatabasePassword = $parts['pass'];
		if (!empty($parts['path'])) {
			$path = ltrim($parts['path'], '/');
			if ($path) $DatabaseName = $path;
		}
	}
} elseif ($rawHost) {
	// Plain hostname (possibly host:port)
	if (strpos($rawHost, ':') !== false && substr_count($rawHost, ':') === 1) {
		list($h, $p) = explode(':', $rawHost, 2);
		$DatabaseServer = $h;
		if (ctype_digit($p)) $DatabasePort = $p;
	} else {
		$DatabaseServer = $rawHost;
	}
}

// Allow explicit discrete env vars to override anything parsed above
if (getenv('DB_PORT') !== false) $DatabasePort = getenv('DB_PORT');
if (getenv('DB_USER') !== false) $DatabaseUsername = getenv('DB_USER');
if (getenv('DB_PASS') !== false) $DatabasePassword = getenv('DB_PASS');
if (getenv('DB_NAME') !== false) $DatabaseName = getenv('DB_NAME');
$DatabaseType     = 'mysqli';

// Application-level optional values
$openSISTitle = getenv('OPEN_SIS_TITLE') !== false ? getenv('OPEN_SIS_TITLE') : 'GS Student Portal';
$openSISNotifyAddress = getenv('OPEN_SIS_NOTIFY') !== false ? getenv('OPEN_SIS_NOTIFY') : '';

// If you need other defaults for local development, set them here or provide environment variables.

?>
