#!/bin/bash
. /etc/openvpn/scripts/config.sh
. /etc/openvpn/scripts/functions.sh

common_name=$(echap "$common_name")
bytes_received=$(echap "$bytes_received")
bytes_sent=$(echap "$bytes_sent")
trusted_ip=$(echap "$trusted_ip")
trusted_port=$(echap "$trusted_port")

# We specify the user is offline
mysql -h$HOST -P$PORT -u$USER -p$PASS $DB -e "UPDATE user SET user_online=0 WHERE user_id='$common_name'"

# We insert the deconnection datetime
mysql -h$HOST -P$PORT -u$USER -p$PASS $DB -e "UPDATE log SET log_end_time=now(), log_received='$bytes_received', log_send='$bytes_sent' WHERE log_trusted_ip='$trusted_ip' AND log_trusted_port='$trusted_port' AND user_id='$common_name' AND log_end_time IS NULL"
