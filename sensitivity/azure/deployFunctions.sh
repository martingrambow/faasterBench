func init faasterbenchcpu --worker-runtime javascript --model V4

cp -f ../../../wrapper/output/cpu/azure/index.js faasterbenchcpu/src/functions/
cd faasterbenchcpu
npm install @azure/functions
npm install applicationinsights
zip -r cpu_azure_func.zip *
mv cpu_azure_func.zip ../
cd ..
rm -r faasterbenchcpu

func init faasterbenchmem --worker-runtime javascript --model V4

cp -f ../../../wrapper/output/cpu/mem/index.js faasterbenchmem/src/functions/
cd faasterbenchmem
npm install @azure/functions
npm install applicationinsights
zip -r mem_azure_func.zip *
mv mem_azure_func.zip ../
cd ..
rm -r faasterbenchmem

func init faasterbenchnet --worker-runtime javascript --model V4

cp -f ../../../wrapper/output/network/azure/index.js faasterbenchnet/src/functions/
cd faasterbenchnet
npm install @azure/functions
npm install applicationinsights
zip -r net_azure_func.zip *
mv net_azure_func.zip ../
cd ..
rm -r faasterbenchnet