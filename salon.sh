#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else   
    echo -e "Welcome to My Salon, how can I help you?\n" 
  fi

  AVAILABLE_SERVICES_RESULT=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$AVAILABLE_SERVICES_RESULT" | while read SERVICE_ID BAR NAME
  do
    if [[ $SERVICE_ID!="service_id" ]]
      then
          echo "$SERVICE_ID) $NAME"
    fi
  done

  read SERVICE_ID_SELECTED
  SERVICE_ID_SELECTED=$($PSQL "SELECT service_id from services where service_id=$SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_ID_SELECTED ]]
     then
        MAIN_MENU "I could not find that service. What would you like today?"
      else
        echo -e "\nWhat's your phone number?"
        read CUSTOMER_PHONE
        CUSTOMER_ID=$($PSQL "SELECT customer_id from customers where phone='$CUSTOMER_PHONE'")
      if [[ -z $CUSTOMER_ID ]]
        then
        #create new customer
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        NEW_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
        CUSTOMER_ID=$($PSQL "SELECT customer_id from customers where phone='$CUSTOMER_PHONE'")
       fi
       CUSTOMER_NAME=$($PSQL "SELECT name from customers where customer_id='$CUSTOMER_ID'")
       CUSTOMER_NAME_FORMATED=$(echo $CUSTOMER_NAME | sed 's/^ *//g')
       echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME_FORMATED?"
       read SERVICE_TIME
       BOOKING_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
       SERVICE_NAME=$($PSQL "SELECT name from services WHERE service_id='$SERVICE_ID_SELECTED'")
       SERVICE_NAME_FORMATED=$(echo $SERVICE_NAME | sed 's/^ *//g')
       echo -e "\nI have put you down for a $SERVICE_NAME_FORMATED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATED."
  fi
}

MAIN_MENU