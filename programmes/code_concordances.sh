#!/usr/bin/bash
#Code pour le concordancier en HTML.
#Boucle qui génère une page HTML comprenant le contexte gauche, le mot cible et le contexte droit pour chaque dump-text :

echo "Génération du concordancier..."

fichier_context=$1
fichier_concordance=$2

if [ $# -ne 2 ]
then
	echo "Le script doit prendre exactement 2 arguments." #Sur la konsole, appeler le programme et ses arguments de la manière suivante : ./code_concordances.sh ../dumps-text ../concordances
	exit 1
fi

for fichier in $(ls "$fichier_context"/fr-*.txt)
do
    nom_fichier=$(basename "$fichier" .txt)
    N=$(echo "nom_fichier" | sed 's/^fr-//')

    fichier_html_concordance="$fichier_concordance/fr-${N}.html"

    echo "Traitement des fichiers : $nom_fichier → fr-${N}.html"

    echo -e "<html>
            <head>
                <meta charset=\"UTF-8\">
            </head>
            <body>
                <table>
                    <tr>
                        <th>Contexte gauche</th>
                        <th>Mot cible</th>
                        <th>Contexte droit</th>
                    </tr>" > "$fichier_html_concordance"

    grep -o -i -E '.{0,50}\b[aâ]mes?\b.{0,50}' "$fichier" | while IFS= read -r line
    do
        mot=$(echo "$line" | grep -o -i -E "\b[ÂAaâ]me(s)?\b" | head -1)
        contexte_gauche=$(echo "$line" | sed -E "s/^(.*)\b[aâ]mes?\b.*$/\1/I")                contexte_droit=$(echo "$line" | sed -E "s/^.*\b[aâ]mes?\b(.*)$/\1/I")

        echo -e "  <tr>
                    <td>$contexte_gauche</td>
                    <td>$mot</td>
                    <td>$contexte_droit</td>
                   </tr>" >> "$fichier_html_concordance"

    done

    echo -e "          </table>
                </body>
            </html>" >> "$fichier_html_concordance"

done

echo "Concordancier terminés."
