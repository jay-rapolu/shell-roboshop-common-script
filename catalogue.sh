#!/bin/bash 

APP_NAME="catalogue"
source ./common.sh

NODEJS_SETUP

APP_SETUP

cp $SCRIPT_PATH/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "creating mongodb repo file"

dnf install mongodb-mongosh -y &>> $LOG_FILE
VALIDATE $? "installing mongodb client"

STATUS=$(mongosh --host mongodb.jayachandrarapolu.site --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
if [ $STATUS -lt 0 ]
then
    mongosh --host mongodb.jayachandrarapolu.site </app/db/master-data.js &>> $LOG_FILE
    VALIDATE $? "loading data to db."
else
    echo "db already exists"
fi