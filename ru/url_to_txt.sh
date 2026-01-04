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

write_metadata()
{
    local metadata_path=$1
    local index=$2
    local url=$3
    # Extracts result from check_encoding func and cuts off the html part to get only the name of the encoding
    local encoding=$(check_encoding "$url" | grep -oP '(?i)charset=\K\S+' | awk '{print tolower($0)}')
    # If it returns an empty string, it marks it as unavailable
    local encoding="${encoding:-indisponible}"
    local http_code=$(lynx --dump --head "$url" | grep -i "HTTP/" | tail -1 | awk '{print $2}')    
    local txt_dump=$4

    # Ensures there is no unnecessary appending
    if file_exists "$metadata_path"; then
        rm $metadata_path
    fi
    touch $metadata_path

    echo "INDEX="$index"" >> $metadata_path
    echo "URL="$url"" >> $metadata_path
    echo "ENCODING="$encoding"" >> $metadata_path
    echo "HTTP_CODE="$http_code"" >> $metadata_path
    echo "TXT_DUMP="$txt_dump"" >> $metadata_path
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
        
        # Dumps raw html in background
        wget -q $url -O html_dump/$base_name-$count.html  &

        write_metadata "$METADATA_FOLDER/$base_name-$count.conf" $count $url "$output_folder/$base_name/$base_name-$count.txt"
        # HTML dump is just too annoying to write within the appropriate func
        # Not the first principle of good programming I am breaking with bash...
        echo "HTML_DUMP="html_dump/$base_name-$count.html"" >> "$METADATA_FOLDER/$base_name-$count.conf"

        count=$((count+1))
    done < "$urls_path"

    # Final success message
    printf "\rAll urls from %s have been converted to txt files in %s%s\n" \
        "$urls_path" "$output_folder" "$base_name"
}

get_urls $1 "txt/original"

# Possible paths : "urls/ru1.txt" ; "urls/ru2.txt"