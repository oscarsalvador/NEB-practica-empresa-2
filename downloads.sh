curl -o "minikube" -L https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 

curl -o "kubectl" -L "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

HELM_RELEASE="v3.11.2"
curl -LO https://get.helm.sh/helm-$HELM_RELEASE-linux-amd64.tar.gz
tar -zxzf helm-$HELM_RELEASE-linux-amd64.tar.gz
mv ./linux-amd64/helm ./helm
rm -rf ./linux-amd64
rm helm-$HELM_RELEASE-linux-amd64.tar.gz

sudo mv ./{minikube,kubectl,helm} /usr/local/bin/