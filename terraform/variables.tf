variable "github_repo" {
  description = "GitHub repository in org/repo format"
  default     = "rosenbergj/zmanimapi"
}

variable "lambda_function_name" {
  description = "Name of the Lambda function to deploy to"
  default     = "ZmanimAPI"
}

variable "s3_bucket_name" {
  description = "S3 bucket used for Lambda deployment artifacts"
}
