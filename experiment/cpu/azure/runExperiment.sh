export TF_VAR_TRIALS1=$1
export TF_VAR_TRIALS2=$2
export REGRESSION=$3
export TF_VAR_WRAPPERCOUNT=$4
export wrappercount="$((TF_VAR_WRAPPERCOUNT-1))"
export CALLS=$5
export ITERATIONS=$6
terraform init
terraform apply -auto-approve

for i in $( eval echo {0..$wrappercount} )
do
    az functionapp deployment source config-zip -g faasterbench-resource-group-v1  -n faasterbench$i --src azure_func.zip
done

export count="$(terraform output -raw WRAPPERCOUNT)"
export EXPERIMENTID="$(terraform output -raw EXPERIMENTID)"
export FUNCTION_ENDPOINTS="$(terraform output FUNCTION_ENDPOINTS)"
export appKey="$(terraform output -raw APPID)"
echo $appKey

echo "experiment ID is $EXPERIMENTID"
echo "endpoints are $FUNCTION_ENDPOINTS"
for value in $FUNCTION_ENDPOINTS
do  
    tmp=${value#*'"'}
    FUNCTION_ENDPOINT=${tmp%'"'*}
    echo $FUNCTION_ENDPOINT
    if [[ $FUNCTION_ENDPOINT = faasterbench* ]] 
    then
        echo "endpoint is https://$FUNCTION_ENDPOINT/api/faasterbench"
        artillery run -t https://$FUNCTION_ENDPOINT/api/faasterbench basicLoad_${CALLS}_${ITERATIONS}.yml
    fi
done 
mkdir logs
echo "Sleep for 5 minutes, so appInsights accurately presents logs"
sleep 300

export log=azure.log
rm logs/$log
touch logs/$log
az monitor app-insights query --app "$appKey" --analytics-query "traces | project message | where message contains 'faaster_${EXPERIMENTID}'" --offset 3h >> logs/$log
mv logs/$log azure_${REGRESSION}_${count}_${CALLS}_${ITERATIONS}.log
echo "got results, will destroy setup..."
terraform destroy -auto-approve