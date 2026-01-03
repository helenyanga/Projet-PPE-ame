#!/bin/bash
source ./utils.sh # Import useful functions

CONFIG_FILE="word_context.conf"
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
else
    echo "Config file not found: $CONFIG_FILE" >&2
    exit 1
fi


#folders="txt/processed/ru1/*"
#for folder in $folders;
#do 
#    echo $folder
#done
headers="before4;before3;before2;before1;target;after1;after2;after3;after4"
echo -n $headers>"kwic.csv"

write_csv_processed_file()
{
    source_path=$1
    export_path=$2
    pattern=$3

    [[ -s "kwic.csv" ]] && echo "" >> "kwic.csv"
    pattern='душ(а|и|е|у|ой|ою|ами|ах)'
    targets="$(grep -B4 -A4 -E --color $pattern sample.txt)"
    for t in $targets; do
        if [[ $t == "--" ]]; then
            truncate -s-2 "kwic.csv"
            echo "">>"kwic.csv"
        else
            echo -n "$t; " >> "kwic.csv"
        fi
    done
    truncate -s-2 "kwic.csv"
}





