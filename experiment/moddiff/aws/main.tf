provider "aws" {
  #region      = var.aws_region
  #access_key  = var.aws_access_key
  #secret_key  = var.aws_secret_key
}

# Archive lambda function
data "archive_file" "main" {
  type        = "zip"
  source_dir  = "../../wrapper/output/aws"
  output_path = "/tmp/wrapper.zip"

  depends_on = [null_resource.main]
}

# Provisioner to install dependencies in lambda package before upload it.
resource "null_resource" "main" {
  triggers = {
    updated_at = timestamp()
  }


}

resource "random_string" "experiment_id" {
  length  = 5
  special = false
  upper   = false
  keepers = {
    prefix = var.project_prefix
  }
}

resource "aws_lambda_function" "wrapper" {
  count         = var.WRAPPERCOUNT
  filename      = "/tmp/wrapper.zip"
  function_name = "lambda-wrapper${count.index}"
  role          = aws_iam_role.wrapper_role.arn
  handler       = "index.handler"
  runtime       = "nodejs16.x"
  timeout       = 300
  memory_size   = 512

  # upload the function if the code hash is changed
  source_code_hash = data.archive_file.main.output_base64sha256

  depends_on = [
    aws_cloudwatch_log_group.loggroup,
  ]

  environment {
    variables = {
      EXPERIMENTID = "${random_string.experiment_id.result}"
      TRIALS1 = var.TRIALS1
      TRIALS2 = var.TRIALS2
    }
  }
}

resource "aws_cloudwatch_log_group" "loggroup" {
  count             = 10 
  name              = "/aws/lambda/lambda-wrapper${count.index}"
  retention_in_days = 14
}



resource "aws_lambda_function_url" "function" {
    count         = var.WRAPPERCOUNT
    function_name      = aws_lambda_function.wrapper[count.index].function_name
    authorization_type = "NONE"
}

resource "aws_iam_role" "wrapper_role" {
  name               = "wrapper_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  inline_policy {
    name = "lamda-hello-world-policy"
    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "LambdaHelloWorld1",
          "Effect" : "Allow",
          "Action" : "*",
          "Resource" : "*"
        }
      ]
    })
  }
}

output "FUNCTION_ENDPOINTS" {
  description = "The URLs of the Lambda Function"
  value       = try(aws_lambda_function_url.function[*].function_url, "")
}

output "EXPERIMENTID" {
    value = "${random_string.experiment_id.result}"
}
output "WRAPPERCOUNT"{
    value = var.WRAPPERCOUNT
}