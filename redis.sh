#!/bin/bash 

source ./common.sh

redis-server -v &>> $LOG_FILE
if [ $? -eq 0 ]
then
    echo "redis is already configured.. skipping"
    exit 1
else
    dnf module disable redis -y &>> $LOG_FILE
    VALIDATE $? "Disabling default redis module"
    
    dnf module enable redis:7 -y &>> $LOG_FILE
    VALIDATE $? "Enabling default redis module"
    
    dnf install redis -y &>> $LOG_FILE
    VALIDATE $? "Installing redis module"
    
    sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
    VALIDATE $? "updating redis configuration"
    
    systemctl enable redis &>> $LOG_FILE
    VALIDATE $? "enabling redis module"
    
    systemctl start redis 
    VALIDATE $? "starting redis module"
fi