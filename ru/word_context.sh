#!/bin/bash
source ../utils.sh # Import useful functions

write_file_arrays()
{
    input_file=$1
    export_folder=$2
    filename="$(get_filename "$input_file")"
    # Possible export folder = txt/processed/$filename
    folder_exist "$export_folder"
    # \p{L} matches any unicode character 
    # (?<!\p{L}) no letter before the match
    # (?!\p{L}) no letter after the match
    pattern='(?<!\p{L})дух(а|у|ом|е|и|ов|ам|ами|ах)?(?!\p{L})'
    
    # Gets the word in the file 1 line of context after and before
    count=0
    current_export_file="$export_folder/$filename-$count.txt"

    grep -nPi -A1 -B1 --color "$pattern" "$input_file" | while IFS= read -r line; do
        if [[ "$line" == "--" ]]; then
            count=$((count+1))
            current_export_file="$export_folder/$filename-$count.txt"
            touch "$current_export_file"
        else
            echo "$line" >> "$current_export_file"
        fi
    done

}

# Spinner characters
spinner="/-\|"
spin_index=0
count_files="$(folder_length "txt/original/ru2/")"

count_file=0
source_folder=txt/original/ru2/*
count_files="$(folder_length "txt/original/ru2/")"

for file in $source_folder; do
    filename="$(get_filename "$file")"
    write_file_arrays $file "txt/processed/$filename"

    # Update spinner
    spin_char="${spinner:spin_index:1}"
    printf "\rConverting urls (%d/%d) %s" "$count_file" "$count_files" "$spin_char"

    # Move to next spinner
    spin_index=$(( (spin_index + 1) % 4 ))

    count_file=$((count_file+1))
done 
printf "\rAll files from %s have been converted to array files\n" \
        "$source_folder"

