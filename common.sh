#!/bin/bash 

USER_ID=$(id -u)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_DIR="/var/log/roboshop-logs"
LOG_FILE="$LOG_DIR/$SCRIPT_NAME.log"
SCRIPT_PATH=$PWD

if [ $USER_ID -ne 0 ]
then
    echo "Please run the script as root user or admin user."
    exit 1
else
    echo "Running script as root user"
    mkdir -p $LOG_DIR
fi

echo "##########################################" &>> $LOG_FILE
echo "Script Started executing at '"$(date)"'" | tee -a $LOG_FILE
echo "##########################################" &>> $LOG_FILE

VALIDATE () {
    if [ $1 -ne 0 ]
    then
        echo "$2 is failed:: Exiting the Script" | tee -a $LOG_FILE
        exit 1
    else
        echo "$2 is Success" | tee -a $LOG_FILE
    fi
}

NODEJS_SETUP(){
    dnf module disable nodejs -y &>> $LOG_FILE
    VALIDATE $? "disabling default nodejs"

    dnf module enable nodejs:20 -y &>> $LOG_FILE
    VALIDATE $? "enabling nodejs version 20"

    dnf install nodejs -y &>> $LOG_FILE
    VALIDATE $? "Installing nodejs"

    npm install &>> $LOG_FILE
    VALIDATE $? "Installing Dependencies"
}

APP_SETUP(){
    id roboshop &>> /dev/null
    if [ $? -eq 0 ]
    then
        echo "user already exists skipping"
    else
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
        VALIDATE $? "adding roboshop system user"
    fi

    mkdir -p /app 
    VALIDATE $? "Creating directory for application"

    curl -o /tmp/${APP_NAME}.zip https://roboshop-artifacts.s3.amazonaws.com/${APP_NAME}-v3.zip &>> $LOG_FILE
    VALIDATE $? "downloading source code"

    cd /app 
    rm -rf *
    unzip /tmp/${APP_NAME}.zip &>> $LOG_FILE
    VALIDATE $? "deploying source code"
    rm -rf /tmp/${APP_NAME}.zip
}

SERVICE_SETUP(){
    cp $SCRIPT_PATH/${APP_NAME}.service /etc/systemd/system/${APP_NAME}.service 
    VALIDATE $? "creating ${APP_NAME} service file"

    systemctl daemon-reload &>> $LOG_FILE
    VALIDATE $? "reloading systemctl service"

    systemctl enable ${APP_NAME} &>> $LOG_FILE
    VALIDATE $? "enabling ${APP_NAME} service"

    systemctl start ${APP_NAME}
    VALIDATE $? "starting ${APP_NAME} service"
}