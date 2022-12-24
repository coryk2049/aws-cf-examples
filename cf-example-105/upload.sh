#!/bin/bash

S3_BUCKET_NAME=acme-networking-demo
CF_STACK_NAME=acme-networking-demo
CF_TEMPLATE_URL=https://acme-networking-demo.s3.amazonaws.com/main.yaml

info() {
    echo -e "[`date '+%m/%d/%Y-%H:%M:%S'`]::INFO::---------------------------------------------------"
    echo -e "[`date '+%m/%d/%Y-%H:%M:%S'`]::INFO::$1"
    echo -e "[`date '+%m/%d/%Y-%H:%M:%S'`]::INFO::---------------------------------------------------"
}

info "Deleting CF stack: ${CF_STACK_NAME}"
aws cloudformation delete-stack --stack-name ${CF_STACK_NAME} 

sleep 5

info "Creating S3 bucket: ${S3_BUCKET_NAME}"
aws s3 mb s3://${S3_BUCKET_NAME}

sleep 5

for FN in $(ls *.yaml); do
	info "Uploading ${FN} to S3 bucket: ${S3_BUCKET_NAME}"
	aws s3 cp ${FN} s3://${S3_BUCKET_NAME}
done

info "List S3 bucket: ${S3_BUCKET_NAME}"
aws s3 ls ${S3_BUCKET_NAME}

#info "Creating CF stack: ${CF_STACK_NAME}"
#aws cloudformation create-stack --stack-name ${CF_STACK_NAME} \
#    --template-body ${CF_TEMPLATE_URL} \


