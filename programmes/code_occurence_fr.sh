#!/usr/bin/bash

#Boucle qui donne le html brute pour chaque urls :
N=$1 #N pour numéro de la ligne
line=1

while read -r line
do
    curl -o "../aspirations/francais/fr_${line}.html" $N
    N=$(expr $N + 1)
done < ../urls/fichier_urls_fr.txt
