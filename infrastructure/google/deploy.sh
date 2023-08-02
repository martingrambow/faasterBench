terraform init
terraform apply -auto-approve
export FUNCTION_ENDPOINT="$(terraform output -raw FUNCTION_ENDPOINT)"