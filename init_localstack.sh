#!/bin/bash

echo "########### Setting resource names as env variables ###########"
LOCALSTACK_DUMMY_ID=000000000000

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

echo "########### List S3 bucket ###########"
awslocal s3api list-buckets
