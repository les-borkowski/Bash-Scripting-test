# IIS MI challenge script - Parse .csv files v.0.4

## Usage

Usage: parse_csv.sh STRING:input_file STRING:output_file INT:desired_cols INT:desired_rows

Example: parse_csv.sh IIS_Contacts_Extract.csv contacts.csv 7 15 

Note: input file needs "Contacts" or "Accouts" string in its name to enable appropriate subscripts.

## Files

parse_csv.sh - main script

fix_phone_nums.sh - inserts +44 prefix instead of 0 in a phone number

replace_linbreaks.sh - removes undesired linebreaks from a .csv file

*LB July 2022*