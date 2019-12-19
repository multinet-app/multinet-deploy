#/bin/bash

# Set constant variables
SECURITY_GROUP_NAME=github-actions-ssh

# Get the current ip address
actions_ip=$(curl ifconfig.me)

# Check if the security group exists
group_id=$(aws ec2 describe-security-groups --group-names $SECURITY_GROUP_NAME | jq ".SecurityGroups[0] .GroupId" | tr -d '"')

if [ -z $group_id ]
then
    # If no string, then the security group doesn't exist so make it
    group_id=$(aws ec2 create-security-group --group-name $SECURITY_GROUP_NAME --description "Allow all trafic in from microsoft and github for github actions automated deployment" --vpc-id $AWS_VPC_ID | jq ".GroupId" | tr -d '"')
else
    # Else quit since it exists and that means that the task must already be running or there is an issue
    return 1
fi

# Add the github actions ip to the security group
aws ec2 authorize-security-group-ingress --group-id $group_id --protocol tcp --port 22 --cidr $actions_ip"/32"

# Query the instances current security groups
original_groups=$(aws ec2 describe-security-groups --group-ids $(aws ec2 describe-instances --instance-id $id --query "Reservations[].Instances[].SecurityGroups[].GroupId[]" --output text) --query "SecurityGroups[].GroupId[]")

# Remove all characters we don't want from the current groups
original_groups=$(echo $original_groups | tr -d '""' | tr -d '[' | tr -d ']' | tr -d ',')

# Reset the security groups adding in the new one
aws ec2 modify-instance-attribute --instance-id $AWS_INSTANCE_ID --groups $group_id $original_groups
