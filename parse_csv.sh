#!/bin/bash
# Purpose: IIS MI challenge script - Parse csv files v.0.5
# LB 05/07/2022
# "Usage $0 STRING:input_file STRING:output_file INT:desired_cols INT:desired_rows"
# -------------------------------------------------------

# SCRIPT SETTINGS
LOG_FILE=debug_parse_csv.log # debug log file
exec {BASH_XTRACEFD}>$LOG_FILE # redirect debug to $LOG_FILE
set -o errexit # exit on error
set -o xtrace # trace what gets executed for debugging

# Error codes
E_WRONGARGSNUM=65 # rename this variable
E_INVALIDARGS=66
E_NOTFOUND=86
E_NOTRECOGNIZED=87
E_SUBSCRIPT=88
E_INVALIDCOLS=95
E_INVALIDROWS=96
E_MATCHDATAROWS=97

#INPUT CHECKS
IS_NUMBER_RE='^[0-9]+$'
REPLACE_LINEBREAKS_SCRIPT=replace_linebreaks.sh
ADD_PHONEPREFIX_SCRIPT=fix_phone_nums.sh


if [ $# -lt 4 ]; then # check if all args are provided
    echo "Usage $0 STRING:input_file STRING:output_file INT:desired_cols INT:desired_rows"
    exit $E_WRONGARGSNUM
elif ! [[ $3 =~ $IS_NUMBER_RE ]] || ! [[ $4 =~ $IS_NUMBER_RE ]]; then # check if $3 and $4 are integers
    echo "Usage $0 STRING:input_file STRING:output_file INT:desired_cols INT:desired_rows"
    exit $E_INVALIDARGS
elif [ ! -e "$1" ]; then # check if the input file exists
    echo "File $1 not found."
    exit $E_NOTFOUND
elif [ ! -e "$REPLACE_LINEBREAKS_SCRIPT" ]; then # check if the script file exists
    echo "Script not found: $REPLACE_LINEBREAKS_SCRIPT."
    exit $E_NOTFOUND
elif [ ! -e "$ADD_PHONEPREFIX_SCRIPT" ]; then # check if the script file exists
    echo "Script not found: $ADD_PHONEPREFIX_SCRIPT."
    exit $E_NOTFOUND
fi


# SCRIPT VARIABLES
HEADERS_ACCOUNTS="accountid,company_name,address1,address2,address3,address4,postcode,website"
HEADERS_CONTACTS="contactid,accountid,first_name,last_name,job_title,mobile,telephone"
DATA_ROWS_START=^\"00
DATA_ROWS_RANGE=5 # data rows count tolerance percent (+/-) 


# functions to count number of columns and data rows
function CountColumns {
    # count commas in the header row, add 1
    columns=$(head -n1 $1 | grep -o "," | wc -l)
    ((columns+=1))
    echo $columns
}

function CountDataRows {
    # count lines starting with $DATA_ROWS_START 
    echo $(grep -c $DATA_ROWS_START $1)
}


# (1) CREATE WORKING COPY OF THE INPUT FILE
cat $1 > $2


# (2,3) CHECK COLUMNS AND ROWS OF THE INPUT FILE
#get number of cols and data rows:
initial_columns=$(CountColumns "$1") 
initial_data_rows=$(CountDataRows "$1")

# multiply following values by 100 to avoid floating point arithmetics
initial_rows_100=$((initial_data_rows * 100))
expected_rows_100=$(($4 * 100))
expected_rows_tolerance=$(($4 * $DATA_ROWS_RANGE))


# check if number of columns in the input file is same as desired amount columns
if [ $initial_columns != $3 ]; then
    echo "Error - Incorrect number of columns: Desired $3 Found: $inital_columns"
    exit $E_INVALIDCOLS
# number of data rows - exclude headers - (if value >|< $DATA_ROWS_RANGE, quit with error)
elif [ $((initial_rows_100)) -lt $((expected_rows_100 - expected_rows_tolerance)) ] \
     || [ $((initial_rows_100)) -gt $((expected_rows_100 + expected_rows_tolerance)) ]; then
    echo "Error - Incorrect number of data rows: Desired $4 Found: $initial_data_rows"
    exit $E_INVALIDROWS
fi


# (4,5,6) CHECK IF FILE IS 'Accounts' OR 'Contacts', THROW ERROR IF NEITHER  
firstline=$(head -n1 $2)
case ${1^} in
    *Contacts*)
        replacement_headers=${HEADERS_CONTACTS^^}
        bash fix_phone_nums.sh $2 # add internationl prefix to phone numbers
        if [ $? != 0 ]; then
            echo "Subscript error: $ADD_PHONEPREFIX_SCRIPT"
            exit E_SUBSCRIPT
        fi;;
    *Offices*)
        replacement_headers=${HEADERS_ACCOUNTS^^}
        bash replace_linebreaks.sh $2 # replace new lines with comas in the address
        if [ $? != 0 ]; then
            echo "Subscript error: $REPLACE_LINEBREAKS_SCRIPT"
            exit E_SUBSCRIPT
        fi;;
    *)
        echo "Input file not recognized." 
        exit $E_NOTRECOGNIZED;;
esac


# Overwrite headers with desired values depending on an input file
sed -i "s/$firstline/$replacement_headers/" $2 
#    ^ -i option to edit same file / add backup extension to make it work with BSD sed on MacOS ie. -i '.bak'


# (7) CHECK IF THE WORKING FILE HAS SAME AMOUNT OF ROWS AS THE ORIGINAL FILE
finished_columns=$(CountColumns "$1")
finished_data_rows=$(CountDataRows "$2")
if [ $initial_data_rows != $finished_data_rows ]; then
    echo "Error: Data rows not matching"
    exit $E_MATCHDATAROWS
fi


# EXIT WITH 0 IF SUCCESSFUL
echo "File created: $2 Columns: $finished_columns Data rows: $finished_data_rows"
exit 0