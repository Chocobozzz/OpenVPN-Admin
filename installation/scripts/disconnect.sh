#!/bin/bash
. /etc/openvpn/scripts/config.sh

# On précise que l'utilisateur n'est plus en ligne
mysql -h$HOST -P$PORT -u$USER -p$PASS $DB -e "UPDATE user SET user_online=0 WHERE user_id='$common_name'"

# On insert le datetime de déconnexion
mysql -h$HOST -P$PORT -u$USER -p$PASS $DB -e "UPDATE log SET log_end_time=now(), log_received='$bytes_received', log_send='$bytes_sent' WHERE log_trusted_ip='$trusted_ip' AND log_trusted_port='$trusted_port' AND user_id='$common_name' AND log_end_time='0000-00-00 00:00:00'"