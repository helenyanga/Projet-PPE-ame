#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Génère un nuage de mots PROPRE - Version finale
"""

import re
from collections import Counter
from wordcloud import WordCloud
import arabic_reshaper
from bidi.algorithm import get_display

print("=" * 50)
print("Génération du nuage de mots arabe")
print("=" * 50)

# 1. Lire le fichier
print("\n1. Lecture du corpus...")
with open('nuages/corpus-arabe.txt', 'r', encoding='utf-8', errors='ignore') as f:
    texte = f.read()

print(f"   ✓ {len(texte)} caractères")

# 2. SUPER NETTOYAGE
print("\n2. Nettoyage agressif...")
texte = re.sub(r'<[^>]+>', '', texte)
texte = re.sub(r'https?://[^\s]+', '', texte)
texte = re.sub(r'www\.[^\s]+', '', texte)
texte = re.sub(r'\b[A-Z]{2,}\b', '', texte)
texte = re.sub(r'[a-zA-Z]+', '', texte)  # TOUT l'anglais
texte = re.sub(r'\d+', '', texte)
texte = re.sub(r'[^\u0600-\u06FF\s]', ' ', texte)

# 3. Découper en mots
mots = texte.split()
print(f"   ✓ {len(mots)} mots extraits")

# 4. LISTE EXHAUSTIVE de mots à EXCLURE
mots_a_exclure = {
    # TOUS les mots de 1-2 lettres
    'و', 'في', 'من', 'إلى', 'على', 'عن', 'مع', 'ل', 'ب', 'ك', 'أن', 'ما', 'لا',
    'هو', 'هي', 'له', 'لها', 'به', 'بها', 'منه', 'منها', 'فيه', 'فيها', 'لي', 'بي',
    'أو', 'لو', 'لن', 'لم', 'قد', 'ف', 'ثم', 'إن', 'كل', 'أي', 'عند', 'بل', 'حتى',
    
    # Prépositions et articles
    'في', 'من', 'إلى', 'على', 'عن', 'مع', 'عند', 'لدى', 'أمام', 'خلف', 'فوق', 'تحت',
    'بين', 'ضد', 'حول', 'دون', 'سوى', 'خلا', 'عدا', 'ال', 'بال', 'لل', 'وال', 'فال',
    
    # Pronoms
    'هذا', 'هذه', 'ذلك', 'تلك', 'هؤلاء', 'أولئك', 'هو', 'هي', 'هم', 'هن', 'هما',
    'أنا', 'نحن', 'أنت', 'أنتم', 'أنتن', 'أنتما', 'ي', 'ك', 'ه', 'نا', 'كم',
    
    # Relatifs
    'الذي', 'التي', 'اللذان', 'اللتان', 'الذين', 'اللاتي', 'اللواتي',
    
    # Verbes auxiliaires
    'كان', 'كانت', 'كانوا', 'يكون', 'تكون', 'يكن', 'ليس', 'ليست', 'مازال',
    
    # Particules
    'قد', 'لم', 'لن', 'لما', 'ل', 'إن', 'إنما', 'أن', 'لأن', 'كي', 'لكي',
    
    # Adverbes
    'جدا', 'أيضا', 'كذلك', 'هكذا', 'هنا', 'هناك', 'هنالك', 'ثم', 'الآن', 'دائما',
    'أبدا', 'ربما', 'لعل', 'نعم', 'كلا', 'بلى', 'حقا', 'فعلا', 'طبعا',
    
    # Conjonctions
    'و', 'أو', 'لكن', 'بل', 'حتى', 'إذ', 'إذا', 'لو', 'لولا', 'كأن', 'ف', 'ثم',
    'بينما', 'رغم', 'إذن', 'لذلك', 'لذا', 'حيث', 'بحيث', 'منذ',
    
    # Pronoms attachés
    'له', 'لها', 'لهم', 'لهن', 'لهما', 'به', 'بها', 'بهم', 'بهن', 'بهما',
    'منه', 'منها', 'منهم', 'منهن', 'منهما', 'فيه', 'فيها', 'فيهم', 'فيهن',
    'عليه', 'عليها', 'عليهم', 'عليهن', 'إليه', 'إليها', 'إليهم', 'إليهن',
    'أنه', 'أنها', 'أنهم', 'أنهن', 'بي', 'بك', 'بنا', 'بكم', 'لي', 'لك', 'لنا',
    
    # Verbes génériques
    'يعد', 'تعد', 'يعتبر', 'تعتبر', 'يمكن', 'تمكن', 'يجب', 'تجب', 'يقول', 'تقول',
    'قال', 'قالت', 'ذكر', 'ذكرت', 'أشار', 'أشارت', 'أكد', 'أكدت', 'بين', 'بينت',
    
    # Mots génériques
    'شيء', 'أشياء', 'أمر', 'أمور', 'جزء', 'أجزاء', 'نوع', 'أنواع', 'بعض', 'كثير',

# Mots génériques de Wikipédia et sites web
    'الموسوعة', 'موسوعة', 'مقال', 'العمل', 'العالم', 'الإمام', 'الفقه',
    'الدكتور', 'الشيخ', 'محمد', 'أحمد', 'صحيح', 'ديسمبر', 'كيف', 'سورة',
    'القرآن', 'الحديث', 'الجزيرة', 'صورة', 'غزة', 'ثقافة', 'الآراء', 'السريع',
    'الرياضة', 'معنا', 'أعرض', 'تحريج', 'اقتصاد', 'منهج', 'بجامعة', 'أبي',
    'جامعة', 'تاريخ', 'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'معجم',
    
    # Chiffres
    'واحد', 'اثنان', 'ثلاثة', 'أربعة', 'خمسة', 'ستة', 'سبعة', 'ثمانية', 'تسعة', 'عشرة',
}

# 5. FILTRER les mots (NOTRE PROPRE FILTRE)
print("\n3. Filtrage des mots...")
mots_propres = []
for mot in mots:
    mot = mot.strip()
    # Ignorer si trop court
    if len(mot) < 3:
        continue
    # Ignorer si dans la liste d'exclusion
    if mot in mots_a_exclure:
        continue
    # Ignorer si commence par un article
    if mot.startswith('ال') and len(mot) > 2:
        mot_sans_article = mot[2:]  # Enlever "ال"
        if mot_sans_article in mots_a_exclure:
            continue
    mots_propres.append(mot)

print(f"   ✓ {len(mots_propres)} mots gardés après filtrage")

# 6. Compter et afficher top 30
compteur = Counter(mots_propres)
print("\n   Top 30 des mots:")
for i, (mot, freq) in enumerate(compteur.most_common(30), 1):
    print(f"   {i:2d}. {mot:20s} : {freq:4d}")

# 7. Recréer le texte avec SEULEMENT les mots propres
texte_filtre = ' '.join(mots_propres)
print(f"\n4. Texte filtré prêt: {len(texte_filtre)} caractères")

# 8. Remodeler pour l'arabe
print("\n5. Préparation arabe (RTL)...")
texte_reshape = arabic_reshaper.reshape(texte_filtre)
texte_bidi = get_display(texte_reshape)

# 9. Créer le nuage
print("\n6. Génération du nuage...")
wordcloud = WordCloud(
    width=2400,
    height=1350,
    background_color='white',
    max_words=60,
    colormap='viridis',
    font_path='/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',
    relative_scaling=1.0,
    min_font_size=25,
    prefer_horizontal=0.7,
    collocations=False
).generate(texte_bidi)

# 10. Sauvegarder
print("\n7. Sauvegarde...")
image = wordcloud.to_image()
image.save('nuages/nuage-arabe.png')

print("\n" + "=" * 50)
print("✓ TERMINÉ !")
print("=" * 50)
print("\nFichier: nuages/nuage-arabe.png")
print()
