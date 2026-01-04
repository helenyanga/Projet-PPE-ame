#!/bin/bash
source ./utils.sh 

CONFIG_FILE="word_context.conf"
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
else
    echo "Config file not found: $CONFIG_FILE" >&2
    exit 1
fi

check_encoding()
{
    local url=$1
    local encoding=$(lynx --dump --head $url | grep -i 'charset=' | awk '{print tolower($0)}')
    echo "$encoding"
}

is_utf()
{
    local encoding=$1
    if [[ $encoding==$UTF_ENCODING_LINE ]];then
        return 0
    else
        return 1
    fi
}

make_txt()
{
    url=$1
    output_path=$2
    local encoding="$(check_encoding $url)"
    local is_unicode="$(is_utf $encoding)"
    if is_utf "$encoding"; then
        lynx --dump $url > $output_path
    else
        echo "$url is $encoding"
        lynx --dump $url | iconv -f windows-1251 -t UTF-8 -o $output_path
    fi
}

get_urls()
{
    urls_path=$1
    output_folder=$2

    # Spinner characters
    spinner="/-\|"
    spin_index=0
    count_urls="$(folder_length "$urls_path")"

    count=1
    base_name="$(get_filename "$urls_path")"
    folder_path_exists "$output_folder/$base_name"
    while read -r url
    do 
        make_txt "$url" "$output_folder/$base_name/$base_name-$count.txt"

        # Update spinner
        spin_char="${spinner:spin_index:1}"
        printf "\rConverting urls (%d/%d) %s" "$count" "$count_urls" "$spin_char"

        # Move to next spinner
        spin_index=$(( (spin_index + 1) % 4 ))

        count=$((count+1))
    done < "$urls_path"

    # Final success message
    printf "\rAll urls from %s have been converted to txt files in %s%s\n" \
        "$urls_path" "$output_folder" "$base_name"
}

get_urls $1 "txt/original"

# Possible paths : "urls/ru1.txt" ; "urls/ru2.txt"