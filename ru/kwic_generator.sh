#!/bin/bash
source ./utils.sh # Import useful functions

CONFIG_FILE="word_context.conf"
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
else
    echo "Config file not found: $CONFIG_FILE" >&2
    exit 1
fi

write_csv()
{
    local source_path=$1
    local export_path=$2
    local pattern=$3
    local window=$CONTEXT_WINDOW  # number of context words before and after the keyword

    [[ -s "$export_path" ]] && echo "" >> "$export_path"

    # Read the file as an array of words
    mapfile -t words < "$source_path"
    len=${#words[@]}

    for i in "${!words[@]}"; do
        word="${words[$i]}"
        if [[ "$word" =~ ^$pattern$ ]]; then
            # Extracts context
            line=""
            for ((j=i-window; j<=i+window; j++)); do
                if (( j < 0 || j >= len )); then
                    line+="; "
                else
                    line+="${words[$j]}; "
                fi
            done
            # Remove trailing space and semicolon
            line="${line%; }"
            echo "$line" >> "$export_path"
        fi
    done
}


write_csv_files()
{
    local folders=$1 # "txt/processed/ru1/*" for instance
    local foldername="$(basename "$folders")" 
    local export_path=$2 # "kwic.csv" for instance
    local headers=$CSV_HEADERS # Headers as defined in config file
    local pattern=${RAW_PATTERNS["$foldername"]}

    echo -n $headers > "$export_path"
    for subfolder in $folders/*; do
        for file in $(find "$subfolder" -maxdepth 1 -type f | sort -V); do
            # Count number of lines in the file
            line_count=$(wc -l < "$file")
            
            # Skip if only one line, one line files most likely only contain the target word which is NOT interesting
            if [[ "$line_count" -le 1 ]]; then
                echo "Skipping $file (only $line_count line)"
                continue
            fi
            write_csv "$file" "$export_path" "$pattern"
        done
    done
    local export_filename="$(get_filename $export_path)"
    # Removing empty lines
    # To do so we create a temporary file and then rename it
    sed -r '/^\s*$/d' "$export_path" > $export_filename.tmp && mv $export_filename.tmp $export_path
}




