terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      # Root module should specify the maximum provider version
      # The ~> operator is a convenient shorthand for allowing only patch releases within a specific minor release.
      version = "~> 3.92"
    }
  }
}

#GENERAL

resource "random_string" "experiment_id" {
  length  = 5
  special = false
  upper   = false
  keepers = {
    prefix = var.project_prefix
  }
}



#AWS
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "resource_group" {
  name = "faasterbench-resource-group-v1"
  location = var.location
}

resource "azurerm_application_insights" "application_insights" {
  name                = "${var.project}-application-insights"
  location            = var.location
  resource_group_name = azurerm_resource_group.resource_group.name
  application_type    = "Node.JS"
}

resource "azurerm_service_plan" "faasterbench" {
  name                = "faasterbench"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_storage_account" "storage_account" {
  name = "${var.project}storagev2"
  resource_group_name = azurerm_resource_group.resource_group.name
  location = var.location
  account_tier = "Standard"
  account_replication_type = "LRS"
}

output "application_insights_key"{
    sensitive   = true
    value       = azurerm_application_insights.application_insights.instrumentation_key
}

output "application_insights_connection_string"{
    sensitive   = true
    value       = azurerm_application_insights.application_insights.connection_string
}
output "application_insights_app_id"{
    sensitive   = false
    value       = azurerm_application_insights.application_insights.app_id
}
output "resource_group_name" {
    value = azurerm_resource_group.resource_group.name
}
output "storage_account_name" {
    value = azurerm_storage_account.storage_account.name
}

output "primary_access_key" {
    sensitive = true
    value = azurerm_storage_account.storage_account.primary_access_key
}

output "service_plan_id" {
    value = azurerm_service_plan.faasterbench.id
}



#Google

provider "google" {
}

locals {
  project_name  = "${var.project_prefix}-${random_string.experiment_id.result}"
}




#function
resource "google_cloudfunctions_function" "cpu_function" {
    count                 = 10
    name                  = "cpuwrapper${count.index}"
    runtime               = var.google_runtime  # of course changeable
    available_memory_mb   = 512

    # Get the source code of the cloud function as a Zip compression
    source_archive_bucket = google_storage_bucket.function_bucket.name
    source_archive_object = google_storage_bucket_object.cpu_wrapper.name

    # Must match the function name in the cloud function `main.py` source code
    entry_point           = "wrapperTest"

    environment_variables = {
        EXPERIMENTID = "${random_string.experiment_id.result}"
    }

    #
    trigger_http          = true


}

resource "google_cloudfunctions_function" "mem_function" {
    count                 = 10
    name                  = "memwrapper${count.index}"
    runtime               = var.google_runtime  # of course changeable
    available_memory_mb   = 512

    # Get the source code of the cloud function as a Zip compression
    source_archive_bucket = google_storage_bucket.function_bucket.name
    source_archive_object = google_storage_bucket_object.mem_wrapper.name

    # Must match the function name in the cloud function `main.py` source code
    entry_point           = "wrapperTest"

    environment_variables = {
        EXPERIMENTID = "${random_string.experiment_id.result}"
    }

    #
    trigger_http          = true


}

resource "google_cloudfunctions_function" "net_function" {
    count                 = 10
    name                  = "netwrapper${count.index}"
    runtime               = var.google_runtime  # of course changeable
    available_memory_mb   = 512

    # Get the source code of the cloud function as a Zip compression
    source_archive_bucket = google_storage_bucket.function_bucket.name
    source_archive_object = google_storage_bucket_object.net_wrapper.name

    # Must match the function name in the cloud function `main.py` source code
    entry_point           = "wrapperTest"

    environment_variables = {
        EXPERIMENTID = "${random_string.experiment_id.result}"
    }

    #
    trigger_http          = true


}

resource "google_cloudfunctions_function_iam_member" "cpu_invoker" {
  count          = 10
  project        = google_cloudfunctions_function.cpu_function[0].project
  region         = google_cloudfunctions_function.cpu_function[0].region
  cloud_function = google_cloudfunctions_function.cpu_function["${count.index}"].name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}

