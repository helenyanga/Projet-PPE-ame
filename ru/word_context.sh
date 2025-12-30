#!/bin/bash

# Import useful functions
source ../utils.sh 

# \p{L} matches any unicode character 
# (?<!\p{L}) no letter before the match
# (?!\p{L}) no letter after the match
pattern='(?<!\p{L})дух(а|у|ом|е|и|ов|ам|ами|ах)?(?!\p{L})'

# Gets the word in the file 1 line of context after and before
test=$(grep -nP -A1 -B1 --color '(?<!\p{L})дух(а|у|ом|е|и|ов|ам|ами|ах)?(?!\p{L})' file.txt )

for w in $test; do
    if [[ $w == "--" ]]
    then
        echo "trails"
    fi
    echo $w >> test.txt
done
