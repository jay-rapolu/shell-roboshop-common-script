#!/bin/bash 

source ./common.sh

read -s -p "Setup a password for mysql db: " MYSQL_PASSWORD

mysql --version &>> $LOG_FILE
if [ $? -eq 0 ]
then
    echo "mysql is already installed.. skipping" | tee -a $LOG_FILE
    exit 1
else
    read -s -p "Enter a password for your mysql server:" MYSQL_PASSWORD

    dnf install mysql-server -y &>> $LOG_FILE
    VALIDATE $? "Installing mysql-server" 

    systemctl enable mysqld &>> $LOG_FILE
    VALIDATE $? "Enabling mysql-server"

    systemctl start mysqld  
    VALIDATE $? "Starting mysql-server"

    mysql_secure_installation --set-root-pass $MYSQL_PASSWORD &>> $LOG_FILE
    VALIDATE $? "Setting root password for mysql server"
fi