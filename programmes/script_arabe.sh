#!/bin/bash

# Script pour analyser le mot "âme" en arabe avec TOKENISATION
# Deux graphies : روح (rouh) et نفس (nafs)

# Vérifier les arguments
if [ $# -ne 2 ]; then
    echo "Usage: $0 <fichier_urls> <mot_arabe>" >&2
    echo "Exemple: $0 URLs/ar-rouh.txt 'روح'" >&2
    exit 1
fi

FICHIER_URLS=$1
MOT_RECHERCHE=$2

# Nom de base pour les fichiers (ex: ar-rouh, ar-nafs)
BASENAME=$(basename "$FICHIER_URLS" .txt)

# Créer les dossiers nécessaires
mkdir -p aspirations
mkdir -p dumps-text
mkdir -p tokens
mkdir -p contextes
mkdir -p concordances
mkdir -p tableaux

# Vérifier que le script Python existe
if [ ! -f "programmes/tokenisation.py" ]; then
    echo "ERREUR: Le script programmes/tokenisation.py n'existe pas !"
    exit 1
fi

# Début du tableau HTML
cat > "tableaux/${BASENAME}.html" << EOF
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>تحليل كلمة "$MOT_RECHERCHE"</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bulma@1.0.4/css/bulma.min.css">
    <style>
        body { direction: rtl; }
        .table { font-family: Arial, sans-serif; }
        .has-background-success-light { background-color: #d4edda; }
        .has-background-warning-light { background-color: #fff3cd; }
        .tag { margin: 2px; }
    </style>
</head>
<body>
    <section class="section">
        <div class="container">
            <h1 class="title">تحليل كلمة "$MOT_RECHERCHE"</h1>
            <p class="subtitle">تحليل صرفي ونحوي</p>
            <table class="table is-striped is-fullwidth is-bordered">
                <thead>
                    <tr>
                        <th>رقم</th>
                        <th>الرابط</th>
                        <th>كود HTTP</th>
                        <th>الترميز</th>
                        <th>عدد التكرارات</th>
                        <th>عدد الكلمات</th>
                        <th>الصفحة HTML</th>
                        <th>النص</th>
                        <th>الكلمات المقطعة</th>
                        <th>المتلازمات</th>
                    </tr>
                </thead>
                <tbody>
EOF

NUMERO_LIGNE=1

while read -r URL;
do
    echo "========================================="
    echo "Traitement URL $NUMERO_LIGNE: $URL"
    echo "========================================="
    
    # Noms des fichiers
    FICHIER_HTML="aspirations/${BASENAME}-${NUMERO_LIGNE}.html"
    FICHIER_TEXTE="dumps-text/${BASENAME}-${NUMERO_LIGNE}.txt"
    FICHIER_TOKENS="tokens/${BASENAME}-${NUMERO_LIGNE}.txt"
    FICHIER_CONTEXTE="contextes/${BASENAME}-${NUMERO_LIGNE}.txt"
    FICHIER_CONCORDANCE="concordances/${BASENAME}-${NUMERO_LIGNE}.html"
    
    # 1. Télécharger la page
    echo "1. Téléchargement..."
    HTTP_CODE=$(curl -L -s -o "$FICHIER_HTML" -w "%{http_code}" "$URL")
    
    # 2. Vérifier le code HTTP
    if [ "$HTTP_CODE" = "200" ]; then
        echo "✓ Téléchargement réussi (HTTP $HTTP_CODE)"
        
        # 3. Détecter l'encodage
        echo "2. Détection de l'encodage..."
        ENCODAGE=$(file -b --mime-encoding "$FICHIER_HTML")
        echo "   Encodage détecté: $ENCODAGE"
        
        # 4. Extraire le texte avec lynx
        echo "3. Extraction du texte..."
        if [ "$ENCODAGE" = "utf-8" ] || [ "$ENCODAGE" = "us-ascii" ]; then
            lynx -dump -nolist -assume_charset=utf-8 -display_charset=utf-8 "$FICHIER_HTML" > "$FICHIER_TEXTE" 2>/dev/null
        else
            # Convertir en UTF-8 d'abord
            TEMP_FILE="${FICHIER_HTML}.utf8"
            iconv -f "$ENCODAGE" -t UTF-8 "$FICHIER_HTML" > "$TEMP_FILE" 2>/dev/null
            lynx -dump -nolist -assume_charset=utf-8 -display_charset=utf-8 "$TEMP_FILE" > "$FICHIER_TEXTE" 2>/dev/null
            rm -f "$TEMP_FILE"
        fi
        
        # 5. TOKENISATION avec Python
        echo "4. Tokenisation..."
        if [ -f "$FICHIER_TEXTE" ] && [ -s "$FICHIER_TEXTE" ]; then
            python3 programmes/tokenisation.py "$FICHIER_TEXTE" "$MOT_RECHERCHE" "$FICHIER_TOKENS" "$FICHIER_CONTEXTE" 2>/dev/null
            
            if [ $? -eq 0 ]; then
                echo "✓ Tokenisation réussie"
                
                # Lire les résultats de la tokenisation
                if [ -f "${FICHIER_TOKENS}.stats" ]; then
                    source "${FICHIER_TOKENS}.stats"
                    OCCURRENCES=$NB_OCCURRENCES
                    NB_TOKENS=$NB_TOTAL_TOKENS
                else
                    OCCURRENCES=0
                    NB_TOKENS=0
                fi
            else
                echo "✗ Erreur lors de la tokenisation"
                OCCURRENCES=0
                NB_TOKENS=0
            fi
        else
            echo "✗ Fichier texte vide ou inexistant"
            OCCURRENCES=0
            NB_TOKENS=0
        fi
        
        echo "   Occurrences trouvées: $OCCURRENCES"
        echo "   Nombre total de tokens: $NB_TOKENS"
        
        # 6. Créer le concordancier HTML
        echo "5. Création du concordancier..."
        if [ -f "$FICHIER_CONTEXTE" ] && [ $OCCURRENCES -gt 0 ]; then
            cat > "$FICHIER_CONCORDANCE" << CONCORD_EOF
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>المتلازمات اللفظية - $MOT_RECHERCHE</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bulma@1.0.4/css/bulma.min.css">
    <style>
        body { direction: rtl; font-family: Arial, sans-serif; }
        .contexte { margin: 15px 0; padding: 15px; background: #f9f9f9; border-right: 4px solid #3273dc; }
        .contexte-gauche { color: #666; }
        .mot-cible { background: #ffeb3b; font-weight: bold; color: #c62828; padding: 2px 4px; }
        .contexte-droit { color: #666; }
    </style>
</head>
<body>
    <section class="section">
        <div class="container">
            <h1 class="title">المتلازمات اللفظية لكلمة "$MOT_RECHERCHE"</h1>
            <div class="box">
                <p><strong>الرابط الأصلي:</strong> <a href="$URL" target="_blank">$URL</a></p>
                <p><strong>عدد التكرارات:</strong> $OCCURRENCES</p>
            </div>
CONCORD_EOF
            
            # Lire les contextes depuis le fichier Python
            if [ -f "$FICHIER_CONTEXTE" ]; then
                while IFS='|' read -r gauche mot droit; do
                    echo "            <div class=\"contexte\">" >> "$FICHIER_CONCORDANCE"
                    echo "                <span class=\"contexte-gauche\">$gauche</span>" >> "$FICHIER_CONCORDANCE"
                    echo "                <span class=\"mot-cible\">$mot</span>" >> "$FICHIER_CONCORDANCE"
                    echo "                <span class=\"contexte-droit\">$droit</span>" >> "$FICHIER_CONCORDANCE"
                    echo "            </div>" >> "$FICHIER_CONCORDANCE"
                done < "$FICHIER_CONTEXTE"
            fi
            
            echo "        </div>" >> "$FICHIER_CONCORDANCE"
            echo "    </section>" >> "$FICHIER_CONCORDANCE"
            echo "</body></html>" >> "$FICHIER_CONCORDANCE"
            
            echo "✓ Concordancier créé"
        else
            echo "- Pas de concordancier (0 occurrence)"
            FICHIER_CONCORDANCE=""
        fi
        
        # 7. Ajouter la ligne au tableau
        TR_CLASS=""
        if [ $OCCURRENCES -gt 0 ]; then
            TR_CLASS="has-background-success-light"
        else
            TR_CLASS="has-background-warning-light"
        fi
        
        echo "                <tr class=\"$TR_CLASS\">" >> "tableaux/${BASENAME}.html"
        echo "                    <td><strong>$NUMERO_LIGNE</strong></td>" >> "tableaux/${BASENAME}.html"
        echo "                    <td><a href=\"$URL\" target=\"_blank\">رابط</a></td>" >> "tableaux/${BASENAME}.html"
        echo "                    <td><span class=\"tag is-success\">$HTTP_CODE</span></td>" >> "tableaux/${BASENAME}.html"
        echo "                    <td>$ENCODAGE</td>" >> "tableaux/${BASENAME}.html"
        echo "                    <td><strong>$OCCURRENCES</strong></td>" >> "tableaux/${BASENAME}.html"
        echo "                    <td>$NB_TOKENS</td>" >> "tableaux/${BASENAME}.html"
        echo "                    <td><a href=\"../$FICHIER_HTML\">HTML</a></td>" >> "tableaux/${BASENAME}.html"
        echo "                    <td><a href=\"../$FICHIER_TEXTE\">نص</a></td>" >> "tableaux/${BASENAME}.html"
        echo "                    <td><a href=\"../$FICHIER_TOKENS\">كلمات</a></td>" >> "tableaux/${BASENAME}.html"
        if [ -n "$FICHIER_CONCORDANCE" ] && [ $OCCURRENCES -gt 0 ]; then
            echo "                    <td><a href=\"../$FICHIER_CONCORDANCE\" class=\"button is-small is-info\">عرض</a></td>" >> "tableaux/${BASENAME}.html"
        else
            echo "                    <td>-</td>" >> "tableaux/${BASENAME}.html"
        fi
        echo "                </tr>" >> "tableaux/${BASENAME}.html"
        
    else
        echo "✗ Erreur HTTP $HTTP_CODE pour $URL"
        # Ligne d'erreur dans le tableau
        echo "                <tr class=\"has-background-danger-light\">" >> "tableaux/${BASENAME}.html"
        echo "                    <td>$NUMERO_LIGNE</td>" >> "tableaux/${BASENAME}.html"
        echo "                    <td><a href=\"$URL\">رابط</a></td>" >> "tableaux/${BASENAME}.html"
        echo "                    <td><span class=\"tag is-danger\">$HTTP_CODE</span></td>" >> "tableaux/${BASENAME}.html"
        echo "                    <td colspan=\"7\">خطأ في التحميل</td>" >> "tableaux/${BASENAME}.html"
        echo "                </tr>" >> "tableaux/${BASENAME}.html"
    fi
    
    NUMERO_LIGNE=$((NUMERO_LIGNE + 1))
    echo ""
    
done < "$FICHIER_URLS"

# Fin du tableau HTML
cat >> "tableaux/${BASENAME}.html" << EOF
                </tbody>
            </table>
            <div class="notification is-info">
                <p><strong>ملاحظة:</strong> تم استخدام التحليل الصرفي التلقائي (Tokenization) باستخدام CAMeL Tools</p>
            </div>
        </div>
    </section>
</body>
</html>
EOF

echo "========================================="
echo "✓ Traitement terminé !"
echo "Voir le résultat: tableaux/${BASENAME}.html"
echo "========================================="
