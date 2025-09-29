#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
MONGODB_HOST=mongodb.daws86s.com
SCRIPT_DIR=$PWD

mkdir -p $LOGS_FOLDER
echo "Script started executed at: $(date)" | tee -a $LOG_FILE
if [ $USERID -ne 0 ]; then
    echo "ERROR:: Please run this script with root prevelege"
    exit 1 # failure is other than 0

fi

VALIDATE(){ # functions receive inputs through args just like shell script args

    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 .... $G SUCCESS $N" | tee -a $LOG_FILE
    fi
}
dnf module disable nginx -y &>>$LOG_FILE
VALIDATE $? "Disabling nginx"
dnf module enable nginx:1.24 -y &>>$LOG_FILE
VALIDATE $? "Enabling nginx: 1.24"

dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "Installing nginx"
systemctl enable nginx &>>$LOG_FILE
systemctl start nginx 
VALIDATE $? "Starting nginx"

rm -rf /usr/share/nginx/html/* 
VALIDATE $? "Removing default content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOG_FILE
VALIDATE $? "downloading frontend application"
cd /usr/share/nginx/html 
unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "unzip frontend"

rm -rf /etc/nginx/nginx.conf

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "copy nginx conf file"
systemctl restart nginx &>>$LOG_FILE
VALIDATE $? "Restarted nginx"


