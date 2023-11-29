export TF_VAR_TRIALS1=$1
export TF_VAR_TRIALS2=$2
export REGRESSION=$3
export TF_VAR_WRAPPERCOUNT=$4
export CALLS=$5
export ITERATIONS=$6

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
    echo "endpoint is $FUNCTION_ENDPOITN"
    artillery run -t $FUNCTION_ENDPOINT basicLoad_${CALLS}_${ITERATIONS}.yml
done

gcloud logging read --project $GOOGLE_PROJECT 'resource.type="cloud_function" AND textPayload:'$EXPERIMENTID --format json > google.log
mv google.log google_${REGRESSION}_${count}_${CALLS}_${ITERATIONS}.log

echo "got results, will destroy setup..."
terraform destroy -auto-approve