resource "google_cloudfunctions_function_iam_member" "mem_invoker" {
  count          = 10
  project        = google_cloudfunctions_function.mem_function[0].project
  region         = google_cloudfunctions_function.mem_function[0].region
  cloud_function = google_cloudfunctions_function.mem_function["${count.index}"].name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}

resource "google_cloudfunctions_function_iam_member" "net_invoker" {
  count          = 10
  project        = google_cloudfunctions_function.net_function[0].project
  region         = google_cloudfunctions_function.net_function[0].region
  cloud_function = google_cloudfunctions_function.net_function["${count.index}"].name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}

#storage
resource "google_storage_bucket" "function_bucket" {
    name     = "${local.project_name}-function"
    location = "EU"
}

resource "google_storage_bucket" "input_bucket" {
    name     = "${local.project_name}-input"
    location = "EU"
}

data "archive_file" "cpu_sourcewrapper" {
    type        = "zip"
    source_dir  = "../wrapper/output/cpu/google/"
    output_path = "./tmp/gcp_cpu_wrapper.zip"
}

data "archive_file" "mem_sourcewrapper" {
    type        = "zip"
    source_dir  = "../wrapper/output/mem/google/"
    output_path = "./tmp/gcp_mem_wrapper.zip"
}

data "archive_file" "net_sourcewrapper" {
    type        = "zip"
    source_dir  = "../wrapper/output/network/google/"
    output_path = "./tmp/gcp_net_wrapper.zip"
}

# Add source code zip to the Cloud Function's bucket
resource "google_storage_bucket_object" "cpu_wrapper" {
    source       = data.archive_file.cpu_sourcewrapper.output_path
    content_type = "application/zip"

    # Append to the MD5 checksum of the files's content
    # to force the zip to be updated as soon as a change occurs
    name         = "src-${data.archive_file.cpu_sourcewrapper.output_md5}.zip"
    bucket       = google_storage_bucket.function_bucket.name
}

resource "google_storage_bucket_object" "mem_wrapper" {
    source       = data.archive_file.mem_sourcewrapper.output_path
    content_type = "application/zip"

    # Append to the MD5 checksum of the files's content
    # to force the zip to be updated as soon as a change occurs
    name         = "src-${data.archive_file.mem_sourcewrapper.output_md5}.zip"
    bucket       = google_storage_bucket.function_bucket.name
}

resource "google_storage_bucket_object" "net_wrapper" {
    source       = data.archive_file.net_sourcewrapper.output_path
    content_type = "application/zip"

    # Append to the MD5 checksum of the files's content
    # to force the zip to be updated as soon as a change occurs
    name         = "src-${data.archive_file.net_sourcewrapper.output_md5}.zip"
    bucket       = google_storage_bucket.function_bucket.name
}

data "google_client_config" "current" {

}

output "GCP_CPU_FUNCTION_ENDPOINTS" {
  description = "The URL of the functions"
  value       = try(google_cloudfunctions_function.cpu_function[*].https_trigger_url, "")
}
output "GCP_MEM_FUNCTION_ENDPOINTS" {
  description = "The URL of the functions"
  value       = try(google_cloudfunctions_function.mem_function[*].https_trigger_url, "")
}
output "GCP_NET_FUNCTION_ENDPOINTS" {
  description = "The URL of the functions"
  value       = try(google_cloudfunctions_function.net_function[*].https_trigger_url, "")
}

output "WRAPPERCOUNT"{
    value = 10
}
output "EXPERIMENTID" {
    value = "${random_string.experiment_id.result}"
}


#AWS

provider "aws" {
  #region      = var.aws_region
  #access_key  = var.aws_access_key
  #secret_key  = var.aws_secret_key
}

# Archive lambda functions
data "archive_file" "aws_cpu_main" {
  type        = "zip"
  source_dir  = "../wrapper/output/cpu/aws"
  output_path = "/tmp/aws_cpu_wrapper.zip"

  depends_on = [null_resource.main]
}

data "archive_file" "aws_mem_main" {
  type        = "zip"
  source_dir  = "../wrapper/output/mem/aws"
  output_path = "/tmp/aws_mem_wrapper.zip"

  depends_on = [null_resource.main]
}

