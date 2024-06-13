#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE TABLE games, teams")

cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do

# insert teams table data
# we need just the tames name for the teams table

# we check to execulde the first row
if [[ $WINNER != "winner" ]]
then

  # we need to check if the team is already in the table 
  # if it is then we dont add it
  # if its not then we add it
  # the table has winners and opponent so we need to check both 

  # first we get the team name 

  TEAM_NAME=$($PSQL "SELECT name FROM teams WHERE name='$WINNER'") #checking if the team is already in the table

  if [[ -z $TEAM_NAME ]]
  then
    TEAM_NAME_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")

    if [[ $TEAM_NAME_RESULT == "INSERT 0 1" ]]
    then
      echo "Inserted into teams, $WINNER" 
    fi
  fi


  TEAM1_NAME=$($PSQL "SELECT name FROM teams WHERE name='$OPPONENT'")

  if [[ -z $TEAM1_NAME ]]
  then
    TEAM1_NAME_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")

    if [[ $TEAM1_NAME_RESULT == "INSERT 0 1" ]]
    then
      echo "Inserted into teams, $OPPONENT" 
    fi
  fi

  # now we need to insert into the games tables
  # games table needs year, round, winner_id(foreign), opponent_id(foreign), winner_goals, opponent_goals
  # winner_id and opponent_id will be added from the teams table as their id is set already

  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

  ADD_GAME_RESULT=$($PSQL "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES($YEAR,'$ROUND',$WINNER_ID,$OPPONENT_ID,$WINNER_GOALS,$OPPONENT_GOALS)")
  if [[ $ADD_GAME_RESULT == "INSERT 0 1" ]]
    then
      echo "Inserted into games table this game, $YEAR,$ROUND,$WINNER vs $OPPONENT with a score of $WINNER_GOALS, $OPPONENT_GOALS" 
    fi

fi

done
