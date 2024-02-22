export TF_VAR_WRAPPERCOUNT=10
export wcount=10
func init faasterbench --worker-runtime javascript --model V4

cp -f ../../../wrapper/output/azure/index.js faasterbench/src/functions/
cd faasterbench
npm install @azure/functions
npm install applicationinsights
zip -r azure_func.zip *
mv azure_func.zip ../
cd ..
rm -r faasterbench

terraform apply -auto-approve

for i in $( eval echo {0..$wcount} )
do
    az functionapp deployment source config-zip -g faasterbench-resource-group-v1  -n faasterbench$i --src azure_func.zip
done

./runExperiment.sh 5000000 5000000 0 5 5 3
./runExperiment.sh 5000000 5000000 0 5 10 3
./runExperiment.sh 5000000 5000000 0 5 25 3
./runExperiment.sh 5000000 5000000 0 10 5 3
./runExperiment.sh 5000000 5000000 0 10 10 3
./runExperiment.sh 5000000 5000000 0 10 25 3


./runExperiment.sh 5000000 5250000 5 5 5 3
./runExperiment.sh 5000000 5250000 5 5 10 3
./runExperiment.sh 5000000 5250000 5 5 25 3
./runExperiment.sh 5000000 5250000 5 10 5 3
./runExperiment.sh 5000000 5250000 5 10 10 3
./runExperiment.sh 5000000 5250000 5 10 25 3

terraform destroy -auto-approve