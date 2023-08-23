provider "aws" {
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

resource "aws_lambda_function" "wrapper" {
  count         = var.WRAPPERCOUNT
  filename      = "/tmp/wrapper.zip"
  function_name = "lambda-wrapper${count.index}"
  role          = aws_iam_role.wrapper_role.arn
  handler       = "index.handler"
  runtime       = "nodejs16.x"
  timeout       = 300

  # upload the function if the code hash is changed
  source_code_hash = data.archive_file.main.output_base64sha256
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
  description = "The URL of the Lambda Function URL"
  value       = try(aws_lambda_function_url.function[*].function_url, "")
}