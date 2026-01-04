#Pour lancer le programme :
#1) ouvrir un terminal et aller dans un environnement : source chemin/environnement/bin/activate
#2)installer WordCloud, matplotlib et nltk si nécessaire.

import os
import unicodedata
from wordcloud import WordCloud
import matplotlib.pyplot as plt
from nltk.corpus import stopwords
import nltk

chemin_dossier = input("🔹 Entrez le chemin du dossier contenant tous les fichiers fr.txt : ").strip()
fichier_rassembler = "../nuage/corpus/tous_contextesfr.txt"
mot_cible = "âme"

#Pour les stopwords français :
try:
    stopwords_fr = set(stopwords.words('french'))
except:
    nltk.download('stopwords')
    stopwords_fr = set(stopwords.words('french'))

#Stopwords supplémentaires si nécessaires :
mots_ignorer = {'un', 'une', 'd', 'l', 'quelques', 'fichier', 'cette', 'ces', 'tout', 'tous',
                 'afin', 'mot', 'peut', 'autant', 'comporte', 'décallée', 'doit', 'apparu',
                 'voir', 'auprès', 'dite', 'deuxième', 'quelle', 'première', 'chaque', 'toute',
                 'vaut', '.', 'bonne', 'autre', 'non', 'fournit', 'sipi', 'plus', 'selon',
                 'utilisé', 'courant', 'comme', 'comment', 'troisième', 'très', 'existe',
                 'detectors', 'désignait', 'oppose', 'prévue', 'correspond', 'fermer',
                 'véritablement', 'également', 'devient', 'sous', 'aussi', 'parfaitement',
                 'compréhension', 'complètement', 'appelle'}
stopwords_fr.update(mots_ignorer)


#Vérification du dossier (s'il existe bien) : 
if not os.path.isdir(chemin_dossier):
    raise FileNotFoundError(f"Le dossier '{chemin_dossier}' n'existe pas.")

#Regroupement des fichiers : 
fichiers_txt = [f for f in os.listdir(chemin_dossier) if f.endswith(".txt")]
if not fichiers_txt:
    raise FileNotFoundError(f"Aucun fichier .txt trouvé dans '{chemin_dossier}'.")
#Prendre en compte les diacritiques pour le mot "âme" :
with open(fichier_rassembler, "w", encoding="utf-8") as out_file:
    for nom_fichier in fichiers_txt:
        chemin_fichier = os.path.join(chemin_dossier, nom_fichier)
        try:
            with open(chemin_fichier, "r", encoding="utf-8") as f:
                texte = f.read()
        except UnicodeDecodeError:
            with open(chemin_fichier, "r", encoding="latin-1") as f:
                texte = f.read()
        texte = unicodedata.normalize("NFC", texte)
        out_file.write(texte + "\n")

print(f"✓ Tous les fichiers ont été concaténés dans '{fichier_rassembler}' avec diacritiques préservés.")


#Extraire les mots qui gravitent autour du mot "âme" :
with open(fichier_rassembler, "r", encoding="utf-8") as f:
    texte = f.read().lower()
texte = unicodedata.normalize("NFC", texte)
tous_les_mots = texte.split()
mots_autour_ame = []

for i, mot in enumerate(tous_les_mots):
    if mot == mot_cible:
        if i > 0:
            mots_autour_ame.append(tous_les_mots[i-1])
        if i < len(tous_les_mots) - 1:
            mots_autour_ame.append(tous_les_mots[i+1])


#Nettoyage :
mots_propres = [mot for mot in mots_autour_ame if mot.isalpha() and len(mot) > 2 and mot not in stopwords_fr]

#Vérification :
print("Mots extraits autour de 'âme' :", mots_autour_ame[:50])
print("Mots après nettoyage :", mots_propres[:50])
print("Nombre de mots trouvés :", len(mots_propres))


#Création du wordcloud : 
if mots_propres:
    nuage = WordCloud(width=800, height=400, background_color="white").generate(" ".join(mots_propres))
    plt.imshow(nuage)
    plt.axis("off")
    plt.title("Mots autour de 'âme' en français")

    os.makedirs("../nuage/images", exist_ok=True)
    plt.savefig("../nuage/images/fr.png", dpi=300, bbox_inches='tight')
    print("✓ Nuage sauvegardé dans ../nuage/images/fr.png")
    plt.show()
else: #Message qui prévient dans le cas où il ne trouve pas le mot.
    print("⚠ Aucun mot trouvé autour de 'âme'. WordCloud non créé.")
