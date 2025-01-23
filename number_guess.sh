#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess --tuples-only -t --no-align -c"
RANDOM_NUM=$((1 + $RANDOM % 1000))
NUM_GUESSES=0

echo Enter your username:
read USERNAME
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
if [[ -z $USER_ID ]]
then
  USER_INSERT_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id=$USER_ID")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo Guess the secret number between 1 and 1000:

MAKE_GUESS() {
  read GUESS
  while [[ ! $GUESS =~ ^[0-9]+$ ]]
  do
    echo That is not an integer, guess again:
    read GUESS
  done
  GUESS_NUM=$(($GUESS_NUM + 1))
}

MAKE_GUESS

while [[ $GUESS != $RANDOM_NUM ]]
do
  if [[ $GUESS -lt $RANDOM_NUM ]]
  then
    echo "It's higher than that, guess again:"
  else
    echo "It's lower than that, guess again:"
  fi
  MAKE_GUESS
done

if [[ -z $GAMES_PLAYED ]]
then
  INSERT_GAMES_RESULT=$($PSQL "UPDATE users SET games_played=1, best_game=$GUESS_NUM WHERE user_id=$USER_ID")
else
  INSERT_GAMES_RESULT=$($PSQL "UPDATE users SET games_played=$(($GAMES_PLAYED + 1)), best_game=$(($GUESS_NUM<$BEST_GAME?$GUESS_NUM:$BEST_GAME)) WHERE user_id=$USER_ID")
fi

echo "You guessed it in $GUESS_NUM tries. The secret number was $RANDOM_NUM. Nice job!"
