#!/bin/bash
# Script de Diagnostic CamPhish - Problème d'affichage

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║        Diagnostic CamPhish - Problème d'Affichage        ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

# 1. Vérifier PHP
echo -e "${YELLOW}[1/8] Vérification de PHP...${NC}"
if command -v php &> /dev/null; then
    PHP_VERSION=$(php -v | head -n 1)
    echo -e "${GREEN}✓ PHP installé : ${PHP_VERSION}${NC}"
else
    echo -e "${RED}✗ PHP n'est pas installé !${NC}"
    echo -e "${YELLOW}   Installez PHP : apt-get install php${NC}"
    exit 1
fi

# 2. Vérifier les fichiers essentiels
echo -e "${YELLOW}[2/8] Vérification des fichiers...${NC}"
files=("camphish.sh" "template.php" "ip.php" "location.php" "post.php" "fingerprint.php")
missing=0
for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓ $file existe${NC}"
    else
        echo -e "${RED}✗ $file manquant${NC}"
        missing=1
    fi
done

if [ $missing -eq 1 ]; then
    echo -e "${RED}Des fichiers essentiels sont manquants !${NC}"
fi

# 3. Vérifier les templates
echo -e "${YELLOW}[3/8] Vérification des templates...${NC}"
templates=("festivalwishes.html" "LiveYTTV.html" "OnlineMeeting.html")
for template in "${templates[@]}"; do
    if [ -f "$template" ]; then
        # Vérifier si le template contient du code PHP avec echo
        if grep -q "echo '" "$template" 2>/dev/null || grep -q 'echo "' "$template" 2>/dev/null; then
            echo -e "${RED}✗ $template contient des 'echo' PHP - PROBLÈME !${NC}"
        else
            echo -e "${GREEN}✓ $template OK (HTML pur)${NC}"
        fi
    fi
done

# 4. Vérifier template.php
echo -e "${YELLOW}[4/8] Analyse de template.php...${NC}"
if [ -f "template.php" ]; then
    if grep -q "echo '" template.php || grep -q 'echo "' template.php; then
        echo -e "${RED}✗ template.php contient 'echo' - PROBLÈME IDENTIFIÉ !${NC}"
        echo -e "${YELLOW}   Ce fichier génère du HTML avec echo au lieu de l'écrire directement${NC}"
        PROBLEM_FOUND=1
    else
        echo -e "${GREEN}✓ template.php OK (pas d'echo)${NC}"
        PROBLEM_FOUND=0
    fi
    
    # Afficher les 10 premières lignes
    echo -e "${BLUE}   Premières lignes de template.php :${NC}"
    head -10 template.php | sed 's/^/   /'
fi

# 5. Vérifier index.php (s'il existe)
echo -e "${YELLOW}[5/8] Vérification de index.php...${NC}"
if [ -f "index.php" ]; then
    if grep -q "echo '" index.php || grep -q 'echo "' index.php; then
        echo -e "${RED}✗ index.php contient 'echo' - Le problème persiste !${NC}"
        echo -e "${YELLOW}   Le fichier généré contient toujours du code PHP avec echo${NC}"
    else
        echo -e "${GREEN}✓ index.php semble correct${NC}"
    fi
    
    echo -e "${BLUE}   Premières lignes de index.php :${NC}"
    head -10 index.php | sed 's/^/   /'
else
    echo -e "${YELLOW}⚠ index.php n'existe pas encore (normal si CamPhish n'a pas été lancé)${NC}"
fi

# 6. Vérifier index2.html
echo -e "${YELLOW}[6/8] Vérification de index2.html...${NC}"
if [ -f "index2.html" ]; then
    echo -e "${GREEN}✓ index2.html existe${NC}"
    
    # Vérifier si c'est vraiment du HTML
    if head -5 index2.html | grep -q "<!DOCTYPE html>"; then
        echo -e "${GREEN}✓ index2.html contient du HTML valide${NC}"
    else
        echo -e "${RED}✗ index2.html ne commence pas par <!DOCTYPE html>${NC}"
    fi
    
    echo -e "${BLUE}   Premières lignes de index2.html :${NC}"
    head -5 index2.html | sed 's/^/   /'
else
    echo -e "${YELLOW}⚠ index2.html n'existe pas encore${NC}"
fi

