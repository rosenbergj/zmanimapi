output "role_arn" {
  description = "Add this value as the AWS_ROLE_ARN secret in GitHub repository settings"
  value       = aws_iam_role.deploy.arn
}
