#!/bin/bash
mkdir -p bigrammes
for fichier in tokens/ar-*.txt; do
    if [[ ! "$fichier" == *".stats"* ]]; then
        numero=$(basename "$fichier" .txt)
        python3 programmes/extraire_bigrammes.py "$fichier" > "bigrammes/${numero}.txt"
        echo "✓ $numero"
    fi
done
echo "Terminé !"
