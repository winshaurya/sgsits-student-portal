<?php
header('Content-Type: application/json');
$start = microtime(true);
$status = 'ok';
$db = 'down';
$error = null;
try {
    require_once __DIR__ . '/ConfigInc.php';
    if (function_exists('db_start')) {
        $conn = db_start();
        if ($conn && @$conn->query('SELECT 1')) {
            $db = 'up';
        } else {
            $db = 'down';
        }
    } else {
        $db = 'unknown';
    }
} catch (Throwable $e) {
    $db = 'down';
    $status = 'degraded';
    $error = $e->getMessage();
}
$time = round((microtime(true) - $start) * 1000, 2);
http_response_code($db === 'up' ? 200 : 500);
echo json_encode([
    'status' => $status,
    'db' => $db,
    'latency_ms' => $time,
    'timestamp' => gmdate('c'),
    'version' => isset($openSISVersion) ? $openSISVersion : null,
    'error' => $error,
]);
