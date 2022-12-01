#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

$PSQL "TRUNCATE teams, games;"

if [[ -a games.csv ]]
then
  cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
  do
    if [[ $YEAR != year ]]
    then
      # get major id
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
      if [[ -z $WINNER_ID ]]
      then
        SQL_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
        if [[ $SQL_RESULT = 'INSERT 0 1' ]]
        then
          echo "Inserted team $WINNER"
          WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
        fi
      fi

      # get opponent id
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
      if [[ -z $OPPONENT_ID ]]
      then
        SQL_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
        if [[ $SQL_RESULT = 'INSERT 0 1' ]]
        then
          echo "Inserted team $OPPONENT"
          OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
        fi
      fi

      SQL_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
      if [[ $SQL_RESULT = 'INSERT 0 1' ]]
      then
        echo "Inserted game: $WINNER - $OPPONENT"
      fi
    fi
  done
fi
