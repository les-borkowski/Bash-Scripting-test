# IIS MI challenge script - Parse .csv files v.0.5

## Description

Bash script to parse given .csv files (create copy of the input file, check columns and rows of the input file, replace headers, fix newlines, add prefix to phone numbers, check if the output is correct, logging, error checking).

Script takes four argument as parameters: input file (1), output file (2),  number of expected columns in the file (3), number of expected rows in the file (4)

### Script variables

- HEADERS_ACCOUNTS: comma separated headers for the output accounts file
- HEADERS_CONTACTS: comma separated headers for the output contacts file
- DATA_ROWS_START: regular expression to identify data row in a file
- DATA_ROWS_RANGE: number which limits rows difference in the output file. Set to 5 (+-5%)

### Debugging

Debugging log can be found in debug_parse_csv.log file - contains details of the last processed file.

###  Subscripts

- fix_phone_nums.sh - Will find the first "0" in a phone number and replace it with a prefix (default is "+44")
- replace_linebreaks.sh - Will remove unnecessary linebreaks from a csv file. Converts linebreaks to UNIX if needed, finds beginning of a data row in a file, removes all linebreaks, then inserts linebreak before start of a data row.

## Requirements

- bash 4+
- sed (Gnu version)

## Usage

Usage: parse_csv.sh STRING:input_file STRING:output_file INT:desired_cols INT:desired_rows

Example: "parse_csv.sh IIS_Contacts_Extract.csv contacts.csv 7 15"

*Note: input file needs "Contacts" or "Accounts" string in its name to run correct subscripts.*

## Files

- parse_csv.sh - main script
- fix_phone_nums.sh - inserts +44 prefix instead of 0 in a phone number
- replace_linebreaks.sh - removes undesired linebreaks from a .csv file
- debug_parse_csv.log - Log file
- one_script_run_them_all.sh - short script that will pass files and desired parameters to parse_csv.sh, run the main script and print output files to the console

*LB July 2022*
