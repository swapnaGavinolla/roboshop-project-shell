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

yum install nginx -y &>>LOGFILE
VALIDATE $? "installing nginx"


systemctl enable nginx &>>LOGFILE
VALIDATE $? "enabling nginx"

systemctl start nginx &>>LOGFILE
VALIDATE $? "starting nginx"

rm -rf /usr/share/nginx/html/* &>>LOGFILE
VALIDATE $? "removing default data"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>>LOGFILE
VALIDATE $? "downloading frontend data"

cd /usr/share/nginx/html &>>LOGFILE
VALIDATE $? "extracting frontend data"


unzip /tmp/web.zip 
VALIDATE $? "unzipping"

systemctl restart nginx  &>>LOGFILE
VALIDATE $? "restarting"