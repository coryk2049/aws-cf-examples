#!/bin/bash
#set -xe

#
# Example script to provision a simple IAM user and group with aws cli functionality
#

info() {
	echo -e "[`date '+%m/%d/%Y-%H:%M:%S'`]::INFO:----------------------------------------------------------"
	echo -e "[`date '+%m/%d/%Y-%H:%M:%S'`]::INFO::$1"
    echo -e "[`date '+%m/%d/%Y-%H:%M:%S'`]::INFO:----------------------------------------------------------"
}

GROUP_NAME="DevGroup"
USER_NAME="DevUser1"
INLINE_POLICY_NAME="DEV-ACCESS-POLICY"

INLINE_POLICY_FILENAME="_${GROUP_NAME}_InlinePolicy.json"
MANAGED_POLICY_LIST_FILENAME="_${GROUP_NAME}_ManagedPolicyList.txt"
POLICY_ACTION_LIST_FILENAME="_${GROUP_NAME}_ManagedPolicyActionList.txt"

info "Creating group [${GROUP_NAME}] if not there already"
aws iam create-group --group-name ${GROUP_NAME}

info "Creating user [${USER_NAME}] if not there already"
aws iam create-user --user-name ${USER_NAME}

info "Adding user [${USER_NAME}] to group [${GROUP_NAME}] if not there already"
aws iam add-user-to-group --user-name ${USER_NAME} --group-name ${GROUP_NAME}

cat > ${INLINE_POLICY_FILENAME} <<EOL
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": "ec2:RunInstances",
            "Condition": {
                "StringEquals": {
                    "ec2:InstanceType": [
                        "t2.micro",
                        "t2.small"
                    ]
                }
            },
            "Resource": "*"
        }
    ]    
}
EOL

info "Attaching inline group policies"
aws iam put-group-policy \
    --group-name ${GROUP_NAME} \
    --policy-name ${INLINE_POLICY_NAME} \
    --policy-document file://${INLINE_POLICY_FILENAME}

cat > ${MANAGED_POLICY_LIST_FILENAME} <<EOL
arn:aws:iam::aws:policy/AmazonS3FullAccess
arn:aws:iam::aws:policy/AWSLambdaFullAccess
arn:aws:iam::aws:policy/AmazonSSMFullAccess
arn:aws:iam::aws:policy/AmazonESFullAccess
arn:aws:iam::aws:policy/IAMReadOnlyAccess
EOL

info "Attaching managed group policies"
for POLICY_ITEM in $(cat ${MANAGED_POLICY_LIST_FILENAME}); do 
    aws iam attach-group-policy \
        --group-name ${GROUP_NAME} \
        --policy-arn ${POLICY_ITEM}
done

#aws iam create-access-key --user-name ${USER_NAME}

info "Listing group policies"
aws iam list-group-policies \
    --group-name ${GROUP_NAME} \
    --output text

info "Listing attached group policies"
aws iam list-attached-group-policies \
    --group-name ${GROUP_NAME} \
    --output text

# REF: https://www.slideshare.net/AmazonWebServices/aws-reinvent-2016-how-to-automate-policy-validation-sec311
cat > ${POLICY_ACTION_LIST_FILENAME} <<EOL
ec2:*
s3:*
iam:*
logs:*
lambda:*
tag:*
EOL

GROUP_ARN=$(aws iam get-group --group-name ${GROUP_NAME}|jq ".Group.Arn"|tr -d '"') 
for ACTION_ITEM in $(cat ${POLICY_ACTION_LIST_FILENAME}); do 
    info "Simulating policy for [${GROUP_ARN}] with [${ACTION_ITEM}]"
    aws iam simulate-principal-policy \
        --policy-source-arn ${GROUP_ARN} \
        --action-names ${ACTION_ITEM} \
        --output json
    breaker
done 
