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

cp mongo.repo  /etc/yum.repos.d/mongo.repo &>>LOGFILE
VALIDATE $? "copying mongo.repo"

yum install mongodb-org -y &>>LOGFILE
VALIDATE $? "installing mongodb"

systemctl enable mongod &>>LOGFILE
VALIDATE $? "enabling mongodb"

systemctl start mongod &>>LOGFILE
VALIDATE $? "starting mongodb"

sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf &>>LOGFILE
VALIDATE $? "editing conf"

systemctl restart mongod &>>LOGFILE
VALIDATE $? "re starting mongodb"
