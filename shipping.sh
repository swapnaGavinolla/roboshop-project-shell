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

yum install maven -y &>>LOGFILE
VALIDATE $? "installing maven"

useradd roboshop &>>LOGFILE
VALIDATE $? "adding user"

mkdir /app &>>LOGFILE
VALIDATE $? "making directory"

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>>LOGFILE
VALIDATE $? "downloading app code"
 
cd /app &>>LOGFILE


unzip /tmp/shipping.zip
VALIDATE $? "unzipping"

cd /app

mvn clean package &>>LOGFILE
VALIDATE $? "installing dependencies"

mv target/shipping-1.0.jar shipping.jar &>>LOGFILE
VALIDATE $? "moving"

cp /root/roboshop-project/shipping.service /etc/systemd/system/shipping.service &>>LOGFILE
VALIDATE $? "copying shipping,service"

systemctl daemon-reload &>>LOGFILE
VALIDATE $? "demon reloading"

systemctl enable shipping &>>LOGFILE
VALIDATE $? "enabling"

systemctl start shipping &>>LOGFILE
VALIDATE $? "starting"

yum install mysql -y &>>LOGFILE
VALIDATE $? "installing mysql client"

mysql -h 172.31.36.160 -uroot -pRoboShop@1 < /app/schema/shipping.sql  &>>LOGFILE
VALIDATE $? "loading schema"

systemctl restart shipping &>>LOGFILE
VALIDATE $? "restarting shipping"