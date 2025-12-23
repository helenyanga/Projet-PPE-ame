#!/bin/bash

add_url()
{
    new_url=$1

    path=
    answered=false 
    while [ "$answered" == false ]
    do 
        echo "Ajouter cette url à \n1. ru1.txt \n2. ru2.txt"
        read path_qst
        if [[ "$path_qst" == "1" ]]
        then
            path="urls/ru1.txt"
            answered=true
        elif [[ "$path_qst" == "2" ]]
        then
            path="urls/ru2.txt"
            answered=true
        else
            echo "Je n'ai pas compris, répondez 1 ou 2."
        fi
    done 

    if ! grep -q "$new_url" "$path"; then 
        echo "$new_url" >> "$path"
        echo "Nouvelle url ajoutée !"
    else
        echo "Url déjà ajoutée"
    fi
}
add_url $1