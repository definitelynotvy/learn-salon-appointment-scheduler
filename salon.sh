#! /bin/bash


PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n" 

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    ID=$(echo $SERVICE_ID | sed 's/ //g')
    NAME=$(echo $SERVICE_NAME | sed 's/ //g')
    echo "$SERVICE_ID) $NAME"
  done

  read SERVICE_ID_SELECTED

  case $SERVICE_ID_SELECTED in
    [1-5]) SERVICES ;;
    *) MAIN_MENU "I could not find that service. What would you like today?" ;;
  esac
}
SERVICES() {
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  CUSTOMER_NAME=$(echo $NAME | sed 's/ //g')
  # if customer doesn't exist
  if [[ -z $NAME ]]
  then
    # get new customer name
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    # insert new customer
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')") 
  fi
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  
  echo -e "\nWhat time would you like your$SERVICE_NAME, $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')?"
  read SERVICE_TIME
  
  
  INSERT_APPOINMENT_RESULT=$($PSQL "insert into appointments(customer_id, service_id, time) values($CUSTOMER_ID, $SERVICE_ID_SELECTED,'$SERVICE_TIME')")
  # send to main menu
  
  # MAIN_MENU "I have put you down for the$(echo $SERVICE_NAME | sed -E 's/^ *| *$//g') at $(echo $SERVICE_TIME | sed -E 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')."
  if [[ $INSERT_APPOINMENT_RESULT == "INSERT 0 1" ]]
  then
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}



MAIN_MENU

