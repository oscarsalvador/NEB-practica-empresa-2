#!/bin/bash

if [ "$1" == "wipe" ]; then
  # ./gitlab/gitlab-helm.sh "wipe"
  sudo rm -rf ./storage
  sudo rm -rf ./gitlab/ca
  sudo rm -rf ./gitlab/configure/NEB-practica-empresa-1
  for i in $(ps -ef | grep "minikube dashboard --profile cicd --url" | awk '{print $2}'); do 
    kill $i
  done
  minikube pause --profile cicd
  minikube stop --profile cicd
  minikube delete --profile cicd
  exit
fi





echo "

[minikube]>>> Create storage folder for persistance 
"

# make sure .,/storage exists, and has 777 permissions
if ! [ -d "./storage" ]; then
  mkdir ./storage
fi

if [ "$(stat -c '%a' ./storage)" != "777" ]; then 
  sudo chmod 777 ./storage
fi






echo "

[minikube]>>> Start cluster 
"
# minikube start --profile cicd1 --driver docker --nodes 1 --mount --mount-string "$(pwd)/storage:/persistent_volumes"
minikube start --profile cicd --nodes 1 \
  --driver docker --cpus 4 --memory 12g \
  --mount --mount-string "$(pwd)/storage:/var/lib/csi-hostpath-data"


echo "

[minikube]>>> Enabling addons 
"

# change default storage class for persistance
minikube addons enable volumesnapshots --profile cicd
minikube addons enable csi-hostpath-driver --profile cicd
minikube addons disable storage-provisioner --profile cicd
minikube addons disable default-storageclass --profile cicd
kubectl patch storageclass csi-hostpath-sc \
  -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'


# load balancer tunnel
# minikube tunnel --profile cicd >/dev/null 2>&1 &
minikube addons enable ingress --profile cicd
minikube addons enable ingress-dns --profile cicd



# minikube addons enable storage-provisioner --profile cicd1

echo "

[minikube]>>> Dashboard 
"
minikube dashboard --profile cicd --url >/tmp/mkdb1.txt 2>&1 &

while ! grep -q http /tmp/mkdb1.txt; do
  sleep 2
done

tail -1 /tmp/mkdb1.txt
