"""
Génération d'un nuage de mots pour le corpus RU1 (russe)
Projet PPE – TAL
"""

import re
from pathlib import Path
from collections import Counter
from wordcloud import WordCloud

print("=" * 50)
print("Génération du nuage de mots – Corpus RU1")
print("=" * 50)

# =====================================================
# 1. Charger TOUS les fichiers ru1-*.txt
# =====================================================

print("\n1. Lecture des fichiers du corpus...")

corpus = []
base_path = Path("ru/txt/original/ru2")

files = sorted(base_path.glob("ru2-*.txt"))

if not files:
    raise FileNotFoundError("Aucun fichier ru2-*.txt trouvé")

for file in files:
    with open(file, encoding="utf-8", errors="ignore") as f:
        corpus.append(f.read())

texte = "\n".join(corpus)
print(f"   ✓ {len(files)} fichiers chargés")
print(f"   ✓ {len(texte)} caractères")

# =====================================================
# 2. Nettoyage du texte (russe uniquement)
# =====================================================

print("\n2. Nettoyage du texte...")

texte = texte.lower()

# Supprimer URLs
texte = re.sub(r'https?://\S+', '', texte)

# Supprimer chiffres
texte = re.sub(r'\d+', '', texte)

# Garder uniquement le cyrillique
texte = re.sub(r'[^\u0400-\u04FF\s-]', ' ', texte)

# Nettoyage des espaces multiples
texte = re.sub(r'\s+', ' ', texte)

# =====================================================
# 3. Découpage en mots + filtrage
# =====================================================

mots = texte.split()

print(f"   ✓ {len(mots)} mots bruts")

# Stoplist minimale (tu peux l'étendre)
stopwords = {
    'и', 'в', 'на', 'что', 'это', 'как', 'к', 'по', 'из', 'за',
    'от', 'о', 'с', 'для', 'у', 'же', 'не', 'бы', 'то',
    'его', 'ее', 'их', 'она', 'он', 'они', 'мы', 'вы',
    'был', 'быть', 'есть', 'были'
}

mots_propres = [
    mot for mot in mots
    if len(mot) > 2
    and mot not in stopwords
    and re.fullmatch(r'[а-яё-]+', mot)
]

print(f"   ✓ {len(mots_propres)} mots conservés")

# =====================================================
# 4. Statistiques (top 30)
# =====================================================

compteur = Counter(mots_propres)

print("\nTop 30 des mots :")
for i, (mot, freq) in enumerate(compteur.most_common(30), 1):
    print(f"{i:2d}. {mot:15s} : {freq}")

# =====================================================
# 5. Génération du nuage de mots
# =====================================================

print("\n5. Génération du nuage...")

wordcloud = WordCloud(
    width=1800,
    height=1000,
    background_color="white",
    max_words=80,
    font_path="C:/Windows/Fonts/arial.ttf",  # IMPORTANT (Windows)
    collocations=False
).generate(" ".join(mots_propres))

# =====================================================
# 6. Sauvegarde
# =====================================================

output_dir = Path("www/ru/nuages")
output_dir.mkdir(parents=True, exist_ok=True)

output_file = output_dir / "nuage-ru2.png"
wordcloud.to_file(output_file)

print("\n" + "=" * 50)
print("✓ TERMINÉ")
print(f"Fichier généré : {output_file}")
print("=" * 50)
