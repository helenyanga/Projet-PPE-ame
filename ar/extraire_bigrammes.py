#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import sys
from collections import Counter

fichier = sys.argv[1]
with open(fichier, 'r', encoding='utf-8', errors='ignore') as f:
    tokens = [ligne.strip() for ligne in f if ligne.strip()]

# Créer bigrammes
bigrammes = []
for i in range(len(tokens)-1):
    if len(tokens[i]) > 2 and len(tokens[i+1]) > 2:
        bigrammes.append(f"{tokens[i]} {tokens[i+1]}")

# Top 5
top = Counter(bigrammes).most_common(5)
result = " | ".join([f"{b[0]} ({b[1]})" for b in top]) if top else "N/A"
print(result)
