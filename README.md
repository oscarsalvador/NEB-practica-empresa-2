![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)
![Helm](https://img.shields.io/badge/Helm-0F1689.svg?style=for-the-badge&logo=Helm&logoColor=white)
![Shell Script](https://img.shields.io/badge/shell_script-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white)
![cURL](https://img.shields.io/badge/curl-073551.svg?style=for-the-badge&logo=curl&logoColor=white)
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
![gitlab](https://img.shields.io/badge/GitLab-FC6D26.svg?style=for-the-badge&logo=GitLab&logoColor=white)
![sonarqube](https://img.shields.io/badge/SonarQube-4E9BCD.svg?style=for-the-badge&logo=SonarQube&logoColor=white)
![LaTeX](https://img.shields.io/badge/latex-%23008080.svg?style=for-the-badge&logo=latex&logoColor=white)


# Cluster stop routine
1. Stop the dashboard with `kill %1` or ctrl+c in the terminal it's running in
2. `minikube pause --profile cicd1`
3. `minikube stop --profile cicd1`

# Cluster creation routine
```
mkdir storage
minikube delete --profile cicd1
minikube start --profile cicd1 --driver docker --nodes 4 --mount --mount-string "$BASE_PATH:/persistent_volumes"
kubectl get nodes
```

Dashboard
```
minikube addons enable ingress --profile cicd1
minikube dashboard --profile cicd1
```


curl -k --request POST --url 'https://gitlab.example.com/oauth/token' --header 'content-type: application/json' --data '{"grant_type": "password", "username": "root", "password": "yOkfWeHYVoriqnaUObEeHPEdJCfLSnIudjO9BvsI7z4PiVAPBxMnrOZM0ZvwU0JP"}'

{"access_token":"58553034e2c3492cb78322b753dabbeaa75e61857e918c2d9605c1614964aff0","token_type":"Bearer","expires_in":7200,"refresh_token":"0cce3a277c9fba43d7b92ebf919ce8bb3fb8c7de0f5724db63ff5e1ddeeee304","scope":"api","created_at":1678920373}



# Ansible
https://www.perplexity.ai/?s=u&uuid=6688de5c-b15d-4958-8d0a-d6e21025bec8
https://www.perplexity.ai/?s=u&uuid=d62e5052-5884-48f8-ae0c-1c36277f631c