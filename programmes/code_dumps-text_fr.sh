#!/usr/bin/bash
#Code pour l'aspiration HTML.
#Boucle pour obtenir le texte brut (dumps-text) de chaque URLs :
echo "Traitement des pages HTML pour l'obtention du texte brut de chaque URLs..."

N=$1 #N pour numéro de la ligne
line=$1

while read -r line
do
    lynx -dump -nolist "../aspirations/fr-${N}.html" > "../dumps-text/fr-${N}.txt"
    N=$(expr $N + 1)
done < ../urls/fr.txt

echo "Dumps terminées."
