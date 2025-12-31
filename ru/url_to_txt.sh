#!/bin/bash
source ../utils.sh 
make_txt()
{
    url=$1
    output_path=$2
    lynx --dump $url > $output_path
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
    folder_exist "$output_folder/$base_name"
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