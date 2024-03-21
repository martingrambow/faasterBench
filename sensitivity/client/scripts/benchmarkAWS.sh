export count=10
export startDate=$(date +%s)
export vars="{ \"experimentid\": \"$EXPERIMENTID\", \"trials1\": \"$1\", \"trials2\": \"$2\" }"
export REGRESSION=$3
file_path="/root/files/cpu/awsURLs.txt"
# Read each line of the file
while IFS= read -r line; do
    FUNCTION_ENDPOINT=$line
    echo "endoint is $FUNCTION_ENDPOINT"
    artillery run -t $FUNCTION_ENDPOINT --variables "$vars" /root/load/memBasicLoad_5_3.yml
done < "$file_path"
mkdir aws_logs
echo "Sleep for 4 minutes, so CloudWatch accurately presents logs"
sleep 240
export queryIDs="awsQueryIDs.log"
export log=aws.log
rm aws_logs/$queryIDs
rm aws_logs/$log
touch aws_logs/$queryIDs
touch aws_logs/$log
for ((i = 0 ; i < $count ; i++)); do
   aws logs start-query --log-group-names "/aws/lambda/cpulambda-wrapper$i"  --query-string 'fields @message | filter @message like "faaster_"' --start-time $startDate --end-time 2000000000 --region eu-west-1  >> aws_logs/$queryIDs
done

file="aws_logs/$queryIDs"
sleep 30
echo "Wait 30 seconds to let queries finish running"
i=1  
while read line; do  
#Reading each line  
    if [[ $line = *query* ]] 
    then
        tmp=${line#*': "'}
        query=${tmp%'"'*}
        aws logs get-query-results --query-id "$query" --region eu-west-1 --output json  >> aws_logs/$log
    fi
    i=$((i+1))  
done < $file  
export logDate=$(date +"%m_%d_%H")
mv aws_logs/$log aws_logs/aws_cpu_${REGRESSION}_${logDate}.log
echo "got results"

file_path="/root/files/mem/awsURLs.txt"
# Read each line of the file
while IFS= read -r line; do
    FUNCTION_ENDPOINT=$line
    echo "endoint is $FUNCTION_ENDPOINT"
    artillery run -t $FUNCTION_ENDPOINT --variables "$vars" /root/load/memBasicLoad_5_3.yml
done < "$file_path"
echo "Sleep for 4 minutes, so CloudWatch accurately presents logs"
sleep 240
rm aws_logs/$queryIDs
rm aws_logs/$log
touch aws_logs/$queryIDs
touch aws_logs/$log
for ((i = 0 ; i < $count ; i++)); do
   aws logs start-query --log-group-names "/aws/lambda/memlambda-wrapper$i"  --query-string 'fields @message | filter @message like "faaster_"' --start-time $startDate --end-time 2000000000 --region eu-west-1  >> aws_logs/$queryIDs
done

file="aws_logs/$queryIDs"
sleep 30
echo "Wait 30 seconds to let queries finish running"
i=1  
while read line; do  
#Reading each line  
    if [[ $line = *query* ]] 
    then
        tmp=${line#*': "'}
        query=${tmp%'"'*}
        aws logs get-query-results --query-id "$query" --region eu-west-1 --output json  >> aws_logs/$log
    fi
    i=$((i+1))  
done < $file  
mv aws_logs/$log aws_logs/aws_mem_${REGRESSION}_${logDate}.log
echo "got results"

## todo read endpoints from file
file_path="/root/files/network/awsURLs.txt"
# Read each line of the file
while IFS= read -r line; do
    FUNCTION_ENDPOINT=$line
    echo "endoint is $FUNCTION_ENDPOINT"
    artillery run -t $FUNCTION_ENDPOINT --variables "$vars" /root/load/netBasicLoad_5_3.yml
done < "$file_path"

echo "Sleep for 4 minutes, so CloudWatch accurately presents logs"
sleep 240
rm aws_logs/$queryIDs
rm aws_logs/$log
touch aws_logs/$queryIDs
touch aws_logs/$log
for ((i = 0 ; i < $count ; i++)); do
   aws logs start-query --log-group-names "/aws/lambda/netlambda-wrapper$i"  --query-string 'fields @message | filter @message like "faaster_"' --start-time $startDate --end-time 2000000000 --region eu-west-1  >> aws_logs/$queryIDs
done

file="aws_logs/$queryIDs"
sleep 30
echo "Wait 30 seconds to let queries finish running"
i=1  
while read line; do  
#Reading each line  
    if [[ $line = *query* ]] 
    then
        tmp=${line#*': "'}
        query=${tmp%'"'*}
        aws logs get-query-results --query-id "$query" --region eu-west-1 --output json  >> aws_logs/$log
    fi
    i=$((i+1))  
done < $file  
mv aws_logs/$log aws_logs/aws_net_${REGRESSION}_${logDate}.log
echo "got results"