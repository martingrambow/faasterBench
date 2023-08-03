terraform init
terraform apply -auto-approve
export FUNCTION_ENDPOINT="$(terraform output -raw FUNCTION_ENDPOINT)"
export EXPERIMENTID="$(terraform output -raw EXPERIMENTID)"
echo "endoint is $FUNCTION_ENDPOINT"
echo "experiment ID is $EXPERIMENTID"
artillery run -t $FUNCTION_ENDPOINT basicLoad.yml
echo "experiment ID is $EXPERIMENTID"
gcloud logging read --project $GOOGLE_PROJECT 'resource.type="cloud_function" AND textPayload:'$EXPERIMENTID --format json > google.log
echo "got results, will destroy setup..."
terraform destroy -auto-approve