#!/bin/bash
. /etc/openvpn/scripts/config.sh
. /etc/openvpn/scripts/functions.sh

common_name=$(echap "$common_name")
trusted_ip=$(echap "$trusted_ip")
trusted_port=$(echap "$trusted_port")
ifconfig_pool_remote_ip=$(echap "$ifconfig_pool_remote_ip")
remote_port_1=$(echap "$remote_port_1")
bytes_received=$(echap "$bytes_received")
bytes_sent=$(echap "$bytes_sent")

# Prevent the error : ERROR 1366 (22007) at line 1: Incorrect double value: '' for column 'log_received' at row 1

if [ -z "$bytes_received" ]
then
      bytes_received=0
fi

if [ -z "$bytes_sent" ]
then
      bytes_sent=0
fi


# We insert data in the log table
mysql -h$HOST -P$PORT -u$USER -p$PASS $DB -e "INSERT INTO log (log_id, user_id, log_trusted_ip, log_trusted_port, log_remote_ip, log_remote_port, log_start_time, log_end_time, log_received, log_send) VALUES(NULL, '$common_name','$trusted_ip', '$trusted_port','$ifconfig_pool_remote_ip', '$remote_port_1', now(),NULL, '$bytes_received', '$bytes_sent')"

# We specify that the user is online
mysql -h$HOST -P$PORT -u$USER -p$PASS $DB -e "UPDATE user SET user_online=1 WHERE user_id='$common_name'"
