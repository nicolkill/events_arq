#!/bin/bash

echo "########### Setting resource names as env variables ###########"
LOCALSTACK_DUMMY_ID=000000000000

guess_arn_for_sqs() {
    local QUEUE_NAME=$1
    echo "arn:aws:sqs:${DEFAULT_REGION}:${LOCALSTACK_DUMMY_ID}:$QUEUE_NAME"
}

create_queue() {
    local QUEUE_NAME_TO_CREATE=$1
    awslocal sqs create-queue\
        --region $DEFAULT_REGION\
        --queue-name $QUEUE_NAME_TO_CREATE
}

echo "########### Creating upload file event SQS ###########"
create_queue $BUCKET_QUEUE
BUCKET_QUEUE_ARN=$(guess_arn_for_sqs $BUCKET_QUEUE)

echo "########### Creating queues in SQS ###########"
IFS=','
read -ra Queues <<< "$QUEUES"
for q in "${Queues[@]}";
do
  create_queue $q
done

echo "########### Create S3 bucket ###########"
awslocal s3api create-bucket\
    --region $DEFAULT_REGION\
    --bucket $BUCKET_NAME\
    --create-bucket-configuration LocationConstraint=$DEFAULT_REGION

echo "########### Adding cors bucket ###########"
awslocal s3api put-bucket-cors\
    --bucket $BUCKET_NAME\
    --cors-configuration '{
      "CORSRules": [
        {
          "AllowedHeaders": ["*"],
          "AllowedMethods" : ["HEAD", "GET", "POST", "PUT", "DELETE"],
          "AllowedOrigins" : [
            "http://localhost:4000",
            "http://localhost:3000"
          ],
          "ExposeHeaders": []
        }
      ]
    }'


echo "########### Set S3 bucket notification configurations ###########"
aws --endpoint-url=http://localhost:4566 s3api put-bucket-notification-configuration\
    --bucket $BUCKET_NAME\
    --notification-configuration  '{
                                      "QueueConfigurations": [
                                         {
                                           "QueueArn": "'"$BUCKET_QUEUE_ARN"'",
                                           "Events": ["s3:ObjectCreated:Put"]
                                         }
                                       ]
                                     }'

echo "########### List S3 bucket ###########"
awslocal s3api list-buckets

echo "########### Get S3 bucket notification configurations ###########"
aws --endpoint-url=http://localhost:4566 s3api get-bucket-notification-configuration\
    --bucket $BUCKET_NAME
