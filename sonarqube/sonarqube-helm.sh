#!/bin/bash
if [ "$1" == "wipe" ]; then
  kubectl config set-context cicd --namespace sonarqube
  kubectl delete pv --all
  sudo rm -rf ../storage/{pv-sonarqube-postgre,pv-sonarqube-sonarqube}
  kubectl delete namespace sonarqube
  exit
fi

kubectl create namespace sonarqube
kubectl config set-context cicd --namespace sonarqube

kubectl apply -f pv-sonarqube.yml
helm install sonar bitnami/sonarqube
while [ $(ls -lah ../storage |grep "drwxrwxrwx"|wc -l) -lt 6 ] ; 
do
  sudo chmod 777 ../storage/*
  sleep 5
done
# sudo mkdir -p ../storage/{pv-sonarqube-postgre,pv-sonarqube-sonarqube}
# sudo chown 1001:1001 ../storage/{pv-sonarqube-postgre,pv-sonarqube-sonarqube}
# sudo chmod 777 ../storage/{pv-sonarqube-postgre,pv-sonarqube-sonarqube}

# kubectl apply -f pv-postgresql.yml
# kubectl apply -f pv-sonarqube.yml
# helm install sonar bitnami/sonarqube
