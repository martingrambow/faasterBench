# Initial Provider Setup

To run benchmarks, faasterBench requires programmatic access to the respective platforms. Below are short descriptions of how to enable this acces for the currently supported FaaS platforms:

## Google

1. Create a new Google Cloud project with `<project_id>`.
2. Go to `IAM > Service account` or `https://console.cloud.google.com/iam-admin/serviceaccounts?project=<project_id>`.
3. Click `Create Service account`.
4. Add the `Project > Owner` permission.
5. Click `Generate Private Key` and download it as `json`, we need the absolute path to the file later.
6. Visit `https://console.developers.google.com/apis/api/cloudfunctions.googleapis.com/overview?project=<project_id>` and enable the cloud functions API.
7. Visit `https://console.cloud.google.com/apis/library/cloudbuild.googleapis.com?project=<project_id>` and enable the Cloud Build API.

## AWS

1. Go to IAM section or `https://console.aws.amazon.com/iam/home?#/users`.
2. Create a new user.
3. Choose "Programmatic access".
4. Got to "Attach existing policies directly" and chose "AdministratorAccess".
5. Go to the last step and save the `Key ID` and `Access Key`.


# (Re-) Run Experiments

Follow the next steps to (re-) run faasterBench experiments:

## Setup

1. To run benchmarks, faasterBench requires programmatic access to the respective platforms. So the first step is to create access keys for the respective platforms, see Initial Provider Setup. 
2. faasterBench also requires some managaing instance to orchestrate the benchmark run (Benchmark Manager). This can either be your local computer or a cloud instance. Setup the manager:
	1. Install the following dependencies:
		```
		sudo apt-get update
		sudo apt-get install -y gnupg
		sudo apt-get install -y software-properties-common
		sudo apt-get install -y git
		sudo apt-get install -y maven
		sudo apt-get install -y awscli
		sudo apt-get install -y npm
		sudo apt-get install -y jq
		
		wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
		echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
		sudo apt update
		sudo apt-get install -y terraform
		
		sudo npm install -g n
		sudo n lts
		sudo n prune
		sudo npm install -g artillery@latest
		
		curl -SLO https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-427.0.0-linux-x86_64.tar.gz && tar zxvf google-cloud-sdk-427.0.0-linux-x86_64.tar.gz google-cloud-sdk && ./google-cloud-sdk/install.sh
		export PATH="/google-cloud-sdk/bin:${PATH}"
		```
	3. (Opt.) **Copy provider keys**: For experiments using Google Cloud, Check that the Google key (.json file) is available on the manager instance.
	4. (Opt.) **Authorize gcloud**
		```
		gcloud auth login --cred-file=key.json
		```
	5. Adjust .bashrc and **set environment variables** (check cloud regions)
		Examples:
		```
		#AWS
		export AWS_ACCESS_KEY_ID=<access_key>
		export AWS_SECRET_ACCESS_KEY=<secret_access_key>
		export AWS_REGION=<region e.g. us-east-1>
		
		export AWS_ACCESS_KEY_ID=AAAAAA333333OOOOOBBBB
		export AWS_SECRET_ACCESS_KEY=xxxxxxxyyyyyyyyyyyzzzzzzzzyyyyyxxxxxxxxx
		export AWS_REGION=eu-west-1
		
		#Google:
		export GOOGLE_APPLICATION_CREDENTIALS=<path/to/privatekey.json>
		export GOOGLE_PROJECT=<project_id>
		export GOOGLE_REGION=<region e.g. us-east1>	

		export GOOGLE_APPLICATION_CREDENTIALS="path/to/file.json"
		export GOOGLE_PROJECT="projectnamehere"
		export GOOGLE_REGION="europe-west3"		
		```
	6. **Restart terminal** to export the environment variables 
	7. **Install Java** to be able to run the wrapper tool
		```
		sudo apt install default-jre
		sudo apt install default-jdk
		```

3. **Clone faasterBench repository** on manager instance
	```
	git clone https://github.com/martingrambow/faasterBench.git
	```

## Wrap Functions and create deployment artifact

1. **Move to wrapper folder**
	```
	cd wrapper
	```
2. **Build wrapper.jar**
	```
	./buildWrapper.sh	
	```
2. (a) **Combine packacke.json files and install different versions of the same packet, if required** 
If your two functions rely on different versions or different dependencies alltogether, there are minute details to consider:  
If requiring the same package in two different versions, import one or both utilizing an alias, shown with the example  of jquery here
	```
	npm install jquery2@npm:jquery@2
	npm install jquery3@npm:jquery@3	
	```
	This will cause your dependencies to include 
	```
	"dependencies": {  
		"jquery2": "npm:jquery@^2.2.4",  
		"jquery3": "npm:jquery@^3.4.1"  
	}  
	(from https://stackoverflow.com/questions/26414587/how-to-install-multiple-versions-of-package-using-npm)
	```
Once this step is complete, a utility called `package-json-merge` can be used to merge your two package.json files for your two functions.
	```
	npm install -g package-json-merge
	package-json-merge package1.json package2.json .... packageN.json > package.json
	```
	(from https://stackoverflow.com/questions/37734638/how-to-merge-multiple-npm-package-json-files-into-one-with-gulp)
2. (b) **Exclude external calls made by your function** 
	faasterBench can exclude time spent in external function calls. To do so, please wrap every external call like so:
	```
	//extstart
	externalCallHere()
	//extstop
	```
	This can be done multiple times throughout the function. faasterBench provides different benchmark values, both including and excluding external calls. 
3. **Wrap functions code** and create deployment artifact 
	```
	./wrapper.sh
	```

## Run experiment

1. **Move to respective experiment folder**
	```
	cd ../experiment/google
	<-OR->
	cd ../experiment/aws
	```
2. **Run experiment**
	```
	./experiment.sh
	```

# Evaluation
