#!/bin/bash

# Import useful functions
source ../utils.sh 

# \p{L} matches any unicode character 
# (?<!\p{L}) no letter before the match
# (?!\p{L}) no letter after the match
pattern='(?<!\p{L})дух(а|у|ом|е|и|ов|ам|ами|ах)?(?!\p{L})'

input_file="file.txt"
filename="$(get_filename "$input_file")"
export_folder="txt/processed/$filename"
folder_exist "$export_folder"
# Gets the word in the file 1 line of context after and before
file=$(grep -nP -A1 -B1 --color '(?<!\p{L})дух(а|у|ом|е|и|ов|ам|ами|ах)?(?!\p{L})' $input_file)
count=0
current_export_file="$export_folder/$filename-$count.txt"

for w in $file; do
    if [[ $w == "--" ]]
    then
        count=$((count+1))
        current_export_file="$export_folder/$filename-$count.txt"
        touch $current_export_file
    else
        echo $w >> $current_export_file
    fi
done
