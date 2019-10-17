#!/bin/bash

# Define variables
REPO=$1
LOCATION=/home/ec2-user/multinet-deploy

# Add an option to let us parse the .env
set +H

# Move to directory
cd $LOCATION

# Clean out all old builds, rebuild, and deploy
# If the repo is multinet we need to rebuild the client and server
if [ $REPO == "multinet" ]
then
docker system prune --all -f
docker-compose build --no-cache $REPO-client
docker-compose build --no-cache $REPO-server
docker-compose up -d
else
# Build the one container
docker system prune --all -f
docker-compose build --no-cache $REPO
docker-compose up -d
fi

echo $REPO" run successful "$(date) >> $LOCATION/whook.log

# mailbody="Testmail via bash script"
# echo "From: info@myserver.test" > /tmp/mailtest
# echo "To: jwilburn@sci.utah.edu" >> /tmp/mailtest
# echo "Subject: Mailtest subject" >> /tmp/mailtest
# echo "" >> /tmp/mailtest
# echo $mailbody >> /tmp/mailtest
# cat /tmp/mailtest | /usr/sbin/sendmail -t