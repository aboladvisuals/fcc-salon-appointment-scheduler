#!/bin/bash 

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only --no-align -c"

echo -e "\n~~~~~ MY SALON ~~~~~"
echo -e "\nWelcome to My Salon, how can I help you today?"

MAIN_MENU() {
  available_services=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")
  
  echo "$available_services" | while IFS="|" read service_id name 
  do
     echo "$service_id) $name"
  done 

  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")

  if [[ -z $SERVICE_NAME ]]
  then 
     echo -e "\nI could not find that service. What would you like today?"
     MAIN_MENU
  else 
     BOOK_APPOINTMENT
  fi
}

BOOK_APPOINTMENT() {
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")

  if [[ -z $CUSTOMER_NAME ]]
  then 
     echo -e "\nI don't have a record for that phone number, what's your name?"
     read CUSTOMER_NAME
     INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
  fi

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")

  echo -e "\nWhat time do you want your appointment at?"
  read SERVICE_TIME

  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")

  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

# Kick off the program by calling the main menu for the first time
MAIN_MENU
