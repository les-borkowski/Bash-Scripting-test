#!/bin/bash
# Purpose: find and replace unnecessary linebreaks in a CSV file
# LB 03/07/2022
# Usage: $0 filename
# --------
# set -x

E_WRONGARGS=65
E_NOTFOUND=86


# check for arguments
if [ $# -lt 1 ]; then
    echo "Usage $0 filename"
    exit $E_WRONGARGS
# check if the I/O file exists
elif [ ! -e "$1" ]; then
    echo "File $1 not found."
    exit $E_NOTFOUND
fi

sed -i "s/\r//g" $1 # convert linebreaks from dos to unix
sed -n -e 'H;${x;s/\n/,/g;s/^,//;p;}' $1 > file.tmp # convert all linebreaks to commas, excpet for the EOF
sed 's/,"0/\n"0/g' file.tmp > $1 # convert commas at the start of the line to linebreaks
rm file.tmp

exit 0