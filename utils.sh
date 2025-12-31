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

path_exists()
{
    folder=$1
    if [ ! -d "$folder" ]; then 
        mkdir -p "$folder"
    fi
}

folder_length() {
    dir="$1"
    # Check if directory exists
    [[ -d "$dir" ]] || { echo 0; return; }
    # Count only regular files in directory (not subdirectories)
    find "$dir" -maxdepth 1 -type f | wc -l | xargs
}
