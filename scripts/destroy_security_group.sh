#/bin/bash

# Set constant variables
SECURITY_GROUP_NAME=github-actions-ssh

# Remove the security group from the instance
aws ec2 modify-instance-attribute --instance-id $AWS_INSTANCE_ID --groups "sg-0c6c1ccf379af096d" "sg-00a5547f58c373231" "sg-0bce9fa27bfbfc695"

# Get the security group name
group_id=$(aws ec2 describe-security-groups --group-names $SECURITY_GROUP_NAME | jq ".SecurityGroups[0] .GroupId" | tr -d '"')

if [ -z $group_id ]
then
    # If no string, then the security group doesn't exist any more which is a problem, exit
    return 1
fi

# Delete the security group
aws ec2 delete-security-group --group-id $group_id