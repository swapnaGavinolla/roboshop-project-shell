#!/bin/bash

DATE=$(date +%F)
SCRIPT_NAME=$0
LOGFILE=/tmp/$SCRIPT_NAME-$DATE.log
R="\e[31m"
G="\e[32m"
N="\e[0m"

VALIDATE(){
if [ $1 -ne 0 ]
then
    echo -e " $2 .... $R failure $N"
    exit 1
else     
    echo -e " $2 .... $G success$N"
fi  
}

USERID=$( id -u )
if [ $USERID -ne 0 ]
then 
   echo "ERROR: run wid root access"
   exit 1
fi

curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>LOGFILE
VALIDATE $? "npm source setup "

yum install nodejs -y &>>LOGFILE
VALIDATE $? "installing nodejs"

#useradd roboshop &>>LOGFILE
#VALIDATE $? "adding user"

#mkdir /app &>>LOGFILE
#VALIDATE $? "creating directory"


curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>>LOGFILE
VALIDATE $? "downloading app code"

cd /app &>>LOGFILE

npm install 
VALIDATE $? "installing npm--dependencies"

cp catalogue.service /etc/systemd/system/catalogue.service &>>LOGFILE
VALIDATE $? "copying catalogue.service"

systemctl daemon-reload &>>LOGFILE
VALIDATE $? "daemon-reloading"

systemctl enable catalogue &>>LOGFILE
VALIDATE $? "enabling catalogue"

systemctl start catalogue &>>LOGFILE
VALIDATE $? "staring  catalogue"

cp mango.repo /etc/yum.repos.d/mongo.repo &>>LOGFILE
VALIDATE $? "copying mango.repo"

yum install mongodb-org-shell -y &>>LOGFILE
VALIDATE $? "installing mongod cloient"

mongo --host 172.31.42.87 </app/schema/catalogue.js &>>LOGFILE
VALIDATE $? "loading schema"