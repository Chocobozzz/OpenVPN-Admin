#!/bin/bash
. /etc/openvpn/scripts/config.sh

# Authentication
user_id=$(mysql -h$HOST -P$PORT -u$USER -p$PASS $DB -sN -e "SELECT user_id FROM user WHERE user_id = '$username' AND user_pass = SHA1('$password') AND user_enable=1 AND (TO_DAYS(now()) &gt;= TO_DAYS(user_start_date) OR user_start_date='0000-00-00') AND (TO_DAYS(now()) &lt;= TO_DAYS(user_end_date) OR user_end_date='0000-00-00')")

# Vérification de l'utilisateur
[ "$user_id" != '' ] && [ "$user_id" = "$username" ] && echo "user : $username" && echo 'authentication ok.' && exit 0 || echo 'authentication failed.'; exit 1
