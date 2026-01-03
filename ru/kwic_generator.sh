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
    source_path=$1
    export_path=$2
    window=3  # number of context words before and after the keyword

    # Only match the exact word 'душа' and its flexions
    pattern='\bдуш(а|и|е|у|ой|ою|ами|ах)\b'

    [[ -s "$export_path" ]] && echo "" >> "$export_path"

    # read the file into an array of words (one per line)
    mapfile -t words < "$source_path"
    len=${#words[@]}

    for i in "${!words[@]}"; do
        word="${words[$i]}"
        if [[ "$word" =~ ^душ(а|и|е|у|ой|ою|ами|ах)$ ]]; then
            # Collect context
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
    folders="txt/processed/ru1/*"

    headers=$HEADERS # Headers as defined in config file
    echo -n $headers > "kwic.csv"
    for subfolder in txt/processed/ru1/*; do
        for file in $(find "$subfolder" -maxdepth 1 -type f | sort -V); do
            # Count number of lines in the file
            line_count=$(wc -l < "$file")
            
            # Skip if only one line
            if [[ "$line_count" -le 1 ]]; then
                echo "Skipping $file (only $line_count line)"
                continue
            fi
            write_csv "$file" "kwic.csv"
        done
    done
    sed -r '/^\s*$/d' "kwic.csv" > kwic.tmp && mv kwic.tmp kwic.csv
}




