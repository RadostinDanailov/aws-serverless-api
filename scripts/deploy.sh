#!/usr/bin/env bash
set -e

# Package Lambda
echo "Packaging Lambda..."
cd lambda
zip -r ../lambda.zip .
cd ..

# Deploy Terraform
echo "Running Terraform..."
terraform init
terraform apply -auto-approve