data "archive_file" "aws_net_main" {
  type        = "zip"
  source_dir  = "../wrapper/output/network/aws"
  output_path = "/tmp/aws_net_wrapper.zip"

  depends_on = [null_resource.main]
}

# Provisioner to install dependencies in lambda package before upload it.
resource "null_resource" "main" {
  triggers = {
    updated_at = timestamp()
  }


}

resource "aws_lambda_function" "cpu_wrapper" {
  count         = 10
  filename      = "/tmp/aws_cpu_wrapper.zip"
  function_name = "cpulambda-wrapper${count.index}"
  role          = aws_iam_role.wrapper_role.arn
  handler       = "index.handler"
  runtime       = var.aws_runtime
  timeout       = 300
  memory_size   = 512

  # upload the function if the code hash is changed
  source_code_hash = data.archive_file.aws_cpu_main.output_base64sha256

  depends_on = [
    aws_cloudwatch_log_group.cpu_loggroup,
  ]

  environment {
    variables = {
      EXPERIMENTID = "${random_string.experiment_id.result}"
    }
  }
}

resource "aws_lambda_function" "net_wrapper" {
  count         = 10
  filename      = "/tmp/aws_net_wrapper.zip"
  function_name = "netlambda-wrapper${count.index}"
  role          = aws_iam_role.wrapper_role.arn
  handler       = "index.handler"
  runtime       = "nodejs16.x"
  timeout       = 300
  memory_size   = 512

  # upload the function if the code hash is changed
  source_code_hash = data.archive_file.aws_net_main.output_base64sha256

  depends_on = [
    aws_cloudwatch_log_group.net_loggroup,
  ]

  environment {
    variables = {
      EXPERIMENTID = "${random_string.experiment_id.result}"
    }
  }
}

resource "aws_lambda_function" "mem_wrapper" {
  count         = 10
  filename      = "/tmp/aws_mem_wrapper.zip"
  function_name = "memlambda-wrapper${count.index}"
  role          = aws_iam_role.wrapper_role.arn
  handler       = "index.handler"
  runtime       = "nodejs16.x"
  timeout       = 300
  memory_size   = 512

  # upload the function if the code hash is changed
  source_code_hash = data.archive_file.aws_mem_main.output_base64sha256

  depends_on = [
    aws_cloudwatch_log_group.mem_loggroup,
  ]

  environment {
    variables = {
      EXPERIMENTID = "${random_string.experiment_id.result}"
    }
  }
}
resource "aws_cloudwatch_log_group" "cpu_loggroup" {
  count             = 10 
  name              = "/aws/lambda/cpulambda-wrapper${count.index}"
  retention_in_days = 30
}
resource "aws_cloudwatch_log_group" "mem_loggroup" {
  count             = 10 
  name              = "/aws/lambda/memlambda-wrapper${count.index}"
  retention_in_days = 30
}
resource "aws_cloudwatch_log_group" "net_loggroup" {
  count             = 10 
  name              = "/aws/lambda/netlambda-wrapper${count.index}"
  retention_in_days = 30
}



resource "aws_lambda_function_url" "cpu_function" {
    count         = 10
    function_name      = aws_lambda_function.cpu_wrapper[count.index].function_name
    authorization_type = "NONE"
}

resource "aws_lambda_function_url" "mem_function" {
    count         = 10
    function_name      = aws_lambda_function.mem_wrapper[count.index].function_name
    authorization_type = "NONE"
}

resource "aws_lambda_function_url" "net_function" {
    count         = 10
    function_name      = aws_lambda_function.net_wrapper[count.index].function_name
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

output "AWS_CPU_FUNCTION_ENDPOINTS" {
  description = "The URLs of the Lambda Function"
  value       = try(aws_lambda_function_url.cpu_function[*].function_url, "")
}

output "AWS_MEM_FUNCTION_ENDPOINTS" {
  description = "The URLs of the Lambda Function"
  value       = try(aws_lambda_function_url.mem_function[*].function_url, "")
}

output "AWS_NET_FUNCTION_ENDPOINTS" {
  description = "The URLs of the Lambda Function"
  value       = try(aws_lambda_function_url.net_function[*].function_url, "")
}
