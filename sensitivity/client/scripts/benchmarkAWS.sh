export count=10
export startDate=$(date +%s)
export vars="{ \"experimentid\": \"$EXPERIMENTID\", \"trials1\": \"$1\", \"trials2\": \"$2\" }"
for value in $FUNCTION_ENDPOINTS
do  
    tmp=${value#*'"'}
    FUNCTION_ENDPOINT=${tmp%'/"'*}
    if [[ $FUNCTION_ENDPOINT = https* ]] 
    then
        echo "endoint is $FUNCTION_ENDPOINT"
        artillery run -t https://$FUNCTION_ENDPOINT/api/faasterbench --variables "$vars" basicLoad_${CALLS}_${ITERATIONS}.yml
    fi
done 
mkdir awslogs
echo "Sleep for 3 minutes, so CloudWatch accurately presents logs"
sleep 180

for ((i = 0 ; i < $count ; i++)); do
   aws logs start-query --log-group-names "/aws/lambda/cpulambda-wrapper$i"  --query-string 'fields @message | filter @message like "faaster_"' --start-time $startDate --end-time 2000000000 --region eu-central-1 >> logs/$queryIDs
done

file="logs/$queryIDs"
sleep 30
echo "Wait 30 seconds to let queries finish running"
i=1  
while read line; do  
#Reading each line  
    if [[ $line = *query* ]] 
    then
        tmp=${line#*': "'}
        query=${tmp%'"'*}
        aws logs get-query-results --query-id "$query" --region eu-central-1 --output json >> logs/$log
    fi
    i=$((i+1))  
done < $file  
export logDate=$(date +"%m_%d_%H")
mv logs/$log aws_cpu_$logDate.log
echo "got results"






## todo read endpoints from file
for value in $FUNCTION_ENDPOINTS
do  
    tmp=${value#*'"'}
    FUNCTION_ENDPOINT=${tmp%'/"'*}
    if [[ $FUNCTION_ENDPOINT = https* ]] 
    then
        echo "endoint is $FUNCTION_ENDPOINT"
        artillery run -t https://$FUNCTION_ENDPOINT/api/faasterbench --variables "$vars" basicLoad_${CALLS}_${ITERATIONS}.yml
    fi
done 
mkdir awslogs
echo "Sleep for 3 minutes, so CloudWatch accurately presents logs"
sleep 180

for ((i = 0 ; i < $count ; i++)); do
   aws logs start-query --log-group-names "/aws/lambda/memlambda-wrapper$i"  --query-string 'fields @message | filter @message like "faaster_"' --start-time $startDate --end-time 2000000000 --region eu-central-1 >> logs/$queryIDs
done

file="logs/$queryIDs"
sleep 30
echo "Wait 30 seconds to let queries finish running"
i=1  
while read line; do  
#Reading each line  
    if [[ $line = *query* ]] 
    then
        tmp=${line#*': "'}
        query=${tmp%'"'*}
        aws logs get-query-results --query-id "$query" --region eu-central-1 --output json >> logs/$log
    fi
    i=$((i+1))  
done < $file  
mv logs/$log aws_mem_$logDate.log
echo "got results"

## todo read endpoints from file
for value in $FUNCTION_ENDPOINTS
do  
    tmp=${value#*'"'}
    FUNCTION_ENDPOINT=${tmp%'/"'*}
    if [[ $FUNCTION_ENDPOINT = https* ]] 
    then
        echo "endoint is $FUNCTION_ENDPOINT"
        artillery run -t https://$FUNCTION_ENDPOINT/api/faasterbench --variables "$vars" basicLoad_${CALLS}_${ITERATIONS}.yml
    fi
done 
mkdir awslogs
echo "Sleep for 3 minutes, so CloudWatch accurately presents logs"
sleep 180

for ((i = 0 ; i < $count ; i++)); do
   aws logs start-query --log-group-names "/aws/lambda/netlambda-wrapper$i"  --query-string 'fields @message | filter @message like "faaster_"' --start-time $startDate --end-time 2000000000 --region eu-central-1 >> logs/$queryIDs
done

file="logs/$queryIDs"
sleep 30
echo "Wait 30 seconds to let queries finish running"
i=1  
while read line; do  
#Reading each line  
    if [[ $line = *query* ]] 
    then
        tmp=${line#*': "'}
        query=${tmp%'"'*}
        aws logs get-query-results --query-id "$query" --region eu-central-1 --output json >> logs/$log
    fi
    i=$((i+1))  
done < $file  
mv logs/$log aws_net_$logDate.log
echo "got results"