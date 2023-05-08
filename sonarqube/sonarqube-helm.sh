#!/bin/bash
if [ "$1" == "wipe" ]; then
  # kubectl config set-context cicd --namespace sonarqube
  # kubectl delete pv --all
  sudo rm -rf ../storage/{pv-sonarqube-postgre,pv-sonarqube-sonarqube}
  kubectl delete namespace sonarqube
  exit
fi

kubectl create namespace sonarqube
kubectl config set-context cicd --namespace sonarqube

sudo mkdir -p ../storage/{pv-sonarqube-postgre,pv-sonarqube-sonarqube}
sudo chmod 777 ../storage/{pv-sonarqube-postgre,pv-sonarqube-sonarqube}
kubectl apply -f pv-sonarqube.yml
# helm upgrade --install sonar sonarqube/sonarqube -f values.yaml
helm install sonar bitnami/sonarqube --set serviceType=NodePort

echo -e "\n\n[Sonar install]>>> Modify permissions of folders in ../storage"
while [ $(ls -lah ../storage | grep "sonarqube" | grep "drwxrwxrwx"| wc -l) -lt 2 ] ; 
do
  sudo chmod 777 ../storage/*
  sleep 5
done

# kubectl create secret tls gitlab-tls-cert --cert=../gitlab/ca/gitlab.local.crt --key=../gitlab/ca/gitlab.local.key
kubectl create secret tls -n sonarqube gitlab-tls-cert --cert=../gitlab/ca/gitlab.local.crt --key=../gitlab/ca/gitlab.local.key
kubectl apply -f ing-sonarqube.yml

# sudo mkdir -p ../storage/{pv-sonarqube-postgre,pv-sonarqube-sonarqube}
# sudo chown 1001:1001 ../storage/{pv-sonarqube-postgre,pv-sonarqube-sonarqube}
# sudo chmod 777 ../storage/{pv-sonarqube-postgre,pv-sonarqube-sonarqube}

# kubectl apply -f pv-postgresql.yml
# kubectl apply -f pv-sonarqube.yml
# helm install sonar bitnami/sonarqube

echo -e "\n\n[Sonar install]>>> Wait until sonar is up"
url="https://sonar.gitlab.local/sessions/new?return_to=%2F"
status=0

while [[ $status -ne 200 && $status -ne 400 ]]; do
  status=$(curl -s -o /dev/null -w "%{http_code}" $url)
  sleep 10
done

echo -e "\n\nSonarqube server returned status code: $status
Username: user
Password: $(kubectl get secret --namespace sonarqube sonar-sonarqube -o jsonpath="{.data.sonarqube-password}" | base64 -d)
" | tee /dev/tty >> /tmp/cluster.txt
