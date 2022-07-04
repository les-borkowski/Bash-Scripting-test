#!/bin/bash
# Purpose: ISS MI challenge script - Parse csv files v.03
# LB 04/07/2022
# "Usage $0 STRING:input_file STRING:output_file INT:desired_cols INT:desired_rows"
# -------------------------------------------------------

# SCRIPT SETTINGS
LOG_FILE=debug_parse_csv.log # debug log file
exec {BASH_XTRACEFD}>$LOG_FILE # redirect debug to $LOG_FILE
set -o errexit # exit on error
set -o xtrace # trace what gets executed for debugging

# Error codes
E_WRONGARGS=65 # rename this variable
E_INVALIDARGS=66
E_NOTFOUND=86
E_NOTRECOGNIZED=87
E_INVALIDCOLS=95
E_INVALIDROWS=96
E_MATCHDATAROWS=97

#INPUT CHECKS
IS_NUMBER_RE='^[0-9]+$'

if [ $# -lt 4 ]; then # check if all args are provided
    echo "Usage $0 input_file output_file desired_cols desired_rows"
    exit $E_WRONGARGS
elif ! [[ $3 =~ $IS_NUMBER_RE ]] || ! [[ $4 =~ $IS_NUMBER_RE ]]; then # check if $3 and $4 are integers
    echo "Usage $0 input_file output_file desired_cols desired_rows"
    exit $E_INVALIDARGS
elif [ ! -e "$1" ]; then # check if input file exists
    echo "File not found."
    exit $E_NOTFOUND
fi

# DESIRED HEADERS FOR OUTPUT FILES
HEADERS_ACCOUNTS="accountid,company_name,address1,address2,address3,address4,postcode,website"
HEADERS_CONTACTS="contactid,accountid,first_name,last_name,job_title,mobile,telephone"
DATA_ROWS_RANGE=5 # data rows count tolerance percent (+/-) 

# functions to count number of columns and data rows
function count_columns {
    # count comas in the header row, add 1
    columns=$(head -n1 $1 | grep -o "," | wc -l)
    ((columns+=1))
    echo $columns
}

function count_data_rows {
    # count lines starting with <"00> 
    echo $(grep -c '^\"00' $1)
}

# CREATE WORKING COPY OF THE INPUT FILE
cat $1 > $2
echo "Copy created in $2"

#2 CHECK COLUMNS AND ROWS OF THE INPUT FILE
#get number of cols and data rows:
initial_columns=$(count_columns "$1") 
initial_data_rows=$(count_data_rows "$2")

# avoid floats in percentage calculations
initial_rows_100=$((initial_data_rows * 100))
expected_rows_100=$(($4 * 100))
expected_rows_tolerance=$(($4 * $DATA_ROWS_RANGE)) # move 5 to a variable

# check if number of columns in the input file is same as desired amount columns
if [ $initial_columns != $3 ]; then
    echo "Error - Incorrect number of columns" # show number here
    exit $E_INVALIDCOLS
# number of data rows - exclude headers - (if value >|< 5%, quit with error)
elif [ $((initial_rows_100)) -lt $((expected_rows_100 - expected_rows_tolerance)) ] \
     || [ $((initial_rows_100)) -gt $((expected_rows_100 + expected_rows_tolerance)) ]; then
    echo "Error - Incorrect number of data rows" # show number here
    exit $E_INVALIDROWS
fi


#3 CHECK IF FILE IS 'Accounts' or 'Contacts'    
#read first line of $2 file
firstline=$(head -n1 $2)
case ${1^} in
    *Contacts*)
        echo 'Contacts';;
        # replacement_headers=$headers_contacts;;
        # replace 0 in the phone numbers with +44
    *Offices*)
        echo "Accounts";;
        # replacement_headers=$headers_accounts;;
        # replace new lines with comas in the address
    *)
        echo "File not recognized."
        exit $E_NOTRECOGNIZED
esac

#set var repl_head with accounts_correct_headers
sed -i'.bak' "s/$firstline/$replacement_headers/" $2 # add -i option to edit same file / backup extension needed to make it work on mac

#6 check if the working file has same amount of rows as the original file
finished_data_rows=$(count_data_rows "$2")
if [ $initial_data_rows != $finished_data_rows ]; then
    echo "Error: Data rows not matching"
    exit $E_MATCHDATAROWS
fi

# exit with 0 if successful
exit 0