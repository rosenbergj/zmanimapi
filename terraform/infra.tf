resource "aws_s3_bucket" "lambda_packages" {
  bucket = var.s3_bucket_name
}

resource "aws_iam_role" "lambda_exec" {
  name = "ZmanimAPI-role-2b8cuuvq"
  path = "/service-role/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_exec_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_cloudwatch_log_group" "lambda" {
  name = "/aws/lambda/${var.lambda_function_name}"
}

resource "aws_lambda_function" "api" {
  function_name                  = var.lambda_function_name
  role                           = aws_iam_role.lambda_exec.arn
  handler                        = "zmanimapi.lambda_handler"
  runtime                        = "python3.13"
  timeout                        = 10
  s3_bucket                      = aws_s3_bucket.lambda_packages.bucket
  s3_key                         = "lambda.zip"
  layers                         = ["arn:aws:lambda:us-east-1:${data.aws_caller_identity.current.account_id}:layer:Zmanim-API-dependencies:42"]
  reserved_concurrent_executions = 5

  lifecycle {
    ignore_changes = [s3_bucket, s3_key]
  }
}

resource "aws_api_gateway_rest_api" "api" {
  name = "Zmanim API"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_request_validator" "query_params" {
  rest_api_id                 = aws_api_gateway_rest_api.api.id
  name                        = "Validate query string parameters and headers"
  validate_request_parameters = true
}

resource "aws_api_gateway_method" "root_get" {
  rest_api_id          = aws_api_gateway_rest_api.api.id
  resource_id          = aws_api_gateway_rest_api.api.root_resource_id
  http_method          = "GET"
  authorization        = "NONE"
  request_validator_id = aws_api_gateway_request_validator.query_params.id

  request_parameters = {
    "method.request.querystring.chagdays" = true
    "method.request.querystring.lat"      = true
    "method.request.querystring.lon"      = true
  }
}

resource "aws_api_gateway_integration" "root_get" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_rest_api.api.root_resource_id
  http_method             = aws_api_gateway_method.root_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.api.invoke_arn
  content_handling        = "CONVERT_TO_TEXT"
}

resource "aws_api_gateway_deployment" "api" {
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_stage" "production" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.api.id
  stage_name    = "production"
}

resource "aws_api_gateway_method_settings" "all" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_stage.production.stage_name
  method_path = "*/*"

  settings {
    throttling_burst_limit = 5
    throttling_rate_limit  = 10
  }
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "6bd11508-09f7-4098-aaa8-9e9071dbb08f"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/GET/"
}

data "aws_acm_certificate" "api" {
  domain   = "*.amishabbatornot.com"
  statuses = ["ISSUED"]
}

resource "aws_api_gateway_domain_name" "zmanapi" {
  domain_name              = "api.zmanapi.com"
  regional_certificate_arn = data.aws_acm_certificate.api.arn
  security_policy          = "TLS_1_2"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_domain_name" "zmanimapi" {
  domain_name              = "api.zmanimapi.com"
  regional_certificate_arn = data.aws_acm_certificate.api.arn
  security_policy          = "TLS_1_2"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_domain_name" "amishabbatornot" {
  domain_name              = "api.amishabbatornot.com"
  regional_certificate_arn = data.aws_acm_certificate.api.arn
  security_policy          = "TLS_1_2"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_base_path_mapping" "zmanapi" {
  domain_name = aws_api_gateway_domain_name.zmanapi.domain_name
  api_id      = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_stage.production.stage_name
}

resource "aws_api_gateway_base_path_mapping" "zmanimapi" {
  domain_name = aws_api_gateway_domain_name.zmanimapi.domain_name
  api_id      = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_stage.production.stage_name
}

resource "aws_api_gateway_base_path_mapping" "amishabbatornot" {
  domain_name = aws_api_gateway_domain_name.amishabbatornot.domain_name
  api_id      = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_stage.production.stage_name
}
