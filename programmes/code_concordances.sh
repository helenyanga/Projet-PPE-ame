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

N=1
for fichier in "$fichier_context"/fr-*.txt
do
    fichier_html_concordance="$fichier_concordance/fr-${N}.html"

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

    phrase_mot=$(egrep -a -o -i '(\w+\W){0,5}\b(Â|â)me(s)?\b(\W+\w){0,5})' "$fichier")

    while IFS= read -r line
    do
        if echo -e "$line" | egrep -iq '\b(Â|â)me(s)?\b'
        then
            mot=$(echo "$line" | egrep -o -i "\bâme(s)?\b")
            contexte_gauche=$(echo -e "$line" | sed -E 's/(.*)\bâme(s)?\b.*/\1/I')
            contexte_droit=$(echo -e "$line" | sed -E 's/.*\bâme(s)?\b(.*)/\1/I')

        echo -e "  <tr>
                    <td>$contexte_gauche</td>
                    <td>$mot</td>
                    <td>$contexte_droit</td>
                </tr>" >> "$fichier_html_concordance"
        fi
    done <<< "$phrase_mot"


    echo -e "          </table>
                </body>
            </html>" >> "$fichier_html_concordance"

    N=$((N + 1))
done

echo "Concordancier terminés."
