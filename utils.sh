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
        mkdir "$folder"
    fi
}