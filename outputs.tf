output "lambda_bucket_name" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.lambda_bucket.id
}

output "function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.hello_world.function_name
}

output "base_url" {
  description = "base URL for API Gateway stage"
  value       = aws_apigatewayv2_stage.lambda.invoke_url
}
