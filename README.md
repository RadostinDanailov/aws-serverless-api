 ### Serverless CRUD API on AWS (Terraform + Lambda + DynamoDB)
A fully serverless, production‑ready CRUD API built using AWS Lambda, API Gateway (HTTP API), DynamoDB, and Terraform.
This project demonstrates real‑world cloud engineering and DevOps practices, including Infrastructure as Code, event‑driven compute, IAM permissions, and automated deployments.
### Overview

#I built the project manually to understand the fundamentals and rebuilt it using Terraform for automation and reproducibility.

This API supports full Create, Read, Update, Delete operations on items stored in DynamoDB.
The entire infrastructure is provisioned using Terraform, ensuring reproducibility and clean automation.

Once deployed, the API is immediately accessible via a public HTTPS endpoint.

### Architecture
Client[Client / Curl / Frontend] -->|HTTPS Request| APIGW[API Gateway<br>HTTP API]
APIGW -->|Proxy Integration| Lambda[Lambda Function<br>Python Handler]
Lambda -->|Read/Write| DynamoDB[(DynamoDB Table<br>serverless-api-demo-items)]
   ###
   AWS[AWS Cloud]
        APIGW
        Lambda
        DynamoDB
    ###
    IaC[Infrastructure as Code]
    Terraform[Terraform<br>Infrastructure Automation]
    Terraform --> AWS


### Project Structure
Code
aws-serverless-api/
├── lambda/
│   └── handler.py
└── infra/
    ├── api_gateway.tf
    ├── dynamodb.tf
    ├── lambda.tf
    ├── main.tf
    ├── outputs.tf
    ├── provider.tf
    ├── variables.tf


###Features

Fully serverless architecture (no servers to manage)

Clean, modular Terraform configuration

Automatic Lambda packaging via archive_file

HTTP API v2 event handling

DynamoDB table with on‑demand capacity

IAM roles with least‑privilege permissions

Auto‑deploy API Gateway stage

Easy to extend with new routes or services

### Deployment

From the infra/ directory:

bash
terraform init
terraform apply
Terraform outputs:

API URL

DynamoDB table name

Example:

Code
api_invoke_url = "https://xxxx.execute-api.eu-west-2.amazonaws.com"
dynamodb_table_name = "serverless-api-demo-items"

###Testing the API
Replace <api> with your actual API URL.

Create an item
bash
curl -X POST https://<api>/items \
  -H "Content-Type: application/json" \
  -d '{"id":"1","name":"First item"}'

Get an item
bash
curl https://<api>/items/1

Update an item
bash
curl -X PUT https://<api>/items/1 \
  -H "Content-Type: application/json" \
  -d '{"name":"Updated item"}'

Delete an item
bash
curl -X DELETE https://<api>/items/1

###Lambda Handler (Python)
python
import json
import boto3
import os

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["TABLE_NAME"])

def lambda_handler(event, context):
    route = event.get("routeKey")
    body = json.loads(event.get("body") or "{}")

    if route == "POST /items":
        table.put_item(Item=body)
        return response(200, {"message": "Item created", "item": body})

    if route == "GET /items/{id}":
        item_id = event["pathParameters"]["id"]
        result = table.get_item(Key={"id": item_id})
        return response(200, result.get("Item", {}))

    if route == "PUT /items/{id}":
        item_id = event["pathParameters"]["id"]
        body["id"] = item_id
        table.put_item(Item=body)
        return response(200, {"message": "Item updated", "item": body})

    if route == "DELETE /items/{id}":
        item_id = event["pathParameters"]["id"]
        table.delete_item(Key={"id": item_id})
        return response(200, {"message": "Item deleted"})

    return response(400, {"message": "Unsupported operation"})

def response(status, body):
    return {
        "statusCode": status,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(body)
    }
### Security & IAM
Lambda runs with a dedicated IAM role

Only DynamoDB table access is permitted

API Gateway is explicitly allowed to invoke Lambda

No hard‑coded credentials

Infrastructure is fully reproducible and version‑controlled
