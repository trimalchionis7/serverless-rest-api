# Configure region
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      created-by = "terraform"
    }
  }
}

# Create S3 bucket name
resource "random_pet" "lambda_bucket_name" {
  length = 2
}

# Create zip archive for Lambda source code
data "archive_file" "lambda_hello_world" {
  type        = "zip"
  source_dir  = "${path.module}/hello_world"
  output_path = "${path.module}/hello_world.zip"
}

# Upload Lambda zip file to S3 bucket
resource "aws_s3_object" "lambda_hello_world" {
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "hello_world.zip"
  source = data.archive_file.lambda_hello_world.output_path
  etag   = filemd5(data.archive_file.lambda_hello_world.output_path)
}

# Define Lambda function
resource "aws_lambda_function" "hello_world" {
  function_name    = "HelloCommunityBuilders"
  s3_bucket        = aws_s3_bucket.lambda_bucket.id
  s3_key           = aws_s3_object.lambda_hello_world.key
  runtime          = "python3.9"
  handler          = "app.lambda_handler"
  source_code_hash = data.archive_file.lambda_hello_world.output_base64sha256
  role             = aws_iam_role.lambda_exec.arn
  layers           = [aws_lambda_layer_version.lambda_layer.arn]
}

# Create HTTP-based REST API using API Gateway
resource "aws_apigatewayv2_api" "lambda" {
  name          = "API Gateway for HTTP-based REST API"
  protocol_type = "HTTP"
}

# Create deployment stage for API Gateway
resource "aws_apigatewayv2_stage" "lambda" {
  api_id      = aws_apigatewayv2_api.lambda.id
  name        = "stage"
  auto_deploy = true
}

# Define integration between API Gateway & Lambda function
resource "aws_apigatewayv2_integration" "hello_world" {
  api_id             = aws_apigatewayv2_api.lambda.id
  integration_uri    = aws_lambda_function.hello_world.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

# Define route for API Gateway
resource "aws_apigatewayv2_route" "hello_world" {
  api_id    = aws_apigatewayv2_api.lambda.id
  route_key = "GET /hello"
  target    = "integrations/${aws_apigatewayv2_integration.hello_world.id}"
}

# Give Gateway permissions
resource "aws_lambda_permission" "api_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello_world.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}

# Create ZIP archive for Lambda layer
data "archive_file" "layer" {
  type        = "zip"
  source_dir  = "${path.module}/layer"
  output_path = "${path.module}/layer/zip"
}

# Define Lambda layer version
resource "aws_lambda_layer_version" "lambda_layer" {
  filename                 = data.archive_file.layer.output_path
  layer_name               = "community-layer"
  source_code_hash         = data.archive_file.layer.output_base64sha256
  compatible_runtimes      = ["python3.9"]
  compatible_architectures = ["x86_64"]
}

resource "null_resource" "pip_install" {
  triggers = {
    shell_hash = sha256(file("${path.module}/hello_world/requirements.txt"))
  }

  provisioner "local-exec" {
    command = "python3 -m pip install -r ${path.module}/hello_world/requirements.txt -t ${path.module}/layer/python"
  }

  depends_on = [data.archive_file.layer]
}
