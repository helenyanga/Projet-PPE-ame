#!/bin/bash

get_filename()
{
    path=$1
    echo "$path" | rev | cut -d"/" -f1 | rev | cut -d "." -f1
}

folder_exist()
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
