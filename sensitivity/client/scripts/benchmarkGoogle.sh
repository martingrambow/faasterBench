export count=10
export start=$(date --rfc-3339=seconds | sed 's/ /T/')
export logDate=$(date +"%m_%d_%H")
export EXPERIMENTID="faaster_"
export REGRESSION=$3
export GOOGLE_PROJECT="csbws2223"
export vars="{ \"experimentid\": \"$EXPERIMENTID\", \"trials1\": \"$1\", \"trials2\": \"$2\" }"
file_path="../files/cpu/gcpURLs.txt"

# Read each line of the file
while IFS= read -r line; do
    echo "Processing line: $line"
    FUNCTION_ENDPOINT=$line
    # FUNCTION_ENDPOINT="$(echo $FUNCTION_ENDPOINTS | jq -r .[$i])"
    echo "endpoint is $FUNCTION_ENDPOINT"
    artillery run -t $FUNCTION_ENDPOINT --variables "$vars" ../load/cpuBasicLoad_25_3.yml
done < "$file_path"
sleep 5
gcloud auth login --cred-file="../keys/keyfile.json" --quiet
mkdir gcp_logs
gcloud logging read --project $GOOGLE_PROJECT 'resource.type="cloud_function" AND textPayload:' $EXPERIMENTID 'AND timestamp>="'$start'"' --format json > gcp_logs/google_cpu_${REGRESSION}_${logDate}.log

start=$(date --rfc-3339=seconds | sed 's/ /T/')
file_path="../files/mem/gcpURLs.txt"
while IFS= read -r line; do
    # Do whatever you want with the variable "$line"
    echo "Processing line: $line"
    FUNCTION_ENDPOINT=$line
    # FUNCTION_ENDPOINT="$(echo $FUNCTION_ENDPOINTS | jq -r .[$i])"
    echo "endpoint is $FUNCTION_ENDPOINT"
    artillery run -t $FUNCTION_ENDPOINT --variables "$vars" ../load/memBasicLoad_25_3.yml
done
sleep 5
end=$(date --rfc-3339=seconds | sed 's/ /T/')
gcloud logging read --project $GOOGLE_PROJECT 'resource.type="cloud_function" AND textPayload:' $EXPERIMENTID 'AND timestamp<="'$start'"' --format json > gcp_logs/google_mem_${REGRESSION}_${logDate}.log

start=$(date --rfc-3339=seconds | sed 's/ /T/')
file_path="../files/net/gcpURLs.txt"
while IFS= read -r line; do
    # Do whatever you want with the variable "$line"
    echo "Processing line: $line"
    FUNCTION_ENDPOINT=$line
    # FUNCTION_ENDPOINT="$(echo $FUNCTION_ENDPOINTS | jq -r .[$i])"
    echo "endpoint is $FUNCTION_ENDPOINT"
    artillery run -t $FUNCTION_ENDPOINT --variables "$vars" ../load/netBasicLoad_25_3.yml
done
sleep 5
end=$(date --rfc-3339=seconds | sed 's/ /T/')
gcloud logging read --project $GOOGLE_PROJECT 'resource.type="cloud_function" AND textPayload:' $EXPERIMENTID 'AND timestamp<="'$start'"' --format json > gcp_logs/google_net_${REGRESSION}_${logDate}.log

