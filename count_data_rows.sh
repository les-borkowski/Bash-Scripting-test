#!/bin/bash
# Purpose: Count columns in a csv file
# LB 07/2022
# Usage: count_columns filename
# ---------------
set -x

data_rows=0

while read line
do
    #echo "Line: $line"
    ((columns+=1))
done < <(tail -n +2 $1)
echo $data_rows > data_rows.tmp
echo "Found $data_rows in file $1"
exit 0