#!/bin/bash
. /etc/openvpn/scripts/config.sh
. /etc/openvpn/scripts/functions.sh

username=$(echap "$username")
password=$(echap "$password")

# Authentication
user_pass=$(mysql -h$HOST -P$PORT -u$USER -p$PASS $DB -sN -e "SELECT user_pass FROM user WHERE user_id = '$username' AND user_enable=1 AND (TO_DAYS(now()) >= TO_DAYS(user_start_date) OR user_start_date IS NULL) AND (TO_DAYS(now()) <= TO_DAYS(user_end_date) OR user_end_date IS NULL)")

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
