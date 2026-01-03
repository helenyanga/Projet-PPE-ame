#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Script de tokenisation pour l'arabe
Compatible avec le projet "Âme"
"""

import sys
import re

try:
    from camel_tools.tokenizers.word import simple_word_tokenize
    from camel_tools.utils.normalize import normalize_alef_ar, normalize_alef_maksura_ar
except ImportError:
    print("ERREUR: CAMeL Tools non installé", file=sys.stderr)
    print("Installez avec: pip3 install camel-tools", file=sys.stderr)
    sys.exit(1)


def normaliser_texte(texte):
    """Normalise le texte arabe"""
    texte = normalize_alef_ar(texte)
    texte = normalize_alef_maksura_ar(texte)
    return texte


def tokeniser_et_analyser(fichier_texte, mot_recherche, fichier_tokens_sortie, fichier_contextes_sortie):
    """
    Tokenise un fichier et cherche les occurrences d'un mot
    
    Args:
        fichier_texte: fichier texte brut
        mot_recherche: mot à chercher (ex: روح)
        fichier_tokens_sortie: où sauver les tokens
        fichier_contextes_sortie: où sauver les contextes
    """
    
    try:
        # Lire le fichier
        with open(fichier_texte, 'r', encoding='utf-8') as f:
            texte = f.read()
        
        if not texte.strip():
            print("Fichier vide", file=sys.stderr)
            return 0, 0
        
        # Normaliser
        texte = normaliser_texte(texte)
        mot_normalise = normaliser_texte(mot_recherche)
        
        # Tokeniser
        tokens = simple_word_tokenize(texte)
        
        # Sauvegarder tous les tokens
        with open(fichier_tokens_sortie, 'w', encoding='utf-8') as f:
            for token in tokens:
                f.write(token + '\n')
        
        # Chercher les occurrences
        occurrences = []
        for i, token in enumerate(tokens):
            # Recherche flexible : le mot peut être dans le token
            if mot_normalise in token or token in mot_normalise:
                occurrences.append(i)
        
        nb_occurrences = len(occurrences)
        
        # Extraire les contextes (fenêtre de 5 tokens)
        contextes = []
        fenetre = 5
        
        for idx in occurrences:
            debut = max(0, idx - fenetre)
            fin = min(len(tokens), idx + fenetre + 1)
            
            gauche = ' '.join(tokens[debut:idx])
            mot = tokens[idx]
            droit = ' '.join(tokens[idx+1:fin])
            
            contextes.append(f"{gauche}|{mot}|{droit}")
        
        # Sauvegarder les contextes
        with open(fichier_contextes_sortie, 'w', encoding='utf-8') as f:
            for ctx in contextes:
                f.write(ctx + '\n')
        
        # Sauvegarder les stats pour bash
        with open(fichier_tokens_sortie + '.stats', 'w', encoding='utf-8') as f:
            f.write(f"NB_OCCURRENCES={nb_occurrences}\n")
            f.write(f"NB_TOTAL_TOKENS={len(tokens)}\n")
        
        print(f"Tokenisation réussie: {len(tokens)} tokens, {nb_occurrences} occurrences", file=sys.stderr)
        
        return len(tokens), nb_occurrences
        
    except Exception as e:
        print(f"ERREUR: {e}", file=sys.stderr)
        return 0, 0


if __name__ == "__main__":
    if len(sys.argv) != 5:
        print("Usage: python3 tokenisation.py <fichier_texte> <mot> <sortie_tokens> <sortie_contextes>")
        sys.exit(1)
    
    fichier_texte = sys.argv[1]
    mot_recherche = sys.argv[2]
    fichier_tokens = sys.argv[3]
    fichier_contextes = sys.argv[4]
    
    nb_tokens, nb_occ = tokeniser_et_analyser(fichier_texte, mot_recherche, fichier_tokens, fichier_contextes)
    
    if nb_tokens > 0:
        sys.exit(0)  # Succès
    else:
        sys.exit(1)  # Échec
