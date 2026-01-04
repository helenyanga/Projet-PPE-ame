#!/bin/bash
source ./utils.sh # Import useful functions

CONFIG_FILE="word_context.conf"
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
else
    echo "Config file not found: $CONFIG_FILE" >&2
    exit 1
fi

write_metadata_kwic()
{
    local csv_path=$1 # csv/ru1-1.csv for example
    local filename=$2 # ru1-1 for example
    local metadata_path="$METADATA_FOLDER/$filename.conf"
    echo "KWIC="$csv_path"" >> $metadata_path
}

write_csv()
{
    local source_path=$1
    local export_path=$2 # csv/
    local pattern=$3
    local window=$CONTEXT_WINDOW  # number of context words before and after the keyword

    # Check if file exist and is not empty
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
    local headers=$CSV_HEADERS # Headers as defined in config file
    local pattern=${RAW_PATTERNS["$foldername"]}

    for subfolder in $folders/*; do
        local subfolder_name="$(basename "$subfolder")"
        local export_path="csv/${subfolder_name}.csv"
        echo -n $headers > "$export_path"

        for file in $(find "$subfolder" -maxdepth 1 -type f | sort -V); do
            # Count number of lines in the file
            line_count=$(wc -l < "$file")
            
            # Skip if only one line, one line files most likely only contain the target word which is NOT interesting
            if [[ "$line_count" -le 1 ]]; then
                echo "Skipping $file (only $line_count line/word)"
                continue
            fi
            write_csv "$file" "$export_path" "$pattern"
        done
        write_metadata_kwic "$export_path" "$subfolder_name"

        local export_filename="$(basename "$export_path")"
        # Removing empty lines
        # To do so we create a temporary file and then rename it
        sed -r '/^\s*$/d' "$export_path" > "$export_filename.tmp" && mv "$export_filename.tmp" "$export_path"
    done
}




