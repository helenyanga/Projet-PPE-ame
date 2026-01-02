#!/usr/bin/bash
#Code pour le concordancier en HTML.
#Boucle qui génère une page HTML comprenant le contexte gauche, le mot cible et le contexte droit pour chaque dump-text :
echo "Génération du concordancier..."

mot=$(egrep -a -i -o "\b(Â|â)me(s)?\b")


echo "Concordancier terminé."
