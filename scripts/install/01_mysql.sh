#!/bin/bash

function mysql_exec()
{
    echo "$1" | mysql -u root --password="$mysql_root_pass" &> /dev/null
}

printf "\n################## Setup MySQL database ##################\n"

[ ! -z "$DB_HOST" ] && echo "DB_HOST=$DB_HOST"
[ -z "$DB_HOST" ]  && read -p "MySQL database host: " DB_HOST
[ -z "$DB_HOST" ]  && print_error "MySQL database host is required!"

# Get root pass (to create the database and the user)
mysql_root_pass=""
status_code=1

while [ $status_code -ne 0 ]; do
  read -p "MySQL root password: " -s mysql_root_pass; echo
  mysql_exec "SHOW DATABASES"
  status_code=$?
done

[ ! -z "$DB_NAME" ] && echo "DB_NAME=$DB_NAME"
[ -z "$DB_NAME" ]  && read -p "MySQL database name: " DB_NAME
[ -z "$DB_NAME" ]  && print_error "MySQL database name is required!"

[ ! -z "$DB_USER" ] && echo "DB_USER=$DB_USER"
[ -z "$DB_USER" ]  && read -p "MySQL user name for $DB_NAME (will be created): " DB_USER
[ -z "$DB_USER" ]  && print_error "MySQL user is required!"

[ ! -z "$DB_PASS" ] && echo "DB_PASS=$DB_PASS"
[ -z "$DB_PASS" ]  && read -p "MySQL user password for $DB_USER: " DB_PASS
[ -z "$DB_PASS" ]  && print_error "MySQL user password is required!"

sql_result=$(mysql_exec "SHOW DATABASES" | grep -e "^$DB_NAME$")

# Check if the database doesn't already exist
if [ "$sql_result" != "" ]; then
  echo "The $DB_NAME database already exists."
  exit
fi

mysql_exec "SHOW GRANTS FOR $DB_USER@localhost"
if [ $? -eq 0 ]; then
  echo "The MySQL user already exists."
  exit
fi

mysql_exec "CREATE DATABASE \`$DB_NAME\`"
mysql_exec "CREATE USER $DB_USER@% IDENTIFIED BY '$DB_PASS'"
mysql_exec "GRANT ALL PRIVILEGES ON \`$DB_NAME\`.*  TO $DB_USER@%"
mysql_exec "FLUSH PRIVILEGES"
