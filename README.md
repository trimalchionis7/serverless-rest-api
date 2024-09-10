# Deploying a Serverless HTTP-based REST API with AWS Lambda, API Gateway and S3 using Terraform

This project deploys a simple REST API using AWS services and the popular IaC tool Terraform.

The infrastructure is built from the following components:

[1] a Lambda handler written in Python, which retrieves a given webpage;

[2] an AWS S3 bucket, with IAM permissions granted to store the Lambda source code;

[3] an API Gateway, which, when the user sends a GET request, passes the request to the Lambda function for processing.

Please note that this project is a work in progress.