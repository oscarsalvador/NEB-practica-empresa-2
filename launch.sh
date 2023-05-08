#!/bin/bash

./start-cluster.sh

cd gitlab
./gitlab-helm.sh # installs helm chart for gitlab with values2.yml
cd -

# update kube-system/coredns configmap to resolve gitlab.local
./coredns.sh

# install sonarqube
cd sonarqube
./sonarqube-helm.sh
SONAR_PW=$(kubectl get secret --namespace sonarqube sonar-sonarqube -o jsonpath="{.data.sonarqube-password}" | base64 -d)
SONAR_TOKEN=$(curl -k -X POST -u user:$SONAR_PW "https://sonar.gitlab.local/api/user_tokens/generate?name=my-token-name&login=user" | jq -r '.token')
echo "Sonar token: $SONAR_TOKEN" | tee /dev/tty >> /tmp/cluster.txt
cd -

# create gitlab PAT
cd gitlab/configure
source ./personal-access-token.sh

# create a script to copy and paste to whichever machine with az-cli will act as runner. Contains cert and gitlab PAT
./generate-runner-setup.sh $PERSONAL_ACCESS_TOKEN

# terraform to configure gitlab groups, environments, projects and variables
cd terraform
KEYSTORE_PW=$(echo $RANDOM | md5sum | cut -c1-6) # generate a random password for the keystore that'll be uploaded to code repos for sonar
TF_APPLY="terraform apply -auto-approve -var-file variables.tfvars \
  -var token=$PERSONAL_ACCESS_TOKEN \
  -var sonar_token=$SONAR_TOKEN \
  -var sonar_keystore_pw=$KEYSTORE_PW"
echo -e "\n\n$TF_APPLY" >> /tmp/cluster.txt
eval "$TF_APPLY"
terraform output -json | jq '.projects.value' > ../projects.json

# script to fill the gitlab projets with the files they need
cd ..
echo -e "\n\nKeystore password: $KEYSTORE_PW" >> /tmp/cluster.txt
sleep 100
./setup-repos.sh $KEYSTORE_PW $PERSONAL_ACCESS_TOKEN
