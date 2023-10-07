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

yum install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>>LOGFILE
VALIDATE $? "installing repo"

yum module enable redis:remi-6.2 -y &>>LOGFILE
VALIDATE $? "enabling repo"

yum install redis -y &>>LOGFILE
VALIDATE $? "installing redis"

sed -i 's/127.0.0.1/0.0.0.0/' /etc/redis.conf  /etc/redis/redis.conf &>>LOGFILE
VALIDATE $? "changing ip"

systemctl enable redis &>>LOGFILE
VALIDATE $? "enabling redis"

systemctl start redis &>>LOGFILE
VALIDATE $? "starting redis"
