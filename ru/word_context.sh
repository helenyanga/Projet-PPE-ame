#!/bin/bash
source ./utils.sh # Import useful functions

CONFIG_FILE="word_context.conf"
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
else
    echo "Config file not found: $CONFIG_FILE" >&2
    exit 1
fi

write_file_arrays()
{
    local input_file=$1
    local export_folder=$2
    local pattern=$3
    local filename="$(get_filename "$input_file")"
    # Possible export folder = txt/processed/$filename
    folder_path_exists "$export_folder"
    
    local count=0
    local current_export_file="$export_folder/$filename-$count.txt"
    # Gets the word in the file 1 line of context after and before
    while IFS= read -r line; do
        if [[ "$line" == "--" ]]; then
            count=$((count+1))
            current_export_file="$export_folder/$filename-$count.txt"
            touch "$current_export_file"
        else
            # Horrible data cleaning part
            clean_line=$(echo "$line" | sed -E '
                s/\[[^]]*\]//g;      # remove anything inside brackets
                s/[(){};,.:!?^]//g;    # remove undesirable punctuation
                s/[^А-Яа-яЁё ]//g   # remove anything non-cyrillic BUT KEEPS SPACES
                s!http[s]\?://\S*!!g # remove links
            ')
            for word in $clean_line; do
                echo "$word"
            done >> "$current_export_file"
        fi
    done < <(grep -Pi -A1 -B1 --color "$pattern" "$input_file")
}

process_files() 
{
    local source_folder_path=$1   # ex txt/original/ru2
    local export_folder_base=$2   # ex txt/processed
    local pattern=$3              # regex pattern to use

    local folder_name="${source_folder_path##*/}"
    local export_folder="$export_folder_base/$folder_name"
    echo "Exporting to $export_folder"
    folder_path_exists "$export_folder"

    local folder_count
    folder_count="$(folder_length "$export_folder")"
    if [[ "$folder_count" -ne 0 ]]; then
        echo "Export folder not empty ($folder_count items)"
        echo "Deleting content..."
        rm -rf "$export_folder"/*
    fi

    # Fancy spinner for startup
    local message="Starting file processing"
    printf "%s" "$message"
    for i in {1..3}; do
        printf "."
        sleep 0.1
    done
    printf "\rFile processing started!\n"

    # Get all files in the source folder
    local files=("$source_folder_path"/*)
    local spinner="/-\|"
    local spin_index=0
    local count_files="${#files[@]}"
    local count_file=0

    # Process each file
    for file in "${files[@]}"; do
        local filename
        filename="$(get_filename "$file")"

        # Call writing and cleaning function
        write_file_arrays "$file" "$export_folder/$filename" "$pattern"

        # Update spinner
        local spin_char="${spinner:spin_index:1}"
        printf "\rProcessing files (%d/%d) %s" "$count_file" "$count_files" "$spin_char"

        # Next spinner char
        spin_index=$(( (spin_index + 1) % 4 ))
        count_file=$((count_file + 1))
    done

    # Success message
    printf "\rAll files from %s have been processed\n" "$source_folder_path"
}

# Center of operations, where this whole madness starts
dialog() {
    echo "Quel dossier convertir ?"

    local source_dir=$SOURCE_DIR
    local files=("$source_dir"/*)
    
    local i=1
    for f in "${files[@]}"; do
        printf '%d) %s\n' "$i" "${f##*/}"
        ((i++))
    done

    echo
    read -p "Choix numéro: " choice

    # Input 
    if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
        echo "Entrée invalide"
        return 1
    fi

    # Map number into the array
    local index=$((choice - 1))

    # Bounds check
    if (( index < 0 || index >= ${#files[@]} )); then
        echo "Choix hors limites"
        return 1
    fi

    local selected="${files[index]}"

    echo "Dossier sélectionné : ${selected##*/}"
    echo "Confirmez ?"
    echo "1) Oui"
    echo "2) Non"
    read -p "" choice2

    if [[ $choice2 == "2" ]];then
        dialog # Starts the function again to change choice
    else
        local folder_name="${selected##*/}"
        local export_dir=$PROCESSED_EXPORT_DIR
        local pattern="${PATTERNS[$folder_name]}"
        process_files $selected $export_dir $pattern
    fi
}

