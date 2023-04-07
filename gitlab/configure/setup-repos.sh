#!/bin/bash
GITLAB_URL="https://gitlab.gitlab.local/"
# Generate a Gitlab Personal Access Token to use in the Terraform project

# GITLAB_URL EN SCRIPT "CONFIGURE_GITLAB.SH", QUE LANZA LOS DEMÁS, Y LES PASA LAS VARIABLES DE 
# ARRIBA A ABAJO, Y DE UNO AL SIGUIENTE (EXPORTAR $PAT AL PADRE PARA USAR EN TF)

# Terraform project that creates the group > repo > environment > branch structure descibed in the .tfvars




# Meter este texto en un readme, sacarlo de aqui
# In my previous project I uploaded all files into a single repo, and organized the source code 
# and infrastructure as code into three folders:
#   - Frontend
#       - src
#       - terraform
#   - Backend
#       - src
#       - terraform
#   - Base infrastrucutre
# Where Frontend and Backend had both the application and terraform code. In this project, I want to separate 
# them into five gitlab projects (repo, env, pipelines) in two groups
#   - application-code
#        - frontend
#        - backend
#   - infra-as-code
#        - frontend
#        - backend
#        - base

# Prepares folders from the original repo to be a new one in gitlab
# receives args: pipeline.yml, repo/directory

# PASSWD="yOkfWeHYVoriqnaUObEeHPEdJCfLSnIudjO9BvsI7z4PiVAPBxMnrOZM0ZvwU0JP"
PASSWD=$(kubectl get secret gitlab-gitlab-initial-root-password -o jsonpath='{.data.password}' | base64 --decode ; echo)

function repo_surgeon () {
  REPO_URL=$(jq --arg name "$1" '.[] | select(.name == $name) | .url' projects.json)
  URL_WITH_CREDENTIALS=$(echo $REPO_URL | sed "s/https:\/\//https:\/\/root:$PASSWD@/")
  echo ${URL_WITH_CREDENTIALS:1:-1}

  # exit
  cp "./pipelines/$1.yml" "./NEB-practica-empresa-1/$2/gitlab-ci.yml"
  cd "./NEB-practica-empresa-1/$2"

  # exit 
  git init
  # git config --global http.sslVerify false
  git add -A
  git commit -m "first commit to ${2}, hello gitlab!"
  # git add remote origin $REPO_URL
  git remote add origin ${URL_WITH_CREDENTIALS:1:-1}
  git push origin master
  # exit 

  cd -
}

rm -rf NEB-practica-empresa-1
git clone https://github.com/oscarsalvador/NEB-practica-empresa-1
mv ./NEB-practica-empresa-1/backend/terraform/ ./NEB-practica-empresa-1/backend-terraform
mv ./NEB-practica-empresa-1/frontend/terraform/ ./NEB-practica-empresa-1/frontend-terraform

repo_surgeon "backend-code" "backend"
repo_surgeon "frontend-code" "frontend" 
repo_surgeon "infra-base" "terraform" 
repo_surgeon "infra-backend" "backend-terraform" 
repo_surgeon "infra-frontend" "frontend-terraform" 

