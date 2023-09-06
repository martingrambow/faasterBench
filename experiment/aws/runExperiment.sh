export TF_VAR_TRIALS1=$1
export TF_VAR_TRIALS2=$2

terraform init
terraform apply -auto-approve
export count="$(terraform output -raw WRAPPERCOUNT)"
export EXPERIMENTID="$(terraform output -raw EXPERIMENTID)"
export FUNCTION_ENDPOINTS="$(terraform output FUNCTION_ENDPOINTS)"
echo "experiment ID is $EXPERIMENTID"
echo "endpoints are $FUNCTION_ENDPOINTS"
for value in $FUNCTION_ENDPOINTS
do  
    tmp=${value#*'"'}
    FUNCTION_ENDPOINT=${tmp%'/"'*}
    if [[ $FUNCTION_ENDPOINT = https* ]] 
    then
        echo "endoint is $FUNCTION_ENDPOINT"
        artillery run -t $FUNCTION_ENDPOINT basicLoad.yml
    fi
done 
mkdir logs
echo "Sleep for 5 minutes, so CloudWatch accurately presents logs"
sleep 300

export queryIDs="awsQueryIDs.log"
export log=aws.log
rm logs/$queryIDs
rm logs/$log
touch logs/$queryIDs
touch logs/$log
for ((i = 0 ; i < $count ; i++)); do
   aws logs start-query --log-group-names "/aws/lambda/lambda-wrapper$i"  --query-string 'fields @message | filter @message like "faaster_"' --start-time 0 --end-time 2000000000 >> logs/$queryIDs
done
file="logs/$queryIDs"
  
i=1  
while read line; do  
#Reading each line  
    if [[ $line = *query* ]] 
    then
        tmp=${line#*': "'}
        query=${tmp%'"'*}
        aws logs get-query-results --query-id "$query" --output json >> logs/$log
    fi
    i=$((i+1))  
done < $file  
echo "got results, will destroy setup..."
terraform destroy -auto-approve