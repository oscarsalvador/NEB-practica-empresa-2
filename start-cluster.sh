#!/bin/bash

function setup_dashboard {
  echo -e "\n\n[minikube]>>> Dashboard"
  minikube dashboard --profile cicd --url >/tmp/cluster.txt 2>&1 &

  while ! grep -q http /tmp/cluster.txt; do
    sleep 2
  done

  tail -1 /tmp/cluster.txt
}

function kill_dashboard {
  for i in $(ps -ef | grep "minikube dashboard --profile cicd --url" | awk '{print $2}'); do 
    kill $i
  done
}



if [ "$1" == "wipe" ]; then
  # ./gitlab/gitlab-helm.sh "wipe"
  sudo rm -rf {storage,gitlab/ca,gitlab/configure/NEB-practica-empresa-1}
  rm gitlab/configure/{projects.json,runner-setup.sh,truststore.jks}
  rm {coredns.json,coredns-fix.json}
  kill_dashboard
  minikube delete --profile cicd
  exit

elif [ "$1" = "start" ]; then
  minikube start --profile cicd
  setup_dashboard
  exit

elif [ "$1" = "stop" ]; then
  minikube stop --profile cicd
  kill_dashboard
  exit
fi




echo -e "\n\n[minikube]>>> Create storage folder for persistance"
# make sure .,/storage exists, and has 777 permissions
if ! [ -d "./storage" ]; then
  mkdir ./storage
fi

if [ "$(stat -c '%a' ./storage)" != "777" ]; then 
  sudo chmod 777 ./storage
fi





echo -e "\n\n[minikube]>>> Start cluster"
minikube start --profile cicd --nodes 3 \
  --driver docker --cpus 4 --memory 16g \
  --mount --mount-string "$(pwd)/storage:/storage"



echo -e "\n\n[minikube]>>> Enabling addons"
minikube addons enable ingress --profile cicd
setup_dashboard
