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

yum install python36 gcc python3-devel -y &>>LOGFILE
VALIDATE $? "installing python"

useradd roboshop &>>LOGFILE
VALIDATE $? "adding user"

mkdir /app &>>LOGFILE
VALIDATE $? "making directory"

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>>LOGFILE
VALIDATE $? "downloading app code"

cd /app &>>LOGFILE

unzip /tmp/payment.zip &>>LOGFILE
VALIDATE $? "unzipping"

cd /app &>>LOGFILE

pip3.6 install -r requirements.txt &>>LOGFILE
VALIDATE $? "installling requirements"

cp /root/roboshop-project/payment.service /etc/systemd/system/payment.service &>>LOGFILE
VALIDATE $? "copying service"

systemctl daemon-reload &>>LOGFILE
VALIDATE $? "demon reloading"

systemctl enable payment &>>LOGFILE
VALIDATE $? "enabling"

systemctl start payment &>>LOGFILE
VALIDATE $? "starting payment"
