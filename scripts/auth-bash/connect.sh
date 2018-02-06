#!/bin/bash

my_path="$(dirname $0)"
cd "$my_path"

source ./../../.env
source ./functions.sh

common_name=$(echap "$common_name")
trusted_ip=$(echap "$trusted_ip")
trusted_port=$(echap "$trusted_port")
ifconfig_pool_remote_ip=$(echap "$ifconfig_pool_remote_ip")
remote_port_1=$(echap "$remote_port_1")
bytes_received=$(echap "$bytes_received")
bytes_sent=$(echap "$bytes_sent")

# We insert data in the log table
mysql -h$DB_HOST -P$DB_PORT -u$DBUSER -p$DB_PASS $DB_NAME -e "INSERT INTO log (log_id, user_id, log_trusted_ip, log_trusted_port, log_remote_ip, log_remote_port, log_start_time, log_end_time, log_received, log_send) VALUES(NULL, '$common_name','$trusted_ip', '$trusted_port','$ifconfig_pool_remote_ip', '$remote_port_1', now(),NULL, '$bytes_received', '$bytes_sent')"

# We specify that the user is online
mysql -h$DB_HOST -P$DB_PORT -u$DBUSER -p$DB_PASS $DB_NAME -e "UPDATE user SET user_online=1 WHERE user_id='$common_name'"
