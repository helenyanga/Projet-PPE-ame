#!/bin/bash

file_exists()
{
    local filepath=$1
    if [ -f $filepath ]; then
        return 0 # File exists
    else
        return 1 # File does not exist
    fi
}

get_filename()
{
    local path=$1
    echo "$path" | rev | cut -d"/" -f1 | rev | cut -d "." -f1
}

get_parent_folder_name()
{
    local path=$1
    local path="$(dirname "$path")"
    local name=${path##*/}
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

