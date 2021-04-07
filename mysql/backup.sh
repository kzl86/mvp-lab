#!/bin/bash

# Creating backup from the MySQL database.

# Deprecated: This script is intended to run on a daily basis as a root cronjob. 
# Run e.g. every 01:00 AM:
# 0 1 * * * /root/backup.sh

# Variable declaration modified since this will be used by a Jenkins pipeline.

PASSWORD=$1

# Define subfunctions.

backup_today() {
    mysqldump \
    --no-tablespaces \
    --single-transaction \
    --quick \
    --user=wp_admin \
    --password=$PASSWORD \
    wordpress > /backup/today/wordpress-"$(date +"%d-%m-%Y")".sql
}

move_today2yesterday() {
    mv /backup/today/* /backup/yesterday/
}

move_yesterday2dated(){
    mkdir /backup/$(date --date="yesterday" +"%d-%m-%Y")
    mv /backup/yesterday/* /backup/$(date --date="yesterday" +"%d-%m-%Y")/
}

# Check prerequisites.

if ! command -v mysqldump &> /dev/null
then
    echo "mysqldump could not be found"
    exit
fi

# Check folder structure and create if needed.
# If this is the first run, directory structure will be created.

[ ! -d "/backup" ] && mkdir /backup
[ ! -d "/backup/today" ] && mkdir /backup/today
[ ! -d "/backup/yesterday" ] && mkdir /backup/yesterday

if [ ! "$(ls -A /backup/today)" ]
    then
        backup_today
        exit 0
    else
        if [ ! "$(ls -A /backup/yesterday)" ]
            then
                move_today2yesterday
                backup_today
                exit
            else
                move_yesterday2dated
                move_today2yesterday
                backup_today
                exit
        fi
        
fi