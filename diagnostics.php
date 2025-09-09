<?php
header('Content-Type: text/plain');
require_once __DIR__.'/Data.php';
$checks = [];
$checks['DB_HOST'] = $DatabaseServer ?? '';
$checks['DB_NAME'] = $DatabaseName ?? '';
$checks['DB_USER'] = $DatabaseUsername ?? '';
$checks['DB_PORT'] = $DatabasePort ?? '';
$checks['PHP_VERSION'] = PHP_VERSION;
$checks['EXTENSIONS'] = array_intersect(['mysqli','pdo_mysql','exif','bcmath','gd'], get_loaded_extensions());
$can_connect = false;
$err = null;
if ($DatabaseServer && $DatabaseUsername && $DatabaseName) {
    $mysqli = @new mysqli($DatabaseServer,$DatabaseUsername,$DatabasePassword,$DatabaseName,(int)$DatabasePort);
    if ($mysqli && !$mysqli->connect_errno) {
        $can_connect = true;
    } else {
        $err = $mysqli ? $mysqli->connect_error : 'unknown';
    }
}
foreach ($checks as $k=>$v) {
    if (is_array($v)) $v = implode(',', $v);
    echo $k.': '.$v."\n";
}

echo 'DB_CAN_CONNECT: '.($can_connect ? 'yes':'no')."\n";
if ($err) echo 'DB_ERROR: '.$err."\n";
if (!$can_connect) {
    echo "\nTroubleshooting:\n";
    echo "1. Verify env vars in Render (DB_HOST/DB_NAME/DB_USER/DB_PASS or DB_URL).\n";
    echo "2. Ensure the MySQL instance allows connections from Render IPs.\n";
    echo "3. If using internal MariaDB, set MYSQL_ROOT_PASSWORD and matching DB_* vars or rely on 'localhost' with root.\n";
}
