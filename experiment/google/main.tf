provider "google" {
}

locals {
  project_name  = "${var.project_prefix}-${random_string.experiment_id.result}"
}


resource "random_string" "experiment_id" {
  length  = 5
  special = false
  upper   = false
  keepers = {
    prefix = var.project_prefix
  }
}

#function
resource "google_cloudfunctions_function" "function" {
    count                 = 10 
    name                  = "wrapper${count.index}"
    runtime               = var.runtime  # of course changeable

    # Get the source code of the cloud function as a Zip compression
    source_archive_bucket = google_storage_bucket.function_bucket.name
    source_archive_object = google_storage_bucket_object.wrapper.name

    # Must match the function name in the cloud function `main.py` source code
    entry_point           = "wrapperTest"

    environment_variables = {
        EXPERIMENTID = "${random_string.experiment_id.result}"
        TRIALS1 = var.TRIALS1
        TRIALS2 = var.TRIALS2
    }

    #
    trigger_http          = true


}

resource "google_cloudfunctions_function_iam_member" "invoker" {
  count = 10
  project        = google_cloudfunctions_function.function[0].project
  region         = google_cloudfunctions_function.function[0].region
  cloud_function = google_cloudfunctions_function.function["${count.index}"].name

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

data "archive_file" "sourcewrapper" {
    type        = "zip"
    source_dir  = "../../wrapper/output/google/"
    output_path = "./tmp/wrapper.zip"
}

# Add source code zip to the Cloud Function's bucket
resource "google_storage_bucket_object" "wrapper" {
    source       = data.archive_file.sourcewrapper.output_path
    content_type = "application/zip"

    # Append to the MD5 checksum of the files's content
    # to force the zip to be updated as soon as a change occurs
    name         = "src-${data.archive_file.sourcewrapper.output_md5}.zip"
    bucket       = google_storage_bucket.function_bucket.name
}

data "google_client_config" "current" {

}

#output "FUNCTION_ENDPOINT" {
#    value = ["https://${data.google_client_config.current.region}-${data.google_client_config.current.project}.cloudfunctions.net/${google_cloudfunctions_function.function.*.name}"]
#    #value = ["${google_cloudfunctions_function.function.*.name}"]
#}

output "EXPERIMENTID" {
    value = "${random_string.experiment_id.result}"
}
