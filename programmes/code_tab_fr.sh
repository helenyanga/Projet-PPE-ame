#!/usr/bin/bash

#Déplacement manuellement :
echo "N.B. :"
echo "Quand le programme sera terminé : écrivez le chemin pour déplacer le fichier crée en sortie dans le dossier que vous souhaitez, avec la commande suivante : mv nomdufichier /chemin/"
echo "Ou déplacer avec la commande suivante : mv"
echo "Avant de lancer le programme : vous pouvez également éxécuter votre fichier.sh suivi de votre premier argument qui est le chemin vers le fichier que vous souhaitez. A cela, vous ajoutez un deuxième argument à la suite qui va indiquer le chemin où vous souhaitez déplacer votre fichier de sortie généré. Cela devra prendre la forme suivante : ./nomdufichier.sh /chemin/fichier chemin/fichierdesortie (si cette option a été choisie, réexécuter le script en ajoutant le second argument)"
echo "Exemple : ./miniprojet.sh /chemin_absolu_ou_relatif/fichier ../tableaux/fichier_data.tsv"
echo "On peut aussi transformer un fichier en un autre fichier avec cette commande suivante : fichier_sortie > fichier_tsv"
echo "(Fin du N.B.)"
echo -e "\n"
#Condition qui vérifie si la variable argument est différent de 1, c'est-à-dire, si un argument est donné.

#On vérifie qu'on a un argument c'est-à-dire, que le fichier est bien un argument :
#$1 : indique l'argument qui est donné, ici c'est le nom du fichier.
fichier_urls=$1

if [ $# -eq 0 ]
then
    echo "Ce programme n'a pas d'argument."
    echo "Vous devez fournir un argument, dans la Konsole, en lui donnant le chemin absolu où se trouve le fichier que vous voulez utiliser."
    echo "Pour ce faire, utiliser la commande suivante : ./nomdufichier.sh argument"
    echo "Si besoin, utiliser la commande 'pwd' pour avoir le chemin en entier ou le chemin relatif suivant par exemple : ../chemin/"
    exit 1
fi


#Condition qui vérifie si le fichier donné existe bien, s'il n'existe pas, il affichera erreur.
echo "Traitement du fichier..."
if [ ! -f $1 ]
then
    echo "Erreur : le fichier "$1" n'existe pas. Recommencer."
    exit 1
fi

echo "Le fichier existe, c'est "$1""
echo -e "...fin du traitement du fichier.\n"

echo "Traitement des URLs... "
#Condition qui vérifie si l'url est valide ou non.
OK=0
NOK=0
while read -r line;
do
    echo "La ligne : $line";
    if [[ $line =~ ^https?:// ]]
    then
        echo "Ressemble à une URL valide."
        OK=$( expr $OK + 1 )
    else
        echo "Ne ressemble pas à une URL valide."
        NOK=$( expr $NOK + 1 )
    fi
done < $fichier_urls
echo "$OK URLs et $NOK lignes douteuses."
echo -e "...fin du traitement des URLs.\n"

fichier_sortie=$2
fichier_html=$3
echo -e "\nOn doit avoir comme résultat :"
echo -e "Numéro_de_la_ligne\tLien\tHTTP \tEncodage_Charset\tNombre_de_mots > envoyer_dans_le fichier_en_sortie : "$2""
echo -e "Numéro_de_la_ligne\tLien\tHTTP \tEncodage_Charset\tNombre_de_mots" > "$fichier_sortie" #On envoie ces titres pour le tableau dans le fichier de sortie.

N=1
#On veut lire ligne par ligne le contenu du fichier.
while read -r line
do
    #On crée des variables pour l'HTTP, l'encodage, le nombre de mots et le fichier de sortie pour que les résultats se génèrent à l'intérieur de ce même fichier.
    fichier_data=$(curl -s -i -L -w "%{http_code}\n%{content_type}" -o ./.fichier_data.tmp $line) #Pour le fichier_data_tmp, on peut écrire la même commande en remplaçant fichier_data.tsb par fichier_data.tsv ; de même pour nb_mots.
    http_code=$(echo "$fichier_data" | head -1)
    content_type=$(echo "$fichier_data" | tail -1 | grep -Po "charset=\S+" | cut -d"=" -f2)

    if [ -z "${content_type}" ] #Cette condition permet de vérifier si l'url contient ou non un encodage. S'il n'en contient pas, il affichera "rien".
	then
		content_type="rien"
	fi

    nb_mots=$(cat ./.fichier_data.tmp | lynx -dump -nolist -stdin $line | wc -w)

    echo -e "${N}\t${line}\t${http_code}\t${content_type}\t${nb_mots}" >> $fichier_sortie #Les chevrons permettent d'envoyer les métadonnées dans le fichier de sortie "tsv".
    N=$( expr $N + 1 )
done < $fichier_urls
