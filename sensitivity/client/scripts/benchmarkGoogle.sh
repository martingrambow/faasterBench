export count=10
export start=$(date +"%Y-%m-%dT%H:%M:%SZ") 
export logDate=$(date +"%m_%d_%H")
export EXPERIMENTID="faaster_"
export REGRESSION=$3
export GOOGLE_PROJECT="csbws2223"
export vars="{ \"experimentid\": \"$EXPERIMENTID\", \"trials1\": \"$1\", \"trials2\": \"$2\" }"
file_path="/root/files/cpu/gcpURLs.txt"
# Read each line of the file
while IFS= read -r line; do
    echo "Processing line: $line"
    FUNCTION_ENDPOINT=$line
    # FUNCTION_ENDPOINT="$(echo $FUNCTION_ENDPOINTS | jq -r .[$i])"
    echo "endpoint is $FUNCTION_ENDPOINT"
    artillery run -t $FUNCTION_ENDPOINT --variables "$vars" /root/load/cpuBasicLoad_5_3.yml
done < "$file_path"
sleep 5
mkdir gcp_logs
gcloud auth login --cred-file="/root/keys/keyfile.json" --quiet
touch /root/scripts/gcp_logs/google_cpu_${REGRESSION}_${logDate}.log
gcloud logging read --project $GOOGLE_PROJECT 'resource.type="cloud_function" AND textPayload:"'$EXPERIMENTID'" AND timestamp>="'$start'"' --format json > /root/scripts/gcp_logs/google_cpu_${REGRESSION}_${logDate}.log


start=$(date +"%Y-%m-%dT%H:%M:%SZ")
file_path="/root/files/mem/gcpURLs.txt"
while IFS= read -r line; do
    # Do whatever you want with the variable "$line"
    echo "Processing line: $line"
    FUNCTION_ENDPOINT=$line
    # FUNCTION_ENDPOINT="$(echo $FUNCTION_ENDPOINTS | jq -r .[$i])"
    echo "endpoint is $FUNCTION_ENDPOINT"
    artillery run -t $FUNCTION_ENDPOINT --variables "$vars" /root/load/memBasicLoad_5_3.yml
done < "$file_path"
sleep 5
touch /root/scripts/gcp_logs/google_mem_${REGRESSION}_${logDate}.log
gcloud logging read --project $GOOGLE_PROJECT 'resource.type="cloud_function" AND textPayload:"'$EXPERIMENTID'" AND timestamp>="'$start'"' --format json > /root/scripts/gcp_logs/google_mem_${REGRESSION}_${logDate}.log
export start=$(date +"%Y-%m-%dT%H:%M:%SZ") 
file_path="/root/files/network/gcpURLs.txt"
while IFS= read -r line; do
    # Do whatever you want with the variable "$line"
    echo "Processing line: $line"
    FUNCTION_ENDPOINT=$line
    # FUNCTION_ENDPOINT="$(echo $FUNCTION_ENDPOINTS | jq -r .[$i])"
    echo "endpoint is $FUNCTION_ENDPOINT"
    artillery run -t $FUNCTION_ENDPOINT --variables "$vars" /root/load/netBasicLoad_5_3.yml
done < "$file_path"
sleep 5
touch /root/scripts/gcp_logs/google_net_${REGRESSION}_${logDate}.log
gcloud logging read --project $GOOGLE_PROJECT 'resource.type="cloud_function" AND textPayload:"'$EXPERIMENTID'" AND timestamp>="'$start'"' --format json > /root/scripts/gcp_logs/google_net_${REGRESSION}_${logDate}.log

