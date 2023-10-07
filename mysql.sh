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

yum module disable mysql -y &>>LOGFILE
VALIDATE $? "disabling mysql"

cp mysql.repo /etc/yum.repos.d/mysql.repo &>>LOGFILE
VALIDATE $? "copying mysql repo"

yum install mysql-community-server -y &>>LOGFILE
VALIDATE $? "insatlling mysql"

systemctl enable mysqld &>>LOGFILE
VALIDATE $? "enabing mysql"

systemctl start mysqld &>>LOGFILE
VALIDATE $? "starting mysql"

mysql_secure_installation --set-root-pass RoboShop@1 &>>LOGFILE
VALIDATE $? "setting  mysql pw"

