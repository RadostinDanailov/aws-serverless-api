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
