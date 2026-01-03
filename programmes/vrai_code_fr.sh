#!/usr/bin/bash

#A titre informatif pour l'utilisateur (1) : comment lancer le programme.
#echo "N.B. :"
#echo "Avant de lancer le programme : vous pouvez également éxécuter votre fichier.sh suivi de votre premier argument qui est le chemin vers le fichier que vous souhaitez. A cela, vous ajoutez un deuxième argument à la suite qui va indiquer le chemin où vous souhaitez déplacer votre fichier de sortie généré. Cela devra prendre la forme suivante : ./nomdufichier.sh /chemin/fichier chemin/fichierdesortie (si cette option a été choisie, réexécuter le script en ajoutant le second argument ; vous pouvez ajouter plusieurs arguments par exemple, un argument qui envoie le contenu d'un fichier dans un autre : /chemin/fichier.tsv > /chemin/fichier.html )"
#echo "Exemple concret : ./miniprojet.sh /chemin_absolu_ou_relatif/fichier ../tableaux/fichier_data.tsv"
#A titre informatif pour l'utilisateur (2) : déplacement manuellement du fichier à un autre.
#echo "Quand le programme sera terminé : écrivez le chemin pour déplacer le fichier crée en sortie dans le dossier que vous souhaitez, avec la commande suivante : mv nomdufichier chemin/"
#echo "Ou déplacer avec la commande suivante : mv"
#A titre informatif pour l'utilisateur (3) : déplacement manuellement du fichier à un autre.
#echo "On peut aussi transformer un fichier en un autre fichier avec cette commande suivante, par exemple : fichier_tmp > fichier_tsv"
#echo "(Fin du N.B.)"
#echo -e "\n"
#Condition qui vérifie si la variable argument est différent de 1, c'est-à-dire, si un argument est donné.


#On vérifie qu'on a un argument c'est-à-dire, que le fichier est bien un argument :
#$1 : indique l'argument qui est donné, ici c'est le nom du fichier.
fichier_urls=$1 #Le fichier contenant les urls passe en variable.
echo "Vérification qu'au moins un argument est bien donné pour ce programme..."
if [ $# -eq 0 ]
then
    echo "Ce programme n'a pas d'argument."
    echo "Vous devez fournir un argument, dans la Konsole, en lui donnant le chemin (absolu ou relatif) où se trouve le fichier que vous voulez utiliser pour ce programme."
    echo "Pour ce faire, utiliser la commande suivante : ./nomdufichier.sh argument"
    echo "Si besoin, utiliser la commande 'pwd' pour avoir le chemin en entier, par exemple : ../chemin/"
    exit 1
fi


#Condition qui vérifie si le fichier donné existe bien, s'il n'existe pas, il affichera erreur.
echo "Traitement du fichier '$1' en cours..."
if [ ! -f $1 ]
then
    echo "Erreur : le fichier "$1" n'existe pas. Recommencer."
    exit 1 #Arrêt du script.
fi

echo "Le fichier existe, c'est "$1""
echo -e "...fin du traitement du fichier.\n"


#Condition qui vérifie si l'url est valide ou non.
echo "Traitement des URLs en cours..."
OK=0
NOK=0
while read -r line; #ligne pour url
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

fichier_tmp=$2
fichier_html=$3
echo -e "\nOn doit avoir comme résultat :"
echo -e "Numéro\tLien\tHTTP\tEncodage Charset\tNombre de mots (envoyer dans le fichier en sortie : '$fichier_tmp'\n)" #Instruction générée en sortie de la Konsole comme information pour l'utilisateur.
echo -e "Numéro\tLien\tHTTP\tEncodage Charset\tNombre de mots > '$fichier_tmp'" #Ce qui doit apparaître dans le fichier de sortie que l'utilisateur nommera.


#Création des dossiers :
mkdir -p ../aspirations
mkdir -p ../dumps-text
mkdir -p ../contextes
mkdir -p ../concordances


echo "<!DOCTYPE html>
    <html>
     <head>
        <meta charset=\"UTF-8\"/>
     </head>
     <body>
        <table>
            <tr>
                <th>Numéro</th>
                <th>Lien</th>
                <th>HTTP</th>
                <th>Encodage Charset</th>
                <th>Nombre de mots</th>
                <th>Occurences</th>
                <th>Aspirations</th>
                <th>Dumps</th>
                <th>Contextes</th>
                <th>Concordances</th>
            </tr>" >> "$fichier_html"

N=1
#On veut lire ligne par ligne le contenu du fichier.
while read -r line
do
    #On crée des variables pour l'HTTP, l'encodage, le nombre de mots et le fichier de sortie pour que les résultats se génèrent à l'intérieur de ce même fichier.
    fichier_data=$(curl -s -i -L -w "%{http_code}\n%{content_type}" -o "../aspirations/fr-${N}.html" $line) #Récupérer la page web avec ses métadonnées et les sauvegarder dans le fichier.
    http_code=$(echo "$fichier_data" | head -1) #Extraction du code HTTP.
    content_type=$(echo "$fichier_data" | tail -1 | grep -Po "charset=\S+" | cut -d"=" -f2) #Extraction de l'encodage.

    if [ -z "${content_type}" ] #Cette condition permet de vérifier si l'url contient ou non un encodage. S'il n'en contient pas, il affichera "rien".
	then
		content_type="rien"
	fi

    nb_mots=$(lynx -dump -nolist "../aspirations/fr-$N.html" | wc -w)

    #Ecrire dans le fichier tsv :
    echo -e "${N}\t${line}\t${http_code}\t${content_type}\t${nb_mots}" >> $fichier_tmp #Les chevrons permettent d'envoyer les métadonnées dans le fichier de sortie "tsv".

    #Pour le tableau HTML :
    aspirations_fichier=$(curl -s -L "$line" -o "../aspirations/fr-${N}.html")
    dumps_fichier=$(lynx -dump -nolist "../aspirations/fr-${N}.html" > "../dumps-text/fr-${N}.txt")
    nb_occurences=$(egrep -a -i -o "\b(Â|â)me(s)?\b" "../dumps-text/fr-${N}.txt" | wc -l)
    contextes_fichier=$(egrep -a -i -C2 "\b(Â|â)me(s)?\b" "../dumps-text/fr-${N}.txt" > "../contextes/fr-${N}.txt")
    #bash code_concordances.sh "$N"





    #Liens cliquables pour le tableau HTML :
    aspirations_fichier="../aspirations/fr-$N.html"
    dumps_fichier="../dumps-text/fr-$N.txt"
    contexte="../contextes/fr-${N}.html"
    concordances_fichier=$"../concordances/fr-${N}.html"


    #Ecrire dans le HTML :
    echo -e " <tr>
                  <td>$N</td>
                  <td><a href=\"$line\">$line</a></td>
                  <td>$http_code</td>
                  <td>$content_type</td>
                  <td>$nb_mots</td>
                  <td>$nb_occurences</td>
                  <td><a href=\"../aspirations/fr-${N}.html\">aspiration</a></<td>
                  <td><a href=\"../dumps-text/fr-${N}.txt\">dump</a></td>
                  <td><a href=\"../contextes/fr-${N}.txt\">contexte</a></td>
                  <td><a href=\"../concordances/fr-${N}.html\">concordancier</a></td>
              </tr>" >> "$fichier_html"

    N=$( expr $N + 1 )
done < $fichier_urls

#Fermer le tableau HTML :
echo "      </table>
     </body>
</html>" >> "$fichier_html"

#Suppression du fichier.tsv qui est le fichier temporaire :
rm ../tableaux/"$fichier_tmp"
