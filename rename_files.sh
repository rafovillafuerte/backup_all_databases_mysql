#!/bin/bash

while IFS=" " read filename; do

renamed=$(echo "$filename" | sed 's/junglesec@cock.li//g')

mv $filename $renamed

done < l
