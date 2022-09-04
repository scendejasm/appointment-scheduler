#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

# A salon appointment scheduler 
echo -e "\n~~~ A salon appointment scheduler ~~~"
# Give users options to choose 
MAIN_MENU () {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "\nPlease select from our current services:\n"
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo -e "$SERVICES" | while read SERVICE_ID BAR SERVICE
  do
    echo "$SERVICE_ID) $SERVICE"
  done

  read SERVICE_ID_SELECTED    
  # if service_id does not exist 
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # send to services menu
    MAIN_MENU "Please enter a valid number"
  else 
    # get service_id
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    # if no service_id
    if [[ -z $SERVICE_NAME ]]
    then
      # send to services menu
      MAIN_MENU "Please enter a valid service number"
    else
      echo "Let's schedule your appointment for $SERVICE_NAME"
      SERVICE_MENU $SERVICE_NAME $SERVICE_ID_SELECTED
    fi
  fi
}

# Service Menu
SERVICE_MENU () {
  SERVICE_ID_SELECTED=$2
  # get customer info
  echo -e "\nWhat is your phone number?"
  read CUSTOMER_PHONE 

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers where phone='$CUSTOMER_PHONE'")

  # if not found
  if [[ -z $CUSTOMER_NAME ]]
  then
    # get new customer name
    echo -e "\nWhat's your name?"
    read CUSTOMER_NAME

    # insert new customer 
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
  fi

  # get customer_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # get requested appt time 
  echo -e "\nWelcome $CUSTOMER_NAME, what time would you like to shedule your $1 appointment?"
  read SERVICE_TIME

  # insert appt 
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  # give customer appt info 
  echo -e "\nI have put you down for a $1 at $SERVICE_TIME, $CUSTOMER_NAME."
  #MAIN_MENU "You can't type ctrl+C to exit"
}
MAIN_MENU