#!/bin/bash

echo "========================================="
echo "Création du fichier texte pour le nuage"
echo "========================================="

# Créer le dossier
mkdir -p nuages

# Fichier de sortie
FICHIER_SORTIE="nuages/corpus-arabe.txt"

# Supprimer s'il existe
rm -f "$FICHIER_SORTIE"

echo "Fusion de tous les fichiers texte..."

# Combiner tous les dumps-text
for fichier in dumps-text/ar-*.txt; do
    if [ -f "$fichier" ]; then
        echo "  + $(basename $fichier)"
        cat "$fichier" >> "$FICHIER_SORTIE"
        echo "" >> "$FICHIER_SORTIE"
    fi
done

# Statistiques
NB_LIGNES=$(wc -l < "$FICHIER_SORTIE")
NB_MOTS=$(wc -w < "$FICHIER_SORTIE")
TAILLE=$(du -h "$FICHIER_SORTIE" | cut -f1)

echo ""
echo "✓ Fichier créé: $FICHIER_SORTIE"
echo "  - Nombre de lignes: $NB_LIGNES"
echo "  - Nombre de mots: $NB_MOTS"
echo "  - Taille: $TAILLE"
echo ""
echo "========================================="
