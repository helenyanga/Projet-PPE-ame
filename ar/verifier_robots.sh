#!/bin/bash

# Vérifier robots.txt pour une URL
# Usage: verifier_robots.sh <URL>

if [ $# -ne 1 ]; then
    echo "Usage: $0 <URL>"
    exit 1
fi

URL=$1

# Extraire le domaine
DOMAINE=$(echo "$URL" | sed -E 's|^https?://([^/]+).*|\1|')
ROBOTS_URL="https://${DOMAINE}/robots.txt"

# Télécharger robots.txt
ROBOTS_CONTENT=$(curl -s -L "$ROBOTS_URL" 2>/dev/null)

if [ -z "$ROBOTS_CONTENT" ]; then
    echo "INCONNU"  # Pas de robots.txt
    exit 0
fi

# Vérifier si on peut scraper
# Chercher "Disallow: /"
if echo "$ROBOTS_CONTENT" | grep -q "Disallow: /"; then
    # Vérifier si c'est pour tous les User-agents
    if echo "$ROBOTS_CONTENT" | grep -B5 "Disallow: /" | grep -q "User-agent: \*"; then
        echo "INTERDIT"
    else
        echo "LIMITE"
    fi
else
    echo "AUTORISE"
fi
