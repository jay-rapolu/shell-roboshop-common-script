#!/bin/bash 

source ./common.sh

dnf module disable nginx -y &>> $LOG_FILE
VALIDATE $? "disabling default nginx"

dnf module enable nginx:1.24 -y &>> $LOG_FILE
VALIDATE $? "disabling nginx version 1.24"

dnf install nginx -y &>> $LOG_FILE
VALIDATE $? "Installing Nginx"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>> $LOG_FILE
VALIDATE $? "downloading source code"

cd /usr/share/nginx/html
rm -rf *
unzip /tmp/frontend &>> $LOG_FILE
rm -rf /tmp/frontend
VALIDATE $? "deploying source code"

systemctl enable nginx &>> $LOG_FILE
VALIDATE $? "Enabling Nginx"

systemctl start nginx
VALIDATE $? "Starting Nginx"

rm -f /etc/nginx/nginx.conf 
cp $SCRIPT_PATH/nginx.conf /etc/nginx/nginx.conf 
VALIDATE $? "Updating Nginx configuration file"

systemctl restart nginx
VALIDATE $? "restarting Nginx"