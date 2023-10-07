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


curl -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>>LOGFILE
VALIDATE $? "downloading app code"

cd /app &>>LOGFILE

unzip /tmp/cart.zip 
VALIDATE $? "unzipping"

npm install -y &>>LOGFILE
VALIDATE $? "installing npm--dependencies"

cp /root/roboshop-project/cart.service /etc/systemd/system/cart.service &>>LOGFILE
VALIDATE $? "copying cart.service"

systemctl daemon-reload &>>LOGFILE
VALIDATE $? "daemon-reloading"

systemctl enable cart &>>LOGFILE
VALIDATE $? "enabling cart"

systemctl start cart &>>LOGFILE
VALIDATE $? "staring  cart"

