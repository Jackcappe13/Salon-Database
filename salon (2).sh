#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ My Salon ~~~~~\n"

MAIN_MENU(){
  # if you are sent to main menu with an argument/message go to main menu and display message
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  
  SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id")
  if [[ -z $SERVICES ]]
    then
      echo "We have no services available at the moment."
    else
      echo -e "\nOur Services:\n"
      echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
    do
      echo "$SERVICE_ID) $SERVICE_NAME"
    done
    echo -e "Choose one service\n"
    read SERVICE_ID_SELECTED
    SERVICE=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    if [[ -z SERVICE ]]
      then
        MAIN_MENU "Service not found"
      else
        # get input for customer phone number
        echo -e "\nInsert your phone number:\n"
        read CUSTOMER_PHONE
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        # if the customer phone is not present already insert it and its name
        if [[ -z $CUSTOMER_NAME ]]
        then
        # get input for customer name
        echo -e "\nInsert your name:\n"
        read CUSTOMER_NAME
        # insert new customer
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
        fi
        # get input for customer service time
        echo -e "\nInsert the time of your appointment:\n"
          read SERVICE_TIME
          CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        # insert appointment  
        INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
        SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
        # output message to user
        echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."

    fi
  fi
}
MAIN_MENU