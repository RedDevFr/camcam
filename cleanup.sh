#!/bin/bash
# CamPhish v2.0 - Enhanced Cleanup Script
# Removes all unnecessary files and logs while preserving important data

echo ""
echo "╔═══════════════════════════════════════╗"
echo "║   CamPhish v2.0 - Cleanup Utility     ║"
echo "╚═══════════════════════════════════════╝"
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Ask for confirmation
read -p "$(echo -e ${YELLOW}"This will remove all captured data. Continue? (y/n): "${NC})" -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}Cleanup cancelled.${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}Starting cleanup...${NC}"
echo ""

# Remove log files
echo -e "${YELLOW}[1/7]${NC} Removing log files..."
rm -f *.log
rm -f .cloudflared.log
rm -f error.log
echo -e "${GREEN}✓ Log files removed${NC}"

# Remove temporary location files
echo -e "${YELLOW}[2/7]${NC} Removing location files..."
rm -f location_*.txt
rm -f current_location.txt
rm -f current_location.bak
rm -f saved.locations.txt
echo -e "${GREEN}✓ Location files removed${NC}"

# Remove captured images
echo -e "${YELLOW}[3/7]${NC} Removing captured images..."
rm -f cam*.png
echo -e "${GREEN}✓ Image files removed${NC}"

# Remove temporary HTML/PHP files
echo -e "${YELLOW}[4/7]${NC} Removing temporary HTML/PHP files..."
rm -f index.php
rm -f index2.html
rm -f index3.html
echo -e "${GREEN}✓ Temporary files removed${NC}"

# Clean saved locations directory
echo -e "${YELLOW}[5/7]${NC} Cleaning saved locations directory..."
if [ -d "saved_locations" ]; then
    rm -rf saved_locations/*
    echo -e "${GREEN}✓ Saved locations cleaned${NC}"
else
    echo -e "${GREEN}✓ No saved locations directory found${NC}"
fi

# Clean captures directory
echo -e "${YELLOW}[6/7]${NC} Cleaning captures directory..."
if [ -d "captures" ]; then
    rm -rf captures/*
    echo -e "${GREEN}✓ Captures directory cleaned${NC}"
else
    echo -e "${GREEN}✓ No captures directory found${NC}"
fi

# Remove IP logs
echo -e "${YELLOW}[7/7]${NC} Removing IP logs..."
rm -f ip.txt
rm -f saved.ip.txt
rm -f saved.ips.txt
echo -e "${GREEN}✓ IP logs removed${NC}"

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║    Cleanup completed successfully!    ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Note: Core script files (camphish.sh, templates, etc.) were preserved.${NC}"
echo ""