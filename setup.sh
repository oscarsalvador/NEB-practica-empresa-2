# helm repo add gitlab https://charts.gitlab.io/
# helm repo update

# minikube delete --profile cicd1

# minikube start --profile cicd1 --driver docker --nodes 3 --mount --mount-string "$(pwd)/storage:/persistent_volumes"
# minikube start --profile cicd1 --driver docker --nodes 1 --mount --mount-string "$(pwd)/storage:/persistent_volumes"
# kubectl get nodes
# minikube addons enable ingress --profile cicd1
# minikube addons enable storage-provisioner --profile cicd1
# minikube dashboard --profile cicd1 --url

# helm install gitlab gitlab/gitlab \
#   --set persistence.enabled=true \
#   --set persistence.size=10Gi \
#   --set persistence.storageClass=standard \
#   --set persistence.accessMode=ReadWriteOnce \ 
#   --set certmanager-issuer.email=you@example.com 

# helm uninstall gitlab
# kubectl create namespace gitlab
# kubectl config set-context cicd1 --namespace gitlab
helm install gitlab gitlab/gitlab \
  --namespace gitlab \
  --set certmanager-issuer.email=you@example.com \
  --set persistence.enabled=true \
  --set persistence.size=10Gi \
  --set persistence.storageClass=standard \
  --set persistence.accessMode=ReadWrite \
  --set persistance.path=/run/media/user/a7c45825-ded3-4acd-b0ef-61663dde6118/y2/documentos/academico/carrera_5/empresa_2/cluster/storage/
  --timeout 600s --wait  \
  --set global.hosts.domain=$(minikube ip --profile cicd1) \
  --set global.hosts.externalIP=$(minikube ip --profile cicd1) \
  -f https://gitlab.com/gitlab-org/charts/gitlab/raw/master/examples/values-minikube-minimum.yaml


helm install gitlab gitlab/gitlab \
  --namespace gitlab \
  --set certmanager-issuer.email=you@example.com \
  --set gitlab.persistence.existingClaim=gitlab-pvc
  --timeout 600s --wait  \
  --set global.hosts.domain=$(minikube ip --profile cicd1) \
  --set global.hosts.externalIP=$(minikube ip --profile cicd1) \
  -f https://gitlab.com/gitlab-org/charts/gitlab/raw/master/examples/values-minikube-minimum.yaml

helm install gitlab gitlab/gitlab \
  --namespace gitlab \
  --set certmanager-issuer.email=you@example.com \
  --timeout 600s --wait  \
  --set global.hosts.domain=$(minikube ip --profile cicd1) \
  --set global.hosts.externalIP=$(minikube ip --profile cicd1) 

  
  https://gitlab.com/gitlab-org/charts/gitlab/-/blob/master/examples/values-minikube.yaml