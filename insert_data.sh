#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
$PSQL "TRUNCATE games, teams"

function getTeamID(){
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$1'")

    if [[ -z $TEAM_ID ]]
    then
        INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES ('$1')") 

        TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$1'")
    fi 
    echo $TEAM_ID 
}


cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONNENT_GOALS
do
  if [[  ! -z $YEAR && $YEAR != "year" ]]
  then
    # ADD TEAMS FIRST
    WINNER_TEAM_ID=$(getTeamID "$WINNER")  
    OPPONENT_TEAM_ID=$(getTeamID "$OPPONENT")
    echo -e "\nID FOR WINNER=$WINNER_TEAM_ID"
    echo -e "\nID FOR OPPONENT=$OPPONENT_TEAM_ID"

    # ADD GAME INFO
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES ($YEAR,'$ROUND',$WINNER_TEAM_ID, $OPPONENT_TEAM_ID, $WINNER_GOALS, $OPPONNENT_GOALS )")

    if [[ $INSERT_GAME_RESULT == 'INSERT 0 1' ]]
    then 
        echo "Inserted into games, $YEAR, $ROUND, $WINNER, $OPPONENT"
    fi

  fi
done