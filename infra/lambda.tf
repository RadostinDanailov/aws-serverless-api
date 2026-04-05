data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda"
  output_path = "${path.module}/../lambda.zip"
}

resource "aws_lambda_function" "api" {
  function_name = "${var.project_name}-handler"
  role          = aws_iam_role.lambda_role.arn
  handler       = "handler.lambda_handler"
  runtime       = "python3.12"

  filename         = "${path.module}/../lambda.zip"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.items.name
    }
  }
}


resource "aws_lambda_permission" "apigw_invoke" {
  statement_id = "AllowAPIGatewayInvoke-${aws_apigatewayv2_api.http_api.id}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}
