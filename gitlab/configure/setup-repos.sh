#!/bin/bash

# if [ -z "$1" ]; then
#   echo "missing truststore pw"
#   exit
# fi
if [ $# -lt 2 ]; then
 echo "setup-repos.sh <TRUSTSTORE_PW> <GITLAB_PAT>"
 exit
fi

TRUSTSTORE_PW=$1
PAT=$2

echo "$TRUSTSTORE_PW $PAT"

kubectl config set-context cicd --namespace gitlab
GITLAB_URL="https://gitlab.gitlab.local/"

PASSWD=$(kubectl get secret gitlab-gitlab-initial-root-password -o jsonpath='{.data.password}' | base64 --decode ; echo)

function repo_surgeon () {
  echo -e "\n\n\nRepo surgeon $1"
  REPO_URL=$(jq --arg name "$1" '.[] | select(.name == $name) | .url' projects.json)
  URL_WITH_CREDENTIALS=$(echo $REPO_URL | sed "s/https:\/\//https:\/\/root:$PASSWD@/")
  # echo ${URL_WITH_CREDENTIALS:1:-1}

  cp "./pipelines/$1.yml" "./NEB-practica-empresa-1/$2/.gitlab-ci.yml"
  cd "./NEB-practica-empresa-1/$2"

  # adds these settings to .git/config, doesnt need to be afer git init
  # git config --global http.sslVerify false 

  if [[ $1 == *code* ]]; then
    git init --initial-branch=master
  elif [[ $1 == *infra* ]]; then
    git init --initial-branch=production
  fi

    git config --local user.name "Administrator"
    git config --local user.email "admin@example.com"

    git add -A
    git commit -m "first commit to ${2}, hello gitlab! - love, admin"

  if [[ $1 == *code* ]]; then
    git remote add origin ${URL_WITH_CREDENTIALS:1:-1}
    git remote show origin
    echo "$1 master"
    git branch
    git push origin master

    git branch develop
    # git checkout preproduction
    git push -u origin develop
    echo "$1 develop"
    git branch

  elif [[ $1 == *infra* ]]; then
    git remote add origin ${URL_WITH_CREDENTIALS:1:-1}
    git remote show origin
    echo "$1 prod"
    git branch
    git push origin production

    sleep 10
    git branch preproduction
    echo "$1 preprod"
    git checkout preproduction
    git branch
    
    cp "../../pipelines/$1-pre.yml" "./.gitlab-ci.yml"
    git add -A 
    git commit -m "preprod isn't meant to be merged back"
    git push -u origin preproduction

  fi

  echo -e "\n\n"
  cd -
}


# for PROJECT_ID in $(jq -r '.[].id' ../projects.json); do
function start_jobs () {
  # REPO_URL=$(jq --arg name "$1" '.[] | select(.name == $name) | .url' projects.json)

  # echo "jq -r --arg project \"$1\" '.[] | select(.name == \$project) | .id' ../projects.json"
  PROJECT_ID=$(jq -r --arg project "$1" '.[] | select(.name == $project) | .id' projects.json )
  

  # if there is any job ongoing, wait for it since manual jobs might not yet be visible
  REMAIN="true"
  while [ "$REMAIN" == "true" ]; do
    REMAIN=$(curl -s -H "PRIVATE-TOKEN: $PAT" "https://gitlab.gitlab.local/api/v4/projects/$PROJECT_ID/jobs" | jq 'any(.[].status; . == "running" or . == "pending")')
    echo -ne "\rJobs ongoing for $1 still going as of $(date +%H:%M:%S)"
    sleep 10
  done

  # echo $PROJECT_ID
  # JOBS=$(curl -s -H "PRIVATE-TOKEN: $PAT" "https://gitlab.gitlab.local/api/v4/projects/$PROJECT_ID/jobs?scope[]=manual&scope[]=scheduled&status[]=created&status[]=manual&status[]=scheduled&when[]=manual&per_page=100" | jq '.[].id')
  JOBS=$(curl -s -H "PRIVATE-TOKEN: $PAT" "https://gitlab.gitlab.local/api/v4/projects/$PROJECT_ID/jobs?scope[]=manual&scope[]=scheduled&status[]=created&status[]=manual&status[]=scheduled&when[]=manual&per_page=100" | jq '.[] | select(.name | IN ("deploy-img-in-aci", "arachni-dast", "deploy:pre", "deploy:pro") | not ).id')
  echo -e "\nJobs for $1: \n $JOBS \n"

  for JOB_ID in $JOBS; do 
    curl --request POST -H "PRIVATE-TOKEN: $PAT" "https://gitlab.gitlab.local/api/v4/projects/$PROJECT_ID/jobs/$JOB_ID/play" 
    sleep 20
  done

  echo -e "\n\n"

  # wait until the triggered jobs are done
  REMAIN="true"
  while [ "$REMAIN" == "true" ]; do
    REMAIN=$(curl -s -H "PRIVATE-TOKEN: $PAT" "https://gitlab.gitlab.local/api/v4/projects/$PROJECT_ID/jobs" | jq 'any(.[].status; . == "running" or . == "pending")')
    echo -ne "\rPipelines for $1 still going as of $(date +%H:%M:%S)"
    sleep 10
  done

  echo -e "\n\n"

}





rm -rf NEB-practica-empresa-1
git clone https://github.com/oscarsalvador/NEB-practica-empresa-1
mv ./NEB-practica-empresa-1/backend/terraform/ ./NEB-practica-empresa-1/backend-terraform
mv ./NEB-practica-empresa-1/frontend/terraform/ ./NEB-practica-empresa-1/frontend-terraform

rm truststore.jks
keytool -importcert -file ../ca/gitlab.gitlab.local.crt -alias "gitlab.gitlab.local" \
 -keystore ./truststore.jks -storepass $TRUSTSTORE_PW  -trustcacerts # create the keystore, with the password which is received as arg
# for id in $(jq -r --arg name "code" '.[] | select(.name | contains($name)) | .id' projects.json); do
#   # only available at project level https://docs.gitlab.com/ee/api/secure_files.html
#   curl --request POST --header "PRIVATE-TOKEN: ${PERSONAL_ACCESS_TOKEN:1:${#PERSONAL_ACCESS_TOKEN} -2}" \
#     --form "name=truststore.jks" --form "file=@truststore.jks" \
#     "https://gitlab.gitlab.local/api/v4/projects/$id/secure_files"
# done
cp ./truststore.jks ./NEB-practica-empresa-1/backend/truststore.jks
cp ./truststore.jks ./NEB-practica-empresa-1/frontend/truststore.jks



repo_surgeon "infra-base" "terraform" 
# sleep 10
# start_jobs "infra-base"

echo "backend-code?"
read
repo_surgeon "backend-code" "backend"
# sleep 10
# start_jobs "backend-code"

echo "frontend-code?"
read
repo_surgeon "frontend-code" "frontend" 
# sleep 10
# start_jobs "frontend-code"

echo "infra-backend?"
read
repo_surgeon "infra-backend" "backend-terraform" 
# sleep 10
# start_jobs "infra-backend"

echo "infra-frontend?"
read
repo_surgeon "infra-frontend" "frontend-terraform" 
# sleep 10
# start_jobs "infra-frontend"

