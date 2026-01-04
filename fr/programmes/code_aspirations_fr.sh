#!/usr/bin/bash
#Code pour l'aspiration HTML.
#Boucle qui télécharge la page url pour chaque lien :
echo "Téléchargement de la page HTML de chaque URLs..."

N=$1 #N pour numéro de la ligne
line=$2

while read -r line
do
    curl -s -L "$line" -o "../aspirations/fr-${line}.html"
    N=$(expr $N + 1)
done < ../urls/fr.txt

echo "Fin du téléchargement des pages HTML. Aspirations terminées."
