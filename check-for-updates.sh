#!/bin/bash

# Move to directory
cd /home/ec2-user/multinet-deploy/

# Clean out all old builds, rebuild, and deploy
docker system prune --all -f
docker-compose build --no-cache
docker-compose up -d

echo "run successful "$(date) >> /home/ec2-user/multinet-deploy/whook.log

# mailbody="Testmail via bash script"
# echo "From: info@myserver.test" > /tmp/mailtest
# echo "To: jwilburn@sci.utah.edu" >> /tmp/mailtest
# echo "Subject: Mailtest subject" >> /tmp/mailtest
# echo "" >> /tmp/mailtest
# echo $mailbody >> /tmp/mailtest
# cat /tmp/mailtest | /usr/sbin/sendmail -t