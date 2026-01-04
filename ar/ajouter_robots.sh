#!/bin/bash

echo "Ajout de la colonne robots.txt au tableau..."

# Créer un fichier temporaire pour stocker les statuts
> /tmp/robots_status.txt

# Pour chaque URL dans le tableau
grep -oP 'href="\K[^"]+(?=" target)' tableaux/ar.html | while read URL; do
    if [[ "$URL" =~ ^http ]]; then
        STATUS=$(bash programmes/verifier_robots.sh "$URL" 2>/dev/null || echo "INCONNU")
        echo "$URL|$STATUS" >> /tmp/robots_status.txt
        echo "  $URL -> $STATUS"
    fi
done

echo ""
echo "✓ Statuts robots.txt collectés"
echo "✓ Sauvegardés dans /tmp/robots_status.txt"
echo ""
echo "Maintenant, tu dois modifier manuellement le tableau HTML"
echo "en ajoutant une colonne <th>robots.txt</th> dans l'en-tête"
echo "et <td>STATUS</td> pour chaque ligne"
