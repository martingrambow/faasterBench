## Setup Client 
cd client
terraform apply -var-file=vars.tfvars
gcloud compute scp --recurse load/ root@benchmark-client:/root/
gcloud compute scp --recurse scripts/ root@benchmark-client:/root/
gcloud compute scp --recurse files/ root@benchmark-client:/root/
gcloud compute scp --recurse ../keys/ root@benchmark-client:/root/
gcloud compute ssh root@benchmark-client
gcloud auth login --cred-file=keys/keyfile.json --quiet
cd scripts
chmod +x benchmarkGoogle.sh benchmarkAzure.sh benchmarkAWS.sh

## Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Install npm and node
nvm install node

# Install artillery
npm install -g artillery


aws configure

export AWS_ACCESS_KEY_ID=<Your KEY HERE>
export AWS_SECRET_ACCESS_KEY=<Your KEY HERE>
export AWS_REGION=eu-west-1