#export TF_VAR_TRIALS1=$1
#export TF_VAR_TRIALS2=$2
export REGRESSION=$3
export TF_VAR_WRAPPERCOUNT=10
export wrapper=$4
export CALLS=$5
export ITERATIONS=$6

terraform apply -replace=random_string.experiment_id -auto-approve
export counter=0
export EXPERIMENTID="$(terraform output -raw EXPERIMENTID)"
export FUNCTION_ENDPOINTS="$(terraform output FUNCTION_ENDPOINTS)"
export appKey="$(terraform output -raw APPID)"
export vars="{ \"experimentid\": \"$EXPERIMENTID\", \"trials1\": \"$1\", \"trials2\": \"$2\" }"
for value in $FUNCTION_ENDPOINTS
do  
    if [[ $counter -lt $wrapper ]]
    then
        tmp=${value#*'"'}
        FUNCTION_ENDPOINT=${tmp%'"'*}
        if [[ $FUNCTION_ENDPOINT = faasterbench* ]] 
        then
            counter=$((counter+1))
            echo $counter
            echo "endpoint is https://$FUNCTION_ENDPOINT/api/faasterbench"
            artillery run -t https://$FUNCTION_ENDPOINT/api/faasterbench --variables "$vars" basicLoad_${CALLS}_${ITERATIONS}.yml
        fi
    fi
done 
mkdir logs
echo "Sleep for 2 minutes, so appInsights accurately presents logs"
sleep 120

export log=azure.log
rm logs/$log
touch logs/$log
az monitor app-insights query --app "$appKey" --analytics-query "traces | project message | where message contains 'faaster_${EXPERIMENTID}'" --offset 3h >> logs/$log
mv logs/$log azure_${REGRESSION}_${counter}_${CALLS}_${ITERATIONS}.log
echo "got results, will destroy setup..."