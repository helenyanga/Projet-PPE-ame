#!/bin/bash

get_filename()
{
    path=$1
    echo "$path" | rev | cut -d"/" -f1 | rev | cut -d "." -f1
}

get_folder_name()
{
    path=$1
    path="$(dirname "$path")"
    name=${path##*/}
    echo $name
}

folder_path_exists()
{
    local folder=$1
    if [ ! -d "$folder" ]; then 
        mkdir -p "$folder"
    fi
}

folder_length() {
    local dir="$1"
    [[ -d "$dir" ]] || { echo 0; return; }
    find "$dir" -mindepth 1 | wc -l
}

