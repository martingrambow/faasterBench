export TF_VAR_TRIALS1=$1
export TF_VAR_TRIALS2=$2
export REGRESSION=$3
export TF_VAR_WRAPPERCOUNT=$4
export CALLS=$5
export ITERATIONS=$6

terraform init
terraform apply -auto-approve
export vars="{ \"experimentid\": \"$EXPERIMENTID\", \"trials1\": \"$1\", \"trials2\": \"$2\" }"
export count="$(terraform output -raw WRAPPERCOUNT)"
export EXPERIMENTID="$(terraform output -raw EXPERIMENTID)"
export FUNCTION_ENDPOINTS="$(terraform output -json FUNCTION_ENDPOINTS)"
echo "experiment ID is $EXPERIMENTID"
echo "endpoints are $FUNCTION_ENDPOINTS"
for (( i = 0; i < $count; i++ ))
do
    FUNCTION_ENDPOINT="$(echo $FUNCTION_ENDPOINTS | jq -r .[$i])"
    echo "endpoint is $FUNCTION_ENDPOINT"
    artillery run -t https://$FUNCTION_ENDPOINT/api/faasterbench --variables "$vars" basicLoad_${CALLS}_${ITERATIONS}.yml
done


mv google.log google_${REGRESSION}_${count}_${CALLS}_${ITERATIONS}.log

echo "got results, will destroy setup..."
terraform destroy -auto-approve