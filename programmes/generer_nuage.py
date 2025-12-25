#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Génère un nuage de mots depuis corpus-arabe.txt - VERSION PROPRE
"""

import re
from wordcloud import WordCloud
import arabic_reshaper
from bidi.algorithm import get_display

print("=" * 50)
print("Génération du nuage de mots arabe")
print("=" * 50)

# Lire le fichier
print("\n1. Lecture du corpus...")
with open('nuages/corpus-arabe.txt', 'r', encoding='utf-8', errors='ignore') as f:
    texte = f.read()

print(f"   ✓ {len(texte)} caractères chargés")

# SUPER NETTOYAGE
print("\n2. Nettoyage du texte...")

# Supprimer tout ce qui est HTML/web
texte = re.sub(r'<[^>]+>', '', texte)  # Balises HTML
texte = re.sub(r'https?://[^\s]+', '', texte)  # URLs
texte = re.sub(r'www\.[^\s]+', '', texte)  # www.
texte = re.sub(r'\b[A-Z]{2,}\b', '', texte)  # Mots en MAJUSCULES (BUTTON, IFRAME, etc.)
texte = re.sub(r'\bhtml\b|\bHTM\b|\bcom\b|\borg\b|\bnet\b', '', texte, flags=re.IGNORECASE)
texte = re.sub(r'\d+', '', texte)  # Nombres
texte = re.sub(r'[^\u0600-\u06FF\s]', ' ', texte)  # Garder SEULEMENT l'arabe et espaces

print(f"   ✓ Texte nettoyé: {len(texte)} caractères")

# Liste EXHAUSTIVE de mots vides arabes
mots_vides = {
    # Articles et prépositions
    'في', 'من', 'إلى', 'على', 'عن', 'مع', 'عند', 'أمام', 'خلف', 'فوق', 'تحت',
    'بين', 'ضد', 'حول', 'دون', 'سوى', 'خلا', 'عدا', 'حاشا', 'منذ', 'بعد', 'قبل',
    'تحت', 'فوق', 'أسفل', 'أعلى', 'وراء', 'خارج', 'داخل', 'لدى', 'إزاء',
    
    # Conjonctions
    'و', 'أو', 'لكن', 'بل', 'حتى', 'إذ', 'إذا', 'لو', 'لولا', 'كأن', 'ف', 'ثم',
    'إن', 'أن', 'لأن', 'كي', 'لكي', 'حين', 'عندما', 'بينما', 'إذ', 'إذا',
    
    # Pronoms
    'ما', 'لا', 'هذا', 'هذه', 'ذلك', 'تلك', 'هؤلاء', 'أولئك', 'هذان', 'هاتان',
    'هو', 'هي', 'هم', 'هن', 'أنا', 'نحن', 'أنت', 'أنتم', 'أنتن', 'هما', 'أنتما',
    'ي', 'ك', 'ه', 'نا', 'كم', 'هم', 'هن',
    
    # Articles
    'ال', 'بال', 'لل', 'وال', 'فال', 'كال', 'الى', 'اللي', 'اللى',
    
    # Mots relatifs
    'الذي', 'التي', 'اللذان', 'اللتان', 'الذين', 'اللاتي', 'اللواتي', 'اللذين',
    'من', 'ما', 'مهما', 'أي', 'أية', 'متى', 'أين', 'أينما', 'حيث', 'حيثما',
    
    # Particules et adverbes
    'قد', 'لم', 'لن', 'لما', 'ل', 'لل', 'ليس', 'ليست', 'لم', 'لن', 'إن', 'إنما',
    'كل', 'بعض', 'كثير', 'قليل', 'عدة', 'عديد', 'جدا', 'أيضا', 'كذلك', 'هكذا',
    'هنا', 'هناك', 'هنالك', 'ثم', 'ثمة', 'الآن', 'حينئذ', 'عندئذ',
    'جدا', 'كثيرا', 'قليلا', 'أحيانا', 'دائما', 'أبدا', 'غالبا', 'ربما', 'لعل',
    'نعم', 'كلا', 'بلى', 'أجل', 'حقا', 'فعلا', 'طبعا', 'بالطبع',
    
    # Verbes auxiliaires très courants
    'كان', 'كانت', 'كانوا', 'يكون', 'تكون', 'أكون', 'نكون', 'يكن', 'تكن',
    'أصبح', 'تصبح', 'يصبح', 'أضحى', 'ظل', 'بات', 'صار', 'مازال', 'ما زال',
    'ليس', 'ليست', 'ليسوا', 'أصبح', 'أمسى', 'بات', 'ظل', 'صار',
    
    # Verbes très génériques
    'يعد', 'تعد', 'يعتبر', 'تعتبر', 'يمكن', 'تمكن', 'يجب', 'تجب', 
    'يقول', 'تقول', 'قال', 'قالت', 'ذكر', 'ذكرت', 'أشار', 'أشارت',
    'أكد', 'أكدت', 'أوضح', 'أوضحت', 'بين', 'بينت', 'يرى', 'ترى', 'رأى',
    'يجد', 'تجد', 'وجد', 'وجدت', 'يعرف', 'تعرف', 'عرف', 'عرفت',
    
    # Pronoms attachés
    'له', 'لها', 'لهم', 'لهن', 'لهما', 'به', 'بها', 'بهم', 'بهن', 'بهما',
    'لي', 'لك', 'لنا', 'لكم', 'بي', 'بك', 'بنا', 'بكم',
    'منه', 'منها', 'منهم', 'منهن', 'منهما', 'مني', 'منك', 'منا', 'منكم',
    'فيه', 'فيها', 'فيهم', 'فيهن', 'فيهما', 'في', 'فيك', 'فينا', 'فيكم',
    'عليه', 'عليها', 'عليهم', 'عليهن', 'عليهما', 'علي', 'عليك', 'علينا', 'عليكم',
    'إليه', 'إليها', 'إليهم', 'إليهن', 'إليهما', 'إلي', 'إليك', 'إلينا', 'إليكم',
    'أنه', 'أنها', 'أنهم', 'أنهن', 'أنهما', 'أني', 'أنك', 'أننا', 'أنكم',
    'ها', 'هي', 'هو', 'هما', 'هم', 'هن',
    
    # Mots génériques
    'شيء', 'أشياء', 'شئ', 'أمر', 'أمور', 'جزء', 'أجزاء', 'نوع', 'أنواع',
    'طريقة', 'طرق', 'كيفية', 'حالة', 'حالات', 'وضع', 'أوضاع',
    
    # Mots de liaison
    'أما', 'إما', 'بينما', 'رغم', 'مع', 'رغم', 'بالرغم', 'على الرغم',
    'إذن', 'لذلك', 'لذا', 'إذا', 'حيث', 'بحيث', 'إذ', 'منذ',
    
    # Chiffres en lettres
    'واحد', 'اثنان', 'ثلاثة', 'أربعة', 'خمسة', 'ستة', 'سبعة', 'ثمانية', 'تسعة', 'عشرة',
    'عشرون', 'ثلاثون', 'أربعون', 'خمسون', 'مئة', 'ألف', 'مليون',
    
    # Mots courts non significatifs
    'ان', 'لن', 'كن', 'لي', 'لك', 'هل', 'بل', 'عل', 'قل', 'فل',
}

# Remodeler pour l'arabe
print("\n3. Préparation du texte arabe (RTL)...")
texte_reshape = arabic_reshaper.reshape(texte)
texte_bidi = get_display(texte_reshape)

# Créer le nuage avec paramètres optimisés
print("\n4. Génération du nuage de mots...")
wordcloud = WordCloud(
    width=2400,
    height=1350,
    background_color='white',
    stopwords=mots_vides,
    max_words=80,  # Encore moins de mots
    colormap='viridis',
    font_path='/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',
    relative_scaling=1.0,  # Maximum ! Les mots fréquents seront ÉNORMES
    min_font_size=20,
    prefer_horizontal=0.7,
    collocations=False  # Éviter les répétitions
).generate(texte_bidi)

# Sauvegarder
print("\n5. Sauvegarde...")
image = wordcloud.to_image()
image.save('nuages/nuage-arabe.png')

print("\n" + "=" * 50)
print("✓ TERMINÉ !")
print("=" * 50)
print("\nFichier créé: nuages/nuage-arabe.png")
print()
