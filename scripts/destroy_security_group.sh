#/bin/bash

# Set constant variables
SECURITY_GROUP_NAME=github-actions-ssh

# Get the security group name
group_id=$(aws ec2 describe-security-groups --group-names $SECURITY_GROUP_NAME | jq ".SecurityGroups[0] .GroupId" | tr -d '"')

# Query the instances current security groups
current_groups=$(aws ec2 describe-security-groups --group-ids $(aws ec2 describe-instances --instance-id $id --query "Reservations[].Instances[].SecurityGroups[].GroupId[]" --output text) --query "SecurityGroups[].GroupId[]")

# Remove all characters we don't want from the original groups
current_groups=$(echo $current_groups | tr -d '""' | tr -d '[' | tr -d ']' | tr -d ',')

# Remove the group we made from the original groups
original_groups=$(printf '%s\n' "${current_groups//$group_id/}")

# Reset the security groups adding in the new one
aws ec2 modify-instance-attribute --instance-id $AWS_INSTANCE_ID --groups $original_groups

if [ -z $group_id ]
then
    # If no string, then the security group doesn't exist any more which is a problem, exit with an error
    return 1
fi

# Delete the security group
aws ec2 delete-security-group --group-id $group_id
