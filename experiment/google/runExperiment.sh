export TF_VAR_TRIALS1=$1
export TF_VAR_TRIALS2=$2

terraform init
terraform apply -auto-approve
export FUNCTION_ENDPOINT="$(terraform output -raw FUNCTION_ENDPOINT)"
export EXPERIMENTID="$(terraform output -raw EXPERIMENTID)"
echo "endoint is $FUNCTION_ENDPOINT"
echo "experiment ID is $EXPERIMENTID"
artillery run -t $FUNCTION_ENDPOINT basicLoad.yml
echo "experiment ID is $EXPERIMENTID"
mkdir logs

gcloud logging read --project $GOOGLE_PROJECT 'resource.type="cloud_function" AND textPayload:'$EXPERIMENTID --format json > logs/google_$3.log
echo "got results, will destroy setup..."
terraform destroy -auto-approve