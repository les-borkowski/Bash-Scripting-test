#!/bin/bash
# Purpose: ISS MI challenge script - Parse csv files v.01
# LB 01/07/2022
# -------------------------------------------------------

#script settings
set -o errexit #exit on error
set -o xtrace #trace what gets executed for debugging

#declare variables here
log_file=error-log.log
# Counts for error checking 
initial_columns=0
initial_data_rows=0
finished_columns=0
finished_data_rows=0
# Desired headers - convert to upper case
headers_accounts="accountid,company_name,address1,address2,address3,address4,postcode,website"
headers_contacts="contactid,accountid,first_name,last_name,job_title,mobile,telephone"

#functions to check number of columns and data rows 
function count_data_rows {
    data_rows=0
    while read line
    do
        #echo "Line: $line"
        ((data_rows+=1))
    done < <(tail -n +2 $1 )
    echo $data_rows
}

function count_columns {
    # count comas in the header row, add 1
    columns=$(head -n1 $1 | grep -o "," | wc -l)
    ((columns+=1))
    echo $columns
}


#1 create working copy of a file
if (($# == 2)); then
    cat $1 > $2
    echo "Copy created in $2"
else
    echo "1. Invalid arguments. Usage: parse_cv.sh input_file output_file" | tee -a ${log_file}
fi

#2 check the file
#get number of cols and data rows:
initial_columns=$(count_columns "$2") 
initial_data_rows=$(count_data_rows "$2")

#if not correct, throw error
    # number of columns (if not correct, quit with error) 
    # number of data rows - exclude headers - (if value > +-5%, quit with error)


#3 change the headers (stored in an array)
    
#read first line of $2 file
firstline=$(head -n1 $2)
echo "Initial: $firstline"
#case statement -> will need fixing - shouldn't depend on output file name
case $2 in
    "contacts.csv")
        replacement_headers=$headers_contacts;;
    "accounts.csv")
        replacement_headers=$headers_accounts;;
esac

#set var repl_head with accounts_correct_headers
sed -i'.bak' "s/$firstline/$replacement_headers/" $2 # add -i option to edit same file / backup extension needed to make it work on mac

firstline2=$(head -n1 $2) #for error checking
echo "Corrected: $firstline2" #for error checking

#4 if file is accounts.csv
    # replace new lines with comas in the address

#5 if file is contacts.csv 
    # replace 0 in the phone numbers with +44

#6 check if the working file has same amount of rows as the original file

# exit with 0 if successful
exit 0