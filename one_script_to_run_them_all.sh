#!/bin/bash
# Purpose: pass files and arguments to the main script
# LB 04/07/2022
# -------------

bash parse_csv.sh IIS_Offices_Extract.csv accounts.csv 8 10
echo
cat accounts.csv
echo
bash parse_csv.sh IIS_Contacts_Extract.csv contacts.csv 7 15
echo
cat contacts.csv


exit 0