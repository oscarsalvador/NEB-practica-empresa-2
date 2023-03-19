minikube start --profile cicd1 --driver docker --nodes 1 --mount --mount-string "$(pwd)/storage:/persistent_volumes"
minikube addons enable ingress --profile cicd1
minikube addons enable storage-provisioner --profile cicd1
minikube dashboard --profile cicd1 --url &
kubectl create namespace gitlab
kubectl config set-context cicd1 --namespace gitlab