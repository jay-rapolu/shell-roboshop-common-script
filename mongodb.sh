#!/bin/bash

source ./common.sh

mongod --version &>> $LOG_FILE
if [ $? -eq 0 ]
then
    echo "mongodb is already installed in the server:: skipping"
else
    cp ./mongo.repo /etc/yum.repos.d/mongo.repo
    VALIDATE $? "Creating mongodb repo file"

    dnf install mongodb-org -y &>> $LOG_FILE
    VALIDATE $? "Installing Mongodb"

    systemctl enable mongod &>> $LOG_FILE
    VALIDATE $? "Enabling Mongodb"

    systemctl start mongod 
    VALIDATE $? "Starting Mongodb" 

    sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
    VALIDATE $? "Allowing remote connections" 

    systemctl restart mongod
    VALIDATE $? "Restarting Mongodb" 
fi