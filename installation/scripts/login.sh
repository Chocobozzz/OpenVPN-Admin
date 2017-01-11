#!/bin/bash
source config.sh
source functions.sh

username=$(echap "$username")
password=$(echap "$password")

if [ "$USELDAP" == 0 ]; then
  # Authentication
  user_pass=$(mysql -h$HOST -P$PORT -u$USER -p$PASS $DB -sN -e "SELECT user_pass FROM user WHERE user_id = '$username' AND user_enable=1 AND (TO_DAYS(now()) >= TO_DAYS(user_start_date) OR user_start_date='0000-00-00') AND (TO_DAYS(now()) <= TO_DAYS(user_end_date) OR user_end_date='0000-00-00')")

  # Check the user
  if [ "$user_pass" == '' ]; then
    echo "$username: bad account."
    exit 1
  fi

  result=$(php -r "if(password_verify('$password', '$user_pass') == true) { echo 'ok'; } else { echo 'ko'; }")

  if [ "$result" == "ok" ]; then
    echo "$username: authentication ok."
    exit 0
  else
    echo "$username: authentication failed."
    exit 1
  fi
else
  result=$( ldapsearch -x -h "$SERVER" -D "uid=$username,$CONNECTIONSTR" -w $pasword -b "$CONNECTIONSTR" )
  if [[ $result == *"result: 0 Success"* ]]; then
    #echo "Logged In!"
    exit 0
  else
    #echo "Invalid Creds!"
    exit 1
  fi
fi
