#!/bin/bash

CONFIG_FILE="word_context.conf"
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
else
    echo "Config file not found: $CONFIG_FILE" >&2
    exit 1
fi

source utils.sh
source url_to_txt.sh
source word_context.sh
source kwic_generator.sh

main_dialog() 
{
    local urls_folder="urls"
    local files=("$urls_folder"/*)

    echo "Quel fichier de URLs voulez-vous convertir ?"

    # List all files with numbers
    local i=1
    for f in "${files[@]}"; do
        printf "%d) %s\n" "$i" "${f##*/}"
        ((i++))
    done

    echo
    read -p "Choix numéro: " choice

    # Validate input
    if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
        echo "Entrée invalide, veuillez entrer un nombre."
        return 1
    fi

    local index=$((choice - 1))
    if (( index < 0 || index >= ${#files[@]} )); then
        echo "Choix hors limites."
        return 1
    fi

    local selected_file="${files[index]}"
    echo "Fichier sélectionné : ${selected_file##*/}"
    
    # Confirm
    echo "Confirmez ?"
    echo "1) Oui"
    echo "2) Non"
    read -p "Votre choix: " confirm

    if [[ "$confirm" == "1" ]]; then
        get_urls "$selected_file" "txt/original"
        local filename="$(get_filename "$selected_file")"
        local pattern="${RAW_PATTERNS[$filename]}"
        local export_dir=$PROCESSED_EXPORT_DIR
        local source_dir="$SOURCE_DIR/$filename"
        process_files $source_dir $export_dir $pattern
        write_csv_files "$export_dir/$filename"
    else
        echo "Recommençons..."
        main_dialog
    fi
}

# Run the main dialog
main_dialog
