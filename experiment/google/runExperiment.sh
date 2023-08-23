export TF_VAR_TRIALS1=$1
export TF_VAR_TRIALS2=$2

terraform init
terraform apply -auto-approve
export count="$(terraform output -raw WRAPPERCOUNT)"
export EXPERIMENTID="$(terraform output -raw EXPERIMENTID)"
echo "experiment ID is $EXPERIMENTID"
for (( i = 0; i < $count; i++ )) 
do
    export FUNCTION_ENDPOINT="https://$GOOGLE_REGION-$GOOGLE_PROJECT.cloudfunctions.net/wrapper$i"
    echo "endoint is $FUNCTION_ENDPOINT"
    artillery run -t $FUNCTION_ENDPOINT basicLoad.yml
done
gcloud logging read --project $GOOGLE_PROJECT 'resource.type="cloud_function" AND textPayload:'$EXPERIMENTID --format json > google.log
mkdir logs

echo "got results, will destroy setup..."
terraform destroy -auto-approve