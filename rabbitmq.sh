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

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>>LOGFILE
VALIDATE $? "downloading repo"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>>LOGFILE
VALIDATE $? "yum repo"

yum install rabbitmq-server -y &>>LOGFILE 
VALIDATE $? "insatlling rabbitmq"

systemctl enable rabbitmq-server &>>LOGFILE
VALIDATE $? "enabling rabbitmq"

systemctl start rabbitmq-server &>>LOGFILE
VALIDATE $? "starting"

rabbitmqctl add_user roboshop roboshop123 &>>LOGFILE
VALIDATE $? "setting pw"