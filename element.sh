#!/bin/bash

# Set up the PSQL variable for querying the database
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Check if an argument was provided
if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit 0
fi

# Check if the argument is an atomic number, symbol, or name
if [[ $1 =~ ^[0-9]+$ ]]
then
  QUERY="SELECT elements.atomic_number, elements.symbol, elements.name, properties.atomic_mass, properties.melting_point_celsius, properties.boiling_point_celsius, types.type
  FROM elements
  INNER JOIN properties ON elements.atomic_number = properties.atomic_number
  INNER JOIN types ON properties.type_id = types.type_id
  WHERE elements.atomic_number = $1"
elif [[ $1 =~ ^[A-Za-z]{1,2}$ ]]
then
  QUERY="SELECT elements.atomic_number, elements.symbol, elements.name, properties.atomic_mass, properties.melting_point_celsius, properties.boiling_point_celsius, types.type
  FROM elements
  INNER JOIN properties ON elements.atomic_number = properties.atomic_number
  INNER JOIN types ON properties.type_id = types.type_id
  WHERE elements.symbol = '$1'"
else
  QUERY="SELECT elements.atomic_number, elements.symbol, elements.name, properties.atomic_mass, properties.melting_point_celsius, properties.boiling_point_celsius, types.type
  FROM elements
  INNER JOIN properties ON elements.atomic_number = properties.atomic_number
  INNER JOIN types ON properties.type_id = types.type_id
  WHERE elements.name = '$1'"
fi

# Execute the query
RESULT=$($PSQL "$QUERY")

# Check if the result is empty
if [[ -z $RESULT ]]
then
  echo "I could not find that element in the database."
else
  # Parse and display the result
  echo "$RESULT" | while IFS="|" read ATOMIC_NUMBER SYMBOL NAME MASS MELTING BOILING TYPE
  do
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
  done
fi
