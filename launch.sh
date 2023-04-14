#!/bin/bash

./start-cluster.sh

# gitlab
cd gitlab
./gitlab-helm.sh # installs helm chart for gitlab with values2.yml

cd configure
source ./personal-access-token.sh

./generate-runner-setup.sh $PERSONAL_ACCESS_TOKEN
cd terraform
eval "terraform apply -auto-approve -var-file variables.tfvars -var token=$PERSONAL_ACCESS_TOKEN"
eval "terraform output -json | jq '.projects.value' > ../projects.json"
cd ..
./setup-repos.sh

