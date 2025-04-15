#!/bin/bash

IMAGE_NAME="orona-cdk-appy"
if [ -z "$AWS_ACCOUNT_ID" ] || [ -z "$AWS_REGION" ]; then
  echo "Please set the AWS_ACCOUNT_ID and AWS_REGION environment variables."
  exit 1
fi
ECR_REPOSITORY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_NAME}"

# Step 1: Authenticate docker to ECR
echo "Authenticating Docker to ECR..."
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

# Step 2: Build the docker image
echo "Building Docker image..."
docker build -t ${IMAGE_NAME} -f docker/Dockerfile .

# Step 3: Tag the docker image
echo "Tagging Docker image..."
docker tag ${IMAGE_NAME}:latest ${ECR_REPOSITORY}:latest

# Step 4: Push the docker image to ECR
echo "Pushing Docker image to ECR..."
docker push ${ECR_REPOSITORY}:latest

echo "Deployment completed successfully!"