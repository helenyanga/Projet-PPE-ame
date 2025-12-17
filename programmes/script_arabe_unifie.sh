#!/bin/bash

# Script pour analyser le mot "âme" en arabe - VERSION CORRIGÉE
# Un seul tableau pour les deux graphies : روح et نفس

# Vérifier les arguments
if [ $# -ne 4 ]; then
    echo "Usage: $0 <fichier_urls> <mot_arabe> <graphie_label> <numero_debut>" >&2
    echo "Exemple: $0 URLs/ar-rouh.txt 'روح' 'rouh' 1" >&2
    echo "         $0 URLs/ar-nafs.txt 'نفس' 'nafs' 31" >&2
    exit 1
fi

FICHIER_URLS=$1
MOT_RECHERCHE=$2
GRAPHIE=$3
NUMERO_DEBUT=$4  # Numéro de départ (1 pour روح, 31 pour نفس)

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
        body { direction: rtl; font-family: Arial, sans-serif; }
        .table { font-size: 14px; }
        .graphie-rouh { background-color: #e3f2fd; }
        .graphie-nafs { background-color: #fff3e0; }
        .has-occurrences { font-weight: bold; color: #2e7d32; }
        .no-occurrences { color: #d32f2f; }
        .tag { margin: 2px; }
    </style>
</head>
<body>
    <section class="hero is-info">
        <div class="hero-body">
            <div class="container has-text-centered">
                <h1 class="title">تحليل كلمة "الروح"</h1>
                <h2 class="subtitle">Analyse du mot "Âme" en arabe</h2>
                <p>الرسمان: روح (1-30) و نفس (31-60)</p>
            </div>
        </div>
    </section>
    
    <section class="section">
        <div class="container">
            <div class="notification is-info is-light">
                <strong>ملاحظة:</strong> هذا الجدول يحتوي على تحليل الرسمين (روح و نفس) - 60 رابطاً
            </div>
            
            <div class="table-container">
                <table class="table is-striped is-fullwidth is-bordered">
                    <thead>
                        <tr>
                            <th>رقم</th>
                            <th>الرسم</th>
                            <th>الرابط</th>
                            <th>HTTP</th>
                            <th>الترميز</th>
                            <th>التكرارات</th>
                            <th>عدد الكلمات</th>
                            <th>HTML</th>
                            <th>النص</th>
                            <th>Tokens</th>
                            <th>المتلازمات</th>
                        </tr>
                    </thead>
                    <tbody>
EOF
fi

NUMERO_LIGNE=$NUMERO_DEBUT

while read -r URL;
do
    echo "========================================="
    echo "Traitement URL $NUMERO_LIGNE ($GRAPHIE): $URL"
    echo "========================================="
    
    # Noms des fichiers
    FICHIER_HTML="aspirations/ar-${NUMERO_LIGNE}.html"
    FICHIER_TEXTE="dumps-text/ar-${NUMERO_LIGNE}.txt"
    FICHIER_TOKENS="tokens/ar-${NUMERO_LIGNE}.txt"
    FICHIER_CONTEXTE="contextes/ar-${NUMERO_LIGNE}.txt"
    FICHIER_CONCORDANCE="concordances/ar-${NUMERO_LIGNE}.html"
    
    # 1. Télécharger
    echo "1. Téléchargement..."
    HTTP_CODE=$(curl -L -s -o "$FICHIER_HTML" -w "%{http_code}" "$URL" --max-time 30)
    
    if [ "$HTTP_CODE" = "200" ]; then
        echo "✓ Téléchargement réussi"
        
        # Vérifier que le fichier n'est pas vide
        if [ ! -s "$FICHIER_HTML" ]; then
            echo "✗ Fichier HTML vide"
            HTTP_CODE="000"
        else
            # 2. Détecter encodage
            ENCODAGE=$(file -b --mime-encoding "$FICHIER_HTML" | head -n1)
            echo "   Encodage: $ENCODAGE"
            
            # 3. Extraire texte
            echo "2. Extraction du texte..."
            if [ "$ENCODAGE" = "utf-8" ] || [ "$ENCODAGE" = "us-ascii" ]; then
                lynx -dump -nolist -assume_charset=utf-8 -display_charset=utf-8 "$FICHIER_HTML" > "$FICHIER_TEXTE" 2>/dev/null
            else
                # Essayer de convertir
                TEMP_FILE="${FICHIER_HTML}.utf8"
                if iconv -f "$ENCODAGE" -t UTF-8 "$FICHIER_HTML" > "$TEMP_FILE" 2>/dev/null; then
                    lynx -dump -nolist -assume_charset=utf-8 -display_charset=utf-8 "$TEMP_FILE" > "$FICHIER_TEXTE" 2>/dev/null
                    rm -f "$TEMP_FILE"
                else
                    # Si iconv échoue, essayer sans conversion
                    echo "   ⚠ Conversion échouée, tentative directe"
                    lynx -dump -nolist "$FICHIER_HTML" > "$FICHIER_TEXTE" 2>/dev/null
                fi
            fi
            
            # Vérifier que le texte n'est pas vide
            if [ ! -s "$FICHIER_TEXTE" ]; then
                echo "✗ Extraction texte échouée (fichier vide)"
                OCCURRENCES=0
                NB_TOKENS=0
            else
                # 4. Tokenisation
                echo "3. Tokenisation..."
                python3 programmes/tokenisation.py "$FICHIER_TEXTE" "$MOT_RECHERCHE" "$FICHIER_TOKENS" "$FICHIER_CONTEXTE" 2>/dev/null
                
                if [ $? -eq 0 ] && [ -f "${FICHIER_TOKENS}.stats" ]; then
                    source "${FICHIER_TOKENS}.stats"
                    OCCURRENCES=$NB_OCCURRENCES
                    NB_TOKENS=$NB_TOTAL_TOKENS
                    echo "✓ Tokenisation réussie: $NB_TOKENS tokens, $OCCURRENCES occurrences"
                else
                    echo "✗ Tokenisation échouée"
                    OCCURRENCES=0
                    NB_TOKENS=0
                fi
            fi
            
            # 5. Concordancier
            if [ -f "$FICHIER_CONTEXTE" ] && [ -s "$FICHIER_CONTEXTE" ] && [ $OCCURRENCES -gt 0 ]; then
                echo "4. Création concordancier..."
                cat > "$FICHIER_CONCORDANCE" << CONCORD_EOF
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <title>المتلازمات - $MOT_RECHERCHE</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bulma@1.0.4/css/bulma.min.css">
    <style>
        body { direction: rtl; font-family: Arial; }
        .contexte { margin: 15px 0; padding: 15px; background: #f9f9f9; border-right: 4px solid #3273dc; }
        .mot-cible { background: #ffeb3b; font-weight: bold; color: #c62828; padding: 2px 5px; }
    </style>
</head>
<body>
    <section class="section">
        <div class="container">
            <h1 class="title">المتلازمات اللفظية - $MOT_RECHERCHE</h1>
            <div class="box">
                <p><strong>الرابط:</strong> <a href="$URL" target="_blank">$URL</a></p>
                <p><strong>التكرارات:</strong> $OCCURRENCES</p>
            </div>
CONCORD_EOF
                
                while IFS='|' read -r gauche mot droit; do
                    echo "            <div class=\"contexte\">" >> "$FICHIER_CONCORDANCE"
                    echo "                <span>$gauche</span> " >> "$FICHIER_CONCORDANCE"
                    echo "                <span class=\"mot-cible\">$mot</span> " >> "$FICHIER_CONCORDANCE"
                    echo "                <span>$droit</span>" >> "$FICHIER_CONCORDANCE"
                    echo "            </div>" >> "$FICHIER_CONCORDANCE"
                done < "$FICHIER_CONTEXTE"
                
                echo "        </div></section></body></html>" >> "$FICHIER_CONCORDANCE"
            else
                FICHIER_CONCORDANCE=""
            fi
        fi
    else
        echo "✗ Erreur HTTP $HTTP_CODE"
        ENCODAGE="N/A"
        OCCURRENCES=0
        NB_TOKENS=0
    fi
    
    # 6. Ajouter ligne au tableau
    TR_CLASS="graphie-${GRAPHIE}"
    OCC_CLASS="no-occurrences"
    if [ $OCCURRENCES -gt 0 ]; then
        OCC_CLASS="has-occurrences"
    fi
    
    # Ligne temporaire
    cat >> "$TABLEAU" << EOF
                    <tr class="$TR_CLASS">
                        <td><strong>$NUMERO_LIGNE</strong></td>
                        <td><span class="tag is-info">$MOT_RECHERCHE</span></td>
                        <td><a href="$URL" target="_blank" style="font-size: 11px;">رابط</a></td>
                        <td><span class="tag is-$([ "$HTTP_CODE" = "200" ] && echo "success" || echo "danger")">$HTTP_CODE</span></td>
                        <td style="font-size: 11px;">$ENCODAGE</td>
                        <td class="$OCC_CLASS"><strong>$OCCURRENCES</strong></td>
                        <td>$NB_TOKENS</td>
                        <td><a href="../$FICHIER_HTML">HTML</a></td>
                        <td><a href="../$FICHIER_TEXTE">TXT</a></td>
                        <td><a href="../$FICHIER_TOKENS">Tokens</a></td>
EOF
    
    if [ -n "$FICHIER_CONCORDANCE" ] && [ -f "$FICHIER_CONCORDANCE" ]; then
        echo "                        <td><a href=\"../$FICHIER_CONCORDANCE\" class=\"button is-small is-info\">عرض</a></td>" >> "$TABLEAU"
    else
        echo "                        <td>-</td>" >> "$TABLEAU"
    fi
    
    echo "                    </tr>" >> "$TABLEAU"
    
    NUMERO_LIGNE=$((NUMERO_LIGNE + 1))
    echo ""
    
done < "$FICHIER_URLS"

echo "========================================="
echo "✓ Traitement terminé pour $GRAPHIE"
echo "   Voir: tableaux/ar.html"
echo "========================================="
