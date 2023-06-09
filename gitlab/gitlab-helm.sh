#!/bin/bash

if [ "$1" == "wipe" ]; then
  kubectl config set-context cicd --namespace gitlab
  helm uninstall gitlab
  sudo rm -rf ./storage
  kubectl delete namespace gitlab
  exit
fi


echo -e "\n\n[helm install]>>> Configure local domain name resolution"
# DNSMASQ="server=/gitlab.local/$(minikube ip --profile cicd)"
# if ! grep -q "$DNSMASQ" /etc/NetworkManager/dnsmasq.d/minikube.conf; then
#   echo $DNSMASQ | sudo tee -a /etc/NetworkManager/dnsmasq.d/minikube.conf
# fi

# Add domains to /etc/hosts, unnecesary with the dns
DOMAINS="$(minikube ip --profile cicd) gitlab.gitlab.local minio.gitlab.local kas.gitlab.local registry.gitlab.local sonar.gitlab.local"
if ! grep -q "$DOMAINS" /etc/hosts; then
  echo $DOMAINS | sudo tee -a /etc/hosts
fi

kubectl create namespace gitlab
kubectl config set-context cicd --namespace gitlab
kubectl apply -f pvc-locales.yml
./certificates.sh

echo -e "\n\n[helm install]>>> Install gitlab in cluster"

helm install gitlab gitlab/gitlab -f values2.yml \
  --set global.hosts.externalIP=$(minikube ip --profile cicd) 
# helm install gitlab gitlab/gitlab --namespace gitlab \
#   --set certmanager-issuer.email=you@example.com \
#   --set global.hosts.domain=gitlab.local \
#   -f https://gitlab.com/gitlab-org/charts/gitlab/raw/master/examples/values-minikube-minimum.yaml

echo -e "\n\n[helm install]>>> Modify permissions of folders in ../storage"
# sudo chmod 777 ../storage/*
while [ $(ls -lah ../storage |grep "drwxrwxrwx"|wc -l) -lt 6 ] ; do
  sudo chmod 777 ../storage/*
  sleep 10
done




echo -e "\n\n[helm install]>>> Wait until webservice is up"
url="https://gitlab.gitlab.local/users/sign_in"
status=0

while [[ $status -ne 200 && $status -ne 400 ]]; do
  status=$(curl -s -o /dev/null -w "%{http_code}" $url)
  sleep 10
done

echo -e "\n\nGitlab server returned status code: $status
User: root
Password: $(kubectl get secret gitlab-gitlab-initial-root-password -o jsonpath='{.data.password}' | base64 --decode ; echo)
" | tee /dev/tty >> /tmp/cluster.txt
