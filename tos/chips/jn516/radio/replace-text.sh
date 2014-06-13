#!/bin/bash
echo "replace $1 .."
echo ".. with $2"
#find . -type f -print0 | xargs -0 sed -i "s/$1/$2/g"

find . -type f -exec sed -i "s/$1/$2/g" {} +
