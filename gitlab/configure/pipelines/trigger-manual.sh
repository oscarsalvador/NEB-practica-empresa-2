#!/bin/bash

if [ -z "$1" ]; then
  echo "missing gitlab pat"
  exit
fi

PAT=$1

# for PROJECT_ID in $(jq -r '.[].id' ../projects.json); do
function start_jobs () {
  # REPO_URL=$(jq --arg name "$1" '.[] | select(.name == $name) | .url' projects.json)

  # echo "jq -r --arg project \"$1\" '.[] | select(.name == \$project) | .id' ../projects.json"
  PROJECT_ID=$(jq -r --arg project "$1" '.[] | select(.name == $project) | .id' ../projects.json )
  

  # if there is any job ongoing, wait for it since manual jobs might not yet be visible
  REMAIN="true"
  while [ "$REMAIN" == "true" ]; do
    sleep 10
    REMAIN=$(curl -s -H "PRIVATE-TOKEN: $PAT" "https://gitlab.gitlab.local/api/v4/projects/$PROJECT_ID/jobs" | jq 'any(.[].status; . == "running" or . == "pending")')
    echo -ne "\rPipelines for $1 still going as of $(date +%H:%M:%S)"
  done

  # echo $PROJECT_ID
  # JOBS=$(curl -s -H "PRIVATE-TOKEN: $PAT" "https://gitlab.gitlab.local/api/v4/projects/$PROJECT_ID/jobs?scope[]=manual&scope[]=scheduled&status[]=created&status[]=manual&status[]=scheduled&when[]=manual&per_page=100" | jq '.[].id')
  JOBS=$(curl -s -H "PRIVATE-TOKEN: $PAT" "https://gitlab.gitlab.local/api/v4/projects/$PROJECT_ID/jobs?scope[]=manual&scope[]=scheduled&status[]=created&status[]=manual&status[]=scheduled&when[]=manual&per_page=100" | jq '.[] | select(.name | IN ("deploy-img-in-aci", "arachni-dast") | not ).id')
  echo -e "\nJobs for $1: \n $JOBS \n"

  for JOB_ID in $JOBS; do 
    curl --request POST -H "PRIVATE-TOKEN: $PAT" "https://gitlab.gitlab.local/api/v4/projects/$PROJECT_ID/jobs/$JOB_ID/play" 
  done

  echo -e "\n\n"

  # wait until the triggered jobs are done
  REMAIN="true"
  while [ "$REMAIN" == "true" ]; do
    sleep 10
    REMAIN=$(curl -s -H "PRIVATE-TOKEN: $PAT" "https://gitlab.gitlab.local/api/v4/projects/$PROJECT_ID/jobs" | jq 'any(.[].status; . == "running" or . == "pending")')
    echo -ne "\rPipelines for $1 still going as of $(date +%H:%M:%S)"
  done

}

start_jobs "infra-base"
start_jobs "backend-code"
start_jobs "frontend-code"
start_jobs "infra-backend"
start_jobs "infra-frontend"

