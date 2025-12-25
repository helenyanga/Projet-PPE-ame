#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Génère un nuage de mots depuis corpus-arabe.txt
"""

import sys
from wordcloud import WordCloud
import matplotlib.pyplot as plt
import arabic_reshaper
from bidi.algorithm import get_display

print("=" * 50)
print("Génération du nuage de mots arabe")
print("=" * 50)

# Lire le fichier texte
print("\n1. Lecture du corpus...")
with open('nuages/corpus-arabe.txt', 'r', encoding='utf-8', errors= 'ignore') as f:
    texte = f.read()

print(f"   ✓ {len(texte)} caractères chargés")
print(f"   ✓ {len(texte.split())} mots environ")

# Mots vides à exclure (MAIS PAS روح et نفس !)
mots_vides = [
    # Articles et prépositions
    'في', 'من', 'إلى', 'على', 'عن', 'مع', 'عند', 'أمام', 'خلف', 'فوق', 'تحت',
    'بين', 'ضد', 'حول', 'دون', 'سوى', 'خلا', 'عدا', 'حاشا', 'منذ', 'بعد', 'قبل',
    
    # Conjonctions
    'و', 'أو', 'لكن', 'بل', 'حتى', 'إذ', 'إذا', 'لو', 'لولا', 'كأن', 'ف', 'ثم',
    
    # Pronoms
    'أن', 'ما', 'لا', 'هذا', 'هذه', 'ذلك', 'تلك', 'هؤلاء', 'أولئك',
    'هو', 'هي', 'هم', 'هن', 'أنا', 'نحن', 'أنت', 'أنتم', 'أنتن', 'هما',
    
    # Articles définis avec prépositions
    'ال', 'بال', 'لل', 'وال', 'فال', 'كال',
    
    # Mots relatifs
    'الذي', 'التي', 'اللذان', 'اللتان', 'الذين', 'اللاتي', 'اللواتي', 'اللذين',
    
    # Adverbes et particules
    'قد', 'لم', 'لن', 'لما', 'كان', 'يكون', 'كل', 'بعض', 'كثير', 'قليل',
    'جدا', 'أيضا', 'كذلك', 'هكذا', 'هنا', 'هناك', 'أين', 'كيف', 'متى', 'لماذا',
    'الآن', 'اليوم', 'أمس', 'غدا', 'دائما', 'أبدا', 'ربما', 'نعم', 'لا',
    
    # Verbes auxiliaires très courants
    'كان', 'يكون', 'أصبح', 'أضحى', 'ظل', 'بات', 'صار', 'ليس', 'مازال', 'كانت',
    'يكن', 'تكون', 'أكون', 'نكون', 'يصبح', 'تصبح',
    
    # Pronoms attachés et préfixes/suffixes
    'له', 'لها', 'لهم', 'لهن', 'به', 'بها', 'بهم', 'بهن', 'لي', 'لك', 'لنا', 'لكم',
    'منه', 'منها', 'منهم', 'منهن', 'مني', 'منك', 'منا', 'منكم',
    'فيه', 'فيها', 'فيهم', 'فيهن', 'في', 'فيك', 'فينا', 'فيكم',
    'عليه', 'عليها', 'عليهم', 'عليهن', 'علي', 'عليك', 'علينا', 'عليكم',
    'إليه', 'إليها', 'إليهم', 'إليهن', 'إلي', 'إليك', 'إلينا', 'إليكم',
    'أنه', 'أنها', 'أنهم', 'أنهن', 'أني', 'أنك', 'أننا', 'أنكم',
    
    # Mots anglais/latins courants
    'and', 'the', 'of', 'to', 'in', 'a', 'is', 'for', 'on', 'with', 'by', 'at', 'from',
    'that', 'this', 'as', 'it', 'or', 'are', 'be', 'was', 'an', 'we', 'you', 'all',
    'can', 'has', 'had', 'but', 'not', 'they', 'have', 'been', 'one', 'their',
    
    # Mots de navigation web (présents dans tes pages)
    'home', 'menu', 'search', 'login', 'page', 'next', 'previous', 'click', 'here',
    'read', 'more', 'back', 'top', 'share', 'print', 'email', 'loading',
    
    # Chiffres et dates en arabe
    'واحد', 'اثنان', 'ثلاثة', 'أربعة', 'خمسة', 'ستة', 'سبعة', 'ثمانية', 'تسعة', 'عشرة',
    
    # Mots très génériques
    'يعد', 'تعد', 'يعتبر', 'تعتبر', 'يمكن', 'تمكن', 'يجب', 'تجب', 'يقول', 'تقول',
    'قال', 'قالت', 'ذكر', 'ذكرت', 'أشار', 'أشارت', 'أكد', 'أكدت'
]

# Remodeler pour l'arabe
print("\n2. Préparation du texte arabe (RTL)...")
texte_reshape = arabic_reshaper.reshape(texte)
texte_bidi = get_display(texte_reshape)

# Créer le nuage
print("\n3. Génération du nuage de mots...")
wordcloud = WordCloud(
    width=1920,
    height=1080,
    background_color='white',
    stopwords=set(mots_vides),
    max_words=100,  # Moins de mots = plus gros
    colormap='viridis',
    font_path='/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',
    relative_scaling=0.8,  # Plus élevé = différence de taille plus grande
    min_font_size=15  # Taille minimum plus grande
).generate(texte_bidi)
# Sauvegarder
# Sauvegarder directement
print("\n4. Sauvegarde de l'image...")
image = wordcloud.to_image()
image.save('nuages/nuage-arabe.png')

print("\n" + "=" * 50)
print("✓ TERMINÉ !")
print("=" * 50)
print("\nFichiers créés:")
print("  - nuages/corpus-arabe.txt (le texte)")
print("  - nuages/nuage-arabe.png (l'image)")
print()
