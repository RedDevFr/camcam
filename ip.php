<?php
header('Content-Type: application/json');

// Enhanced IP detection function
function getClientIP() {
    $ip_keys = array(
        'HTTP_CLIENT_IP',
        'HTTP_X_FORWARDED_FOR',
        'HTTP_X_FORWARDED',
        'HTTP_X_CLUSTER_CLIENT_IP',
        'HTTP_FORWARDED_FOR',
        'HTTP_FORWARDED',
        'REMOTE_ADDR'
    );
    
    foreach ($ip_keys as $key) {
        if (array_key_exists($key, $_SERVER) === true) {
            foreach (explode(',', $_SERVER[$key]) as $ip) {
                $ip = trim($ip);
                
                // Validate IP address
                if (filter_var($ip, FILTER_VALIDATE_IP, FILTER_FLAG_NO_PRIV_RANGE | FILTER_FLAG_NO_RES_RANGE) !== false) {
                    return $ip;
                }
            }
        }
    }
    
    // Fallback to REMOTE_ADDR
    return $_SERVER['REMOTE_ADDR'] ?? 'Unknown';
}

// Get comprehensive visitor information
$ipaddress = getClientIP();
$useragent = $_SERVER['HTTP_USER_AGENT'] ?? 'Unknown';
$timestamp = date('Y-m-d H:i:s');
$referer = $_SERVER['HTTP_REFERER'] ?? 'Direct';
$accept_language = $_SERVER['HTTP_ACCEPT_LANGUAGE'] ?? 'Unknown';
$accept_encoding = $_SERVER['HTTP_ACCEPT_ENCODING'] ?? 'Unknown';
$connection = $_SERVER['HTTP_CONNECTION'] ?? 'Unknown';
$host = $_SERVER['HTTP_HOST'] ?? 'Unknown';
$request_uri = $_SERVER['REQUEST_URI'] ?? '/';

// Create unique session ID
$sessionId = md5($ipaddress . $useragent . date('YmdH'));

// Parse User Agent for better device detection
function parseUserAgent($ua) {
    $result = [
        'browser' => 'Unknown',
        'browser_version' => '',
        'os' => 'Unknown',
        'device_type' => 'Unknown',
        'device_brand' => 'Unknown'
    ];
    
    // Detect OS
    if (preg_match('/windows nt 10/i', $ua)) $result['os'] = 'Windows 10/11';
    elseif (preg_match('/windows nt 6.3/i', $ua)) $result['os'] = 'Windows 8.1';
    elseif (preg_match('/windows nt 6.2/i', $ua)) $result['os'] = 'Windows 8';
    elseif (preg_match('/windows nt 6.1/i', $ua)) $result['os'] = 'Windows 7';
    elseif (preg_match('/macintosh|mac os x ([\d_]+)/i', $ua, $match)) {
        $version = isset($match[1]) ? str_replace('_', '.', $match[1]) : '';
        $result['os'] = 'macOS ' . $version;
    }
    elseif (preg_match('/iphone os ([\d_]+)/i', $ua, $match)) {
        $result['os'] = 'iOS ' . str_replace('_', '.', $match[1]);
        $result['device_type'] = 'Mobile';
        $result['device_brand'] = 'Apple iPhone';
    }
    elseif (preg_match('/ipad.*os ([\d_]+)/i', $ua, $match)) {
        $result['os'] = 'iPadOS ' . str_replace('_', '.', $match[1]);
        $result['device_type'] = 'Tablet';
        $result['device_brand'] = 'Apple iPad';
    }
    elseif (preg_match('/android ([\d.]+)/i', $ua, $match)) {
        $result['os'] = 'Android ' . $match[1];
        $result['device_type'] = preg_match('/mobile/i', $ua) ? 'Mobile' : 'Tablet';
        
        // Detect Android device brand
        if (preg_match('/samsung/i', $ua)) $result['device_brand'] = 'Samsung';
        elseif (preg_match('/huawei/i', $ua)) $result['device_brand'] = 'Huawei';
        elseif (preg_match('/xiaomi/i', $ua)) $result['device_brand'] = 'Xiaomi';
        elseif (preg_match('/oppo/i', $ua)) $result['device_brand'] = 'Oppo';
        elseif (preg_match('/vivo/i', $ua)) $result['device_brand'] = 'Vivo';
        elseif (preg_match('/oneplus/i', $ua)) $result['device_brand'] = 'OnePlus';
        elseif (preg_match('/motorola|moto/i', $ua)) $result['device_brand'] = 'Motorola';
        elseif (preg_match('/lg/i', $ua)) $result['device_brand'] = 'LG';
        elseif (preg_match('/nokia/i', $ua)) $result['device_brand'] = 'Nokia';
        elseif (preg_match('/pixel/i', $ua)) $result['device_brand'] = 'Google Pixel';
        else $result['device_brand'] = 'Android Device';
    }
    elseif (preg_match('/linux/i', $ua)) $result['os'] = 'Linux';
    
    // Detect Browser
    if (preg_match('/edg\/([\d.]+)/i', $ua, $match)) {
        $result['browser'] = 'Microsoft Edge';
        $result['browser_version'] = $match[1];
    }
    elseif (preg_match('/chrome\/([\d.]+)/i', $ua, $match)) {
        $result['browser'] = 'Google Chrome';
        $result['browser_version'] = $match[1];
    }
    elseif (preg_match('/safari\/([\d.]+)/i', $ua, $match) && !preg_match('/chrome/i', $ua)) {
        $result['browser'] = 'Safari';
        $result['browser_version'] = $match[1];
    }
    elseif (preg_match('/firefox\/([\d.]+)/i', $ua, $match)) {
        $result['browser'] = 'Firefox';
        $result['browser_version'] = $match[1];
    }
    elseif (preg_match('/opera|opr\/([\d.]+)/i', $ua, $match)) {
        $result['browser'] = 'Opera';
        $result['browser_version'] = isset($match[1]) ? $match[1] : '';
    }
    
    // Detect device type if not set
    if ($result['device_type'] === 'Unknown') {
        if (preg_match('/mobile/i', $ua)) $result['device_type'] = 'Mobile';
        elseif (preg_match('/tablet/i', $ua)) $result['device_type'] = 'Tablet';
        else $result['device_type'] = 'Desktop';
    }
    
    return $result;
}

