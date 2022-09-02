#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon -c"

# A salon appointment scheduler 
echo -e "\n~~~ A salon appointment scheduler ~~~"
echo -e "\nHere is a list of our current services:"
SERVICES=$($PSQL "SELECT * FROM services")
echo $SERVICES