# 7. Tester le serveur PHP
echo -e "${YELLOW}[7/8] Test du serveur PHP...${NC}"
if [ -f "index.php" ]; then
    echo -e "${BLUE}   Tentative de rendu de index.php avec PHP...${NC}"
    
    # Créer un fichier de test
    echo '<?php echo "PHP fonctionne correctement"; ?>' > test_php.php
    
    OUTPUT=$(php test_php.php 2>&1)
    if [ "$OUTPUT" = "PHP fonctionne correctement" ]; then
        echo -e "${GREEN}✓ PHP peut exécuter du code correctement${NC}"
    else
        echo -e "${RED}✗ Problème d'exécution PHP : $OUTPUT${NC}"
    fi
    
    rm -f test_php.php
    
    # Tester index.php
    echo -e "${BLUE}   Test de rendu de index.php...${NC}"
    INDEX_OUTPUT=$(php index.php 2>&1 | head -20)
    
    if echo "$INDEX_OUTPUT" | grep -q "<!DOCTYPE html>"; then
        echo -e "${GREEN}✓ index.php génère du HTML${NC}"
    elif echo "$INDEX_OUTPUT" | grep -q "echo"; then
        echo -e "${RED}✗ index.php affiche du code PHP brut !${NC}"
        echo -e "${YELLOW}   Voici ce qui est généré :${NC}"
        echo "$INDEX_OUTPUT" | head -5 | sed 's/^/   /'
    fi
fi

# 8. Diagnostic du problème
echo ""
echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                    DIAGNOSTIC FINAL                       ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

if [ "$PROBLEM_FOUND" -eq 1 ]; then
    echo -e "${RED}❌ PROBLÈME IDENTIFIÉ :${NC}"
    echo ""
    echo -e "${YELLOW}Le fichier template.php utilise 'echo' pour générer le HTML.${NC}"
    echo -e "${YELLOW}Quand camphish.sh fait :${NC}"
    echo -e "${BLUE}   sed 's+forwarding_link+'$link'+g' template.php > index.php${NC}"
    echo ""
    echo -e "${YELLOW}Il copie le code PHP avec 'echo' dans index.php, ce qui fait${NC}"
    echo -e "${YELLOW}que le navigateur affiche le code source au lieu du HTML rendu.${NC}"
    echo ""
    echo -e "${GREEN}✅ SOLUTION :${NC}"
    echo ""
    echo -e "1. ${BLUE}Remplacez template.php par la version corrigée${NC}"
    echo -e "   ${YELLOW}bash fix_template.sh${NC}"
    echo ""
    echo -e "2. ${BLUE}Ou modifiez manuellement template.php pour écrire le HTML directement${NC}"
    echo -e "   ${YELLOW}sans utiliser echo${NC}"
    echo ""
else
    echo -e "${YELLOW}⚠️  AUTRES CAUSES POSSIBLES :${NC}"
    echo ""
    echo -e "1. ${BLUE}Le serveur PHP n'est pas démarré correctement${NC}"
    echo -e "   Solution : Redémarrez camphish.sh"
    echo ""
    echo -e "2. ${BLUE}Le lien ngrok/cloudflare n'est pas correct${NC}"
    echo -e "   Solution : Vérifiez que le lien contient bien votre domaine"
    echo ""
    echo -e "3. ${BLUE}Le navigateur affiche le code source${NC}"
    echo -e "   Solution : Vérifiez avec curl :"
    echo -e "   ${YELLOW}curl -L [votre_lien_ngrok]/index.php | head -20${NC}"
    echo ""
    echo -e "4. ${BLUE}Les fichiers HTML sont servis comme texte brut${NC}"
    echo -e "   Solution : Ajoutez un fichier .htaccess"
    echo ""
fi

# Recommandations
echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                    RECOMMANDATIONS                        ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${YELLOW}Pour tester si le problème persiste :${NC}"
echo ""
echo -e "1. ${GREEN}Lancez CamPhish :${NC}"
echo -e "   ${BLUE}bash camphish.sh${NC}"
echo ""
echo -e "2. ${GREEN}Testez le lien généré dans votre navigateur${NC}"
echo ""
echo -e "3. ${GREEN}Si vous voyez du code source, faites Ctrl+U pour voir le source${NC}"
echo -e "   ${YELLOW}Si vous voyez du PHP (<?php echo...), le problème vient de template.php${NC}"
echo -e "   ${YELLOW}Si vous voyez du HTML normal, le problème vient du serveur${NC}"
echo ""
echo -e "4. ${GREEN}Testez également avec curl :${NC}"
echo -e "   ${BLUE}curl [lien_ngrok]/index.php | head -30${NC}"
echo ""

echo -e "${BLUE}Fichiers de log créés :${NC}"
echo -e "   diagnostic_report.txt - Ce rapport complet"
echo ""

# Sauvegarder le rapport
{
    echo "=== Rapport de Diagnostic CamPhish ==="
    echo "Date: $(date)"
    echo ""
    echo "PHP Version: $(php -v | head -n 1)"
    echo ""
    echo "Fichiers présents:"
    ls -la *.php *.html 2>/dev/null
    echo ""
    echo "Contenu de template.php (20 premières lignes):"
    head -20 template.php 2>/dev/null
    echo ""
    echo "Contenu de index.php (20 premières lignes):"
    head -20 index.php 2>/dev/null
} > diagnostic_report.txt

echo -e "${GREEN}✓ Rapport sauvegardé dans diagnostic_report.txt${NC}"
echo ""