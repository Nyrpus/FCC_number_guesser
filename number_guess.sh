#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Get username
echo Enter your username:
read USERNAME

# Check if user exists in database
GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE name='$USERNAME'")
BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE name='$USERNAME'")

# If it's a new player
if [[ -z $GAMES_PLAYED ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  # Add new user to database with 0 games played
  INSERT_RESULT=$($PSQL "INSERT INTO users(name, games_played, best_game) VALUES('$USERNAME', 0, NULL)")
else
  
  # Greet returning user
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Generate a random number between 1 and 1000
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

echo "Guess the secret number between 1 and 1000:"
GUESS_COUNT=0
GUESSED=false

while [[ $GUESSED == false ]]
do
  read GUESS
  
  # Check if input is an integer
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    continue
  fi
  
  # Increment guess count
  (( GUESS_COUNT++ ))
  
  # Check guess against secret number
  if [[ $GUESS -eq $SECRET_NUMBER ]]
  then
    GUESSED=true
  elif [[ $GUESS -gt $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi
done

# When number is guessed
echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"

# Update user statistics in database
CURRENT_GAMES=$($PSQL "SELECT games_played FROM users WHERE name='$USERNAME'")
NEW_GAMES=$(( CURRENT_GAMES + 1 ))

CURRENT_BEST=$($PSQL "SELECT best_game FROM users WHERE name='$USERNAME'")

# Update best game if this is their first game or if they beat their previous record
if [[ -z $CURRENT_BEST || $GUESS_COUNT -lt $CURRENT_BEST ]]
then
  UPDATE_RESULT=$($PSQL "UPDATE users SET games_played=$NEW_GAMES, best_game=$GUESS_COUNT WHERE name='$USERNAME'")
else
  UPDATE_RESULT=$($PSQL "UPDATE users SET games_played=$NEW_GAMES WHERE name='$USERNAME'")
fi