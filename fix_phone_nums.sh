#!/bin/bash
# Purpose: change first 0 in a phone number to +44
# LB 04/07/2022 v.0.5
# Usage: $0 filename
# ------------------------------------------------
# set -x

E_WRONGARGS=65
E_NOTFOUND=86

# check for arguments
if [ $# -lt 1 ]
then
    echo "Usage $0 filename"
    exit $E_WRONGARGS
fi

# check if the I/O file exists
if [ ! -e "$1" ]
then
    echo "File not found."
    exit $E_NOTFOUND
fi

IFS=$'\n' # set string separator to linebreak
for number in $(grep -oh '"0[1-9][0-9 ]\+"' $1) # grep numbers and spaces between double quotes
#                     ^^ -o show only matching text -h --no-filename
do
    prefixed_number=${number/\"0/\"+44}
    sed -i '.bak' "s/$number/$prefixed_number/" $1
done

IFS=$' ' # reset IFS

exit 0