$ua_info = parseUserAgent($useragent);

// Format data for text file (legacy format for shell script)
$data = "IP: " . $ipaddress . "\n";
$data .= "User-Agent: " . $useragent . "\n";
$data .= "Timestamp: " . $timestamp . "\n";

// Save to ip.txt for shell script detection
$file = 'ip.txt';
file_put_contents($file, $data);

// Also save to master log
$masterData = "\n=== New Visitor ===\n";
$masterData .= "Session ID: " . $sessionId . "\n";
$masterData .= "Timestamp: " . $timestamp . "\n";
$masterData .= "IP Address: " . $ipaddress . "\n";
$masterData .= "Device: {$ua_info['device_brand']} ({$ua_info['device_type']})\n";
$masterData .= "OS: {$ua_info['os']}\n";
$masterData .= "Browser: {$ua_info['browser']} {$ua_info['browser_version']}\n";
$masterData .= "User Agent: " . $useragent . "\n";
$masterData .= "Referer: " . $referer . "\n";
$masterData .= "Language: " . $accept_language . "\n";
$masterData .= "Host: " . $host . "\n";
$masterData .= "Request URI: " . $request_uri . "\n";
$masterData .= "-------------------\n";

$masterFile = 'saved.ips.txt';
if (!file_exists($masterFile)) {
    touch($masterFile);
    chmod($masterFile, 0666);
}
file_put_contents($masterFile, $masterData, FILE_APPEND);

// Save to JSON for Dashboard
$jsonFile = 'sessions.json';
$sessions = [];

// FIX: Ensure file exists and is writable
if (!file_exists($jsonFile)) {
    file_put_contents($jsonFile, '{}');
    chmod($jsonFile, 0666);
}

try {
    $content = file_get_contents($jsonFile);
    $sessions = json_decode($content, true);
    if (!is_array($sessions)) {
        $sessions = [];
    }
} catch (Exception $e) {
    error_log("Error reading sessions.json: " . $e->getMessage());
    $sessions = [];
}

if (!isset($sessions[$sessionId])) {
    $sessions[$sessionId] = [
        'session_id' => $sessionId,
        'ip_address' => $ipaddress,
        'device_info' => $ua_info,
        'user_agent' => $useragent,
        'referer' => $referer,
        'accept_language' => $accept_language,
        'accept_encoding' => $accept_encoding,
        'host' => $host,
        'request_uri' => $request_uri,
        'first_visit' => $timestamp,
        'last_activity' => $timestamp,
        'page_views' => 1,
        'captures' => [],
        'locations' => [],
        'fingerprints' => []
    ];
} else {
    $sessions[$sessionId]['last_activity'] = $timestamp;
    $sessions[$sessionId]['page_views'] = ($sessions[$sessionId]['page_views'] ?? 0) + 1;
}

// FIX: Save with error handling
try {
    $jsonData = json_encode($sessions, JSON_PRETTY_PRINT);
    if ($jsonData === false) {
        error_log("JSON encoding error: " . json_last_error_msg());
        $jsonData = '{}';
    }
    file_put_contents($jsonFile, $jsonData);
    chmod($jsonFile, 0666);
} catch (Exception $e) {
    error_log("Error writing sessions.json: " . $e->getMessage());
}

// Return session ID and device info to frontend
echo json_encode([
    'status' => 'success',
    'session_id' => $sessionId,
    'device_info' => $ua_info,
    'timestamp' => $timestamp
]);
?>
