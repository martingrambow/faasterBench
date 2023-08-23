export TF_VAR_TRIALS1=$1
export TF_VAR_TRIALS2=$2

terraform init
terraform apply -auto-approve
export FUNCTION_ENDPOINTS=("$(terraform output -raw FUNCTION_ENDPOINTS)")
export EXPERIMENTID="$(terraform output -raw EXPERIMENTID)"
echo "experiment ID is $EXPERIMENTID"


#TODO 

mkdir logs

echo "got results, will destroy setup..."
terraform destroy -auto-approve