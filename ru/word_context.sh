#!/bin/bash
source ../utils.sh # Import useful functions

write_file_arrays()
{
    local input_file=$1
    local export_folder=$2
    local filename="$(get_filename "$input_file")"
    # Possible export folder = txt/processed/$filename
    folder_exist "$export_folder"
    # \p{L} matches any unicode character 
    # (?<!\p{L}) no letter before the match
    # (?!\p{L}) no letter after the match
    local pattern='(?<!\p{L})дух(а|у|ом|е|и|ов|ам|ами|ах)?(?!\p{L})'
    
    # Gets the word in the file 1 line of context after and before
    local count=0
    local current_export_file="$export_folder/$filename-$count.txt"

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

process_files_with_spinner() 
{
    local source_folder_path=$1 # txt/original/ru2
    local export_folder_base=$2 # txt/processed

    local source_folder="$source_folder_path/*"
    local spinner="/-\|"
    local spin_index=0
    local count_files
    count_files=$(folder_length "$source_folder_path")
    local count_file=0

    for file in $source_folder; do
        local filename
        filename="$(get_filename "$file")"
        write_file_arrays "$file" "$export_folder_base/$filename"

        # Update spinner
        local spin_char="${spinner:spin_index:1}"
        printf "\rConverting files (%d/%d) %s" "$count_file" "$count_files" "$spin_char"

        # Move to next spinner
        spin_index=$(( (spin_index + 1) % 4 ))

        count_file=$((count_file+1))
    done

    printf "\rAll files from %s have been converted to array files\n" "$source_folder_path"
}

process_files_with_spinner "txt/original/ru2" "txt/processed"
process_files_with_spinner "txt/original/ru1" "txt/processed"
