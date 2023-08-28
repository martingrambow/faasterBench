export TF_VAR_TRIALS1=$1
export TF_VAR_TRIALS2=$2

terraform init
terraform apply -auto-approve
export count="$(terraform output -raw WRAPPERCOUNT)"
export EXPERIMENTID="$(terraform output -raw EXPERIMENTID)"
export FUNCTION_ENDPOINTS="$(terraform output -json FUNCTION_ENDPOINTS)"
echo "experiment ID is $EXPERIMENTID"
echo "endpoints are $FUNCTION_ENDPOINTS"
for (( i = 0; i < $count; i++ ))
do
    FUNCTION_ENDPOINT="$(echo $FUNCTION_ENDPOINTS | jq -r .[$i])"
    echo "endoint is $FUNCTION_ENDPOINT"
    artillery run -t $FUNCTION_ENDPOINT basicLoad.yml
done

gcloud logging read --project $GOOGLE_PROJECT 'resource.type="cloud_function" AND textPayload:'$EXPERIMENTID --format json > google.log
mkdir logs

echo "got results, will destroy setup..."
terraform destroy -auto-approve