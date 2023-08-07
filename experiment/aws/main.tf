terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

resource "aws_lambda_function" "function" {
  function_name = "wrapper"
  handler       = var.handler
  runtime       = var.runtime

  filename         = "wrapper.zip"
  source_code_hash = data.archive_file.function_zip.output_base64sha256

  role = ""
  environment {
    variables = {
    }
  }
}

data "archive_file" "function_zip" {
  source_dir  = "../../wrapper/output"
  type        = "zip"
  output_path = "wrapper.zip"
}