#!/bin/bash

# Script pour analyser le mot "âme" en arabe - VERSION UNIFIÉE
# Un seul tableau pour les deux graphies : روح et نفس

# Vérifier les arguments
if [ $# -ne 3 ]; then
    echo "Usage: $0 <fichier_urls> <mot_arabe> <graphie_label>" >&2
    echo "Exemple: $0 URLs/ar-rouh.txt 'روح' 'rouh'" >&2
    exit 1
fi

FICHIER_URLS=$1
MOT_RECHERCHE=$2
GRAPHIE=$3  # "rouh" ou "nafs" pour nommer les fichiers

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

# Fichier tableau unique
TABLEAU="tableaux/ar.html"

# Si le tableau n'existe pas, créer l'en-tête
if [ ! -f "$TABLEAU" ]; then
    cat > "$TABLEAU" << EOF
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>تحليل كلمة "الروح" - Analyse du mot "Âme"</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bulma@1.0.4/css/bulma.min.css">
    <style>
        body { direction: rtl; }
        .table { font-family: Arial, sans-serif; }
        .graphie-rouh { background-color: #e3f2fd; }
        .graphie-nafs { background-color: #fff3e0; }
        .has-background-success-light { background-color: #d4edda; }
        .has-background-warning-light { background-color: #fff3cd; }
        .tag { margin: 2px; }
    </style>
</head>
<body>
    <section class="hero is-info">
        <div class="hero-body">
            <div class="container has-text-centered">
                <h1 class="title">تحليل كلمة "الروح"</h1>
                <h2 class="subtitle">Analyse du mot "Âme" en arabe</h2>
                <p>الرسمان: روح و نفس</p>
            </div>
        </div>
    </section>
    
    <section class="section">
        <div class="container">
            <div class="notification is-info is-light">
                <strong>ملاحظة:</strong> هذا الجدول يحتوي على تحليل الرسمين (روح و نفس) معاً
            </div>
            
            <table class="table is-striped is-fullwidth is-bordered">
                <thead>
                    <tr>
                        <th>رقم</th>
                        <th>الرسم</th>
                        <th>الرابط</th>
                        <th>كود HTTP</th>
                        <th>الترميز</th>
                        <th>التكرارات</th>
                        <th>عدد الكلمات</th>
                        <th>HTML</th>
                        <th>النص</th>
                        <th>الكلمات</th>
                        <th>المتلازمات</th>
                    </tr>
                </thead>
                <tbody>
EOF
fi

# Compter le nombre de lignes déjà dans le tableau pour continuer la numérotation
NUMERO_LIGNE=$(grep -c "<tr class=" "$TABLEAU" 2>/dev/null || echo 0)
NUMERO_LIGNE=$((NUMERO_LIGNE + 1))

# Traiter chaque URL
while read -r URL;
do
    echo "========================================="
    echo "Traitement URL $NUMERO_LIGNE ($GRAPHIE): $URL"
    echo "========================================="
    
    # Noms des fichiers avec préfixe de graphie
    FICHIER_HTML="aspirations/ar-${GRAPHIE}-${NUMERO_LIGNE}.html"
    FICHIER_TEXTE="dumps-text/ar-${GRAPHIE}-${NUMERO_LIGNE}.txt"
    FICHIER_TOKENS="tokens/ar-${GRAPHIE}-${NUMERO_LIGNE}.txt"
    FICHIER_CONTEXTE="contextes/ar-${GRAPHIE}-${NUMERO_LIGNE}.txt"
    FICHIER_CONCORDANCE="concordances/ar-${GRAPHIE}-${NUMERO_LIGNE}.html"
    
    # 1. Télécharger
    echo "1. Téléchargement..."
    HTTP_CODE=$(curl -L -s -o "$FICHIER_HTML" -w "%{http_code}" "$URL")
    
    if [ "$HTTP_CODE" = "200" ]; then
        echo "✓ Téléchargement réussi"
        
        # 2. Détecter encodage
        ENCODAGE=$(file -b --mime-encoding "$FICHIER_HTML")
        
        # 3. Extraire texte
        echo "2. Extraction du texte..."
        if [ "$ENCODAGE" = "utf-8" ] || [ "$ENCODAGE" = "us-ascii" ]; then
            lynx -dump -nolist -assume_charset=utf-8 -display_charset=utf-8 "$FICHIER_HTML" > "$FICHIER_TEXTE" 2>/dev/null
        else
            TEMP_FILE="${FICHIER_HTML}.utf8"
            iconv -f "$ENCODAGE" -t UTF-8 "$FICHIER_HTML" > "$TEMP_FILE" 2>/dev/null
            lynx -dump -nolist -assume_charset=utf-8 -display_charset=utf-8 "$TEMP_FILE" > "$FICHIER_TEXTE" 2>/dev/null
            rm -f "$TEMP_FILE"
        fi
        
        # 4. Tokenisation
        echo "3. Tokenisation..."
        if [ -f "$FICHIER_TEXTE" ] && [ -s "$FICHIER_TEXTE" ]; then
            python3 programmes/tokenisation.py "$FICHIER_TEXTE" "$MOT_RECHERCHE" "$FICHIER_TOKENS" "$FICHIER_CONTEXTE" 2>/dev/null
            
            if [ $? -eq 0 ] && [ -f "${FICHIER_TOKENS}.stats" ]; then
                source "${FICHIER_TOKENS}.stats"
                OCCURRENCES=$NB_OCCURRENCES
                NB_TOKENS=$NB_TOTAL_TOKENS
            else
                OCCURRENCES=0
                NB_TOKENS=0
            fi
        else
            OCCURRENCES=0
            NB_TOKENS=0
        fi
        
        echo "   Occurrences: $OCCURRENCES | Tokens: $NB_TOKENS"
        
        # 5. Concordancier
        if [ -f "$FICHIER_CONTEXTE" ] && [ $OCCURRENCES -gt 0 ]; then
            cat > "$FICHIER_CONCORDANCE" << CONCORD_EOF
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <title>المتلازمات - $MOT_RECHERCHE</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bulma@1.0.4/css/bulma.min.css">
    <style>
        body { direction: rtl; }
        .contexte { margin: 15px 0; padding: 15px; background: #f9f9f9; border-right: 4px solid #3273dc; }
        .mot-cible { background: #ffeb3b; font-weight: bold; color: #c62828; }
    </style>
</head>
<body>
    <section class="section">
        <div class="container">
            <h1 class="title">المتلازمات اللفظية - $MOT_RECHERCHE</h1>
            <p><a href="$URL">الرابط الأصلي</a></p>
CONCORD_EOF
            
            while IFS='|' read -r gauche mot droit; do
                echo "            <div class=\"contexte\">" >> "$FICHIER_CONCORDANCE"
                echo "                <span>$gauche</span>" >> "$FICHIER_CONCORDANCE"
                echo "                <span class=\"mot-cible\">$mot</span>" >> "$FICHIER_CONCORDANCE"
                echo "                <span>$droit</span>" >> "$FICHIER_CONCORDANCE"
                echo "            </div>" >> "$FICHIER_CONCORDANCE"
            done < "$FICHIER_CONTEXTE"
            
            echo "        </div></section></body></html>" >> "$FICHIER_CONCORDANCE"
        fi
        
        # 6. Ajouter au tableau (temporairement dans un fichier)
        TEMP_ROW="/tmp/row_$$.html"
        
        TR_CLASS="graphie-${GRAPHIE}"
        if [ $OCCURRENCES -gt 0 ]; then
            TR_CLASS="$TR_CLASS has-background-success-light"
        fi
        
        cat > "$TEMP_ROW" << EOF
                <tr class="$TR_CLASS">
                    <td><strong>$NUMERO_LIGNE</strong></td>
                    <td><span class="tag is-info">$MOT_RECHERCHE</span></td>
                    <td><a href="$URL" target="_blank">رابط</a></td>
                    <td><span class="tag is-success">$HTTP_CODE</span></td>
                    <td>$ENCODAGE</td>
                    <td><strong>$OCCURRENCES</strong></td>
                    <td>$NB_TOKENS</td>
                    <td><a href="../$FICHIER_HTML">HTML</a></td>
                    <td><a href="../$FICHIER_TEXTE">نص</a></td>
                    <td><a href="../$FICHIER_TOKENS">كلمات</a></td>
EOF
        
        if [ -f "$FICHIER_CONCORDANCE" ] && [ $OCCURRENCES -gt 0 ]; then
            echo "                    <td><a href=\"../$FICHIER_CONCORDANCE\" class=\"button is-small is-info\">عرض</a></td>" >> "$TEMP_ROW"
        else
            echo "                    <td>-</td>" >> "$TEMP_ROW"
        fi
        
        echo "                </tr>" >> "$TEMP_ROW"
        
        # Insérer la ligne avant </tbody>
        sed -i "/<\/tbody>/i $(cat $TEMP_ROW | tr '\n' ' ')" "$TABLEAU"
        rm -f "$TEMP_ROW"
        
    else
        echo "✗ Erreur HTTP $HTTP_CODE"
    fi
    
    NUMERO_LIGNE=$((NUMERO_LIGNE + 1))
    echo ""
    
done < "$FICHIER_URLS"

echo "✓ Traitement terminé pour $GRAPHIE"
