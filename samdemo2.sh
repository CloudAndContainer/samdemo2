#!/bin/bash

# create s3 bucket in the same region as in aws configure
S3_BUCKET=serverlesswebapplifecyclemgmt
STACK_NAME=serverlesswebapplifecyclemgmt

USE_MSG="Usage: samdemo2.sh S3_BUCKET STACK_NAME"

# check if bucket exists
if [ -z "$S3_BUCKET" ]; then
  echo "Missing S3_BUCKET and STACK_NAME"
  echo $USE_MSG
  exit 1
fi

# check if stackname is provided and is not duplicate (https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks)
if [ -z "$STACK_NAME" ]; then
  echo "Missing STACK_NAME"
  echo $USE_MSG
  exit 1
fi

# upload files to S3
sam package \
  --template-file template.yaml \
  --s3-bucket $S3_BUCKET \
  --output-template-file package.yaml

# deploy to cloud formation
sam deploy \
  --template-file package.yaml \
  --stack-name $STACK_NAME \
  --capabilities CAPABILITY_IAM

# get API endpoint
API_ENDPOINT=$(aws cloudformation describe-stacks \
  --stack-name $STACK_NAME \
  --query 'Stacks[0].Outputs[0].OutputValue')

# remove quotes
API_ENDPOINT=$(sed -e 's/^"//' -e 's/"$//' <<< $API_ENDPOINT)
