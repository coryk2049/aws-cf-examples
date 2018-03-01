#!/bin/bash
#set -xe

#
# Example script to deploy simple web app with AWS CodeDeploy and S3
#
APP_NAME=poc-web-app
APP_SOURCE_CODE_PATH=~/GitHub/aws-cf-examples/cf-example-12/SampleApp_Linux
DEPLOYMENT_CONFIG_NAME=CodeDeployDefault.OneAtATime
#DEPLOYMENT_CONFIG_NAME=CodeDeployDefault.AllAtOnce
DEPLOYMENT_GROUP_NAME=${APP_NAME}-dg
S3_BUCKET_NAME=coryk-poc-repo
S3_APP_BUNDLE_NAME=SampleApp_Linux.zip
EC2_TAG_NAME_VALUE=POC
AWS_REGION=us-east-1

info() {
	echo -e "[`date '+%m/%d/%Y-%H:%M:%S'`]::INFO::$1"
}

breaker() {
	info "----------------------------------------------------------"
}

info "Creating S3 bucket: ${S3_BUCKET_NAME}"
aws s3api create-bucket --bucket ${S3_BUCKET_NAME} \
		--region ${AWS_REGION}

info "Deleting deployment group: ${DEPLOYMENT_GROUP_NAME}"
aws deploy delete-deployment-group \
    --application-name ${APP_NAME} \
    --deployment-group-name ${DEPLOYMENT_GROUP_NAME}

info "Deleting application: ${APP_NAME}"
aws deploy delete-application \
    --application-name ${APP_NAME}

info "Creating application: ${APP_NAME}"
aws deploy create-application \
    --application-name ${APP_NAME}

info "Pushing source code onto S3 bucket: s3://${S3_BUCKET_NAME}/${S3_APP_BUNDLE_NAME}"
aws deploy push \
    --application-name ${APP_NAME} \
    --s3-location s3://${S3_BUCKET_NAME}/${S3_APP_BUNDLE_NAME} \
    --source ${APP_SOURCE_CODE_PATH} > /tmp/aws_deploy_push.output

ETAG=$(tail -1 /tmp/aws_deploy_push.output|awk -F'=' '{print $5}'|awk '{print $1}')
ARN=$(aws iam get-role --role-name CodeDeployServiceRole|jq '.Role.Arn'|tr -d '"')

info "ETAG: ${ETAG}"
info "ARN : ${ARN}"

info "Creating deployment group: ${DEPLOYMENT_GROUP_NAME}"
aws deploy create-deployment-group \
    --application-name ${APP_NAME} \
    --deployment-config-name ${DEPLOYMENT_CONFIG_NAME} \
    --deployment-group-name ${DEPLOYMENT_GROUP_NAME} \
    --ec2-tag-filters Key=Name,Value=${EC2_TAG_NAME_VALUE},Type=KEY_AND_VALUE \
    --service-role-arn ${ARN}

info "Creating deployment"
# REF: https://github.com/aws/aws-codedeploy-agent/issues/14
DID=$(aws deploy create-deployment \
    --application-name ${APP_NAME} \
    --s3-location bucket=${S3_BUCKET_NAME},key=${S3_APP_BUNDLE_NAME},bundleType=zip,eTag=${ETAG} \
    --file-exists-behavior OVERWRITE \
    --deployment-group-name ${DEPLOYMENT_GROUP_NAME}|jq '.deploymentId'|tr -d '"')

info "Get deployment status, may still be in-progress so please verify with AWS management console!"
aws deploy get-deployment \
    --deployment-id ${DID} \
    --query "deploymentInfo.status" \
    --output text
