<?php
header('Content-Type: application/json');

$input = file_get_contents('php://input');
$data = json_decode($input, true);

if (empty($data) || !isset($data['fingerprint'])) {
    echo json_encode(['status' => 'error', 'message' => 'Invalid fingerprint data']);
    exit;
}

try {
    $sessionId = $data['session_id'] ?? null;
    $fingerprint = $data['fingerprint'];
    
    // Extract readable device information
    $deviceInfo = extractDeviceInfo($fingerprint);
    
    // Update sessions.json
    $jsonFile = 'sessions.json';
    if (file_exists($jsonFile) && $sessionId) {
        $sessions = json_decode(file_get_contents($jsonFile), true) ?? [];
        
        if (isset($sessions[$sessionId])) {
            $sessions[$sessionId]['fingerprint'] = [
                'timestamp' => date('Y-m-d H:i:s'),
                'fingerprint_id' => $fingerprint['id'] ?? 'unknown',
                'confidence' => $fingerprint['confidence'] ?? 0,
                'device_summary' => $deviceInfo,
                'raw_data' => $fingerprint
            ];
            $sessions[$sessionId]['last_activity'] = date('Y-m-d H:i:s');
            
            file_put_contents($jsonFile, json_encode($sessions, JSON_PRETTY_PRINT));
        }
    }
    
    // Save to fingerprints log file
    $logData = "\n=== Device Fingerprint Captured ===\n";
    $logData .= "Timestamp: " . date('Y-m-d H:i:s') . "\n";
    $logData .= "Session ID: " . $sessionId . "\n";
    $logData .= "Fingerprint ID: " . ($fingerprint['id'] ?? 'unknown') . "\n";
    $logData .= "Confidence Score: " . ($fingerprint['confidence'] ?? 0) . "%\n\n";
    $logData .= "=== Device Details ===\n";
    $logData .= $deviceInfo;
    $logData .= "\n" . str_repeat("-", 60) . "\n";
    
    $logFile = 'fingerprints.log';
    file_put_contents($logFile, $logData, FILE_APPEND);
    
    echo json_encode([
        'status' => 'success',
        'session_id' => $sessionId,
        'device_info' => $deviceInfo
    ]);
    
} catch (Exception $e) {
    echo json_encode(['status' => 'error', 'message' => $e->getMessage()]);
}

function extractDeviceInfo($fp) {
    $info = "";
    
    // Browser Information
    if (isset($fp['browser'])) {
        $browser = $fp['browser'];
        $info .= "Browser: {$browser['name']} {$browser['version']}\n";
        $info .= "Engine: {$browser['engine']}\n";
    }
    
    // Operating System (from basic info)
    if (isset($fp['basic']['platform'])) {
        $info .= "Platform: {$fp['basic']['platform']}\n";
    }
    
    // Screen Information
    if (isset($fp['screen'])) {
        $screen = $fp['screen'];
        $info .= "Screen: {$screen['width']}x{$screen['height']} ({$screen['color_depth']} bit)\n";
        $info .= "Device Pixel Ratio: {$screen['device_pixel_ratio']}\n";
        $info .= "Orientation: {$screen['orientation']}\n";
    }
    
    // Hardware
    if (isset($fp['hardware'])) {
        $hw = $fp['hardware'];
        $info .= "CPU Cores: {$hw['cpu_cores']}\n";
        $info .= "Device Memory: {$hw['device_memory']} GB\n";
        $info .= "Mobile Device: " . ($hw['mobile'] ? 'Yes' : 'No') . "\n";
        $info .= "Touch Points: {$hw['max_touch_points']}\n";
    }
    
    // WebGL (GPU Info)
    if (isset($fp['webgl']) && $fp['webgl']['supported']) {
        $webgl = $fp['webgl'];
        $info .= "\nGPU Information:\n";
        $info .= "  Vendor: {$webgl['vendor']}\n";
        $info .= "  Renderer: {$webgl['renderer']}\n";
    }
    
    // Network
    if (isset($fp['network']) && !isset($fp['network']['status'])) {
        $net = $fp['network'];
        $info .= "\nNetwork:\n";
        $info .= "  Type: {$net['effective_type']}\n";
        $info .= "  Downlink: {$net['downlink']} Mbps\n";
        $info .= "  RTT: {$net['rtt']} ms\n";
    }
    
    // Media Devices
    if (isset($fp['media']) && !isset($fp['media']['status'])) {
        $media = $fp['media'];
        $info .= "\nMedia Devices:\n";
        $info .= "  Cameras: {$media['video_input']}\n";
        $info .= "  Microphones: {$media['audio_input']}\n";
        $info .= "  Speakers: {$media['audio_output']}\n";
    }
    
    // Fonts
    if (isset($fp['fonts'])) {
        $info .= "\nInstalled Fonts: {$fp['fonts']['count']}\n";
    }
    
    // Timezone
    if (isset($fp['timezone'])) {
        $tz = $fp['timezone'];
        $info .= "\nTimezone: {$tz['timezone']}\n";
        $info .= "Locale: {$tz['locale']}\n";
    }
    
    // Battery (if available)
    if (isset($fp['battery']) && $fp['battery']['supported']) {
        $bat = $fp['battery'];
        $status = $bat['charging'] ? 'Charging' : 'Discharging';
        $info .= "\nBattery: {$bat['level']}% ({$status})\n";
    }
    
    // Languages
    if (isset($fp['basic']['languages'])) {
        $langs = is_array($fp['basic']['languages']) ? implode(', ', $fp['basic']['languages']) : $fp['basic']['languages'];
        $info .= "\nLanguages: {$langs}\n";
    }
    
    return $info;
}
?>